module objarrayAF

open objarray

one sig AbsFun {
  af: set Object
}

fact AbsFunDef {
  AbsFun.af = ObjectArray.array[Int]
}

run RepOk for 10 Object, 10 seq, 5 int
