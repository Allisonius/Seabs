module graphsymAF2

open graphsym

one sig AbsFun {
  af1: Event -> Location, -- isolated nodes
  af2: Event -> Location -> Event -> Location -- edges
}

fact AbsFunDef {
  all n: Node | no n.(edges + ~edges) implies n.event -> n.location in AbsFun.af1
  all e: Event, l: Location {
    e -> l in AbsFun.af1 implies
      some n: Node | HasFieldValues[n, e, l] and no n.(edges + ~edges)
  }
  all n1, n2: Node {
    n2 in n1.edges implies
      n1.event -> n1.location -> n2.event -> n2.location in AbsFun.af2
  }
  all e1, e2: Event, l1, l2: Location {
    e1 -> l1 -> e2 -> l2 in AbsFun.af2 implies
      some n1, n2: Node {
        HasFieldValues[n1, e1, l1]
        HasFieldValues[n2, e2, l2]
        n2 in n1.edges
      }
  }
}

pred HasFieldValues[n: Node, e: Event, l: Location] {
  n.event = e
  n.location = l
}

run Acyclic
