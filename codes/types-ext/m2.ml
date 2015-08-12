  type Common.msg += Send of string * string

  let handle fallback = function
  | Send (dest, msg) ->
      print_endline (Printf.sprintf "Send (%s, %s)" dest msg)
  | x -> fallback x

  let () = Common.extend_handle handle
  let () = Common.add (Send ("client", "config reloaded"))
