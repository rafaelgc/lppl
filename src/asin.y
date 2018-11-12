/*****************************************************************************/
/**  Ejemplo de BISON-I: S E M - 2          2018-2019 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "libtds.h"
%}

%union {
	char* ident;
	int cent;
}

%token <cent> CTE_
%token <ident> ID_
%token OPSUMA_ OPMULT_ OPDIV_ OPRES_ OPIGUAL_ OPMOD_
%token OPMASIGUAL_ OPMENOSIGUAL_ OPPORIGUAL_ OPDIVIGUAL_
%token OPINCR_ OPDECR_
%token IGUAL_ DISTINTO_ MAY_ MEN_ MAYIGUAL_  MENIGUAL_ NOT_ OR_ AND_
%token INT_ BOOL_
%token PUNCOM_ ALLA_ CLLA_ APAR_ CPAR_ ACOR_ CCOR_
%token READ_ PRINT_ TRUE_ FALSE_
%token IF_ ELSE_ FOR_
%type <cent> tipoSimple expresionSufija constante expresion operadorUnario expresionUnaria expresionMultiplicativa expresionAditiva expresionRelacional expresionIgualdad instruccionAsignacion expresionOpcional instruccionSeleccion instruccionIteracion
%%

programa: ALLA_ secuenciaSentencias CLLA_
;
secuenciaSentencias: sentencia
| secuenciaSentencias sentencia
;
sentencia: declaracion
| instruccion
;
declaracion: tipoSimple ID_ PUNCOM_ {
	if (!insTSimpleTDS($2, $1, 0)) {
		yyerror("La variable ya está declarada.");
	}
	//mostrarTDS();
}
| tipoSimple ID_ OPIGUAL_ constante PUNCOM_ {
	if (!insTSimpleTDS($2, $1, 0)) {
		yyerror("La variable ya está declarada.");
	}
	//mostrarTDS();
}
| tipoSimple ID_ ACOR_ CTE_ CCOR_ PUNCOM_ {
	if ($4 <= 0) {
		yyerror("La talla del array es incorrecta.");
	}

	if (!insTVectorTDS($2, T_ARRAY, 0, $1, $4)) {
		yyerror("La array ya está declarado.");
	}
	//mostrarTDS();
}
;
tipoSimple: INT_ { $$ = T_ENTERO; }
| BOOL_ { $$ = T_LOGICO; }
;
instruccion: ALLA_ listaInstrucciones CLLA_
| instruccionEntradaSalida
| instruccionAsignacion
| instruccionSeleccion
| instruccionIteracion
;
listaInstrucciones: listaInstrucciones instruccion
| 
;
instruccionAsignacion: ID_ operadorAsignacion expresion PUNCOM_ {
	$$ = T_ERROR;
	if ($3 != T_ERROR) {
		SIMB s = obtenerTDS($1);
		if (s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En instruccionAsignacion)"); }
		else if (s.tipo != $3) { yyerror("El tipo de la variable y el de la expresión tienen que ser iguales. (En instruccionAsignacion)"); }
		else {
		    $$ = $3;
		}
	}
}
| ID_ ACOR_ expresion CCOR_ operadorAsignacion expresion PUNCOM_ {
	$$ = T_ERROR;	
	if ($3 != T_ERROR && $6 != T_ERROR) {
		SIMB s = obtenerTDS($1);
		if (s.tipo == T_ERROR) {
			yyerror("Identificador no declarado. (En instruccionAsignacion)");
		}
		else if (s.tipo != T_ARRAY) {
			yyerror("La variable no es un array. (En instruccionAsignacion)");
		}
		else if ($6 != s.telem){
			yyerror("El tipo de los elementos del array y el tipo de la expresión son distintos. (En instruccionAsignacion)");
		}
		else if ($3 != T_ENTERO) {
			yyerror("El índice del array tiene que ser un entero. (En instruccionAsignacion)");
		}
		else {
			$$ = $6;
		}
	}
}
;
instruccionEntradaSalida: READ_ APAR_ ID_ CPAR_ PUNCOM_ {
	///////$$ = T_ERROR;
    SIMB s = obtenerTDS($3);
    if (s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En instruccionEntradaSalida)"); }
	else if (s.tipo != T_ENTERO) { yyerror("La variable tiene que ser entera. (En instruccionEntradaSalida)"); }
	
}
| PRINT_ APAR_ expresion CPAR_ PUNCOM_ {
	if ($3 != T_ENTERO) {
		yyerror("El tipo tiene que ser entero. (En instruccionEntradaSalida)");
		///////// $$ = T_ERROR
	}
}
;
instruccionSeleccion: IF_ APAR_ expresion CPAR_ instruccion ELSE_ instruccion {
	if ($3 != T_ERROR) {	
		if ($3 != T_LOGICO){
			yyerror("El tipo tiene que ser lógico. (En instruccionSeleccion)");
		}
		else {
			$$ = T_VACIO;
		}
	}
}
;
instruccionIteracion: FOR_ APAR_ expresionOpcional PUNCOM_ expresion {
	if ($5 != T_LOGICO){
		yyerror("El tipo tiene que ser lógico. (En instruccionIteracion)");
	}
	else {
		$<cent>$ = T_VACIO;
	}
} PUNCOM_ expresionOpcional CPAR_ instruccion { $$ = T_VACIO; }
;
expresionOpcional: expresion { $$ = $1; }
| ID_ operadorAsignacion expresion {
	$$ = T_ERROR;
    SIMB s = obtenerTDS($1);
    if (s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionOpcional)"); }
    else if (s.tipo != $3) { yyerror("El tipo de la variable y el de la expresión tienen que ser iguales. (En expresionOpcional)"); }
    else {
        $$ = $3;
    }
}
| { $$ = T_VACIO; }
;
expresion: expresionIgualdad { 
	/*if ($1 == T_ENTERO) { yyerror("ES ENTERO"); }*/ $$ = $1; }
