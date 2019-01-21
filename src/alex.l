/*****************************************************************************/
/**  Ejemplo de BISON-I: S E M - 2          2018-2019 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"

void printLine();

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
constante       (\+|\-)?{digito}+
comentario "//".*
identificador {letra}({letra}|{digito}|_)*
%%

{delimitador}   { printLine(); }
{comentario}	{ printLine(); }

read            { printLine(); return READ_; }
print           { printLine(); return PRINT_; }

"if"            { printLine(); return IF_; }
"else"          { printLine(); return ELSE_; }
"for"           { printLine(); return FOR_; }
"except"	{ printLine(); return EXCEPT_; } /* ************************************************************************* */

"int"           { printLine(); return INT_; }
"bool"          { printLine(); return BOOL_; }
"true"          { printLine(); return TRUE_; }
"false"         { printLine(); return FALSE_; }

"++"            { printLine(); return OPINCR_; }
"--"            { printLine(); return OPDECR_; }
"+="            { printLine(); return OPMASIGUAL_; }
"-="            { printLine(); return OPMENOSIGUAL_; }
"*="            { printLine(); return OPPORIGUAL_; }
"/="            { printLine(); return OPDIVIGUAL_; }

"+"             { printLine(); return OPSUMA_; }
"-"             { printLine(); return OPRES_; }
"!"             { printLine(); return NOT_; }

"="				{ printLine(); return OPIGUAL_; }

"*"             { printLine(); return OPMULT_; }
"/"             { printLine();return OPDIV_; }
"%"             { printLine();return OPMOD_; }

">"             { printLine(); return MAY_; }
"<"             { printLine(); return MEN_; }
">="            { printLine(); return MAYIGUAL_; }
"<="            { printLine(); return MENIGUAL_; }
"=="            { printLine(); return IGUAL_; }
"!="            { printLine(); return DISTINTO_; }

"&&"             { printLine(); return AND_; }
"||"             { printLine(); return OR_; }

";"             { printLine(); return PUNCOM_; }

"{"             { printLine(); return ALLA_; }
"}"             { printLine(); return CLLA_; }
"["             { printLine(); return ACOR_; }
"]"             { printLine(); return CCOR_; }
"("             { printLine(); return APAR_; }
")"             { printLine(); return CPAR_; }

{constante}     { printLine(); yylval.cent = atoi(yytext); return CTE_; }
{identificador} { printLine(); yylval.ident = strdup(yytext); return ID_; }
.               {yyerror("Caracter desconocido");}
%%

void printLine() {
	if (verbosidad) {
		ECHO;
	}
}
