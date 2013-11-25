
let make_id =
  let cpt = ref 0 in
  fun () -> incr cpt; Printf.sprintf "__solution__%d" !cpt
;;

let get_solution_label data env =
  let (data, xmls) = Stog_engine.get_in_env data env ("", "solution-label") in
  let xmls = match xmls with [] -> [Xtmpl.D "Answer"] | _ -> xmls in
  (data, xmls)
;;

let fun_solution data env atts subs =
  match Xtmpl.get_arg atts ("", "id") with
    Some s ->
      (* id already present, return same node *)
      raise Xtmpl.No_change
  | None ->
      (* create a unique id *)
      let id = make_id () in
      let (data, xml) = get_solution_label data env in
      let xmls =
        [ Xtmpl.E (("", "button"),
           Xtmpl.atts_of_list
             [ ("", "href"), [Xtmpl.D ("#"^id)] ;
               ("", "data-toggle"), [Xtmpl.D "collapse"] ;
               ("", "class"), [Xtmpl.D "btn btn-info solution"]
             ],
           xml) ;
          Xtmpl.E (("", "div"),
           Xtmpl.atts_of_list
             [("", "id"), [Xtmpl.D id] ; ("", "class"), [Xtmpl.D "collapse codeblock"]],
           subs)
        ]
      in
      (data, xmls)
;;


let () = Stog_plug.register_html_base_rule
  ("", "solution") fun_solution ;;
(*
This must be added at the end of each page:
<script type="text/javascript" src="jquery.js"></script>
<script type="text/javascript" src="bootstrap-collapse.js"></script>

*)