void yyerror(char *msg){
    fprintf(stderr, "%s\n", msg);
    exit(1);
}
//-----------------------Funciones para validacion de tipos-----------------------//
int validarInt(char entero[]) {
    int casteado = atoi(entero);
    char msg[100];
    if(casteado < -32768 || casteado > 32767) {
        sprintf(msg, "ERROR: Entero %d fuera de rango. Debe estar entre [-32768; 32767]\n", casteado);
        yyerror(msg);
    } else {
        return 0;
    }
}

int validarFloat(char flotante[]) {
    double casteado = atof(flotante);
    casteado = fabs(casteado);
    char msg[300];
    if(casteado < pow(-1.17549,-38) || casteado >  pow(3.40282,38)){
        sprintf(msg, "ERROR: Float %f fuera de rango. Debe estar entre [1.17549e-38; 3.40282e38]\n", casteado);
        yyerror(msg);
    } 
    else {

        return 0;
    }
}

int validarString(char cadena[]) {
    char msg[100];

    if( strlen(cadena) > 32){ //en lugar de 30 verifica con 32 porque el string viene entre comillas
        sprintf(msg, "ERROR: Cadena %s demasiado larga. Maximo 30 caracteres\n", cadena);
        yyerror(msg);
    }
    char sincomillas[31];
    int i;
    for(i=0; i< strlen(cadena) - 2 ; i++) {
            sincomillas[i]=cadena[i+1];
    }
    sincomillas[i]='\0';
    return 0;
}

int validarLongitudId(char cadena[]) {
    char msg[100];
    if( strlen(cadena) > 15){
        sprintf(msg, "ERROR: Id de variable %s demasiado largo. Maximo 15 caracteres.\n", cadena);
        yyerror(msg);
    }
    return 0;
}

//Verificar si un token es palabra reservada
void validarPalabraReservada(char *nombreToken)
{
	bool marca = false;

	if(strcmp (nombreToken, "if") == 0)
		marca = true;
	if(strcmp (nombreToken, "else") == 0)
		marca = true;
	if(strcmp (nombreToken, "while") == 0)
		marca = true;
	if(strcmp (nombreToken, "float") == 0)
		marca = true;
	if(strcmp (nombreToken, "string") == 0)
		marca = true;
	if(strcmp (nombreToken, "int") == 0)
		marca = true;
	if(strcmp (nombreToken, "avg") == 0)
		marca = true;

	if(marca){
		char *msg;
		sprintf(msg, "ERROR: Id de variable %s es una palabra reservada del lenguaje.\n", nombreToken);
		yyerror(msg);
    }
}

/* int resetTipos(){
    contTipos = 0;
    strcpy(tipos[contTipos],"null");
}

int validarTipos(char tipo[]) {
    char msg[100];
    int i ;
    for(i=0; i< contTipos; i++){
        if(compararTipos(tipo,tipos[i])!=0){
            sprintf(msg, "ERROR: Tipos incompatibles\n");
            yyerror(msg);
        }
    }
    resetTipos();
    return 0;
} */

//-----------------------Fin de funciones para validacion-----------------------//