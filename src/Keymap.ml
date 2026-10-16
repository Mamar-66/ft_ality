type t = (Types.key * Types.symbol) list

let pool = "qweasdzxcrfvtgbyhnujmikolp1234567890QWEASDZXCRFVTGBYHNUJMIKOLP"

let arrow_of_symbol symbol =
  match String.lowercase_ascii symbol with
  | "up" -> Some Types.Up
  | "down" -> Some Types.Down
  | "left" -> Some Types.Left
  | "right" -> Some Types.Right
  | _ -> None

let build symbols =
  let rec assign symbols next acc =
    match symbols with
    | [] -> Ok (List.rev acc)
    | symbol :: rest ->
        match arrow_of_symbol symbol with
        | Some arrow when not (List.mem_assoc arrow acc) ->
            assign rest next ((arrow, symbol) :: acc)
        | _ when next >= String.length pool ->
            Error ("too many different keys in the grammar (max "
                   ^ string_of_int (String.length pool) ^ ")")
        | _ -> assign rest (next + 1) ((Types.Byte pool.[next], symbol) :: acc)
  in
  assign (List.sort_uniq compare symbols) 0 []

let symbol_of_key keymap key = List.assoc_opt key keymap
let bindings keymap = keymap

let key_to_string = function
  | Types.Up -> "up"
  | Types.Down -> "down"
  | Types.Left -> "left"
  | Types.Right -> "right"
  | Types.Byte ' ' -> "space"
  | Types.Byte ('\n' | '\r') -> "enter"
  | Types.Byte '\t' -> "tab"
  | Types.Byte '\127' -> "backspace"
  | Types.Byte c when c > ' ' && c < '\127' -> String.make 1 c
  | Types.Byte c -> "byte " ^ string_of_int (int_of_char c)
