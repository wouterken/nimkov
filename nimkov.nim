import ncache
import times
import ssm
import os, algorithm
import tables
import threadpool
import wal
type
  Nimkov* = ref NimkovType
  NimkovType = object
    cache: NCache
    ssms: Table[string, SSM]

proc startWorkers(nk:Nimkov):void;

var walChannel:TChannel[string]
walChannel.open()

iterator every(n:int):int=
  var round = 0
  while true:
    sleep(n)
    yield(round)
    inc round

proc wallWriter():void=
  while true:
    WAL.write(walChannel.recv())


proc compactor():void=
  discard

proc new*(_:typedesc[Nimkov], size:int):Nimkov=
  new(result)
  result.ssms = initTable[string, SSM]()
  result.cache = NCache.new(size)
  result.startWorkers

proc startWorkers(nk:Nimkov):void=
  spawn wallWriter()
  spawn compactor()

proc listSsms(nk:Nimkov):seq[string]=
  result = @[]
  for filename in walkFiles("ssms/*.ssm"):
    result.add(filename)
  result.sort do (x, y: string) -> int: cmp(y, x)

proc `[]`*(nk:Nimkov, key:string):string=
  if not nk.cache.contains(key):
    for filename in nk.listSsms:
      var ssm:SSM;
      try:
        ssm = if nk.ssms.hasKey(filename): nk.ssms[filename] else: SSM.new(filename, nk.cache)
      except OSError:
        continue
      nk.ssms[filename] = ssm
      var ssmValue = ssm[key]
      if ssmValue != nil:
        nk.cache[key] = ssmValue
        break
  nk.cache[key]

proc `[]=`*(nk:Nimkov, key, value:string):bool{.discardable.}=
  var escaped = nk.cache.put(key, value)
  walChannel.send(escaped)
