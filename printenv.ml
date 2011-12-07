(*********************************************************************************)
(*  "Introduction au langage OCaml" par Maxence Guesdon est mis                  *)
(*  à disposition selon les termes de la licence Creative Commons                *)
(*   Paternité                                                                   *)
(*   Pas d'Utilisation Commerciale                                               *)
(*   Partage des Conditions Initiales à l'Identique                              *)
(*   2.0 France.                                                                 *)
(*                                                                               *)
(*  Contact: Maxence.Guesdon@inria.fr                                            *)
(*                                                                               *)
(*                                                                               *)
(*********************************************************************************)

let print_one acc_err var =
  try print_endline (Unix.getenv var); acc_err
  with Not_found -> true;;

match Array.length Sys.argv with
  n when n <= 1 ->
    (* affiche tout l'environnement *)
    Array.iter print_endline (Unix.environment ());
    exit 0
| n ->
    let args = Array.sub Sys.argv 1 (n - 1) in
    let error = Array.fold_left print_one false args in
    exit (if error then 1 else 0)
;;