/*****************************************************************************/
/**  Ejemplo de BISON-I: S E M - 2          2018-2019 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"
%}
/*----------------------------------------------------------------------
  Dado que las funciones "input()" y "unput(c)" son costosas y no las
  utilizaremos, evitaremos que se generen automaticamente sus rutinas
  correspondientes desactivandolas mediante las siguientes opciones:
----------------------------------------------------------------------*/
%option noinput
%option nounput
/*----------------------------------------------------------------------
  Para mantener el numero de linea actual en la variable global yylineno
----------------------------------------------------------------------*/
%option yylineno

delimitador     [ \t\n]+
letra [a-zA-Z]
digito          [0-9]
constante       {digito}+
comentario "//".*
identificador {letra}({letra}|{digito})*
%%

{delimitador}   { ECHO; }
{comentario}	{ ECHO; }

read            { ECHO; return READ_; }
print           { ECHO; return PRINT_; }

"if"            { ECHO; return IF_; }
"else"          { ECHO; return ELSE_; }
"for"           { ECHO; return FOR_; }

"int"           { ECHO; return INT_; }
"bool"          { ECHO; return BOOL_; }
"true"          { ECHO; return TRUE_; }
"false"         { ECHO; return FALSE_; }

"++"            { ECHO; return OPINCR_; }
"--"            { ECHO; return OPDECR_; }
"+="            { ECHO; return OPMASIGUAL_; }
"-="            { ECHO; return OPMENOSIGUAL_; }
"*="            { ECHO; return OPPORIGUAL_; }
"/="            { ECHO; return OPDIVIGUAL_; }

"+"             { ECHO; return OPSUMA_; }
"-"             { ECHO; return OPRES_; }
"!"             { ECHO; return NOT_; }

"="		{ ECHO; return OPIGUAL_; }

"*"             { ECHO; return OPMULT_; }
"/"             { ECHO;return OPDIV_; }
"%"             { ECHO;return OPMOD_; }

">"             { ECHO; return MAY_; }
"<"             { ECHO; return MEN_; }
">="            { ECHO; return MAYIGUAL_; }
"<="            { ECHO; return MENIGUAL_; }
"=="            { ECHO; return IGUAL_; }
"!="            { ECHO; return DISTINTO_; }

"&&"             { ECHO; return AND_; }
"||"             { ECHO; return OR_; }

";"             { ECHO; return PUNCOM_; }

"{"             { ECHO; return ALLA_; }
"}"             { ECHO; return CLLA_; }
"["             { ECHO; return ACOR_; }
"]"             { ECHO; return CCOR_; }
"("             { ECHO; return APAR_; }
")"             { ECHO; return CPAR_; }

{constante}     { ECHO; return CTE_; }
{identificador} { ECHO; return ID_; }
.               {yyerror("Caracter desconocido");}
%%
