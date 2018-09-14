c:\GnuWin32\bin\bison -dyv sintactico.y
c:\GnuWin32\bin\flex lexico.l
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o primera.exe

echo Ejecutando prueba.txt
primera.exe prueba.txt
pause

del y.tab.c y.tab.h y.output lex.yy.c primera.exe
