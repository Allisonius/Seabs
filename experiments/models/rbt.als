module rbt

abstract sig Color {}

one sig Red, Black extends Color {}

one sig RBT {
  root: lone Node,
  size: Int
}

sig Node {
  key: Int,
  left, right: lone Node,
  color: Color
}

pred Acyclic(t: RBT) {
  all n: t.root.*(left + right) {
    n !in n.^(left + right)
    lone n.~(left + right)
    no n.left & n.right
  }
}

pred SizeOk(t: RBT) {
  t.size = #t.root.*(left + right)
}

pred SearchOk(t: RBT) {
  all n: t.root.*(left + right) {
    all m: n.left.*(left + right) | m.key.lt[n.key]
    all m: n.right.*(left + right) | m.key.gt[n.key]
  }
}

pred ColorOk(t: RBT) {
  all n: t.root.*(left + right) |
    n.color = Red implies Red !in n.(left + right).color
  all m, n: t.root.*(left + right) |
    m != n and lone m.(left + right) and lone n.(left + right) implies
      #{x: Node | x in m.*(~(left + right)) and x.color = Black } = #{y: Node | y in n.*(~(left + right)) and y.color = Black} 
}

pred RepOk(t: RBT) {
  Acyclic[t]
  SizeOk[t]
  SearchOk[t]
  ColorOk[t]
}

fact Reachability { RBT.root.*(left + right) = Node }

fact ConsecutiveKeysFrom0 {
  0 in Node.key
  all n: Node | n.key != 0 implies some m: Node | m.key = prev[n.key]
}

run RepOk for 7
