module dll

one sig DLL {
  header: lone Node
}

sig Node {
  pre, nxt: lone Node,
  elem: Int
}

// All nodes are reachable from the header node.
fact Reachable {
  Node = DLL.header.*nxt
}

fact Acyclic {
  // The list has no directed cycle along nxt, i.e., no node is
  // reachable from itself following one or more traversals along nxt.
  all n: Node | n !in n.^nxt
}

pred UniqueElem() {
  // Unique nodes contain unique elements.
  no disj n1, n2: Node | n1.elem = n2.elem
}

pred ConsistentPreAndNxt() {
  // For any node n1 and n2, if n1.nxt = n2, then n2.pre = n1; and vice versa.
  nxt = ~pre
}

pred RepOk() {
  UniqueElem
  ConsistentPreAndNxt
}

run RepOk for 6 but 3 Int
