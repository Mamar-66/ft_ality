let is_printable str =
  let rec check i =
    i >= String.length str
    || (let code = int_of_char str.[i] in
        (code >= 32 && code <> 127 || str.[i] = '\t') && check (i + 1))
  in
  check 0

let parse_keys str =
  let keys = List.map String.trim (String.split_on_char ',' str) in
  if List.exists (fun key -> key = "") keys then Error "empty key in sequence"
  else Ok keys

let parse_rule line eq =
  let name =
    String.trim (String.sub line (eq + 1) (String.length line - eq - 1))
  in
  if name = "" then Error "empty move name"
  else
    match parse_keys (String.sub line 0 eq) with
    | Error msg -> Error msg
    | Ok keys -> Ok (Some { Types.keys = keys; name = name })

let parse_line raw =
  let line = String.trim raw in
  if line = "" || line.[0] = '#' then Ok None
  else if not (is_printable line) then Error "invalid (non printable) character"
  else
    match String.index_opt line '=' with
    | None -> Error "missing '=' (expected: key1, key2, ... = Move name)"
    | Some eq -> parse_rule line eq

type line =
  | Line of string
  | End
  | Too_long

let max_line_length = 4096

let read_line ic =
  let finish chars = Line (String.concat "" (List.rev_map (String.make 1) chars)) in
  let rec loop chars length =
    match input_char ic with
    | exception End_of_file -> if chars = [] then End else finish chars
    | '\n' -> finish chars
    | _ when length >= max_line_length -> Too_long
    | c -> loop (c :: chars) (length + 1)
  in
  loop [] 0

let fold_file f init filename =
  let error line_no msg =
    Error (filename ^ ": line " ^ string_of_int line_no ^ ": " ^ msg)
  in
  let rec loop ic line_no acc =
    match read_line ic with
    | End -> Ok acc
    | Too_long -> error line_no "line too long"
    | Line line ->
        match parse_line line with
        | Error msg -> error line_no msg
        | Ok None -> loop ic (line_no + 1) acc
        | Ok (Some rule) -> loop ic (line_no + 1) (f acc rule)
  in
  match open_in filename with
  | exception Sys_error msg -> Error msg
  | ic ->
      let result =
        try loop ic 1 init with Sys_error msg -> Error (filename ^ ": " ^ msg)
      in
      close_in_noerr ic;
      result
