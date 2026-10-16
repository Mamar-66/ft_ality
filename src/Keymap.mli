type t

val build : Types.symbol list -> (t, string) result
val symbol_of_key : t -> Types.key -> Types.symbol option
val bindings : t -> (Types.key * Types.symbol) list
val key_to_string : Types.key -> string
