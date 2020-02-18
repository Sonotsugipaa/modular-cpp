CPPC=g++ -std=c++17
CC=gcc -std=c99
CC_WARN=-Wpedantic -Wall -Wextra
CC_COMPILE=-c -o
CC_LINK=-o
CC_INCLUDE_PATH=-Iinclude
CC_LIB_PATH=-Llib

# The following variables need to be set (or unset) externally:
#    CC_PROFILE  (use release or debug flags)
#    CC_COMPILE_OPTIONS  (compile-time options)
#    CC_LINK_OPTIONS  (link-time options)
#    CC_MODULE_DIR  (path to the module, excluding the last path separator)
#    CC_MODULE_OBJECTS  (all objects in the module)



.PRECIOUS: build/%.o



build/%.o: src/%.cpp
	@echo "Compiling \"$@\""
	@$(CPPC) $(CC_WARN) $(CC_PROFILE) $(CC_INCLUDE_PATH) \
		-I"${CC_MODULE_DIR}" \
		$(CC_COMPILE_OPTIONS) $(CC_COMPILE) "$@" "$<"

build/%.o: src/%.c
	@echo "Compiling \"$@\""
	@$(CPPC) $(CC_WARN) $(CC_PROFILE) $(CC_INCLUDE_PATH) \
		-I"${CC_MODULE_DIR}" \
		$(CC_COMPILE_OPTIONS) $(CC_COMPILE) "$@" "$<"



# g++ can link C compiled objects, but gcc cannot link C++ compiled objects
# without explicitly linking the C++ STL;
# main files *must* be written in C++.
bin/%: build/%/main.o
	@echo "Linking \"$@\""
	@$(CPPC) $(CC_WARN) $(CC_PROFILE) $(CC_INCLUDE_PATH) \
		-I"${CC_MODULE_DIR}" \
		$(CC_LIB_PATH) $(CC_LINK_OPTIONS) \
		$(CC_LINK) "$@" "$<" $(shell find build/ -name '*.o' -not -name 'main.o')
