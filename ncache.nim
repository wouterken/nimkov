include strtabs
import threadpool, algorithm, strutils
import times

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

proc put*(cache:NCache, key, value:string):bool{.discardable.}=
  cache.warmed[key] = value
  if cache.warmed.len > cache.size:
    cache.shift
    return true

  var warmFile = cache.warmFile
  var struct = cache.warmed
  return false

proc `[]`*(cache:NCache, key:string):string=
  result = nil
  if not cache.warmed.hasKey(key):
    if cache.frozen.hasKey(key):
      cache.warmed[key] = cache.frozen[key]
  if cache.warmed.hasKey(key):
    result = cache.warmed[key]

proc `[]=`*(cache:NCache, key, value:string):bool{.discardable.}=
  return cache.put(key, value)



proc frozen_copy(cache:NCache):StringTableRef=
  new(result)
  result[]= cache.frozen[]

proc frozen_pairs(cache:NCache):tuple[delim:string, pairs:seq[tuple[key, value:string]]]=
  var pairs:seq[tuple[key,value:string]] = @[]
  var delim = "--"
  for key,value in cache.frozen_copy.pairs:
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
  var frozenPairs = cache.frozen_pairs
  var outputFile:File
  outputFile.writeln("boundary="&frozenPairs.delim)
  for index, pair in frozenPairs.pairs:
    var data = frozenPairs.delim & pair.key & "=" & pair.value
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

