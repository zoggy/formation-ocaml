class c1 =
  object
    val mutable v = 1
    method print = Printf.printf "c1.v = %d" v; print_newline ()
  end;;
class c2 =
  object(self)
    inherit c1 as super
    method set x = v <- x
    method! print =
      super#print ;
      Printf.printf "c2.v = %d" v; print_newline ()
  end;;
class c3 =
  object(self)
    inherit c1 as super
    method set x = v <- x
    method! print =
      super#print ;
      Printf.printf "c3.v = %d" v; print_newline ()
  end;;
class c4 =
  object(self)
    inherit c2 as c2
    inherit! c3 as c3

    method! print =
      c2#print ;
      c3#print ;
      Printf.printf "c4.v = %d" v;
      print_newline ()

    method set_c2 x = c2#set x
    method set_c3 x = c3#set x
  end;;
