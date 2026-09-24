let rec find_opt key = function
  | [] -> None
  | (k, v) :: _ when k = key -> Some v
  | _ :: t -> find_opt key t

let rec read_lines ic acc =
  let read_next_line () =
    try Some (input_line ic) with End_of_file -> None
  in
  match read_next_line () with
  | Some line -> read_lines ic (line :: acc)
  | None ->
      close_in ic;
      List.rev acc

let parse_line line =
  match String.split_on_char '=' line with
  | [seq_str; move_str] ->
      let keys_raw = String.split_on_char ',' seq_str in
      let keys = List.map String.trim keys_raw in
      Some (keys, String.trim move_str)
  | _ -> None

let parse_file filename =
  let ic = open_in filename in
  let lines = read_lines ic [] in
  let rec filter_map ls acc =
    match ls with
    | [] -> List.rev acc
    | h :: t ->
        match parse_line h with
        | Some rule -> filter_map t (rule :: acc)
        | None -> filter_map t acc
  in
  filter_map lines []

(* --- Génération automatique du key mapping --- *)
let rec get_unique_symbols rules acc =
  match rules with
  | [] -> List.rev acc
  | (syms, _) :: t ->
      let rec add_syms ss a =
        match ss with
        | [] -> a
        | s :: st -> if List.mem s a then add_syms st a else add_syms st (s :: a)
      in
      get_unique_symbols t (add_syms syms acc)

let generate_mapping symbols =
  let available_keys = ["q"; "w"; "e"; "a"; "s"; "d"; "z"; "x"; "c"; "v"; "f"; "r"] in
  let rec assign syms keys acc =
    match syms, keys with
    | [], _ -> List.rev acc
    | s :: st, k :: kt -> assign st kt ((k, s) :: acc)
    | s :: st, [] -> assign st [] (("?", s) :: acc) (* Si trop de symboles *)
  in
  assign symbols available_keys []