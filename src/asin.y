/*****************************************************************************/
/**  Ejemplo de BISON-I: S E M - 2          2018-2019 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "libtds.h"
#include "libgci.h"
%}

%union {
	char* ident;
	int cent;
	EXPRE expre;
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
%type <cent> tipoSimple operadorUnario operadorAditivo operadorIgualdad operadorRelacional operadorMultiplicativo operadorAsignacion operadorIncremento
%type <expre> expresionSufija  expresion  expresionUnaria expresionMultiplicativa expresionAditiva expresionRelacional expresionIgualdad instruccionAsignacion expresionOpcional instruccionSeleccion instruccionIteracion constante
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
	if (!insTSimpleTDS($2, $1, dvar)) {
		yyerror("La variable ya está declarada.");
	}
	else {
		if (verTDS) mostrarTDS();
		dvar += TALLA_TIPO_SIMPLE;
	}
}
| tipoSimple ID_ OPIGUAL_ constante PUNCOM_ {
	if (!insTSimpleTDS($2, $1, dvar)) {
		yyerror("La variable ya está declarada.");
	}
	else {
		if (verTDS) mostrarTDS();
		emite(EASIG, crArgPos($4.pos), crArgNul(), crArgPos(dvar));
		dvar += TALLA_TIPO_SIMPLE;
	}
}
| tipoSimple ID_ ACOR_ CTE_ CCOR_ PUNCOM_ {
	if ($4 <= 0) {
		yyerror("La talla del array es incorrecta.");
	}

	if (!insTVectorTDS($2, T_ARRAY, dvar, $1, $4)) {
		yyerror("La array ya está declarado.");
	}
	else {
		dvar += TALLA_TIPO_SIMPLE * $4;
		if (verTDS) mostrarTDS();
	}
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
	$$.tipo = T_ERROR;
	if ($3.tipo != T_ERROR) {
		SIMB s = obtenerTDS($1);
		if (s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En instruccionAsignacion)"); }
		else if (s.tipo != $3.tipo) { yyerror("El tipo de la variable y el de la expresión tienen que ser iguales. (En instruccionAsignacion)"); }
		else {
		    $$.tipo = $3.tipo;
		    
		    if ($2 == EASIG) {
			    emite(EASIG, crArgPos($3.pos),crArgNul(),crArgPos(s.desp));
		    }
		    else {
			    emite($2, crArgPos(s.desp), crArgPos($3.pos), crArgPos(s.desp));
		    }
		}
	}
}
| ID_ ACOR_ expresion CCOR_ operadorAsignacion expresion PUNCOM_ {
	$$.tipo = T_ERROR;	
	if ($3.tipo != T_ERROR && $6.tipo != T_ERROR) {
		SIMB s = obtenerTDS($1);
		if (s.tipo == T_ERROR) {
			yyerror("Identificador no declarado. (En instruccionAsignacion)");
		}
		else if (s.tipo != T_ARRAY) {
			yyerror("La variable no es un array. (En instruccionAsignacion)");
		}
		else if ($6.tipo != s.telem){
			yyerror("El tipo de los elementos del array y el tipo de la expresión son distintos. (En instruccionAsignacion)");
		}
		else if ($3.tipo != T_ENTERO) {
			yyerror("El índice del array tiene que ser un entero. (En instruccionAsignacion)");
		}
		else {
			$$.tipo = $6.tipo;
			
            if ($5 == EASIG) {
                emite(EVA, crArgPos(s.desp), crArgPos($3.pos), crArgPos($6.pos));
            }
            else {
                $$.pos = creaVarTemp();
                emite(EAV, crArgPos(s.desp), crArgPos($3.pos), crArgPos($$.pos));
                emite($5, crArgPos($$.pos), crArgPos($6.pos), crArgPos($$.pos));
                emite(EVA, crArgPos(s.desp), crArgPos($3.pos), crArgPos($$.pos));
            }
		}
	}
}
;
instruccionEntradaSalida: READ_ APAR_ ID_ CPAR_ PUNCOM_ {
    SIMB s = obtenerTDS($3);
    if (s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En instruccionEntradaSalida)"); }
	else if (s.tipo != T_ENTERO) { yyerror("La variable tiene que ser entera. (En instruccionEntradaSalida)"); }
	else {
		emite(EREAD, crArgNul(), crArgNul(), crArgPos(s.desp));
	}
	
}
| PRINT_ APAR_ expresion CPAR_ PUNCOM_ {
	if ($3.tipo != T_ENTERO) {
		yyerror("El tipo tiene que ser entero. (En instruccionEntradaSalida)");
	}
	else {
		emite(EWRITE, crArgNul(), crArgNul(), crArgPos($3.pos));
	}
}
;
instruccionSeleccion: IF_ APAR_ expresion CPAR_ {
	if ($3.tipo != T_ERROR) {	
		if ($3.tipo != T_LOGICO){
			yyerror("El tipo tiene que ser lógico. (En instruccionSeleccion)");
		}
		else {
			$<cent>$ = creaLans(si);
            emite(EIGUAL, crArgPos($3.pos), crArgEnt(0), crArgEtq(-1));
		}
	}
}
instruccion ELSE_ {
    $<cent>$ = creaLans(si);
    emite(GOTOS, crArgNul(), crArgNul(), crArgEtq(-1));
    completaLans($<cent>5, crArgEtq(si));
} instruccion {    
	$$.tipo = T_VACIO;
	completaLans($<cent>8, crArgEtq(si));
}
;
instruccionIteracion: FOR_ APAR_ expresionOpcional PUNCOM_ {
	$<cent>$ = si;
} expresion {
	if ($6.tipo != T_LOGICO){
		yyerror("El tipo tiene que ser lógico. (En instruccionIteracion)");
	}
	else {
		$<expre>$.tipo = T_VACIO;
        $<expre>$.pos = creaLans(si);
        emite(EIGUAL, crArgPos($6.pos), crArgEnt(0), crArgEtq(-1));
        $<expre>$.instruccionesFor = creaLans(si);
        emite(GOTOS, crArgNul(), crArgNul(), crArgEtq(-1));
	}
} PUNCOM_ {
    $<cent>$ = si;
} expresionOpcional {
    emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<cent>5));
} CPAR_ {
    completaLans($<expre>7.instruccionesFor, crArgEtq(si));
} instruccion {
    $$.tipo = T_VACIO;
    emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<cent>9));
    completaLans($<expre>7.pos, crArgEtq(si));
}
;
expresionOpcional: expresion { $$ = $1; }
| ID_ operadorAsignacion expresion {
	$$.tipo = T_ERROR;
    SIMB s = obtenerTDS($1);
    if (s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionOpcional)"); }
    else if (s.tipo != $3.tipo) { yyerror("El tipo de la variable y el de la expresión tienen que ser iguales. (En expresionOpcional)"); }
    else {
        $$.tipo = $3.tipo;

        if ($2 == EASIG) {
			emite(EASIG, crArgPos($3.pos),crArgNul(),crArgPos(s.desp));
		}
		else {
			emite($2, crArgPos(s.desp), crArgPos($3.pos), crArgPos(s.desp));
		}
    }
}
| { $$.tipo = T_VACIO; }
;
expresion: expresionIgualdad { $$ = $1; } /////////////////////////////////////// TODO: AND / OR
| expresion operadorLogico expresionIgualdad {
    $$.tipo = T_ERROR;
    if($1.tipo != $3.tipo) { yyerror("Expresiones de tipos distintos (En expresion)"); }
    else { $$.tipo = T_LOGICO; }
}
;
expresionIgualdad: expresionRelacional { $$ = $1; }
| expresionIgualdad operadorIgualdad expresionRelacional {
    $$.tipo = T_ERROR;
    if($1.tipo != $3.tipo) { yyerror("Expresiones de tipos distintos (En expresionIgualdad)"); }
    else {
        $$.tipo = T_LOGICO;
        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
		emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
		emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
    }
}
;
expresionRelacional: expresionAditiva { $$ = $1; }
| expresionRelacional operadorRelacional expresionAditiva {
    $$.tipo = T_ERROR;
    if($1.tipo != $3.tipo) { yyerror("Expresiones de tipos distintos. (En expresionRelacional)"); }
    else if($1.tipo == T_LOGICO) { yyerror("Los operandos tienen que ser enteros. (En expresionRelacional)"); }
    else {
        $$.tipo = T_LOGICO;
        
        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
		emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
		emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
    }
}
;
expresionAditiva: expresionMultiplicativa { $$ = $1; }
| expresionAditiva operadorAditivo expresionMultiplicativa {
    $$.tipo = T_ERROR;
    if($1.tipo != $3.tipo) { yyerror("Expresiones de tipos distintos. (En expresionAditiva)"); }
    else if($1.tipo == T_LOGICO) { yyerror("Los operandos tienen que ser enteros. (En expresionAditiva)"); }
    else {
        $$.tipo = T_ENTERO;
        $$.pos = creaVarTemp();
        emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
    }
}
;
expresionMultiplicativa: expresionUnaria { $$ = $1; }
| expresionMultiplicativa operadorMultiplicativo expresionUnaria {
    $$.tipo = T_ERROR;
    if($1.tipo != $3.tipo) { yyerror("Expresiones de tipos distintos. (En expresionMultiplicativa)"); }
    else if($1.tipo == T_LOGICO) { yyerror("Los operandos tienen que ser enteros. (En expresionMultiplicativa)"); }
    else {
        $$.tipo = T_ENTERO;
        $$.pos = creaVarTemp();
        emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
    }
}
;
expresionUnaria: expresionSufija { $$ = $1; }
| operadorUnario expresionUnaria { /////////////// TODO: complicado. $1 se usa para comprobación de tipos.
    $$.tipo = T_ERROR;
    if ($1 != $2.tipo) { yyerror("Operador inadecuado para la expresion. (En expresionUnaria)"); }
    else { $$.tipo = $1; }
}
| operadorIncremento ID_ {
    $$.tipo = T_ERROR;
    SIMB s = obtenerTDS($2);
    if (s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionUnaria)"); }
    else if (s.tipo != T_ENTERO) { yyerror("El tipo tiene que ser entero. (En expresionUnaria)"); }
    else {
        $$.tipo = T_ENTERO;
        $$.pos = s.desp;
        emite($1, crArgPos(s.desp), crArgEnt(1), crArgPos(s.desp));
    }
}
;
expresionSufija: APAR_ expresion CPAR_ { $$ = $2; }
| ID_ operadorIncremento { 
     $$.tipo = T_ERROR;
     SIMB s = obtenerTDS($1);
	 if(s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionSufija)"); }
	 else if(s.tipo != T_ENTERO) { yyerror("Identificador no es de tipo entero. (En expresionSufija)"); }
     else { 
        $$.tipo = s.tipo;
        $$.pos = s.desp; 
        emite($2, crArgPos(s.desp), crArgEnt(1), crArgPos(s.desp));
}	
 }
| ID_ ACOR_ expresion CCOR_ { 
    $$.tipo = T_ERROR;
    SIMB s = obtenerTDS($1);
    if(s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionSufija)"); }
    if($3.tipo != T_ENTERO) { yyerror("Expresion no es de tipo entera. (En expresionSufija)"); }
    else { 
        $$.tipo = s.telem;
        $$.pos = creaVarTemp();
        emite(EAV, crArgPos(s.desp), crArgPos($3.pos), crArgPos($$.pos));
    }	
 }
| ID_ { 
    $$.tipo = T_ERROR;
    SIMB s = obtenerTDS($1);
    if(s.tipo == T_ERROR) { yyerror("Identificador no declarado. (En expresionSufija)"); }
    else {
        $$.tipo = s.tipo;
        $$.pos = creaVarTemp();
        emite(EASIG, crArgPos(s.desp), crArgNul(), crArgPos($$.pos));
    }
}
| constante { $$ = $1; }
;
constante: TRUE_ {
	$$.tipo = T_LOGICO;
	$$.pos = creaVarTemp();
	emite(EASIG, crArgEnt(TRUE), crArgNul(), crArgPos($$.pos));
}
| FALSE_ {
	$$.tipo = T_LOGICO;
	$$.pos = creaVarTemp();
	emite(EASIG, crArgEnt(FALSE), crArgNul(), crArgPos($$.pos));
}
| CTE_ {
	$$.tipo = T_ENTERO;
	$$.pos = creaVarTemp();
	emite(EASIG, crArgEnt(yylval.cent), crArgNul(), crArgPos($$.pos));
}
;
operadorAsignacion: OPIGUAL_ { $$ = EASIG; }
| OPMASIGUAL_ { $$ = ESUM; }
| OPMENOSIGUAL_ { $$ = EDIF; }
| OPPORIGUAL_ { $$ = EMULT; }
| OPDIVIGUAL_ { $$ = EDIVI; }
;
operadorLogico: AND_ 
| OR_ 
;
operadorIgualdad: IGUAL_ { $$ = EIGUAL; }
| DISTINTO_ { $$ = EDIST; }
;
operadorRelacional: MAY_ { $$ = EMAY; }
| MEN_ { $$ = EMEN; }
| MAYIGUAL_ { $$ = EMAYEQ; }
| MENIGUAL_ { $$ = EMENEQ; }
;
operadorAditivo: OPSUMA_ { $$ = ESUM; }
| OPRES_ { $$ = EDIF; }
;
operadorMultiplicativo: OPMULT_ { $$ = EMULT; }
| OPMOD_ { $$ = RESTO; }
| OPDIV_ { $$ = EDIVI; }
;
operadorUnario: OPSUMA_ { $$ = T_ENTERO; }
| OPRES_ { $$ = T_ENTERO; }
| NOT_ { $$ = T_LOGICO; }
;
operadorIncremento: OPINCR_ { $$ = ESUM; }
| OPDECR_ { $$ = EDIF; }
;


%%

