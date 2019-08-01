module bstAF

open bst

one sig AbsFun { af: set Int }

fact AbsFunDef { AbsFun.af = BST.root.*(left + right).key }

run RepOk for 9
