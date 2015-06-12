import ncache
import times
import ssm
import os, algorithm
import tables

type
  Nimkov* = ref NimkovType
  NimkovType = object
    cache: NCache
    ssms: Table[string, SSM]

proc new*(_:typedesc[Nimkov], size:int):Nimkov=
  new(result)
  result.ssms = initTable[string, SSM]()
  result.cache = NCache.new(size)

proc list_ssms(nk:Nimkov):seq[string]=
  result = @[]
  for filename in walkFiles("ssms/*.ssm"):
    result.add(filename)
  result.sort do (x, y: string) -> int: cmp(y, x)

proc `[]`*(nk:Nimkov, key:string):string=
  if nk.cache[key] == nil:
    for filename in nk.list_ssms:
      var ssm:SSM;
      try:
         ssm = if nk.ssms.hasKey(filename): nk.ssms[filename] else: SSM.new(filename)
      except:
        continue
      nk.ssms[filename] = ssm
      var ssm_value = ssm[key]
      if ssm_value != nil:
        nk.cache[key] = ssm_value
        break
  nk.cache[key]

proc `[]=`*(nk:Nimkov, key, value:string):bool{.discardable.}=
  nk.cache.put(key, value)

