  type Common.msg += Reload of string | Alert of string

  let handle fallback = function
  | Reload s -> print_endline ("Reload "^s)
  | Alert s -> print_endline ("Alert "^s)
  | x -> fallback x

  let () = Common.extend_handle handle
  let () = Common.add (Reload "config.file")
  let () = Common.add (Alert "Initialisation done")