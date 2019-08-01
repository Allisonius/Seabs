module bst

one sig BST {
  root: lone Node,
  size: one Int
}

sig Node {
  key: lone Int,
  left, right: lone Node
}

pred Acyclic(t: BST) {
  all n: t.root.*(left + right) {
    n !in n.^(left + right)
    lone n.~(left + right)
    no n.left & n.right
  }
}

pred SizeOk(t: BST) {
  t.size = #t.root.*(left + right)
}

pred SearchOk(t: BST) {
  all n: t.root.*(left + right) {
    some n.key
    all m: n.left.*(left + right) | m.key.lt[n.key]
    all m: n.right.*(left + right) | m.key.gt[n.key]
  }
}

pred RepOk(t: BST) {
  Acyclic[t]
  SizeOk[t]
  SearchOk[t]
}

fun keys[]: set Int { nodes[].key }

fun nodes[]: set Node { BST.root.*(left + right) }


fact UnreachableNodesHaveDefaultFieldValues {
  all n: Node - nodes[] | n.key = 0 and no n.(left + right)
}
--fact Reachability { BST.root.*(left + right) = Node }

fact ConsecutiveKeysFrom0 {
  no keys[] or 0 in keys[]
  all n: nodes[] | n.key != 0 implies some m: nodes[] | m.key = prev[n.key]
}

run RepOk for 9
