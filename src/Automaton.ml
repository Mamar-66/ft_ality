type state = {
  id : int;
  word : Types.symbol list;
  moves : Types.move_name list;
  next : (Types.symbol * state) list;
}

type t = {
  root : state;
  states : int;
  rules : int;
  alphabet : Types.symbol list;
}

let new_state id word = { id = id; word = word; moves = []; next = [] }

let empty = { root = new_state 0 []; states = 1; rules = 0; alphabet = [] }

let rec insert node keys name next_id =
  match keys with
  | [] when List.mem name node.moves -> (node, next_id)
  | [] -> ({ node with moves = node.moves @ [ name ] }, next_id)
  | key :: rest ->
      let (child, next_id) =
        match List.assoc_opt key node.next with
        | Some child -> (child, next_id)
        | None -> (new_state next_id (node.word @ [ key ]), next_id + 1)
      in
      let (child, next_id) = insert child rest name next_id in
      ({ node with next = (key, child) :: List.remove_assoc key node.next },
       next_id)

let add_rule automaton rule =
  let add_symbol alphabet key =
    if List.mem key alphabet then alphabet else key :: alphabet
  in
  let (root, states) =
    insert automaton.root rule.Types.keys rule.Types.name automaton.states
  in
  { root = root;
    states = states;
    rules = automaton.rules + 1;
    alphabet = List.fold_left add_symbol automaton.alphabet rule.Types.keys }

let rule_count automaton = automaton.rules
let state_count automaton = automaton.states
let alphabet automaton = List.sort compare automaton.alphabet
let initial automaton = automaton.root

let step automaton state symbol =
  let rec walk node = function
    | [] -> Some node
    | key :: rest ->
        match List.assoc_opt key node.next with
        | Some child -> walk child rest
        | None -> None
  in
  let rec longest_suffix = function
    | [] -> automaton.root
    | (_ :: shorter) as suffix ->
        match walk automaton.root suffix with
        | Some node -> node
        | None -> longest_suffix shorter
  in
  match List.assoc_opt symbol state.next with
  | Some child -> child
  | None -> longest_suffix (state.word @ [ symbol ])

let id state = state.id
let word state = state.word
let moves state = state.moves
let is_initial state = state.word = []
let is_final state = state.moves <> []
