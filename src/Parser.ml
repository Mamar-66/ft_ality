let rec find_opt key = function
  | [] -> None
  | (k, v) :: _ when k = key -> Some v
  | _ :: t -> find_opt key t

let read_lines ic =
  let rec aux acc =
    match try Some (input_line ic) with End_of_file -> None with
    | Some line -> aux (line :: acc)
    | None -> List.rev acc
  in
  try
    let lines = aux [] in
    close_in ic;
    lines
  with exn ->
    close_in_noerr ic;
    raise exn

let parse_line line =
  let line = String.trim line in
  if line = "" || String.get line 0 = '#' then None
  else
    match String.split_on_char '=' line with
    | [seq_str; move_str] ->
        let keys_raw = String.split_on_char ',' seq_str in
        let keys = 
          keys_raw 
          |> List.map String.trim 
          |> List.filter (fun s -> String.length s > 0) 
        in
        let move = String.trim move_str in
        
        if keys = [] || String.length move = 0 then None
        else Some (keys, move)
        
    | _ -> None

let parse_file filename =
  let ic = open_in filename in
  let lines = read_lines ic in
  let rec filter_map ls acc =
    match ls with
    | [] -> List.rev acc
    | h :: t ->
        match parse_line h with
        | Some rule -> filter_map t (rule :: acc)
        | None -> filter_map t acc
  in
  let rules = filter_map lines [] in
  if rules = [] then
    failwith "Grammar file is empty or contains no valid rules."
  else
    rules

let get_unique_symbols rules =
  let rec aux rs acc =
    match rs with
    | [] -> List.rev acc
    | (syms, _) :: t ->
        let rec add_syms ss a =
          match ss with
          | [] -> a
          | s :: st -> if List.mem s a then add_syms st a else add_syms st (s :: a)
        in
        aux t (add_syms syms acc)
  in
  aux rules []

let generate_mapping symbols =
  let make_key i =
    if i < 26 then 
      String.make 1 (Char.chr (Char.code 'a' + i))
    else if i < 52 then 
      String.make 1 (Char.chr (Char.code 'A' + (i - 26)))
    else if i < 62 then 
      String.make 1 (Char.chr (Char.code '0' + (i - 52)))
    else 
      "k" ^ string_of_int i
  in
  List.mapi (fun i sym -> (make_key i, sym)) symbols