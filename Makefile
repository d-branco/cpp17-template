NAME			:= a.out

ARGS			=
DEBUG_LEVEL		:= 1

FORMATABLE		= $(HEADERS) $(SRCS) $(TEST_SRCS)
TEST_NAME		:= test_$(NAME)
DEBUG_NAME		:= debug_$(NAME)
ASAN_NAME		:= asan_$(NAME)
SRC_DIR			:= srcs
INC_DIR			:= include
TEST_DIR		:= tests
BUILD_DIR		:= build

DOCTEST_DIR		:= include/external/
DOCTEST_URL		:= https://raw.githubusercontent.com/doctest/doctest/master/doctest/doctest.h

########################################################## Objects and Headers #
HEADERS			= $(shell find $(INC_DIR) -name "*.hpp" 2>/dev/null)
SRCS			= $(shell find $(SRC_DIR) -name "*.cpp" 2>/dev/null)
OBJS			= $(SRCS:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.o)
TEST_SRCS		= $(shell find $(TEST_DIR) -name "*.cpp" 2>/dev/null)
TEST_OBJS		= $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/test_%.o,$(SRCS)) \
			  $(patsubst $(TEST_DIR)/%.cpp,$(BUILD_DIR)/tests/test_%.o,$(TEST_SRCS))
DEBUG_OBJS		= $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/debug_%.o,$(SRCS))
ASAN_OBJS		= $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/asan_%.o,$(SRCS))
##################################################################### Compiler #
CC				:= c++
CFLAGS			+= -std=c++17
CFLAGS			+= -Wall -Wextra
CFLAGS			+= -Werror
CFLAGS			+= -Wshadow -Wnon-virtual-dtor
CFLAGS			+= -Wpedantic
CFLAGS			+= -Wconversion -Wsign-conversion -Wold-style-cast
CFLAGS			+= -Wnull-dereference -Wdouble-promotion -Wformat=2
CFLAGS			+= $(LDFLAGS) $(LDLIBS)

TEST_FLAGS		= $(CFLAGS) -DTESTING

INC_DIRS		:= $(shell find $(INC_DIR) -type d 2>/dev/null)
INCLUDES		:= $(addprefix -I, $(INC_DIRS))
LDFLAGS			:=
LDLIBS			:=


GPROF_FLAGS		+= -pg
CLANG_CHECK		:= $(shell for tool in clang-check clang-check-21 clang-check-20 \
			   clang-check-19 clang-check-18 clang-check-17; do \
			   command -v $$tool 2>/dev/null && break; done)
DEBUG_FLAGS		= $(CFLAGS) -O0
DEBUG_FLAGS		+= -g3
DEBUG_FLAGS		+= -DHARL=$(DEBUG_LEVEL)
DEBUG_STAMP		:= $(BUILD_DIR)/.debug_level
FORCE:
ASAN_FLAGS		= $(CFLAGS)
ASAN_FLAGS		+= -fsanitize=address,undefined -fno-omit-frame-pointer -g3

########################################################### Intermediate steps #
RM				:= rm --force --recursive --verbose
AR				:= ar rcs

###################################################################### Targets #
all: $(NAME)

$(NAME): $(OBJS)
	@\
	echo "$(GRAY)Compiled with:	$(CC) $(RESET)" ; \
	echo "$(GRAY)Compile flags:	$(CFLAGS) $(RESET)" ; \
	echo "$(GRAY)Linking flags:	$(INCLUDES) $(RESET)" ; \
	$(CC) $(OBJS) $(INCLUDES) $(CFLAGS) -o $(NAME)	&&	\
	echo "$(GRAY)File compiled:$(RESET)	./$(NAME)"

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@\
	mkdir -p $(dir $@) ; \
	$(CC) $(INCLUDES) $(CFLAGS) -c $< -o $@	&&	\
	echo "$(GRAY)Obj. compiled:	$<$(RESET)"

