let dir_handle = Unix.opendir "/tmp";;

try

  while true do

    let f = Unix.readdir dir_handle in

    print_endline f

  done

with End_of_file -> Unix.closedir dir_handle;;
