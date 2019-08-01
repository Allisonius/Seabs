module bstsym

open bst

open util/ordering[Node]

fact SymmetryBreaking { // pre-order
  BST.root in first[]
  all n: BST.root.*(left + right) {
    some n.left implies n.left in next[n]
    no n.left implies n.right in next[n]
    some n.right and some n.left implies n.right in next[max[n.left.*(left + right)]]
  }
}

run RepOk for 9
