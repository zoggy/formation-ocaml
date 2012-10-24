
let make_id =
  let cpt = ref 0 in
  fun () -> incr cpt; Printf.sprintf "__solution__%d" !cpt
;;

let get_solution_label env =
  let s =
    match Stog_html.get_in_env env "solution-label" with
      "" -> "Answer"
    | s -> s
  in
  Xtmpl.xml_of_string s
;;

let fun_solution env atts subs =
  match Xtmpl.get_arg atts "id" with
    Some s ->
      (* id already present, return same node *)
      raise Xtmpl.No_change
  | None ->
      (* create a unique id *)
      let id = make_id () in
      [ Xtmpl.T ("button",
         ["href", "#"^id ; "data-toggle", "collapse" ; "class", "btn btn-info solution"],
         [get_solution_label env]) ;
        Xtmpl.T ("div",
         ["id", id ; "class", "collapse codeblock"],
         subs)
      ]
;;
let rules stog elt_id elt = [ "solution", fun_solution ];;

let () = Stog_plug.register_level_fun 5 (Stog_html.compute_elt rules);;
(*
This must be added at the end of each page:
<script type="text/javascript" src="jquery.js"></script>
<script type="text/javascript" src="bootstrap-collapse.js"></script>

*)