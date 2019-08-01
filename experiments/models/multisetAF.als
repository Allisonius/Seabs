module multisetAF

open multiset

one sig AbsFun {
  array: Int -> Int,
  length: Int
}
fact {
  !lt[AbsFun.length, 0]
  eq[AbsFun.length, 0] implies no AbsFun.array
  all x: Int | (lt[x, 0] or !lt[x, AbsFun.length]) implies no AbsFun.array[x] else
              one AbsFun.array[x]
}

pred Sorted {
  all x: Int | !lt[x, 0] and lt[x, minus[AbsFun.length, 1]] implies 
              !gt[AbsFun.array[x], AbsFun.array[plus[x, 1]]]
}

pred Permutation {
  all x: MultiSet.array[Int] + AbsFun.array[Int] |
    eq[#MultiSet.array.x, #AbsFun.array.x]
}

fact AbsFunDef {
  Sorted
  Permutation
}

run {} for 3 int
