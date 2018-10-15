/*****************************************************************************/
/**  Ejemplo de BISON-I: S E M - 2          2018-2019 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
%}

%union {
	int cent;
}

%token <cent> ID_ CTE_
%token OPSUMA_ OPMULT_ OPDIV_ OPRES_ OPIGUAL_ OPMOD_
%token OPMASIGUAL_ OPMENOSIGUAL_ OPPORIGUAL_ OPDIVIGUAL_
%token OPINCR_ OPDECR_
%token IGUAL_ DISTINTO_ MAY_ MEN_ MAYIGUAL_  MENIGUAL_ NOT_ OR_ AND_
%token INT_ BOOL_
%token PUNCOM_ ALLA_ CLLA_ APAR_ CPAR_ ACOR_ CCOR_
%token READ_ PRINT_ TRUE_ FALSE_
%token IF_ ELSE_ FOR_

%%

programa: ALLA_ secuenciaSentencias CLLA_
;
secuenciaSentencias: sentencia
| secuenciaSentencias sentencia
;
sentencia: declaracion
| instruccion
;
declaracion: tipoSimple ID_ PUNCOM_
| tipoSimple ID_ OPIGUAL_ constante PUNCOM_
| tipoSimple ID_ ACOR_ CTE_ CCOR_ PUNCOM_
;
tipoSimple: INT_
| BOOL_
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
instruccionAsignacion: ID_ operadorAsignacion expresion PUNCOM_
| ID_ ACOR_ expresion CCOR_ operadorAsignacion expresion PUNCOM_
;
instruccionEntradaSalida: READ_ APAR_ ID_ CPAR_ PUNCOM_
| PRINT_ APAR_ expresion CPAR_ PUNCOM_
;
instruccionSeleccion: IF_ APAR_ expresion CPAR_ instruccion ELSE_ instruccion
;
instruccionIteracion: FOR_ APAR_ expresionOpcional PUNCOM_ expresion PUNCOM_ expresionOpcional CPAR_ instruccion
;
expresionOpcional: expresion
| ID_ OPIGUAL_ expresion
|
;
expresion: expresionIgualdad
| expresion operadorLogico expresionIgualdad
;
expresionIgualdad: expresionRelacional
| expresionIgualdad operadorIgualdad expresionRelacional
;
expresionRelacional: expresionAditiva
| expresionRelacional operadorRelacional expresionAditiva
;
expresionAditiva: expresionMultiplicativa
| expresionAditiva operadorAditivo expresionMultiplicativa
;
expresionMultiplicativa: expresionUnaria
| expresionMultiplicativa operadorMultiplicativo expresionUnaria
;
expresionUnaria: expresionSufija { $$ = $1; }
| operadorUnario expresionUnaria {
	if ($1 ==)
}
| operadorIncremento ID_
;
expresionSufija: APAR_ expresion CPAR_ { $$ = $2; }
| ID_ operadorIncremento { $$ = $1 + $2; }
| ID_ ACOR_ expresion CCOR_ { /*****/ }
| ID_ { $$ = $1; }
| constante { $$ = $1; }
;
constante: TRUE_ { $$ = 1; }
| FALSE_ { $$ = 0; }
| CTE_ { $$ = $1; }
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
operadorUnario: OPSUMA_
| OPRES_
| NOT_
;
operadorIncremento: OPINCR_ { $$ = 1; }
| OPDECR_ { $$ = -1; }
;


%%

