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

(** la fonction suivante incremente le compteur du mot en parametre.
si le mot n'est pas dans la table, il est ajoute avec un compteur a 1. *)
let add_word table w =
  try
    let n = Hashtbl.find table w in
    Hashtbl.replace table w (n+1)
  with Not_found ->
    Hashtbl.add table w 1
;;

(** la fonction de comptage des mots d'un fichier en parametre.
Pour chaque ligne, on recupere la liste des mots avec la fonction 'words',
puis on incremente le compteur de chaque mot avec la fonction 'add_word'
definie ci-dessus. On lit jusqu'a la fin du fichier (exception End_of_file)
et on retourne la table de comptage. *)
let count_in_file file =
  let table = Hashtbl.create 111 in
  let ic = open_in file in
  try
    while true do
      let line = input_line ic in
      List.iter (add_word table) (words line)
    done;
    assert false
  with
    End_of_file -> close_in ic; table
;;

let print_words =
  Hashtbl.iter
    (fun word n -> Printf.printf "%s: %d\n" word n)
;;

let table = count_in_file Sys.argv.(1);;
print_words table;;
