
module XR = Xtmpl_rewrite
module Xml = Xtmpl_xml
module XH = Xtmpl_xhtml

let make_id =
  let cpt = ref 0 in
  fun () -> incr cpt; Printf.sprintf "__solution__%d" !cpt
;;

let get_solution_label data env =
  let (data, xmls) = Stog_engine.get_in_env data env ("", "solution-label") in
  let xmls = match xmls with [] -> [XR.cdata "Answer"] | _ -> xmls in
  (data, xmls)
;;

let fun_solution data env ?loc atts subs =
  match XR.get_att atts ("", "id") with
    Some s ->
      (* id already present, return same node *)
      raise XR.No_change
  | None ->
      (* create a unique id *)
      let id = make_id () in
      let (data, xml) = get_solution_label data env in
      let xmls =
        [ XH.button
           ~atts:(XR.atts_of_list
             [ ("", "href"), [XR.cdata ("#"^id)] ;
               ("", "data-toggle"), [XR.cdata "collapse"] ;
               ("", "class"), [XR.cdata "btn btn-info solution"]
             ])
           xml ;
          XH.div ~id ~class_:"collapse codeblock" subs
        ]
      in
      (data, xmls)
;;

let find_sub_contents ?loc loctag xmls tag =
  let pred = function
    XR.D _ | XR.C _ | XR.PI _ -> false
  | XR.E { XR.name } -> name = tag
  in
  try
    match List.find pred xmls with
    | XR.E { XR.subs } -> subs
    | _ -> assert false
  with Not_found ->
      Stog_plug.error
        (Xml.loc_sprintf loc
         "Missing <%s> tag in %s" (Xml.string_of_name tag) loctag);
      []

let fun_mlmli data env ?loc atts subs =
  let file = XR.opt_att atts ~def: [ XR.cdata ""] ("", "file") in
  let id = XR.get_att atts ("", "id") in
  let ml = find_sub_contents ?loc "<mlmli>" subs ("","ml") in
  let mli = find_sub_contents ?loc "<mlmli>" subs ("","mli") in
  let atts = match id with
    | None -> XR.atts_empty
    | Some id -> XR.atts_one ("","id") id
  in
  let code ext contents =
  XH.div ~classes: [ext]
      [
        XH.div ~classes: ["module-file"]
          (
           (XH.div ~classes: ["module-filename"]
            (file @ [XR.cdata ("."^ext)])
           ) :: contents
          )
      ]
  in
  let xml =
    XH.div ~atts ~classes: ["module-files"]
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
