open Lwt;;

type command =
  { command : string ; (**  la commande a lancer *)

    deps : command list ; (** la commande qui doivent etre terminees avant *)

    mutable thread : unit Lwt.t option ;
      (** le thread Lwt qui traite la commande *)
  }

(** Creation d'une commande, avec au debut aucun thread Lwt
  en charge de l'attente de son execution. *)
let mk_command command deps = { command ; deps ; thread = None }

let rec run com =
  (* on execute les dependances; si elles sont deja terminees,
     par exemple parce qu'elles ont deja ete lancees parce que
     dans les dependances d'une autre commande, elles ne sont
     pas relancees, les threads correspondants etant toujours
     en etat "termine".
  *)
  Lwt_list.iter_p run com.deps >>=
    fun _ ->
      match com.thread with
        Some t ->
          (* si un thread attend dejà la fin de la commande, le renvoyer *)
          t
      | None ->
          (* sinon, il faut creer ce thread pour l'execution de la commande *)
          let t =
            Lwt_process.exec (Lwt_process.shell com.command) >>=
              function
              | Unix.WEXITED 0 -> Lwt.return_unit
              | _ -> Lwt.fail (Failure ("Command failed: "^com.command))
          in
          (* on met ce thread dans notre structure de donnees, pour qu'en cas
             de multiples commandes dependant de celle-ci, elle ne soit
             executee qu'une fois et attendue que par un seul thread *)
          com.thread <- Some t;
          (* finalement, on renvoie ce thread *)
          t

