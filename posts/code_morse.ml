let mapping =
  [ 'A', "._" ; 'B', "_..." ; 'C', "_._." ;
    'D', "_.." ; 'E', "." ; 'F', ".._." ;
    'G', "__." ; 'H', "...." ; 'I', ".." ;
    'J', ".___" ; 'K', "_._" ; 'L', "._.." ;
    'M', "__" ; 'N', "_." ; 'O', "___" ;
    'P', ".__." ; 'Q', "__._" ; 'R', "._." ;
    'S', "..." ; 'T', "_" ; 'U', ".._" ;
    'V', "..._" ; 'W', ".__" ; 'X', "_.._" ;
    'Y', "_.__" ; 'Z', "__.." ; '0', "_____" ;
    '1', ".____" ; '2', "..___" ; '3', "...__" ;
    '4', "...._" ; '5', "....." ; '6', "_...." ;
    '7', "__..." ; '8', "___.." ; '9', "____." ;
  ] ;;

module Char_key = struct type t = char let compare = Pervasives.compare end;;
module Char_map = Map.Make (Char_key);;

let map_to_morse = List.fold_left
  (fun map (char, morse_code) -> Char_map.add char morse_code map)
  Char_map.empty mapping;;

let char_to_morse = function
  ' ' -> ""
| c ->
  try Char_map.find c map_to_morse
  with Not_found ->
     let msg = Printf.sprintf "char_to_morse: invalid character %C" c in
    raise (Invalid_argument msg)
;;
let to_morse str =
  let len = String.length str in
  let buf = Buffer.create 256 in
  let on_char i c =
    Buffer.add_string buf (char_to_morse c);
    if i < len - 1 then Buffer.add_char buf ' '
  in
  String.iteri on_char str;
  Buffer.contents buf
;;

module Str_map =
  Map.Make (struct type t = string let compare = Pervasives.compare end);;

let map_from_morse = List.fold_left
  (fun map (char, morse) -> Str_map.add morse char map)
  Str_map.empty mapping ;;

let char_from_morse = function
  "" -> ' '
| str ->
   try Str_map.find str map_from_morse
   with Not_found ->
     let msg = Printf.sprintf "char_from_morse: invalid Morse code %S" str in
     raise (Invalid_argument msg)
;;

let split_string s =
  let len = String.length s in
  let rec iter acc pos =
    if pos >= len then
      match acc with
        "" -> []
      | _ -> [acc]
    else
      match s.[pos] with
       ' ' -> acc :: (iter "" (pos + 1))
      | c -> iter (Printf.sprintf "%s%c" acc c) (pos + 1)
  in
  iter "" 0
;;

let from_morse str =
  let words = split_string str in
  let buf = Buffer.create 256 in
  let on_word i str = Buffer.add_char buf (char_from_morse str) in
  List.iteri on_word words;
  Buffer.contents buf
;;

let main () =
  let decode = ref false in
  let options = [ "-d", Arg.Set decode, " decode morse code" ] in
  let args = ref [] in
  Arg.parse options
    (fun arg -> args := arg :: !args)
    (Printf.sprintf "Usage: %s [-d] <text|Morse>" Sys.argv.(0));
  let text = String.concat " " (List.rev !args) in
  let result = (if !decode then from_morse else to_morse) text in
  print_endline result
;;

try main ()
with Invalid_argument msg ->
  prerr_endline msg;
  exit 1
;;











