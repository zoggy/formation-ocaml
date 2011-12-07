(*********************************************************************************)
(*  "Introduction au langage OCaml" par Maxence Guesdon est mis                  *)
(*  à disposition selon les termes de la licence Creative Commons                *)
(*   Paternité                                                                   *)
(*   Pas d'Utilisation Commerciale                                               *)
(*   Partage des Conditions Initiales à l'Identique                              *)
(*   2.0 France.                                                                 *)
(*                                                                               *)
(*  Contact: Maxence.Guesdon@inria.fr                                            *)
(*                                                                               *)
(*                                                                               *)
(*********************************************************************************)

(** Read the xml file for oug formation and generate corresponding
   latex and additional files. *)

type eval_type = [`Toplevel | `Errors | `Simple]
type code = {
  code : string ;
  eval : eval_type option ;
  lines : bool ;
  hide : bool ;
  }

type t =
  | OCaml of code
  | C of code
  | Figure of string

let t_parser = XmlParser.make ()
let _ = XmlParser.prove t_parser false

let att_value atts s =
  try List.assoc s atts
  with Not_found ->
      failwith (Printf.sprintf "No attribute %s in attributes" s)
;;

let att_value_def atts f def s =
  try f (List.assoc s atts)
  with Not_found -> def
;;

(*c==v=[String.string_of_in_channel]=1.0====*)
let string_of_in_channel ic =
  let len = 1024 in
  let s = String.create len in
  let buf = Buffer.create len in
  let rec iter () =
    try
      let n = input ic s 0 len in
      if n = 0 then
        ()
      else
        (
         Buffer.add_substring buf s 0 n;
         iter ()
        )
    with
      End_of_file -> ()
  in
  iter ();
  Buffer.contents buf
(*/c==v=[String.string_of_in_channel]=1.0====*)

(*c==v=[String.strip_string]=1.0====*)
let strip_string s =
  let len = String.length s in
  let rec iter_first n =
    if n >= len then
      None
    else
      match s.[n] with
        ' ' | '\t' | '\n' | '\r' -> iter_first (n+1)
      | _ -> Some n
  in
  match iter_first 0 with
    None -> ""
  | Some first ->
      let rec iter_last n =
        if n <= first then
          None
        else
          match s.[n] with
            ' ' | '\t' | '\n' | '\r' -> iter_last (n-1)
          |	_ -> Some n
      in
      match iter_last (len-1) with
        None -> String.sub s first 1
      |	Some last -> String.sub s first ((last-first)+1)
(*/c==v=[String.strip_string]=1.0====*)
(*c==v=[File.string_of_file]=1.0====*)
let string_of_file name =
  let chanin = open_in_bin name in
  let len = 1024 in
  let s = String.create len in
  let buf = Buffer.create len in
  let rec iter () =
    try
      let n = input chanin s 0 len in
      if n = 0 then
        ()
      else
        (
         Buffer.add_substring buf s 0 n;
         iter ()
        )
    with
      End_of_file -> ()
  in
  iter ();
  close_in chanin;
  Buffer.contents buf
(*/c==v=[File.string_of_file]=1.0====*)

let _ = Toploop.set_paths ();;
let _ = Toploop.initialize_toplevel_env();;
let _ =
  match Hashtbl.find Toploop.directive_table "rectypes" with
    Toploop.Directive_none f -> f ()
  | _ -> assert false;;
let _ = Toploop.max_printer_steps := 20;;


let ocaml_phrases_of_string s =
  let s = strip_string s in
  let len = String.length s in
  let s =
    if len < 2 || String.sub s (len - 2) 2 <> ";;" then
      s^";;"
    else
      s
  in
  let acc = ref [] in
  let last_start = ref 0 in
  let len = String.length s in
  for i = 0 to len - 2 do
    if s.[i] = ';' && s.[i+1] = ';' then
      begin
        acc := (String.sub s !last_start (i + 2 - !last_start)) :: !acc;
        last_start := i+2
      end
  done;
  List.rev_map strip_string !acc
;;

(* to include the Topdirs module *)
let x = Topdirs.dir_quit;;
let _ = Location.input_name := "";;
let stderr_file = Filename.temp_file "gentex" "txt";;
let stdout_file = Filename.temp_file "gentex" "txt";;

let original_stderr = Unix.dup Unix.stderr;;
let original_stdout = Unix.dup Unix.stdout;;

let eval_ocaml_phrase ?(exc=false) phrase =
  try
    let lexbuf = Lexing.from_string phrase in
    let fd_err = Unix.openfile stderr_file
      [Unix.O_WRONLY; Unix.O_CREAT; Unix.O_TRUNC]
      0o640
    in
    Unix.dup2 fd_err Unix.stderr;
    let fd_out = Unix.openfile stdout_file
      [Unix.O_WRONLY; Unix.O_CREAT; Unix.O_TRUNC]
      0o640
    in
    Unix.dup2 fd_out Unix.stdout;
    Unix.close fd_out;
    let phrase = !Toploop.parse_toplevel_phrase lexbuf in
    ignore(Toploop.execute_phrase true Format.str_formatter phrase);
    let exec_output = Format.flush_str_formatter () in
    let err = string_of_file stderr_file in
    let out = string_of_file stdout_file in
    (
     match err with
       "" -> ()
     | s -> Format.pp_print_string Format.str_formatter s
    );
    (
     match out with
       "" -> ()
     | s -> Format.pp_print_string Format.str_formatter s
    );
    Format.pp_print_string Format.str_formatter exec_output;
    strip_string (Format.flush_str_formatter ())
  with
  | e ->
      Errors.report_error Format.str_formatter e;
      let err = Format.flush_str_formatter () in
      let msg = Printf.sprintf "ocaml error with code:\n%s\n%s" phrase err in
      if exc then failwith msg else strip_string err
;;

let eval_ocaml ?exc f code =
  let phrases = ocaml_phrases_of_string code in
  let rec iter = function
    [] -> ()
  | h :: q ->
      f (q=[]) h (eval_ocaml_phrase ?exc h);
      iter q
  in
  iter phrases
;;

let doc_of_file file =
  let ic = open_in file in
  let s = string_of_in_channel ic in
  close_in ic;
  s
;;

let latex_highlight lang options s =
  let com = Printf.sprintf
    "highlight -f -O latex %s %s"
      (match lang with
         "" -> "--force"
       | _ -> Printf.sprintf "--syntax=%s" lang
      )
      (String.concat " " options)
  in
  let (ic,oc) = Unix.open_process com in
  output_string oc s;
  close_out oc;
  let s = string_of_in_channel ic in
  ignore(Unix.close_process (ic, oc));
  s
;;

let latex_highlight_none options s =
  Str.global_replace
    (Str.regexp_string "\\hlstd") "\\hltop"
    (latex_highlight "" options s);;
let latex_highlight_ocaml = latex_highlight "ml";;
let latex_highlight_c = latex_highlight "c";;

let string_of_code code =
(*  Printf.fprintf oc "\n\\framebox{\\parbox{15cm}{%s}}\n" code*)
  Printf.sprintf "\n\\parbox{15cm}{%s}\n\n" code
;;

let string_of_ocaml =
  let code_id = ref 0 in
  fun code ->
    let eval =
      let code_options =
        if code.lines then ["-l"] else []
      in
      match code.eval with
        None -> latex_highlight_ocaml code_options code.code
      | Some kind ->
          let b = Buffer.create 256 in
          let (f, exc) =
            match kind with
              `Toplevel | `Errors ->
                (
                 (fun last code res ->
                    let s_code = latex_highlight_ocaml code_options code in
                    let s_res = match res with
                        "" -> ""
                      | _ -> latex_highlight_none [] res
                    in
                    Printf.bprintf b
                      "\\# %s%s%s" s_code s_res
                      (if last or res="" then "" else "")),
                 kind <> `Errors
                )
            | `Simple ->
                (
                 (fun last code _ ->
                    let s_code = latex_highlight_ocaml code_options code in
                    Printf.bprintf b "%s%s" s_code (if last then "" else "\n")),
                 true)
          in
          eval_ocaml ~exc f code.code;
          Buffer.contents b
    in
    let s_code = string_of_code (*(latex_highlight_ocaml options *)eval in
    Printf.sprintf "%s%s%s"
      (if code.hide then (incr code_id; Printf.sprintf "\\begin{answer}{code%d}\n" !code_id) else "")
      s_code
      (if code.hide then "\\end{answer}\n" else "")
;;

let string_of_c code =
  let options =
    (if code.lines then ["-l"] else [])
  in
  string_of_code (latex_highlight_c options code.code)

let string_of_t = function
| OCaml code -> string_of_ocaml code
| C code -> string_of_c code
| Figure s -> Printf.sprintf "{\\bf figure %s}" s
;;

let replace doc =
  let xml_to_t = function
  | Xml.Element ("c", atts, _)
  | Xml.Element ("C", atts, _) ->
      let code = att_value atts "code" in
      let lines = att_value_def atts ((=) "true") false "lines" in
      C { code = code ; lines = lines ; eval = None ; hide = false}
  | Xml.Element ("ocaml",atts,_) ->
      let code = att_value atts "code" in
      let eval =
        try
          match List.assoc "eval" atts with
            "top" -> Some `Toplevel
          | "true" -> Some `Simple
          | "errors" -> Some `Errors
          | s -> failwith (Printf.sprintf "Value '%s' invalid for attribute 'eval'." s)
        with Not_found -> None
      in
      let lines = att_value_def atts ((=) "true") false "lines" in
      let hide = att_value_def atts ((=) "true") false "hide" in
      OCaml { code = code ; eval = eval ; lines = lines ; hide = hide }
  | Xml.Element ("fig",atts,_) -> Figure (att_value atts "file")
  | Xml.Element (tag, _, _) -> failwith (Printf.sprintf "tag %s not handled" tag)
  | Xml.PCData _ -> assert false
  in
  let replace matched =
    let len = String.length matched in
    matched.[0] <- ' ';
    matched.[1] <- '<';
    matched.[len-2] <- '/';
    let xml =
      try Xml.parse_string matched
      with Xml.Error e -> failwith (Printf.sprintf "%s:\n%s" (Xml.error e) matched)
    in
    let t = xml_to_t xml in
    string_of_t t
  in
(*  let re = Str.regexp "<['a'-'z''A'-'Z'].*/>" in*)
(*  let rex = Str.regexp "<ocaml\\($\\|.\\)*/>" in*)
  let iflags = Pcre.cflags [`MULTILINE] in
  let rex = Pcre.regexp ~iflags "(*ANYCRLF)<\\$([^\\$])*\\$>" in
  Pcre.substitute ~rex ~subst: replace doc
;;

let usage = Printf.sprintf "Usage: %s <xml file>" Sys.argv.(0);;

let restore_fd () =
  Unix.dup2 original_stdout Unix.stdout;
  Unix.dup2 original_stderr Unix.stderr
;;

let main () =
  if Array.length Sys.argv < 2 then failwith usage;
  let doc = doc_of_file Sys.argv.(1) in
  try
    let doc = replace doc in
    restore_fd ();
    output_string stdout doc
  with
    e ->
      restore_fd ();
(*      ignore(Sys.command (Printf.sprintf "cat %s" (Filename.quote stdout_file)));*)
      raise e
;;



(*c==v=[Misc.safe_main]=1.0====*)
let safe_main main =
  try main ()
  with
    Failure s
  | Sys_error s ->
      prerr_endline s;
      exit 1
(*/c==v=[Misc.safe_main]=1.0====*)

let _ = safe_main main