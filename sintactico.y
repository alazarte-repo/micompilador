%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <math.h>
#include <string.h>
#include "y.tab.h"
#include "ts.h"
#include "tercetos.h"
#include "validacion.h"

FILE  *yyin;
char *yytext;
%}

%union{
 char s[20];
}

%token DEFVAR
%token ENDDEF

%token <s>ID
%token MAYOR MAYOR_IGUAL MENOR MENOR_IGUAL IGUAL DISTINTO   
%token ASIG SUMA RESTA MUL DIV
%token P_A P_C LL_A LL_C PA_A PA_C P_Y_C DP COMA

%token ENTERO REAL CADENA INT FLOAT STRING

%token AND OR

%token IF ELSE WHILE AVG

%%
raiz:
    programa	{
	printf("Generando Tabla de Simbolos\n");
	symbolTableToHtml(symbolTable,"ts.html");
	printf("Generando GCI\n");
	generarIntermedia();
	}
	;

programa:
        sentencias																{printf("COMPILACION OK\n");}
		;								
sentencias:
            sentencias sent													{printf("GRUPO DE SENTENCIAS\n");}
			|sent																{printf("SENTENCIA INDIVIDUAL\n");}
			;								
sent:
    asignacion																	{printf("ASIGNACION\n");}
	|decision																	{printf("DECISION\n");}
	|declaracion																{printf("DECLARACION\n");}
	|iteracion																	{printf("ITERA\n");}
	|promedio																	{printf("AVG\n");}
	;

asignacion:
            ID ASIG formato_asignacion 
			;
			
formato_asignacion:
                    expresion													{symbol id = getSymbol(yylval.s); asigIndice = crear_terceto___(":=", id.nombre, expIndice);printf("ASIGNACION SIMPLE\n");}
					|ID ASIG formato_asignacion									{printf("ASIGNACION MULTIPLE\n");}
					;
decision:
        IF P_A condiciones P_C LL_A sentencias LL_C				    			{
																				modificarSalto(nroTerceto + 1, desapilar());
																				auxDesapilar = desapilar();
																				if(auxDesapilar == -1)
																					modificarSalto(nroTerceto + 1, desapilar());
																				else
																					apilar(auxDesapilar);
																				printf("IF\n");
																				}
		|IF P_A condiciones P_C LL_A sentencias LL_C ELSE
																				{
																				crear_terceto_("JI");
																				modificarSalto(nroTerceto + 1, desapilar());				
																				auxDesapilar = desapilar();
																				if(auxDesapilar == -1)
																					modificarSalto(nroTerceto + 1, desapilar());
																				else
																					apilar(auxDesapilar);
																				apilar(nroTerceto);
																				}
																				
				LL_A sentencias LL_C											{modificarSalto(nroTerceto + 1, desapilar());printf("IF-ELSE\n");}
		;
		
declaracion:
            DEFVAR declaraciones ENDDEF										{saveIdType();printf("BLOQUE DECLARACION\n");}
			;	
declaraciones:
                declaraciones formato_declaracion
				|formato_declaracion
				;
formato_declaracion:
                    ID DP tipo_dato											{validarLongitudId(yylval.s);saveId(yylval.s);printf("DECLARACION SIMPLE\n");}
					|ID COMA formato_declaracion								{validarLongitudId($1);symbol idTipo = getSymbol(yylval.s);saveId($1);saveType(idTipo.tipo);printf("DECLARACION MULTIPLE\n");}
					;
tipo_dato:
        INT																	{saveType("int");printf("INT\n");}
		|FLOAT																	{saveType("float");printf("FLOAT\n");}
		|STRING																	{saveType("string");printf("STRING\n");}
		;			
		
iteracion:
            WHILE P_A condiciones P_C LL_A sentencias LL_C						{printf("WHILE\n");}
            ;						

