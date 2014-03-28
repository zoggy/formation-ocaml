let prod = ref false;;
let options =
  [ "-prod", Arg.Set prod, " compute the product instead of the sum" ];;

let read_options () =
  let args = ref [] in
  Arg.parse options
    (fun s -> args := s :: !args)
    (Printf.sprintf "Utilisation: %s [-prod] a b" Sys.argv.(0));
  match !args with
    [a;b] ->
      begin
        try (int_of_string a, int_of_string b)
        with _ -> failwith "Un argument n'est pas un entier"
      end
  | _ -> failwith "Il faut deux et seulement deux entiers en arguments"
;;

let (a, b) =
  try read_options ()
  with Failure msg -> prerr_endline msg; exit 1;;

let result = (if !prod then ( * ) else ( + )) a b;;
print_int result;;
