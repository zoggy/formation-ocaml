let rec count dir =
  let h = Unix.opendir dir in
  let rec iter n =
    match
      try Some (Unix.readdir h)
      with End_of_file -> None
    with
      None -> Unix.closedir h; n
    | Some file ->
        if file = Filename.current_dir_name
          || file = Filename.parent_dir_name
        then
          iter n
        else
          begin
            let file = Filename.concat dir file in
            match (Unix.lstat file).Unix.st_kind with
              Unix.S_REG -> iter (n+1)
            | Unix.S_DIR ->
                let n_under = count file in
                iter (n + n_under)
            | _ -> iter n
          end
  in
  iter 0
;;

let fatal msg = prerr_endline msg; exit 1 ;;

if Array.length Sys.argv < 2 then
  fatal (Printf.sprintf "Usage: %s <dir>" Sys.argv.(0))
else
  try
    let n = count Sys.argv.(1) in
    print_endline (string_of_int n)
  with
    Unix.Unix_error (e, s1, s2) ->
      let msg = Printf.sprintf "%s: %s %s" (Unix.error_message e) s1 s2 in
      fatal msg
;;