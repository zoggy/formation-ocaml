type command

(** Creation d'une commande à partir d'une chaine (la commande a lancer)
  et des commandes dont elle depend. *)
val mk_command : string -> command list -> command

(** Execution de la commande et de ses dependances, en utilisant
 le parallelisme latent dans les dependances.
 Utilise Lwt.fail (Failure ...) en cas d'erreur d'execution d'une commande. *)
val run : command -> unit Lwt.t
