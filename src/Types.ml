type symbol = string
type moveName = string
type stateId = int

type transition = symbol * stateId

type node = {
  id : stateId;
  moves : moveName list;
  transitions : transition list;
}

type automaton = {
  nextId : stateId;
  nodes : (stateId * node) list;
  currentState : stateId;
}