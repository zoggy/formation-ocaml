let words s =
  let len = String.length s in
  let rec iter acc_words acc_current i =
    if i >= len then
      match acc_current with
        "" -> List.rev acc_words
      | w -> List.rev (w :: acc_words)
    else
      match s.[i] with
      | 'a'..'z' | 'A'..'Z' ->
          iter acc_words (Printf.sprintf "%s%c" acc_current s.[i]) (i+1)
      | _ ->
          match acc_current with
            "" -> iter acc_words acc_current (i+1)
          | w -> iter (w::acc_words) "" (i+1)
  in
  iter [] "" 0
;;

module Dict = Map.Make
  (struct type t = string let compare = String.compare end);;

(** la fonction suivante incremente le compteur du mot en parametre.
   si le mot n'est pas dans la table, il est ajoute avec un compteur a 1. *)
let add_word dict word =
  try
    let n = Dict.find word dict in
    let dict = Dict.remove word dict in
    Dict.add word (n+1) dict
  with Not_found ->
      Dict.add word 1 dict
;;

(** la fonction de comptage des mots d'un fichier en parametre.
   Pour chaque ligne, on recupere la liste des mots avec la fonction 'words',
   puis on incremente le compteur de chaque mot avec la fonction 'add_word'
   definie ci-dessus. On lit jusqu'a la fin du fichier (exception End_of_file)
   et on retourne le dictionnaire. *)
let count_in_file file =
  let ic = open_in file in
  let rec read_lines dict =
    let line_opt =
      try Some (input_line ic)
      with End_of_file -> None
    in
    (* le rattrapage de l'exception de fin de fichier est confine
       pour permettre la recursivite terminale *)
    match line_opt with
      None -> dict
    | Some line ->
        let dict = List.fold_left add_word dict (words line) in
        read_lines dict
  in
  let dict = read_lines Dict.empty in
  close_in ic;
  dict
;;

let print_words =
  Dict.iter
  (fun word n -> Printf.printf "%s: %d\n" word n)
;;

let dict = count_in_file Sys.argv.(1);;
print_words dict;;