$(DEBUG_NAME): $(DEBUG_OBJS)
	@\
	echo "$(GRAY)Compiled with:	$(CC) $(RESET)" ; \
	echo "$(GRAY)Compile flags:	$(DEBUG_FLAGS) $(RESET)" ; \
	echo "$(GRAY)Linking flags:	$(INCLUDES) $(RESET)" ; \
	$(CC) $(DEBUG_FLAGS) $(INCLUDES) $(DEBUG_OBJS) -o $(DEBUG_NAME) &&\
	echo "$(GRAY)File compiled:$(RESET)	./$(DEBUG_NAME)"

$(DEBUG_STAMP): FORCE
	@mkdir -p $(BUILD_DIR)
	@if [ "$$(cat $(DEBUG_STAMP) 2>/dev/null)" != "$(DEBUG_LEVEL)" ]; then \
		echo "$(GRAY)Debug level:$(RESET)	$(DEBUG_LEVEL)"; \
		echo "$(DEBUG_LEVEL)" > $(DEBUG_STAMP); \
		rm -f $(DEBUG_OBJS); \
	fi

$(BUILD_DIR)/debug_%.o: $(SRC_DIR)/%.cpp $(DEBUG_STAMP)
	@\
	mkdir -p $(dir $@) &&\
	$(CC) $(DEBUG_FLAGS) $(INCLUDES) -c $< -o $@ &&\
	echo "$(GRAY)Obj. compiled:	$<$(RESET)"

$(TEST_NAME): $(TEST_OBJS)
	@\
	echo "$(GRAY)Compiled with:	$(CC) $(RESET)" ; \
	echo "$(GRAY)Compile flags:	$(TEST_FLAGS) $(RESET)" ; \
	echo "$(GRAY)Linking flags:	$(INCLUDES) $(RESET)" ; \
	$(CC) $(TEST_FLAGS) $(INCLUDES) $(TEST_OBJS) -o $(TEST_NAME) &&\
	echo "$(GRAY)File compiled:$(RESET)	./$(TEST_NAME)"

$(BUILD_DIR)/test_%.o: $(SRC_DIR)/%.cpp
	@\
	mkdir -p $(dir $@) &&\
	$(CC) $(TEST_FLAGS) $(INCLUDES) -c $< -o $@ &&\
	echo "$(GRAY)Obj. compiled:	$<$(RESET)"

$(BUILD_DIR)/tests/test_%.o: $(TEST_DIR)/%.cpp
	@\
	mkdir -p $(dir $@) &&\
	$(CC) $(TEST_FLAGS) $(INCLUDES) -c $< -o $@ &&\
	echo "$(GRAY)Obj. compiled:	$<$(RESET)"

$(ASAN_NAME): $(ASAN_OBJS)
	@\
	echo "$(GRAY)Compiled with:	$(CC) $(RESET)" ; \
	echo "$(GRAY)Compile flags:	$(ASAN_FLAGS) $(RESET)" ; \
	echo "$(GRAY)Linking flags:	$(INCLUDES) $(RESET)" ; \
	$(CC) $(ASAN_FLAGS) $(INCLUDES) $(ASAN_OBJS) -o $(ASAN_NAME) &&\
	echo "$(GRAY)File compiled:$(RESET)	./$(ASAN_NAME)"

$(BUILD_DIR)/asan_%.o: $(SRC_DIR)/%.cpp
	@\
	mkdir -p $(dir $@) &&\
	$(CC) $(ASAN_FLAGS) $(INCLUDES) -c $< -o $@ &&\
	echo "$(GRAY)Obj. compiled:	$<$(RESET)"

$(BUILD_DIR)/tests/asan_%.o: $(TEST_DIR)/%.cpp
	@\
	mkdir -p $(dir $@) &&\
	$(CC) $(ASAN_FLAGS) $(INCLUDES) -c $< -o $@ &&\
	echo "$(GRAY)Obj. compiled:	$<$(RESET)"

