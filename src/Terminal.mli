type event =
  | Key of Types.key
  | Unknown of string
  | Quit

type reader

val enable_raw_mode : unit -> bool

val reader : reader
val next : reader -> event * reader
