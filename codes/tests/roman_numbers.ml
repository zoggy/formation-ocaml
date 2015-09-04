
(* The available letters *)
let letters = [| 'M' ; 'D' ; 'C' ; 'L' ; 'X' ; 'V' ; 'I' |];;

(* Compute values of letters *)
let values =
  let len = Array.length letters in
  let t = Array.make len 1 in
  let rec iter i =
    if i >= 0 then
      begin
        let factor = if i mod 2 = 0 then 2 else 5 in
        t.(i) <- t.(i+1) * factor;
        iter (i-1)
      end
  in
  iter (len - 2);
  t
;;

(* Convert an arabic to a roman (as string) *)
let to_roman n =
  if (n <= 0 && n > 4888) then failwith "n is not in the range.";
  (* the result will be stored in buffer b *)
  let b = Buffer.create 20 in
  (* compute once the length of the letters array *)
  let len = Array.length letters in
  (* iter from the highest letter to the lowest *)
  let rec iter n i =
    (* stop if we reached the end of the letters *)
    if i < len then
      begin
        (* get the value associated to the current letter *)
        let v = values.(i) in
        (* compute how many of the current letter we must print ;
           this will never be >= 4 because this case has been
           handled when handling the previous (higher) letter. *)
        let q = n / v in
        if q > 0 then
          Buffer.add_string b (String.make q letters.(i));
        (* let's handle the rest *)
        let n = n mod v in
        (* get the value of the lower letter which is not
          just half the current letter, i.e. for C it is X, not L. *)
        let prev = if i mod 2 = 0 then i + 2 else i + 1 in
        let n =
          (* if this lower letter exists and n is between the
             current letter and current letter - the lower letter ... *)
          if prev < len && n >= v - values.(prev) then
            (
             (* ... then print the lower letter and the current letter,
               like in "XC" for 90 *)
             Printf.bprintf b "%c%c" letters.(prev) letters.(i);
             (* decrease n *)
             n - (v - values.(prev))
            )
          else
            n
        in
        (* handle next (lower) letter *)
        iter n (i+1)
      end
  in
  iter n 0;
  Buffer.contents b
;;

