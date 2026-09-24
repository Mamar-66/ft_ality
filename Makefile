NAME = ft_ality
CC = ocamlopt

SRC_DIR = src
OBJ_DIR = obj

CFLAGS = -w +A-4-42-44-45-70 -I $(OBJ_DIR)

SRCS = $(SRC_DIR)/Types.ml \
       $(SRC_DIR)/Parser.ml \
       $(SRC_DIR)/Automaton.ml \
       $(SRC_DIR)/Main.ml

OBJS = $(patsubst $(SRC_DIR)/%.ml, $(OBJ_DIR)/%.cmx, $(SRCS))

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJS)

$(OBJ_DIR)/%.cmx: $(SRC_DIR)/%.ml | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re