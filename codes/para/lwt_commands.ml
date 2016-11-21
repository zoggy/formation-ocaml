open Lwt;;

type command =
  { command : string ; (**  la commande à lancer *)

    deps : command list ;
      (** les commandes qui doivent être terminées avant *)

    mutable thread : unit Lwt.t option ;
      (** le thread Lwt qui traite la commande *)
  }

(** Création d'une commande, avec au début aucun thread Lwt
  en charge de l'attente de son exécution. *)
let mk_command command deps = { command ; deps ; thread = None }

let rec run com =
  match com.thread with
    Some t ->
      (* si un thread attend déjà la fin de la commande, le renvoyer *)
      t
  | None ->
      (* sinon on exécute les dépendances; si elles sont déjà terminées,
         par exemple parce qu'elles ont déjà été lancées car étant
         dans les dépendances d'une autre commande, elles ne sont
         pas relancées, les threads correspondants étant toujours
         en état "terminé". *)
      Lwt_list.iter_p run com.deps >>=
        fun _ ->
          (* on créé un thread et son réveilleur associé, ce qui permet
             aux commandes dépendant de notre commande de se mettre en
             attente. Lorsque l'exécution de la commande sera terminée,
             le réveilleur sera utilisé pour réveiller le thread (qui
             passera en état "terminé") et débloquer les commandes qui
             dépendent de notre commande. *)
          let (t, wakener) = Lwt.wait () in
          (* on met ce thread t dans notre structure de données, pour qu'en
             cas de multiples commandes dépendant de cette commande, cette
             dernière ne soit exécutée qu'une fois *)
          com.thread <- Some t ;
          (* on exécute ensuite la commande *)
          Lwt_process.exec (Lwt_process.shell com.command) >>=
            function
            | Unix.WEXITED 0 ->
                (* lorsqu'elle se termine, on "réveille" le thread associé à
                   notre commande. Ce thread (ici t) se termine avec la valeur
                   passée à Lwt.wakeup, ici (). *)
                Lwt.wakeup wakener () ;
              Lwt.return_unit
            | _ -> Lwt.fail (Failure ("Command failed: "^com.command))