clean:
	@\
	if [ -d $(BUILD_DIR) ]; then \
	rm -rfv  $(BUILD_DIR) | while read line; do \
		file=$$(echo "$$line" | sed "s/.*'\(.*\)'/\1/"); \
		echo "$(GRAY)Objects Clean:  $$file$(RESET)"; \
	done; \
	fi

fclean: clean
	@\
	make clean --silent; \
	for file in $(NAME) $(TEST_NAME) $(DEBUG_NAME) $(ASAN_NAME); do \
		if [ -f $$file ]; then \
			echo "$(GRAY)File fcleaned: $(RESET) $$file"; \
			rm -f $$file; \
		fi; \
	done

re: fclean all
	@echo "$(GRAY)redone$(RESET)"

.PHONY: all clean fclean re hooks clang-check valgrind test run debug asan doctest exe gprof time style check-style fix-style format check-guards clangd init ctest FORCE

####################################################################### Format #
.clang-format:
	@echo "\
	Language: Cpp\n\
	Standard: c++17\n\
	\n\
	AlignConsecutiveDeclarations:\n\
	  Enabled: true\n\
	  AcrossEmptyLines: true\n\
	  AcrossComments: true\n\
	  AlignCompound: true\n\
	  AlignFunctionPointers: false\n\
	  PadOperators: true\n\
	AlignConsecutiveMacros:\n\
	  Enabled: true\n\
	  AcrossEmptyLines: false\n\
	  AcrossComments: false\n\
	  AlignCompound: false\n\
	  PadOperators: true\n\
	AlignAfterOpenBracket: Align\n\
	AlignConsecutiveAssignments: true\n\
	AlignEscapedNewlinesLeft: true\n\
	AllowAllConstructorInitializersOnNextLine: false\n\
	AllowAllParametersOfDeclarationOnNextLine: false\n\
	AllowShortBlocksOnASingleLine: true\n\
	AllowShortIfStatementsOnASingleLine: Never\n\
	AllowShortFunctionsOnASingleLine: None\n\
	AlwaysBreakAfterReturnType: None\n\
	AlwaysBreakBeforeMultilineStrings: false\n\
	BinPackArguments: false\n\
	BinPackParameters: false\n\
	BreakBeforeBraces: Allman\n\
	BreakBeforeBinaryOperators: All\n\
	BreakBeforeTernaryOperators: false\n\
	BreakConstructorInitializers: AfterColon\n\
	PackConstructorInitializers: CurrentLine\n\
	ColumnLimit: 100\n\
	ConstructorInitializerIndentWidth: 4\n\
	IndentPPDirectives: AfterHash\n\
	IndentWidth: 4\n\
	KeepEmptyLinesAtTheStartOfBlocks: false\n\
	MaxEmptyLinesToKeep: 1\n\
	PointerAlignment: Right\n\
	PenaltyBreakBeforeFirstCallParameter: 100\n\
	PenaltyBreakString: 100\n\
	PenaltyExcessCharacter: 1000000\n\
	PPIndentWidth: 1\n\
	RemoveBracesLLVM: false\n\
	SeparateDefinitionBlocks: Always\n\
	SpaceAfterCStyleCast: false\n\
	SpaceBeforeAssignmentOperators: true\n\
	SpaceBeforeParens: ControlStatements\n\
	SpaceInEmptyParentheses: false\n\
	SpacesInCStyleCastParentheses: false\n\
	SpacesInParentheses: false\n\
	SpacesInSquareBrackets: false\n\
	TabWidth: 4\n\
	UseTab: Never\n\
	" > .clang-format

format: check-guards .clang-format
	@\
	for file in $(FORMATABLE); do	\
		if ! clang-format "$$file" | diff -q "$$file" - > /dev/null 2>&1; then \
			clang-format -i "$$file"	&&	\
			echo "$(GRAY)File formated:$(RESET)	$$file"; \
		fi; \
	done

