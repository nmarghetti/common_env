#! /bin/sh

gcc -v -ggdb -fdiagnostics-color=always -std=c18 -Wall -Wextra -pedantic test.c -o hello
