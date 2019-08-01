module objarray

open util/integer

sig Object {}

one sig ObjectArray {
  array: seq Object
}

pred RepOk {
  all x: ObjectArray.array[Int] | eq[#indsOf[ObjectArray.array, x], 1]
}

fact Reachability {
  ObjectArray.array[Int] = Object
}

run RepOk for 10 Object, 10 seq, 5 int
