include strtabs
import threadpool, algorithm, strutils
import times
import kv

type
  NCache* = ref NCacheType
  NCacheType = object
    warmFile:   string
    coldFile:   string
    warmed:     StringTableRef
    frozen:     StringTableRef
    size:       int

proc shift(cache:NCache):void;
proc saveSSM(cache:NCache, table:StringTableRef, filename:string):void;

proc put*(cache:NCache, key, value:string):string{.discardable.}=
  cache.warmed[key] = value
  if cache.warmed.len > cache.size:
    cache.shift
  var warmFile = cache.warmFile
  var struct = cache.warmed
  return KV.toKVString(key, value)

proc `[]`*(cache:NCache, key:string):string=
  var needle = key
  result = nil
  if not cache.warmed.hasKey(needle):
    if cache.frozen.hasKey(needle):
      cache.warmed[needle] = cache.frozen[needle]
      result = cache.warmed[needle]
  else:
    result = cache.warmed[needle]

proc `[]=`*(cache:NCache, key, value:string):string{.discardable.}=
  return cache.put(key, value)

proc contains*(cache:NCache, key:string):bool=
  (cache.warmed.hasKey(key) or cache.frozen.hasKey(key)) and cache[key] != nil

proc frozenCopy(cache:NCache):StringTableRef=
  new(result)
  result[]= cache.frozen[]

proc frozenPairs(cache:NCache):tuple[delim:string, pairs:seq[tuple[key, value:string]]]=
  var pairs:seq[tuple[key,value:string]] = @[]
  var delim = "--"
  for key,value in cache.frozenCopy.pairs:
    pairs.add((key, value))
    if key.contains(delim) or value.contains(delim):
      delim.add("-")

  pairs.sort(proc(x, y: tuple[key, value:string]) :int =
    cmp(x[0], y[0]))
  return (delim, pairs)

proc nextFile():string=
  var filename = "ssms/ssm-"
  var fileIndex = epochTime()
  while existsFile (filename & $(fileIndex) & ".ssm"):
    fileIndex += 0.000001
  result = filename & $(fileIndex) & ".ssm"

proc saveSSM(cache:NCache, table:StringTableRef, filename:string):void=
  var frozenPairs = cache.frozenPairs
  var outputFile:File = open(filename, fmWrite)
  for index, pair in frozenPairs.pairs:
    var data = KV.toKVString(pair.key, pair.value)
    discard outputFile.writeChars(cast[seq[char]](data), 0, data.len)

proc saveCold(cache:NCache):void=
  cache.saveSSM(cache.frozen, cache.coldFile)

proc saveWarm(cache:NCache):void=
  cache.saveSSM(cache.warmed, cache.warmFile)

proc shift(cache:NCache):void=
  cache.coldFile = cache.warmFile
  cache.frozen   = cache.warmed
  cache.warmed   = newStringTable(modeCaseSensitive)
  cache.warmFile = nextFile()
  cache.saveCold



proc new*(_:typedesc[NCache], size:int):NCache=
  new(result)
  result.size = size
  result.warmFile = nextFile()
  result.warmed   = newStringTable(modeCaseSensitive)
  result.frozen   = newStringTable(modeCaseSensitive)


##
# Tests
##
when isMainModule:
  var cache = NCache.new(100)
  var key = """hello
  world=thistest"""
  var value = """ This=
  a multiline test"""
  assert cache[key] == nil
  cache[key] = value
  assert cache[key] == value