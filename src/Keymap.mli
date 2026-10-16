(* Key mapping, computed from the alphabet of the grammar.

   Symbols named up / down / left / right (any case) get the arrow keys,
   every other symbol gets the next free key of a fixed pool
   (q w e a s d z x ...), in alphabetical order of the symbols. *)

type t

val build : Types.symbol list -> (t, string) result
val symbol_of_key : t -> Types.key -> Types.symbol option
val bindings : t -> (Types.key * Types.symbol) list
val key_to_string : Types.key -> string
