import macros, parseutils, sequtils

macro i*(text: string{lit}): expr =
  var nodes: seq[NimNode] = @[]
  # Parse string literal into "stuff".
  for k, v in text.strVal.interpolatedFragments:
    if k == ikStr or k == ikDollar:
      nodes.add(newLit(v))
    else:
      nodes.add(parseExpr("$(" & v & ")"))
  # Fold individual nodes into a statement list.
  result = newNimNode(nnkStmtList).add(
    foldr(nodes, a.infix("&", b)))