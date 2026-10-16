type t
type state

val empty : t
val add_rule : t -> Types.rule -> t

val rule_count : t -> int
val state_count : t -> int
val alphabet : t -> Types.symbol list

val initial : t -> state
val step : t -> state -> Types.symbol -> state

val id : state -> int
val word : state -> Types.symbol list
val moves : state -> Types.move_name list
val is_initial : state -> bool
val is_final : state -> bool
