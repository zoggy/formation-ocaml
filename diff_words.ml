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

let words s =
  let len = String.length s in
  let rec iter acc_words acc_current i =
    if i >= len then
      match acc_current with
        "" -> List.rev acc_words
      | w -> List.rev (w :: acc_words)
    else
      match s.[i] with
      | 'a'..'z' | 'A'..'Z' | 'é' | 'è' | 'ê' | 'à' ->
        iter acc_words (Printf.sprintf "%s%c" acc_current s.[i]) (i+1)
		  | _ ->
		    match acc_current with
		      "" -> iter acc_words acc_current (i+1)
		    | w -> iter (w::acc_words) "" (i+1)
  in
  iter [] "" 0
;;

module Words = Set.Make
  (struct type t = string let compare = Pervasives.compare end);;

(** la fonction suivante crée l'ensemble des mots du fichier en parametre.
Pour chaque ligne, on recupere la liste des mots avec la fonction 'words'
et on ajoute chacun de ces mots a l'ensemble en cours de construction.
A la fin du fichier (exception End_of_file), on retourne l'ensemble construit. *)
let word_set_of_file file =
  let ic = open_in file in
   let rec read_lines set =
     let line_opt =
       try Some (input_line ic)
       with End_of_file -> None
     in
    (* le rattrapage de l'exception de fin de fichier est confine
       pour permettre la recursivite terminale *)
    match line_opt with
       None -> set
     | Some line ->
        let set = List.fold_left
          (fun set word -> Words.add word set)
            set (words line)
        in
        read_lines set
  in
  let set = read_lines Words.empty in
  close_in ic;
  set
;;

let print_words = Words.iter print_endline ;;

let set1 = word_set_of_file Sys.argv.(1);;
let set2 = word_set_of_file Sys.argv.(2);;
print_words (Words.inter set1 set2);;
