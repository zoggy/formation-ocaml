(** Multiplexer plusieurs flux de chaînes accompagnés chacun
  d'un nom pour diriger leur contenu vers la fonction [proc]. *)
let multiplex proc streams =
  Lwt_list.iter_p
    (fun (name, stream) ->
       Lwt_stream.iter_s (fun s -> proc (name, s)) stream
    )
    streams

(** Cette fonction prend un couple (nom de flux, chaîne) et
  passe ce couple à [proc] si la chaîne contient l'expression
  régulière en paramètre. *)
let grep proc re (stream_name, s) =
  try ignore(Str.search_forward re s 0); proc (stream_name, s)
  with Not_found -> Lwt.return_unit

(** Cette fonction prend un couple (nom de flux, chaîne) et
  l'affiche sur la sortie standard, ou bien seulement la chaîne
  si le nom du flux est la chaîne vide. *)
let print (stream_name, s) =
  Lwt_io.write_line Lwt_io.stdout
    (match stream_name with
      "" -> s
    | _ -> stream_name^": "^s
    )

let () =
  try
    (* Erreur si pas assez d'arguments sur la ligne de commande *)
    match Array.to_list Sys.argv with
      [] | [ _ ] ->
        failwith (Printf.sprintf "Usage: %s <string> [files]" Sys.argv.(0))
    | _ :: str :: files ->
        (* on construit la liste des flux d'entrée:
           - si aucun fichier, c'est l'entrée standard sans nom de flux,
           - si un seul fichier, le flux des lignes du fichier, sans nom de flux
           - si plusieurs fichiers, les flux des lignes de chaque fichier, avec
             comme nom de chaque flux le nom du fichier *)
        let streams =
          match files with
            [] -> ["", Lwt_io.read_lines Lwt_io.stdin]
          | [one] -> ["", Lwt_io.lines_of_file one]
          | _-> List.map (fun file -> (file, Lwt_io.lines_of_file file)) files
        in
        (* on construit une fois pour toute l'expression régulière correspondant
           à la chaîne en paramètre *)
        let re = Str.regexp_string str in
        (* il ne reste plus qu'à multiplexer les entrées vers la fonction de
           traitement, ici [grep] qui appellera [print]. *)
        let t = multiplex (grep print re) streams in
        Lwt_main.run t
  with
    Failure msg | Sys_error msg ->
      prerr_endline msg; exit 1
  | e ->
      prerr_endline (Printexc.to_string e); exit 1
