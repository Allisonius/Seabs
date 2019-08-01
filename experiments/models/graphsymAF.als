module graphsymAF

open graphsym

one sig AbsFun { -- does not model isolated nodes
  af: Event -> Location -> Event -> Location
}

fact AbsFunDef {
  all n1, n2: Node {
    n2 in n1.edges implies
      n1.event -> n1.location -> n2.event -> n2.location in AbsFun.af
  }
  all e1, e2: Event, l1, l2: Location {
    e1 -> l1 -> e2 -> l2 in AbsFun.af implies
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

run Acyclic for 3