| expresion operadorLogico expresionIgualdad {
    $$ = T_ERROR;
    if($1 != $3) { yyerror("Expresiones de tipos distintos (En expresion)"); }
    else { $$ = T_LOGICO; }
}
;
expresionIgualdad: expresionRelacional { $$ = $1; }
| expresionIgualdad operadorIgualdad expresionRelacional {
    $$ = T_ERROR;
    if($1 != $3) { yyerror("Expresiones de tipos distintos (En expresionIgualdad)"); }
    else { $$ = T_LOGICO; }
}
;
expresionRelacional: expresionAditiva { $$ = $1; }
| expresionRelacional operadorRelacional expresionAditiva {
    $$ = T_ERROR;
    if($1 != $3) { yyerror("Expresiones de tipos distintos. (En expresionRelacional)"); }
    else if($1 == T_LOGICO) { yyerror("Los operandos tienen que ser enteros. (En expresionRelacional)"); }
    else { $$ = T_LOGICO; }
}
;
expresionAditiva: expresionMultiplicativa { $$ = $1; }
| expresionAditiva operadorAditivo expresionMultiplicativa {
    $$ = T_ERROR;
    if($1 != $3) { yyerror("Expresiones de tipos distintos. (En expresionAditiva)"); }
    else if($1 == T_LOGICO) { yyerror("Los operandos tienen que ser enteros. (En expresionAditiva)"); }
    else { $$ = T_ENTERO; }
}
;
expresionMultiplicativa: expresionUnaria { $$ = $1; }
| expresionMultiplicativa operadorMultiplicativo expresionUnaria {
    $$ = T_ERROR;
    if($1 != $3) { yyerror("Expresiones de tipos distintos. (En expresionMultiplicativa)"); }
    else if($1 == T_LOGICO) { yyerror("Los operandos tienen que ser enteros. (En expresionMultiplicativa)"); }
    else { $$ = T_ENTERO; }
}
;
expresionUnaria: expresionSufija { $$ = $1; }
| operadorUnario expresionUnaria {
    $$ = T_ERROR;
    if ($1 != $2) { yyerror("Operador inadecuado para la expresion. (En expresionUnaria)"); }
    else { $$ = $1; }
}
| operadorIncremento ID_ {
    $$ = T_ERROR;
    SIMB s = obtenerTDS($2);
    if (s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionUnaria)"); }
    else if (s.tipo != T_ENTERO) { yyerror("El tipo tiene que ser entero. (En expresionUnaria)"); }
    else {
        $$ = T_ENTERO;
    }
}
;
expresionSufija: APAR_ expresion CPAR_ { $$ = $2; }
| ID_ operadorIncremento { 
     $$ = T_ERROR;
     SIMB s = obtenerTDS($1);
	 if(s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionSufija)"); }
	 else if(s.tipo != T_ENTERO) { yyerror("Identificador no es de tipo entero. (En expresionSufija)"); }
     else { $$ = s.tipo; }	
 }
| ID_ ACOR_ expresion CCOR_ { 
     $$ = T_ERROR;
     SIMB s = obtenerTDS($1);
	 if(s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionSufija)"); }
	 if($3 != T_ENTERO) { yyerror("Expresion no es de tipo entera. (En expresionSufija)"); }
     else { $$ = s.telem; }	
 }
| ID_ { 
    $$ = T_ERROR;
    SIMB s = obtenerTDS($1);
    if(s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionSufija)"); }
    else { $$ = s.tipo; }
}
| constante { $$ = $1; }
;
constante: TRUE_ { $$ = T_LOGICO; }
| FALSE_ { $$ = T_LOGICO; }
| CTE_ { $$ = T_ENTERO; }
;
operadorAsignacion: OPIGUAL_ 
| OPMASIGUAL_
| OPMENOSIGUAL_
| OPPORIGUAL_
| OPDIVIGUAL_
;
operadorLogico: AND_ 
| OR_ 
;
operadorIgualdad: IGUAL_
| DISTINTO_
;
operadorRelacional: MAY_
| MEN_
| MAYIGUAL_
| MENIGUAL_
;
operadorAditivo: OPSUMA_
| OPRES_
;
operadorMultiplicativo: OPMULT_
| OPMOD_ 
| OPDIV_ 
;
operadorUnario: OPSUMA_ { $$ = T_ENTERO; }
| OPRES_ { $$ = T_ENTERO; }
| NOT_ { $$ = T_LOGICO; }
;
operadorIncremento: OPINCR_
| OPDECR_
;


%%

