module dtree

one sig Tree { root : lone Node }

sig Node { edges: set Node, elem: Int}

fact isDirectedTree {  
  no iden & ^edges --acyclic
  edges.~edges in iden --injective
}

fact Reachability{
  all n : Node | n in Tree.root.*edges --connected
}

fact UniqueElem {
  no disj n1, n2: Node | n1.elem = n2.elem
}

run {} for 5 but 3 Int
