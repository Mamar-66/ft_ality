let empty_node id : Types.node = {
  Types.id = id;
  moves = [];
  transitions = [];
}

let empty_automaton : Types.automaton = {
  Types.nextId = 1;
  nodes = [(0, empty_node 0)];
  currentState = 0;
}

let get_node aut id : Types.node =
  match Parser.find_opt id aut.Types.nodes with
  | Some n -> n
  | None -> empty_node id

let update_node aut node =
  let filtered = List.filter (fun (k, _) -> k <> node.Types.id) aut.Types.nodes in
  { aut with Types.nodes = (node.Types.id, node) :: filtered }

let rec add_rule_rec aut current_id symbols move =
  let current_node = get_node aut current_id in
  match symbols with
  | [] ->
      let new_node = { current_node with Types.moves = current_node.Types.moves @ [move] } in
      update_node aut new_node
  | sym :: rest ->
      match Parser.find_opt sym current_node.Types.transitions with
      | Some next_id ->
          add_rule_rec aut next_id rest move
      | None ->
          let new_id = aut.Types.nextId in
          let aut_with_new = { 
            aut with 
            Types.nextId = new_id + 1; 
            Types.nodes = (new_id, empty_node new_id) :: aut.Types.nodes 
          } in
          let updated_current = { 
            current_node with 
            Types.transitions = (sym, new_id) :: current_node.Types.transitions 
          } in
          let aut_updated = update_node aut_with_new updated_current in
          add_rule_rec aut_updated new_id rest move

let add_rule aut (symbols, move) =
  add_rule_rec aut 0 symbols move

let rec print_debug_end_states moves id =
  match moves with
  | [] -> ()
  | m :: t ->
      print_endline ("Found end state for \"" ^ m ^ "\" at: " ^ string_of_int id);
      print_debug_end_states t id

let step aut sym debug =
  let current_id = aut.Types.currentState in
  let current_node = get_node aut current_id in
  match Parser.find_opt sym current_node.Types.transitions with
  | Some next_id ->
      if debug then begin
        print_endline ("State " ^ string_of_int current_id ^ ", \"" ^ sym ^ "\" -> State " ^ string_of_int next_id);
        let next_node = get_node aut next_id in
        print_debug_end_states next_node.Types.moves next_id
      end;
      { aut with Types.currentState = next_id }
  | None ->
      let root_node = get_node aut 0 in
      match Parser.find_opt sym root_node.Types.transitions with
      | Some next_id ->
          if debug then begin
            print_endline ("State 0, \"" ^ sym ^ "\" -> State " ^ string_of_int next_id);
            let next_node = get_node aut next_id in
            print_debug_end_states next_node.Types.moves next_id
          end;
          { aut with Types.currentState = next_id }
      | None ->
          if debug then print_endline ("No transition for \"" ^ sym ^ "\" (reset to state 0)");
          { aut with Types.currentState = 0 }