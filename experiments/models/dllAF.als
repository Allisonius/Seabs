module dllAF

open dll

one sig AbsFun { af: set Int }

fact AbsFunDef { AbsFun.af = DLL.header.*nxt.elem }

run RepOk for 6 but 3 Int


