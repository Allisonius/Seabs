module bstp

one sig BSTp {
  root: lone Node,
  size: one Int
}

sig Node {
  key: lone Int,
  left, right, parent: lone Node
}

pred Acyclic(t: BSTp) {
  all n: t.root.*(left + right) {
    n !in n.^(left + right)
    lone n.~(left + right)
    no n.left & n.right
  }
}

pred SizeOk(t: BSTp) {
  t.size = #t.root.*(left + right)
}

pred SearchOk(t: BSTp) {
  all n: t.root.*(left + right) {
    some n.key
    all m: n.left.*(left + right) | m.key.lt[n.key]
    all m: n.right.*(left + right) | m.key.gt[n.key]
  }
}

pred ParentOk(t: BSTp) {
  parent = ~(left + right)
}

pred RepOk(t: BSTp) {
  Acyclic[t]
  SizeOk[t]
  SearchOk[t]
  ParentOk[t]
}

fact Reachability { BSTp.root.*(left + right) = Node }

fact ConsecutiveKeysFrom0 {
  0 in Node.key
  all n: Node | n.key != 0 implies some m: Node | m.key = prev[n.key]
}

run RepOk for 7
