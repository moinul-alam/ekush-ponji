@echo off
:: Get current directory name
for %%I in (.) do set CurrDir=%%~nxI

:: Create tree structure and save to text file
tree /F > "%CurrDir%_structure.txt"

echo Directory structure saved to %CurrDir%_structure.txt
pause
