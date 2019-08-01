module multiset

one sig MultiSet {
  array: Int -> Int,
  length: Int
}
fact {
  !lt[MultiSet.length, 0]
  eq[MultiSet.length, 0] implies no MultiSet.array
  all x: Int | (lt[x, 0] or !lt[x, MultiSet.length]) implies no MultiSet.array[x] else
              one MultiSet.array[x]
}

pred RepOk {}

run RepOk for 3 int

/*
  8 ints
  seq length: 3
  length=0: 1
  length=1: 8
  length=2: 8 * 8 = 64
  length=3: 8 * 8 * 8 = 512
  TOTAL=585

  FOR SORTED

  length=0: 1
  length=1: 8
  length=2: 8 * 9 / 2
  length=3: ...
*/
