@echo off
tree /F /A "%~dp0..\lib" > "%~dp0lib_structure.txt"
notepad "%~dp0lib_structure.txt"