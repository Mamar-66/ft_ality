type symbol = string

type move_name = string

type rule = {
  keys : symbol list;
  name : move_name;
}

type key =
  | Byte of char
  | Up
  | Down
  | Left
  | Right
