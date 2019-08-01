module list

one sig List { header: lone Node }

sig Node { elem: Int, link: lone Node }

pred Acyclic { /* no directed cycle */
  all n: List.header.*link | n !in n.^link }

pred NoRepetition { /* unique nodes have unique elements */
  all disj m, n: List.header.*link | m.elem != n.elem }

pred RepOk { Acyclic and NoRepetition }

fact Reachability { /* no disconnected nodes */
  List.header.*link = Node }

run RepOk for 6 but 3 int
