(*********************************************************************************)
(*  "Introduction au langage OCaml" par Maxence Guesdon est mis                  *)
(*  � disposition selon les termes de la licence Creative Commons                *)
(*   Paternit�                                                                   *)
(*   Pas d'Utilisation Commerciale                                               *)
(*   Partage des Conditions Initiales � l'Identique                              *)
(*   2.0 France.                                                                 *)
(*                                                                               *)
(*  Contact: Maxence.Guesdon@inria.fr                                            *)
(*                                                                               *)
(*                                                                               *)
(*********************************************************************************)

let words s =
  let len = String.length s in
  let rec iter acc_words acc_current i =
    if i >= len then
      match acc_current with
        "" -> List.rev acc_words
      | w -> List.rev (w :: acc_words)
    else
      match s.[i] with
        'a'..'z' | 'A'..'Z' | '�' | '�' | '�' | '�' ->
					iter acc_words (Printf.sprintf "%s%c" acc_current s.[i]) (i+1)
		  | _ ->
		    match acc_current with
		      "" -> iter acc_words acc_current (i+1)
		    | w -> iter (w::acc_words) "" (i+1)
  in
  iter [] "" 0
;;