module minheap

one sig MinHeap {
  root: lone Node
}

sig Node {
  key: one Int,
  left, right: lone Node
}

pred Acyclic {
  all n: MinHeap.root.*(left + right) {
    n !in n.^(left + right)
    lone n.~(left + right)
    no n.left & n.right
  }
}

pred HeapOk {
  all n: MinHeap.root.*(left + right) {
    all m: n.left.*(left + right) | m.key.gt[n.key]
    all m: n.right.*(left + right) | m.key.gt[n.key]
  }
}

pred RepOk {
  Acyclic
  HeapOk
}

fact Reachability { MinHeap.root.*(left + right) = Node }

run RepOk for 5 but 3 Int
