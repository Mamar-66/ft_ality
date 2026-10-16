type event =
  | Key of Types.key
  | Unknown of string
  | Quit

type reader = char option

let stty args = Sys.command ("stty " ^ args ^ " 2> /dev/null") = 0

let enable_raw_mode () =
  stty "-icanon -echo -isig min 1 time 0"
  && begin
    at_exit (fun () -> ignore (stty "icanon echo isig"));
    Sys.set_signal Sys.sigterm (Sys.Signal_handle (fun _ -> exit 1));
    Sys.set_signal Sys.sighup (Sys.Signal_handle (fun _ -> exit 1));
    true
  end

let read_char () =
  try Some (input_char stdin) with End_of_file | Sys_error _ -> None

let is_final_byte c = c >= '@' && c <= '~'

let control_sequence () =
  let rec skip () =
    match read_char () with
    | Some c when not (is_final_byte c) -> skip ()
    | _ -> Unknown "escape sequence"
  in
  match read_char () with
  | Some 'A' -> Key Types.Up
  | Some 'B' -> Key Types.Down
  | Some 'C' -> Key Types.Right
  | Some 'D' -> Key Types.Left
  | Some c when is_final_byte c -> Unknown "escape sequence"
  | Some _ -> skip ()
  | None -> Quit

let escape () =
  match read_char () with
  | Some ('[' | 'O') -> (control_sequence (), None)
  | Some c -> (Unknown "escape", Some c)
  | None -> (Quit, None)

let decode = function
  | '\003' | '\004' -> (Quit, None)
  | '\027' -> escape ()
  | c -> (Key (Types.Byte c), None)

let reader = None

let next = function
  | Some c -> decode c
  | None ->
      match read_char () with
      | Some c -> decode c
      | None -> (Quit, None)
