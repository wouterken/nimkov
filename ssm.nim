
import queues
import re
import strutils
import times, os
import critbits

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
    cache:          CritBitTree[string]



proc binary_search(ssm:SSM, search:string):string{.inline.};
proc binary_search(ssm:SSM, search:string, min,max:int64):string{.inline.};

proc `[]`*(ssm:SSM, key:string):string{.inline.}=
  if key.contains(ssm.delimiter): return nil
  if not ssm.cache.contains(key): ssm.cache[key] = ssm.binary_search(key)
  return ssm.cache[key]

proc binary_search(ssm:SSM, search:string):string=
  binary_search(ssm, search, 0'i64, ssm.length)

proc move_to_delimiter(ssm:SSM, at: int64):void{.inline.}=
  var buffer:seq[char] = newSeq[char](ssm.delimiter.len)
  ssm.file.setFilePos(at);

  discard ssm.file.readChars(buffer, 0, ssm.delimiter.len)
  var snippet:string = cast[string](buffer);

  for i in 1..(ssm.length - at):
    var string_end:int = cast[int](i mod ssm.delimiter.len)
    snippet[string_end] = ssm.file.readChar()
    if(snippet[string_end + 1..ssm.delimiter.len - 1] & snippet[0..string_end]) == ssm.delimiter:
      return
  ssm.file.setFilePos(0)
  discard ssm.file.readLine()
  ssm.file.setFilePos(ssm.file.getFilePos() + ssm.delimiter.len)

proc scan_to_delimiter(ssm:SSM):string{.inline.}=
  var pair:string = ""
  while ssm.file.getFilePos() < ssm.length and cast[string](pair[^ssm.delimiter.len..^1]) != ssm.delimiter:
    pair.add(ssm.file.readChar())
  return if cast[string](pair[^ssm.delimiter.len..^1]) == ssm.delimiter: pair[0..^(ssm.delimiter.len + 1)] else: pair


proc binary_search(ssm:SSM, search:string, min, max:int64):string=
  if max - min < search.len:
    return nil
  var middle:int64 = min + (max - min) div 2

  ssm.move_to_delimiter(middle)
  var pair = ssm.scan_to_delimiter().split("=")
  if pair.len != 2:
    return nil
  var (key, value) = (pair[0], pair[1])
  if key == search:
    return value
  if key < search:
    return ssm.binary_search(search, middle, max)
  else:
    return ssm.binary_search(search, min, middle)
  return ""


proc read_delimiter(ssm:SSM):void{.inline.}=
  var firstLine:string = ssm.file.readLine
  if firstLine =~ re"boundary=(.+)$":
    ssm.delimiter = matches[0]
  else:
    raise newException(OSError, "Could not read delimiter")


proc new*(_:typedesc[SSM], filename:string):SSM=
  new(result)
  if not result.file.open(filename):
    raise newException(OSError, "Couldn't open SSM")
  try:
    result.read_delimiter()
  except IOError:
    raise newException(OSError, "Couldn't open SSM")
  except OSError:
    raise newException(OSError, "Couldn't open SSM")
  result.length = getFileSize(result.file)

