import queues, re, strutils, times, os, critbits, ncache, kv
import macros/strint
##
# SSM is a sorted static map.
# This is a read only map stored on a file in disc
##
type
  SSM* = ref SSMType
  SSMType = object
    delimiter:      string
    file:           File
    length:         int64
    cache:          NCache

proc binarySearch(ssm:SSM, search:string):string{.inline.};
proc binarySearch(ssm:SSM, search:string, min,max:int64):string{.inline.};

proc `[]`*(ssm:SSM, key:string):string{.inline.}=
  var needle = KV.escape(key)
  if not ssm.cache.contains(needle):
    var value:string = ssm.binarySearch(needle)
    if value != nil: ssm.cache[needle] = value
  return ssm.cache[needle]

proc binarySearch(ssm:SSM, search:string):string=
  binarySearch(ssm, search, 0'i64, ssm.length)

proc moveToDelimiter(ssm:SSM, at: int64):void{.inline.}=
  if at == 0:
    ssm.file.setFilePos(1)
    return

  ssm.file.setFilePos(at);

  for i in 1..(ssm.length - at):
    var delim:char = ssm.file.readChar()
    var pos = ssm.file.getFilePos()
    if(delim == '\L' and pos != ssm.length): return
  ssm.file.setFilePos(1)

proc binarySearch(ssm:SSM, search:string, min, max:int64):string=
  var middle:int64 = min + (max - min) div 2

  if max == 1:         ssm.file.setFilePos(1)
  elif max - min <= 1: return nil
  else:                ssm.moveToDelimiter(middle)

  var (key, value) = KV.toKV(ssm.file.readLine())

  if key == search:  return KV.escape(value)
  if max == 1:       return nil
  elif key < search: return ssm.binarySearch(search, middle, max)
  else:              return ssm.binarySearch(search, min, middle)

proc new*(_:typedesc[SSM], filename:string, cache:NCache):SSM=
  new(result)
  if not result.file.open(filename):
    raise newException(OSError, "Couldn't open SSM")
  result.length = getFileSize(result.file)
  result.cache = cache

##
# Tests
##
when isMainModule:
  var ssm = SSM.new("ssms/test-ssm.ssm", NCache.new(100))
  assert ssm["dogs"]   == "cats"
  assert ssm["apples"] == "pears"
  assert ssm["woop"]   == "boop"
  assert ssm["zap"]    == "cap"
  assert ssm["jello"]  == "world"
