module type Output = sig
  val message : string -> unit
  val error : string -> unit
end

module Output_terminal = struct
    let message msg = print_endline msg
    let error msg = print_endline (Printf.sprintf "\027[91m%s\027[0m" msg)
end

module Output_other = struct
  let message = print_endline
  let error = print_endline
end

let choose_output () =
  if Unix.isatty Unix.stdout then
    (module Output_terminal : Output)
  else
    (module Output_other)

let treatment output =
  let (module O : Output) = output in
  O.message "Normal message";
  O.error "Error message"

let () = treatment (choose_output())
