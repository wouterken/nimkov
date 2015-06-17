import strutils
import macros/strint
import macros/pipeline
type
  KV* = object
  KVEscapeSingleton* = typedesc[KV]

const ESC     = "\x1b"
const ESC_ESC = "\x1bx;"
const EQL     = "="
const NL      = "\n"
const ESC_EQL = ESC & "e;"
const ESC_NL  = ESC & "ln;"

proc escape*(_:KVEscapeSingleton, str:string):string=
  str |>
    replace(ESC, ESC_ESC) |>
    replace(EQL, ESC_EQL) |>
    replace(NL,  ESC_NL)

proc unescape*(_:KVEscapeSingleton, str:string):string=
  str |>
    replace(ESC_NL,  NL)  |>
    replace(ESC_EQL, EQL) |>
    replace(ESC_ESC, ESC)

proc toKVString*(_:KVEscapeSingleton, key:string, val:string):string=
  "\n" & i"${KV.escape(key)}=${KV.escape(val)}"

proc toKV*(_:KVEscapeSingleton, keyValString:string):tuple[key,val:string]=
  var parts:seq[string] = keyValString.replace("\n","").split("=")
  case parts.len
  of 2: return (parts[0], parts[1])
  else: return ("","")


##
# Tests
##
when isMainModule:
  var key = """hello
  world=thistest"""
  var value = """ This=
  a multiline test"""
  var escaped =  KV.escape(key)
  var asKVString:string = KV.toKVString(key, value)

  assert escaped == "helloln;  worlde;thistest"
  assert KV.unescape(escaped) == key
  assert asKVString == "\nhelloln;  worlde;thistest= Thise;ln;  a multiline test"
  assert KV.toKV(asKVString) == (key: KV.escape(key), val: KV.escape(value))