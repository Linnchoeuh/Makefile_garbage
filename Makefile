NAME = dsh
CC = gcc
SRC = $(shell find ./ -name "*.c")
OBJ = $(SRC:.c=.o)
INCLUDE = ./include

#FLAGS
CFLAG = -g3 -std=c11
ERRFLAG = -Wextra -Wall -Werror

#LIBRARY VARIABLE
LIBPATH = lib/
LIBFLAG = -L $(LIBPATH) -lprinto -lterminal

#DON'T TOUCH
ECHO = /bin/echo -e
LIBSDIRECTORIES = $(shell find $(LIBPATH)*/ -maxdepth 0 -type d -printf "$(LIBPATH)%f ")

DEFLT	=	"\033[00m"
PINK	=	"\033[0;36m"
GREEN	=	"\033[1;32m"
TEAL	=	"\033[1;36m"
RED		=	"\033[0;31m"
BLUE	=	"\033[34m"
BLINK 	= 	"\033[1;92m"
SBLINK	= 	"\033[0m"
INVERT  =	"\033[7m"

all:$(NAME)

%.o : %.c
	@if [ "$(findstring $(LIBPATH),$@)" != $(LIBPATH) ]; then \
	$(CC) -o $@ -c $< -I$(INCLUDE) $(CFLAG) $(ERRFLAG) $(LIBFLAG) && \
	$(ECHO) $(BLINK) "[OK]"$(SBLINK) $(PINK) $< $(DEFLT) || \
	$(ECHO) $(RED) "[KO]" $(PINK) $< $(DEFLT); fi;

$(NAME):$(OBJ)
	@ $(CC) $(shell find ./ -name "*.o") -o $(NAME) \
	-I$(INCLUDE) $(CFLAG) $(ERRFLAG) $(LIBFLAG) && \
	$(ECHO) $(BLINK) "[OK]"$(SBLINK) $(PINK) $(NAME) $(DEFLT) || \
	$(ECHO) $(RED) "[KO]" $(TEAL) $(NAME) $(DEFLT) \
	It may doesn't work because you didn't compile libs, then try : make lib

clean:
	@ find -name "*.o" -delete && find -name "*~" -delete && \
	$(ECHO) $(BLINK) "[CLEAN SUCCESS]" $(DEFLT)

fclean:
	@find . -name "*.o" -not -path "./$(LIBPATH)*" -delete \
			-name "*.a" -not -path "./$(LIBPATH)*" -delete \
			-or -name "*.exe" -delete \
        	-or -name "a.out" -delete \
			-or -name "*.so" -delete  \
        	-or -name "*~" -delete \
			-or -name "vgcore*" -delete
	@$(ECHO) $(GREEN) "All temporal file deleted!" $(DEFLT)
	@find -name $(NAME) -delete
	@$(ECHO) $(GREEN) "Executable deleted!" $(DEFLT)

re: 		fclean all

install:	all
	@sudo mv $(NAME) /usr/bin/
	@$(ECHO) $(GREEN) "Program installed!" $(DEFLT)

uninstall:
	@sudo rm -i /usr/bin/$(NAME)
	@$(ECHO) $(GREEN) "Program deleted!" $(DEFLT)


lib: FORCE
	@for path in $(LIBSDIRECTORIES); do \
		$(ECHO) $(BLINK)$(BLUE)" [COMPILING LIBRARY : $$path]"$(DEFLT); \
		cd $$path && make re && mv *.a ../ && \
		cp $(INCLUDE)/*.h ../../include && cd ../../; \
	done

libclean:
	@rm -f $(LIBPATH)*.a
	@$(ECHO) $(GREEN) "[.a static libraries files deleted.]" $(DEFLT)
	@for path in $(LIBSDIRECTORIES); do \
		$(ECHO) $(BLINK)$(BLUE)" [CLEANING LIBRARY : $$path]"$(DEFLT); \
		cd $$path && make fclean && cd ../../; \
	done

libupdate:
	@for path in $(LIBSDIRECTORIES); do \
		$(ECHO) $(BLINK)$(BLUE)" [CHECKING UPDATE OF : $$path]"$(DEFLT); \
		cd $$path && git pull && cd ../../; \
	done
	@make lib

FORCE: