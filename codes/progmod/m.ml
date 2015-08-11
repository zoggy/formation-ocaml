type pair = int * int
let x = 1
let y = 2
let make_pair x y = (x,y)
let first (x,_) = x
let second (_,y) = y
