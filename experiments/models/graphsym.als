module graphsym

sig Node {
  event: one Event,
  location: one Location,
  edges: set Node
}

sig Location {}

sig Event {}

pred Acyclic {
  all n: Node | n !in n.^edges
}

run Acyclic
