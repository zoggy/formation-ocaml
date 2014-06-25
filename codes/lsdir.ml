let ls_dir dir =
  try
    let handle = Unix.opendir dir in
    let rec read acc =
       match
         try Some(Unix.readdir handle)
         with End_of_file -> None
       with
         None -> acc
       | Some file ->
           let f = Filename.concat dir file in
           match (Unix.stat f).Unix.st_kind with
             Unix.S_REG -> read (file :: acc)
           | _ -> read acc
     in
     read []
  with
    Unix.Unix_error (e, s1, s2) ->
      failwith (Printf.sprintf "%s: %s %s" (Unix.error_message e) s1 s2)
;;