module minheapAF

open minheap

one sig AbsFun { af: set Int }

fact AbsFunDef { AbsFun.af = MinHeap.root.*(left + right).key }

run RepOk for 5 but 3 Int
