NAME     = ft_ality

OCAMLOPT = ocamlopt
FLAGS    = -w +A-4-42-44-45-70 -I $(OBJ_DIR)

SRC_DIR  = src
OBJ_DIR  = obj

MODULES  = Types Parser Keymap Automaton Terminal Main
CMX      = $(MODULES:%=$(OBJ_DIR)/%.cmx)

all: $(NAME)

$(NAME): $(CMX)
	$(OCAMLOPT) $(FLAGS) -o $(NAME) $(CMX)

$(OBJ_DIR)/%.cmi: $(SRC_DIR)/%.mli | $(OBJ_DIR)
	$(OCAMLOPT) $(FLAGS) -c -o $@ $<

$(OBJ_DIR)/%.cmx: $(SRC_DIR)/%.ml | $(OBJ_DIR)
	$(OCAMLOPT) $(FLAGS) -c -o $@ $<

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/Parser.cmi $(OBJ_DIR)/Keymap.cmi \
$(OBJ_DIR)/Automaton.cmi $(OBJ_DIR)/Terminal.cmi: $(OBJ_DIR)/Types.cmx
$(OBJ_DIR)/Parser.cmx: $(OBJ_DIR)/Parser.cmi
$(OBJ_DIR)/Keymap.cmx: $(OBJ_DIR)/Keymap.cmi
$(OBJ_DIR)/Automaton.cmx: $(OBJ_DIR)/Automaton.cmi
$(OBJ_DIR)/Terminal.cmx: $(OBJ_DIR)/Terminal.cmi
$(OBJ_DIR)/Main.cmx: $(OBJ_DIR)/Parser.cmx $(OBJ_DIR)/Keymap.cmx \
                     $(OBJ_DIR)/Automaton.cmx $(OBJ_DIR)/Terminal.cmx

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME)

re: fclean
	$(MAKE) all

.PHONY: all clean fclean re
