#!/bin/bash

mkdir -p src include

if [ -z "$BIN_DIR" ]; then BIN_DIR="bin"; fi
if [ -z "$BUILD_DIR" ]; then BUILD_DIR="build"; fi

function autobuild {
	LIST_FILE="src/$1/targets.txt"
	export CC_MODULE_DIR="$1"
	rm -f "$LIST_FILE" || return 1
	SOURCES="$(find "src/$1" -regex "src/$1/.*\.cpp" -type f)" || return 1
	echo "$SOURCES" | while read SOURCE; do
		mkdir -p "${BUILD_DIR}/$1" || return 1
		# transform the source-file string to its related target
		TARGET="$(echo "$SOURCE" \
			| sed "s|.cpp\$|.o|" \
			| sed "s|^src|${BUILD_DIR}|" )"
		# if the target is older than the source file (or if it doesn't exist),
		# add it to the list of targets.
		if [ "$SOURCE" -nt "$TARGET" ]; then
			printf "%q\n" "$TARGET" >>"$LIST_FILE" || return 1
			echo "Using target \"$TARGET\""
		elif [ -n "$TARGET" ]; then
			echo "Ignoring up-to-date target \"$TARGET\""
		fi
	done
	# if the targets file exists, make 'em.
	if [ -f "$LIST_FILE" ]; then
		make -j"$JOBS_COUNT" $(cat "$LIST_FILE") || return 1
	fi
	# if the main object file exists and has been updated, link the module
	if [ -f "${BUILD_DIR}/$1/main.o" -a "${BUILD_DIR}/$1/main.o" -nt "${BIN_DIR}/$1" ]; then
		mkdir -p "${BIN_DIR}" || return 1
		make -j"$JOBS_COUNT" "${BIN_DIR}/$1"
	fi
}

if [ -z "$1" ]; then
	echo -e "\e[1;91mNo module specified: each directory in src/ is a module.\e[m" 1>&2
elif [ ! -d "src/$1" ]; then
	mkdir -p "src/$1" && touch "src/$1/build.sh" \
		&& echo -e "\e[1;91mCould not find module \"$1\", creating an empty one.\e[m" 1>&2 \
		|| (echo -e "\e[1;91mCould not find module \"$1\"; failed to create an empty one.\e[m" 1>&2 && exit 1)
else
	while [ -n "$1" ]; do
		# run the "build.sh" file to set additional environment variables,
		# and run customized commands before building the module.
		if [ -f "src/$1/build.sh" ]; then
			. "src/$1/build.sh" $@ || exit 1
		else
			touch "src/$1/build.sh"
		fi
		if [ -f "src/$1/makefile" ]; then
			make -f "src/$1/makefile" || exit 1
		else
			autobuild "$1" || exit 1
		fi
		shift 1
	done
fi

