let date = Unix.gmtime (Unix.time ()) ;;

let string_of_month = function
  0 -> "janvier"
| 1 -> "février"
| 2 -> "mars"
| 3 -> "avril"
| 4 -> "mai"
| 5 -> "juin"
| 6 -> "juillet"
| 7 -> "août"
| 8 -> "septembre"
| 9 -> "octobre"
| 10 -> "novembre"
| 11 -> "décembre"
| _ -> assert false (* on ne doit pas avoir une autre valeur *)
;;

let date_string_of_tm tm =
  Printf.sprintf "%d %s %d"
    tm.Unix.tm_mday
    (string_of_month tm.Unix.tm_mon)
    (1900 + tm.Unix.tm_year)
;;

print_endline (date_string_of_tm date);;