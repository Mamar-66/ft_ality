let rec print_mapping mapping =
  match mapping with
  | [] -> print_endline "----------------------"
  | (key, sym) :: t ->
      print_endline (key ^ " -> " ^ sym);
      print_mapping t

let rec print_moves moves =
  match moves with
  | [] -> ()
  | m :: t ->
      print_endline (m ^ " !!");
      print_moves t

let rec repl aut mapping debug =
  print_string "> ";
  flush stdout;
  match try Some (read_line ()) with End_of_file -> None with
  | None -> ()
  | Some input ->
      let input_trim = String.trim input in
      if input_trim = "exit" then ()
      else
        let actual_sym = match Parser.find_opt input_trim mapping with
          | Some sym -> sym
          | None -> input_trim
        in
        
        let new_aut = Automaton.step aut actual_sym debug in
        let current_node = Automaton.get_node new_aut new_aut.Types.currentState in
        
        if current_node.Types.moves <> [] then begin
          print_moves current_node.Types.moves
        end;
        
        repl new_aut mapping debug

let parse_args args =
  let rec aux ls filename debug =
    match ls with
    | [] -> (filename, debug)
    | ("-d" | "--debug") :: t -> aux t filename true
    | arg :: t ->
        if String.length arg > 0 && String.get arg 0 = '-' then
          (None, false)
        else match filename with
          | None -> aux t (Some arg) debug
          | Some _ -> (None, false)
  in
  aux args None false

let () =
  let args = List.tl (Array.to_list Sys.argv) in
  let (filename_opt, debug) = parse_args args in
  match filename_opt with
  | Some filename ->
      begin try
        let rules = Parser.parse_file filename in
        let trained_aut = List.fold_left Automaton.add_rule Automaton.empty_automaton rules in
        let unique_symbols = Parser.get_unique_symbols rules [] in
        let mapping = Parser.generate_mapping unique_symbols in
        
        print_endline "Key mappings:";
        print_mapping mapping;
        
        repl trained_aut mapping debug
      with
      | Sys_error msg ->
          prerr_endline ("Error: " ^ msg);
          exit 1
      | _ ->
          prerr_endline "Error: Failed to parse grammar file.";
          exit 1
      end
      
  | None ->
      prerr_endline "Usage: ./ft_ality [-d|--debug] <grammar_file.gmr>";
      exit 1