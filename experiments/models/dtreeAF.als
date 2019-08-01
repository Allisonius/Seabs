module dtreeAF
open dirtree

one sig AbsFun { af: set Int}

fact AbsFunDef { AbsFun.af = Tree.root.*edges.elem}

run {} for 5 but 3 Int
