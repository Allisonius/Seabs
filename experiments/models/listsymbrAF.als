    
module listsymbrAF

open list

open util/ordering[Node]

one sig AbsFun {
  af1: List -> Node,
  af2: Node -> Int,
  af3: Node -> Node
}

fact AbsFunDef {
  // define relations
  AbsFun.af1 = header
  AbsFun.af2 = elem
  AbsFun.af3 = link

  // symmetry breaking
  List.header in first[]
  all n: List.header.*link | n.link in next[n]
}

run RepOk for 6 but 3 int
