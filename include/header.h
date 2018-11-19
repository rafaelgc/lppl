/*****************************************************************************/
/*****************************************************************************/
#ifndef _HEADER_H
#define _HEADER_H

/************************************* Variables externas definidas en el AL */
#define FALSE 0
#define TRUE 1

extern int yylex();
extern int yyparse();

extern FILE *yyin;
extern int   yylineno;
extern char *yytext;
/****************************************************** Funciones auxiliares */
extern void yyerror(const char * msg) ;   /* Tratamiento de errores          */

extern int verbosidad;
extern int verTDS;

/************************************** Tallas asociadas a los tipos simples */
#define TALLA_TIPO_SIMPLE 1

/***************************** Variables externas definidas en las librerías */
extern int dvar;

typedef struct expre {
	int tipo;
	int pos;
} EXPRE;

#endif  /* _HEADER_H */
/*****************************************************************************/
/*****************************************************************************/
