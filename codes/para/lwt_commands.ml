open Lwt;;

type command =
  { command : string ; (**  la commande à lancer *)

    deps : command list ; (** les commandes qui doivent être terminées avant *)

    mutable thread : unit Lwt.t option ;
      (** le thread Lwt qui traite la commande *)
  }

(** Création d'une commande, avec au début aucun thread Lwt
  en charge de l'attente de son exécution. *)
let mk_command command deps = { command ; deps ; thread = None }

let rec run com =
  (* on exécute les dépendances; si elles sont déjà terminées,
     par exemple parce qu'elles ont déjà été lancées parce que
     dans les dépendances d'une autre commande, elles ne sont
     pas relancées, les threads correspondants étant toujours
     en état "terminé".
  *)
  Lwt_list.iter_p run com.deps >>=
    fun _ ->
      match com.thread with
        Some t ->
          (* si un thread attend déjà la fin de la commande, le renvoyer *)
          t
      | None ->
          (* sinon, il faut créer ce thread pour l'exécution de la commande *)
          let t =
            Lwt_process.exec (Lwt_process.shell com.command) >>=
              function
              | Unix.WEXITED 0 -> Lwt.return_unit
              | _ -> Lwt.fail (Failure ("Command failed: "^com.command))
          in
          (* on met ce thread dans notre structure de données, pour qu'en cas
             de multiples commandes dépendant de celle-ci, elle ne soit
             exécutée qu'une fois et attendue que par un seul thread *)
          com.thread <- Some t;
          (* finalement, on renvoie ce thread *)
          t
