#! /bin/bash

# export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

g++ -v -ggdb -fdiagnostics-color=always -std=c++17 -Wall -Wextra -pedantic fs_test.cpp -o fstest
