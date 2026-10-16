type context = {
  automaton : Automaton.t;
  keymap : Keymap.t;
  debug : bool;
}

let separator = "----------------------"

let print_mapping keymap =
  print_endline "Key mappings:";
  List.iter
    (fun (key, symbol) ->
       print_endline (Keymap.key_to_string key ^ " -> " ^ symbol))
    (Keymap.bindings keymap);
  print_endline separator

let print_debug_step from symbol target =
  let id state = string_of_int (Automaton.id state) in
  print_endline
    ("State " ^ id from ^ ", \"" ^ symbol ^ "\" -> State " ^ id target);
  if Automaton.is_final target then
    List.iter
      (fun move ->
         print_endline ("Found end state for \"" ^ move ^ "\" at: " ^ id target))
      (Automaton.moves target)
  else print_endline ("State " ^ id target ^ " is not an end state")

let print_result symbol state =
  if Automaton.is_initial state then
    print_endline (symbol ^ "   (no combo goes on with this key, input reset)")
  else begin
    print_endline (String.concat ", " (Automaton.word state));
    List.iter (fun move -> print_endline (move ^ " !!")) (Automaton.moves state)
  end;
  print_newline ()

let on_symbol ctx state symbol =
  let target = Automaton.step ctx.automaton state symbol in
  if ctx.debug then print_debug_step state symbol target;
  print_result symbol target;
  target

let on_unmapped ctx description =
  if ctx.debug then print_endline "Back to State 0";
  print_endline (description ^ "   (not mapped, input reset)");
  print_newline ();
  Automaton.initial ctx.automaton

let rec run ctx state reader =
  match Terminal.next reader with
  | (Terminal.Quit, _) -> print_endline "Bye!"
  | (Terminal.Unknown description, reader) ->
      run ctx (on_unmapped ctx description) reader
  | (Terminal.Key key, reader) ->
      match Keymap.symbol_of_key ctx.keymap key with
      | Some symbol -> run ctx (on_symbol ctx state symbol) reader
      | None -> run ctx (on_unmapped ctx (Keymap.key_to_string key)) reader

let train filename =
  match Parser.fold_file Automaton.add_rule Automaton.empty filename with
  | Ok automaton when Automaton.rule_count automaton = 0 ->
      Error (filename ^ ": no rule found in the grammar")
  | result -> result

let start ctx =
  print_mapping ctx.keymap;
  if ctx.debug then
    print_endline ("Debug mode: " ^ string_of_int (Automaton.rule_count ctx.automaton)
                   ^ " rules, " ^ string_of_int (Automaton.state_count ctx.automaton)
                   ^ " states. Initial state: 0");
  if Terminal.enable_raw_mode () then
    print_endline "Press the mapped keys. Ctrl-D or Ctrl-C to quit.";
  print_newline ();
  run ctx (Automaton.initial ctx.automaton) Terminal.reader

let fail message =
  prerr_endline ("ft_ality: " ^ message);
  exit 1

let main filename debug =
  match train filename with
  | Error message -> fail message
  | Ok automaton ->
      match Keymap.build (Automaton.alphabet automaton) with
      | Error message -> fail message
      | Ok keymap ->
          start { automaton = automaton; keymap = keymap; debug = debug }

let parse_args = function
  | [| _; ("-d" | "--debug"); file |] | [| _; file; ("-d" | "--debug") |] ->
      Some (file, true)
  | [| _; file |] -> Some (file, false)
  | _ -> None

let () =
  match parse_args Sys.argv with
  | Some (file, debug) when file <> "" && file.[0] <> '-' -> main file debug
  | _ ->
      prerr_endline "Usage: ./ft_ality [-d | --debug] <grammar_file>";
      exit 1
