type command

(** Création d'une commande à partir d'une chaîne (la commande à lancer)
  et des commandes dont elle dépend. *)
val mk_command : string -> command list -> command

(** Exécution de la commande et de ses dépendances, en utilisant
 le parallélisme latent dans les dépendances.
 Utilise Lwt.fail (Failure ...) en cas d'erreur d'exécution d'une commande. *)
val run : command -> unit Lwt.t