condiciones: 
            condicion 
                { 				
                condMulIndice = crear_terceto__(obtenerSalto(1), condMulIndice, nroTerceto);
                //si aca, dps de genera el terceto apilamos numero de terceto, tenemos el de la condicion que hay que modificar mas adelante
                apilar(nroTerceto);
                printf("\ncondiciones : condicion"); 
                }
            |condicion AND 
                {							
                crear_terceto__(obtenerSalto(1), condMulIndice, nroTerceto); //salto si es falso
                apilar(nroTerceto);
                apilar(-1); //para indicar que hubo and y tenemos que desapilar dos veces en algunos casos
                //si aca, dps de genera el terceto apilamos numero de terceto, tenemos el de la condicion que hay que modificar mas adelante
                }
            condicion 					
                { 				
                crear_terceto__(obtenerSalto(1), condMulIndice, nroTerceto); //salto si es falso
                apilar(nroTerceto);
                //si aca, dps de genera el terceto apilamos numero de terceto, tenemos el de la condicion que hay que modificar mas adelante
                printf("\ncondiciones : condicion OP_AND condicion"); 
                }
            |condicion OR 
                {								
                crear_terceto__(obtenerSalto(0), condMulIndice, nroTerceto); //salto si es verdadero
                apilar(nroTerceto);
                //si aca, dps de genera el terceto apilamos numero de terceto, tenemos el de la condicion que hay que modificar mas adelante
                }
            condicion 
                { 
                crear_terceto__(obtenerSalto(1), condMulIndice, nroTerceto); //salto si es falso
                modificarSalto(nroTerceto + 1, desapilar());
                apilar(nroTerceto);
                //si aca, dps de genera el terceto apilamos numero de terceto, tenemos el de la condicion que hay que modificar mas adelante
                printf("\ncondiciones : condicion OP_OR condicion"); 
                }
            |PA_A condicion P_C
                { 
                condMulIndice = crear_terceto__(obtenerSalto(0), condMulIndice, nroTerceto);
                apilar(nroTerceto);
                //si aca, dps de genera el terceto apilamos numero de terceto, tenemos el de la condicion que hay que modificar mas adelante
                printf("\ncondiciones : OP_NOT condicion");
                }
            ;								

condicion: 
            expresion operador_comparacion
            {
            condIndice = expIndice;
            }
            expresion 
            { 
                condMulIndice = crear_terceto__("CMP", condIndice, expIndice);
                printf("\ncondicion : expresion op_comparacion expresion "); 
            }
            ;

operador_comparacion:
                    IGUAL 
                    { 
                        operacionLogica = IGUAL;
                        printf("\nop_comparacion : OP_IGUAL"); 
                    }| 
                    MENOR 
                    { 
                        operacionLogica = MENOR;
                        printf("\nop_comparacion : MENOR"); 
                    }| 
                    MAYOR 
                    { 
                        operacionLogica = MAYOR;
                        printf("\nop_comparacion : MAYOR"); 
                    }| MAYOR_IGUAL
                    { 
                        operacionLogica = MAYOR_IGUAL;
                        printf("\nop_comparacion : MAYOR_IGUAL"); 
                    }| 
                    MENOR_IGUAL
                    { 
                        operacionLogica = MENOR_IGUAL;
                        printf("\nop_comparacion : MENOR_IGUAL"); 
                    }| 
                    DISTINTO 
                    { 
                        operacionLogica = DISTINTO;
                        printf("\nop_comparacion : DISTINTO "); 
                    } ;								

promedio:
        AVG P_A PA_A formato_promedio PA_C P_C									{printf("FUNCION PROMEDIO (AVG)\n");}
		;
formato_promedio:
                expresion
				|expresion COMA formato_promedio
				;
expresion:
        expresion RESTA termino											    	{expIndice = crear_terceto__("-", expIndice, terIndice);printf("RESTA\n");}
		|expresion SUMA termino													{expIndice = crear_terceto__("+", expIndice, terIndice);printf("SUMA\n");}
		|termino																{expIndice = terIndice;printf("TERMINO\n");}
		;									

termino:
        termino MUL factor														{terIndice = crear_terceto__("*", terIndice, facIndice);printf("MULTIPLICACION\n");}
		|termino DIV factor														{terIndice = crear_terceto__("/", terIndice, facIndice);printf("DIVISION\n");}
		|factor																	{terIndice = facIndice;printf("FACTOR\n");}
		;									

factor:
        ID																		{symbol id = getSymbol(yylval.s);facIndice = crear_terceto_(id.nombre);printf("ID\n");}
		|tipo																	{printf("CTE\n");}
		|P_A expresion P_C														{printf("EXPRESION\n");}
		;									

tipo:
    ENTERO																		{validarInt(yytext);symbol id = getSymbol(yylval.s);facIndice = crear_terceto_(id.valor);printf("ENTERO\n");}   
	|REAL																		{validarFloat(yytext);symbol id = getSymbol(yylval.s);facIndice = crear_terceto_(id.valor);printf("FLOAT\n");}
	|CADENA																		{validarString(yytext);printf("CADENA\n");}
	;

%%

int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  }
  
  fclose(yyin);
  return 0;
}
