# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.9

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/build

# Include any dependencies generated for this target.
include CMakeFiles/trs2bin.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/trs2bin.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/trs2bin.dir/flags.make

CMakeFiles/trs2bin.dir/trs2bin.c.o: CMakeFiles/trs2bin.dir/flags.make
CMakeFiles/trs2bin.dir/trs2bin.c.o: ../trs2bin.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/trs2bin.dir/trs2bin.c.o"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/trs2bin.dir/trs2bin.c.o   -c /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/trs2bin.c

CMakeFiles/trs2bin.dir/trs2bin.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/trs2bin.dir/trs2bin.c.i"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/trs2bin.c > CMakeFiles/trs2bin.dir/trs2bin.c.i

CMakeFiles/trs2bin.dir/trs2bin.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/trs2bin.dir/trs2bin.c.s"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/trs2bin.c -o CMakeFiles/trs2bin.dir/trs2bin.c.s

CMakeFiles/trs2bin.dir/trs2bin.c.o.requires:

.PHONY : CMakeFiles/trs2bin.dir/trs2bin.c.o.requires

CMakeFiles/trs2bin.dir/trs2bin.c.o.provides: CMakeFiles/trs2bin.dir/trs2bin.c.o.requires
	$(MAKE) -f CMakeFiles/trs2bin.dir/build.make CMakeFiles/trs2bin.dir/trs2bin.c.o.provides.build
.PHONY : CMakeFiles/trs2bin.dir/trs2bin.c.o.provides

CMakeFiles/trs2bin.dir/trs2bin.c.o.provides.build: CMakeFiles/trs2bin.dir/trs2bin.c.o


# Object files for target trs2bin
trs2bin_OBJECTS = \
"CMakeFiles/trs2bin.dir/trs2bin.c.o"

# External object files for target trs2bin
trs2bin_EXTERNAL_OBJECTS =

trs2bin: CMakeFiles/trs2bin.dir/trs2bin.c.o
trs2bin: CMakeFiles/trs2bin.dir/build.make
trs2bin: CMakeFiles/trs2bin.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable trs2bin"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/trs2bin.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/trs2bin.dir/build: trs2bin

.PHONY : CMakeFiles/trs2bin.dir/build

CMakeFiles/trs2bin.dir/requires: CMakeFiles/trs2bin.dir/trs2bin.c.o.requires

.PHONY : CMakeFiles/trs2bin.dir/requires

CMakeFiles/trs2bin.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/trs2bin.dir/cmake_clean.cmake
.PHONY : CMakeFiles/trs2bin.dir/clean

CMakeFiles/trs2bin.dir/depend:
	cd /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/build /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/build /home/pbetti/elettronica/Z80-CPM/hardware/Z80DarkStar/software/NE-DOS/trs2bin/build/CMakeFiles/trs2bin.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/trs2bin.dir/depend

