OS LOG

Created by Rew1l

Thx PatapSmile for game "wsg"

This is os that can only run binary programs (with org 100h) from disk where it have been installed.

Program "filetrans" is for transfer programms or files from other filesystem to LOG OS filesystem. Usage: filetrans <dist> <file>

Program "cdisk" is just for creating void file for transfer in it files of OS and other. Usage: cdisk

Makefile functions:

    "make" for compile all

    "make clean" for clean bin/binExt directories

    "make run" for run qemu with disk from ./bin/

OS was tested in qemu-system-i386.