%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include "y.tab.h"
%}

%option noyywrap
%option yylineno

DIGITO			[0-9]
LETRA			[a-zA-Z]
ID				{LETRA}{DIGITO}({LETRA}|{DIGITO}|_)*

ENTERO			-?{DIGITO}+
REAL			-?{DIGITO}*"."{DIGITO}*|0
CADENA			["]([^"]|\\.)*["]

ABRIR			"-/"
CERRAR			"/-"
CONTENIDO		[a-zA-Z0-9 ]*
COMENTARIO 		{ABRIR}{CONTENIDO}{CERRAR}		

%%
{COMENTARIO} 	{;}
{ID}			{strcpy(yylval.s, yytext);return ID;}

">"				{return MAYOR;}
">="			{return MAYOR_IGUAL;}
"<"				{return MENOR;}
"<="			{return MENOR_IGUAL;}
"=="			{return IGUAL;}
"!="			{return DISTINTO;}

"&&"			{return AND;}
"||"			{return OR;}

":="			{return ASIG;}
"+"				{return SUMA;}
"-"				{return RESTA;}
"*"				{return MUL;}	
"/"				{return DIV;}	

"("				{return P_A;}	
")"				{return P_C;}
"["				{return PA_A;}
"]"				{return PA_C;}
"{"				{return LL_A;}	
"}"				{return LL_C;}

":"				{return DP;}
";"				{return P_Y_C;}
","				{return COMA;}

DEFVAR			{return DEFVAR;}
ENDDEF			{return ENDDEF;}

{ENTERO}		{return ENTERO;}
{REAL}			{return REAL;}
{CADENA}		{return CADENA;}

int				{return INT;}
float			{return FLOAT;}
string			{return STRING;}

if				{return IF;}
else			{return ELSE;}
while			{return WHILE;}

AVG				{return AVG;}

%%
