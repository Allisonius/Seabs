module graphAF2

open graph

one sig AbsFun {
  af: Node -> Node
}

fact AbsFunDef {
  AbsFun.af = *edges & Node -> Node
}

run {} for 4
