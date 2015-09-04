let run_thread id =
  for i = 1 to 10 do
    print_endline
     (Printf.sprintf
       "Je suis le thread %d et c'est mon affichage %d." id i);
  done;;

(* Créer les threads *)
let threads = List.map
  (fun id -> Thread.create run_thread id)
  [ 1 ; 2 ; 3];;

(* Attendre la fin de tous les threads *)
List.iter Thread.join threads;;
