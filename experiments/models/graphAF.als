module graphAF

open graph

one sig AbsFun {
  af: Node -> Node
}

fact AbsFunDef {
  AbsFun.af = ^edges
}

run {} for 4
