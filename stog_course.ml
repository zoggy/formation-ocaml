
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
  match Xtmpl.get_att atts ("", "id") with
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

let find_sub_contents loc xmls tag =
  let pred = function
    Xtmpl.D _ -> false
  | Xtmpl.E (tag2, _, _) -> tag2 = tag
  in
  try
    match List.find pred xmls with
    | Xtmpl.E(_,_,xmls) -> xmls
    | _ -> assert false
  with Not_found ->
      Stog_plug.error
        (Printf.sprintf "Missing <%s> tag in %s" (Xtmpl.string_of_name tag) loc);
      []

let fun_mlmli data env atts subs =
  let file = Xtmpl.opt_att atts ~def: [ Xtmpl.D ""] ("", "file") in
  let id = Xtmpl.get_att atts ("", "id") in
  let ml = find_sub_contents "<mlmli>" subs ("","ml") in
  let mli = find_sub_contents "<mlmli>" subs ("","mli") in
  let atts = match id with
    | None -> Xtmpl.atts_empty
    | Some id -> Xtmpl.atts_one ("","id") id
  in
  let code ext contents =
  Xtmpl_xhtml.div ~classes: [ext]
      [
        Xtmpl_xhtml.div ~classes: ["module-file"]
          (
           (Xtmpl_xhtml.div ~classes: ["module-filename"]
            (file @ [Xtmpl.D ("."^ext)])
           ) :: contents
          )
      ]
  in
  let xml =
    Xtmpl_xhtml.div ~atts ~classes: ["module-files"]
     [ code "mli" mli ; code "ml" ml ]
  in
  (data, [xml])

let () = Stog_plug.register_html_base_rule ("", "mlmli") fun_mlmli ;;
let () = Stog_plug.register_html_base_rule ("", "solution") fun_solution ;;

(*
This must be added at the end of each page:
<script type="text/javascript" src="jquery.js"></script>
<script type="text/javascript" src="bootstrap-collapse.js"></script>

*)