.clang-tidy:
	@\
	echo "\
	Checks: |\n\
	  readability-*,\n\
	  -readability-magic-numbers,\n\
	  -readability-braces-around-statements,\n\
	  bugprone-*,\n\
	  performance-*,\n\
	  clang-analyzer-*,\n\
	  modernize-*,\n\
	  -modernize-use-trailing-return-type,\n\
	  cppcoreguidelines-*,\n\
	  -cppcoreguidelines-avoid-magic-numbers,\n\
	  -cppcoreguidelines-pro-type-member-init,\n\
	  -cppcoreguidelines-avoid-const-or-ref-data-members\n\
	\n\
	CheckOptions:\n\
	  - key:   readability-identifier-naming.ClassCase\n\
	    value: CamelCase\n\
	  - key:   readability-identifier-naming.FunctionCase\n\
	    value: lower_case\n\
	  - key:   readability-identifier-naming.PrivateMemberSuffix\n\
	    value: '_'\n\
	\n\
	HeaderFilterRegex: '^(?!.*include/external/).*'\n\
	" > .clang-tidy

style: .clang-format .clang-tidy
	@\
	clang-format --verbose --dry-run $(FORMATABLE)	; \
	clang-tidy --quiet -extra-arg=-std=c++17 $(SRCS) $(TEST_SRCS)	\
	-- $(CFLAGS) $(INCLUDES)	; \
	make check-guards --silent

check-style: .clang-format .clang-tidy
	@\
	fail=0; \
	echo "$(GRAY)Checking code formatting...$(RESET)"; \
	for file in $(FORMATABLE); do \
		if ! clang-format --dry-run --Werror "$$file" > /dev/null 2>&1; then \
			echo "$(YELLOW)$$file is not formatted correctly$(RESET)"; \
			fail=1; \
		fi; \
	done; \
	echo "$(GRAY)Running clang-tidy...$(RESET)"; \
	clang-tidy --quiet -extra-arg=-std=c++17 $(SRCS) $(TEST_SRCS) -- $(CFLAGS) $(INCLUDES) || fail=1; \
	echo "$(GRAY)Checking header guards...$(RESET)"; \
	make check-guards --silent || fail=1; \
	exit $$fail

fix-style: .clang-tidy format
	@\
	clang-tidy --quiet --fix --use-color --extra-arg=-std=c++17 $(SRCS) $(TEST_SRCS) -- $(CFLAGS) $(INCLUDES)	; \
	make check-guards --silent ;\
	make format --silent

check-guards:
	@fail=0	; \
	for file in $$(find $(INC_DIR) -name "*.hpp" 2>/dev/null); do \
		filename=$$(basename $$file)	; \
		guard=$$(echo $$filename | tr 'a-z' 'A-Z' | sed 's/\./_/g')	; \
		if ! grep -q "#ifndef $$guard" $$file\
			|| ! grep -q "#define $$guard" $$file; then \
			echo "$(YELLOW)$$file  is missing header guard:$(RESET)\
	\n#ifndef $$guard\n#define $$guard\n\n#endif // $$guard"	; \
			fail=1	; \
		fi	; \
	done; \
	exit $$fail

clang-check:
	@\
	if [ -z "$(CLANG_CHECK)" ]; then \
		echo "$(YELLOW)clang-check not found in PATH$(RESET)"; \
		exit 1; \
	fi; \
	$(CLANG_CHECK) --analyze $(FORMATABLE) -- $(CFLAGS) $(INCLUDES)	; \
	rm -f *.plist

.clangd: .clang-format .clang-tidy
	@\
	echo "\
	CompileFlags:\n\
	  Add: [-std=c++17, -pedantic, -Wall, -Wextra, -Werror, -I../include, -Iinclude]\n\
	Diagnostics:\n\
	  UnusedIncludes: None\n\
	---\n\
	If:\n\
	  PathMatch: include/external/doctest.h\n\
	Diagnostics:\n\
	  Suppress: \"*\"\n\
	Index:\n\
	  Background: Skip\n\
	\n\
	" > .clangd

