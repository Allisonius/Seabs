module listAF

open list

one sig AbsFun { af: set Int }

fact AbsFunDef { AbsFun.af = List.header.*link.elem }

run RepOk for 6 but 3 int
