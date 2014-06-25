
let com =
  let clean = Lwt_commands.mk_command "rm -f file1.txt file2.txt file3.txt" [] in
  Lwt_commands.mk_command "ls -l file*.txt"
    [ Lwt_commands.mk_command "sleep 1 ; touch file1.txt" [ clean ] ;
      Lwt_commands.mk_command "sleep 1 ; touch file2.txt" [ clean ] ;
      Lwt_commands.mk_command "sleep 1 ; touch file3.txt" [ clean ] ;
    ]

let () =
  try Lwt_main.run (Lwt_commands.run com)
  with Failure msg -> prerr_endline msg ; exit 1