init: .clang-format .clang-tidy .clangd
	@mkdir -p $(DOCTEST_DIR) && curl -fsSL $(DOCTEST_URL) -o $(DOCTEST_DIR)/doctest.h
	@bash .scripts/install-git-hooks.sh

############################################################# ANSI Escape Code #
RESET			:= \033[0m

PURPLE		:= \033[1;35m
GRAY		:= \033[1;90m
YELLOW		:= \033[1;93m
BLUE		:= \033[1;96m
GREEN		:= \033[32m
ORANGE		:= \033[33m

BG_GREEN	:= \033[1;30m\033[102m
BG_RED		:= \033[1;30m\033[101m

######################################################################### Time #
time: $(NAME)
	@\
	echo "$(GRAY)Executing arg:$(RESET)	time ./$(NAME) $(ARGS)"	; \
	trap '' INT TERM	; \
	$(TIMED_RUN) ./$(NAME) $(ARGS)	; \
	RET=$$?	; \
	trap - INT TERM	; \
	exit $$RET

define TIMED_RUN
time --quiet --format "==CRONO== Total time: %E "
endef

##################################################################### Valgrind #
valgrind: $(NAME)
	@\
	echo "$(GRAY)Executing arg:$(RESET)	time valgrind ./$(NAME) $(ARGS)"	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(NAME) VALGRIND$(RESET)"	; \
	trap '' INT TERM	; \
	$(TIMED_RUN) $(VALGRIND_CMD) ./$(NAME) $(ARGS)	; \
	RET=$$?	; \
	trap - INT TERM	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(NAME) VALGRIND$(RESET)"	; \
	echo "$(RESET)$(GRAY)Return value:$(RESET) $$RET"	; \
	exit $$RET

VALGRIND_CMD = valgrind \
	--track-fds=yes \
	--show-error-list=yes \
	--leak-check=full \
	--show-leak-kinds=all \
	--track-origins=yes \
	--max-stackframe=4200000 \
	--quiet --show-error-list=yes

######################################################################### Test #
test: format $(NAME) $(TEST_NAME) $(DEBUG_NAME) $(ASAN_NAME)
	@\
	echo "$(GRAY)Executing arg:$(RESET)	./$(TEST_NAME) $(TEST_ARGS)"	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(TEST_NAME) DOCTEST START$(RESET)"	; \
	trap '' INT TERM	; \
	./$(TEST_NAME) $(TEST_ARGS)	; \
	RET1=$$?	; \
	trap - INT TERM	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(TEST_NAME) DOCTEST END$(RESET)"	; \
	\
	echo "$(GRAY)Executing arg:$(RESET)	time ./$(DEBUG_NAME) $(TEST_ARGS)"	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(DEBUG_NAME) DEBUG START$(RESET)"	; \
	trap '' INT TERM	; \
	$(TIMED_RUN) ./$(DEBUG_NAME) $(TEST_ARGS)	; \
	RET2=$$?	; \
	trap - INT TERM	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(DEBUG_NAME) DEBUG END$(RESET)"	; \
	\
	echo "$(GRAY)Executing arg:$(RESET)	time valgrind ./$(NAME) $(TEST_ARGS)"	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(NAME) VALGRIND START$(RESET)"	; \
	trap '' INT TERM	; \
	$(TIMED_RUN) $(VALGRIND_CMD) --error-exitcode=1 ./$(NAME) $(TEST_ARGS)	; \
	RET3=$$?	; \
	trap - INT TERM	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(NAME) VALGRIND END$(RESET)"	; \
	\
	echo "$(GRAY)Executing arg:$(RESET)	./$(ASAN_NAME) $(TEST_ARGS)"	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(ASAN_NAME) ASAN START$(RESET)"	; \
	trap '' INT TERM	; \
	./$(ASAN_NAME) $(TEST_ARGS)	; \
	RET4=$$?	; \
	trap - INT TERM	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(ASAN_NAME) ASAN END$(RESET)"	; \
	\
	echo "$(RESET)$(GRAY)Return value:$(RESET)  DOCTEST: $$RET1"	; \
	echo "$(RESET)$(GRAY)Return value:$(RESET)    DEBUG: $$RET2"	; \
	echo "$(RESET)$(GRAY)Return value:$(RESET) VALGRIND: $$RET3"	; \
	echo "$(RESET)$(GRAY)Return value:$(RESET)     ASAN: $$RET4"	; \
	SUM=$$((RET1 + RET2 + RET3 + RET4))	; \
	if [ $$SUM -eq 0 ]; then \
		echo "$(BG_GREEN) $(RESET) $(GRAY)ALL PASSED$(RESET)"; \
		exit 0; \
	fi; \
	echo "$(BG_RED) $(RESET) $(GRAY)FAILURES DETECTED$(RESET)"

ctest: fclean test

doctest: format $(TEST_NAME)
	@\
	echo '$(GRAY)Executing arg:$(RESET)	./$(TEST_NAME) $(TEST_ARGS)'	; \
	trap '' INT TERM	; \
	./$(TEST_NAME) $(TEST_ARGS)	; \
	RET=$$?	; \
	trap - INT TERM	; \
	echo "$(RESET)$(GRAY)Return value:$(RESET) DOCTEST: $$RET"	; \
	exit $$RET

asan: format $(ASAN_NAME)
	@\
	echo "$(GRAY)Executing arg:$(RESET)	./$(ASAN_NAME) $(TEST_ARGS)"	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(ASAN_NAME) ASAN START$(RESET)"	; \
	trap '' INT TERM	; \
	./$(ASAN_NAME) $(TEST_ARGS)	; \
	RET=$$?	; \
	trap - INT TERM	; \
	echo "$(RESET)$(GRAY)=========================================="\
	" $(ASAN_NAME) ASAN END$(RESET)"	; \
	echo "$(RESET)$(GRAY)Return value:$(RESET) ASAN: $$RET"	; \
	exit $$RET

exe: format $(NAME)
	@\
	echo '$(GRAY)Executing arg:$(RESET)	time ./$(NAME) $(ARGS)'	; \
	trap '' INT TERM	; \
	$(TIMED_RUN) ./$(NAME) $(ARGS)	; \
	RET=$$?	; \
	trap - INT TERM	; \
	exit $$RET

run: $(NAME)
	@\
	echo '$(GRAY)Executing arg:$(RESET)	./$(NAME) $(ARGS)'	; \
	trap '' INT TERM	; \
	./$(NAME) $(ARGS)	; \
	RET=$$?	; \
	trap - INT TERM	; \
	exit $$RET

debug: format $(DEBUG_NAME)
	@\
	echo '$(GRAY)Executing arg:$(RESET)	time ./$(DEBUG_NAME) $(ARGS)'	; \
	trap '' INT TERM	; \
	$(TIMED_RUN) ./$(DEBUG_NAME) $(ARGS)	; \
	RET=$$?	; \
	trap - INT TERM	; \
	exit $$RET

gprof: CFLAGS += $(GPROF_FLAGS)
gprof: fclean $(NAME)
	@\
	echo '$(GRAY)Executing arg:$(RESET)	gprof ./$(NAME)'	; \
	trap '' INT TERM	; \
	./$(NAME) $(ARGS)	; \
	trap - INT TERM
	gprof $(NAME) gmon.out > gmon-ignoreme.txt	; \
	cat gmon-ignoreme.txt	; \
	rm -f gmon-ignoreme.txt gmon.out
