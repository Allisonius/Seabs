module bstsymAF

open bstsymbr

one sig AbsFun { af: set Int }

fact AbsFunDef { AbsFun.af = BST.root.*(left + right).key }

run RepOk for 9
