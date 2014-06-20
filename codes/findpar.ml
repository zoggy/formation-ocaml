open Lwt;;

let rec count =
  let on_entry dir name =
    if name = Filename.current_dir_name
      || name = Filename.parent_dir_name
    then
      Lwt.return 0
    else
      let file = Filename.concat dir name in
      Lwt_unix.lstat file
        >>= fun stats ->
          match stats.Unix.st_kind with
          | Unix.S_REG -> Lwt.return 1
          | Unix.S_DIR -> count file
          | _ -> Lwt.return 0
  in
  let rec iter dir h acc n =
    Lwt.try_bind
      (fun () -> Lwt_unix.readdir h)
      (fun file ->
         if file = Filename.current_dir_name
           || file = Filename.parent_dir_name
         then
           iter dir h acc n
         else
           begin
             let file = Filename.concat dir file in
             Lwt_unix.lstat file
               >>= fun stats ->
                 match stats.Unix.st_kind with
                 | Unix.S_REG -> iter dir h acc (n+1)
                 | Unix.S_DIR ->
                     let thr = count file in
                     iter dir h (thr :: acc) n
                 | _ -> iter dir h acc n
           end
      )
      (function End_of_file ->
          Lwt_unix.closedir h >>=
             fun _ ->
               Lwt_list.fold_left_s
                 (fun acc thr -> thr >|= (+) acc) n acc
      )
  in
  fun dir ->
    Lwt_unix.opendir dir
    >>= fun h -> iter dir h [] 0
;;

let fatal msg = prerr_endline msg; exit 1 ;;

if Array.length Sys.argv < 2 then
  fatal (Printf.sprintf "Usage: %s <dir>" Sys.argv.(0))
else
  try
    let n = Lwt_main.run (count Sys.argv.(1)) in
    print_endline (string_of_int n)
  with
    Unix.Unix_error (e, s1, s2) ->
      let msg = Printf.sprintf "%s: %s %s" (Unix.error_message e) s1 s2 in
      fatal msg
;;