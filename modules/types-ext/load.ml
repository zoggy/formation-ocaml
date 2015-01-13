Dynlink.loadfile "m2.cmo";;
Dynlink.loadfile "m1.cmo";;
let () = Common.handle_queue_messages ();;