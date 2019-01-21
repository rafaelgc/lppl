/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_ASIN_H_INCLUDED
# define YY_YY_ASIN_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    CTE_ = 258,
    ID_ = 259,
    OPSUMA_ = 260,
    OPMULT_ = 261,
    OPDIV_ = 262,
    OPRES_ = 263,
    OPIGUAL_ = 264,
    OPMOD_ = 265,
    OPMASIGUAL_ = 266,
    OPMENOSIGUAL_ = 267,
    OPPORIGUAL_ = 268,
    OPDIVIGUAL_ = 269,
    OPINCR_ = 270,
    OPDECR_ = 271,
    IGUAL_ = 272,
    DISTINTO_ = 273,
    MAY_ = 274,
    MEN_ = 275,
    MAYIGUAL_ = 276,
    MENIGUAL_ = 277,
    NOT_ = 278,
    OR_ = 279,
    AND_ = 280,
    INT_ = 281,
    BOOL_ = 282,
    PUNCOM_ = 283,
    ALLA_ = 284,
    CLLA_ = 285,
    APAR_ = 286,
    CPAR_ = 287,
    ACOR_ = 288,
    CCOR_ = 289,
    READ_ = 290,
    PRINT_ = 291,
    TRUE_ = 292,
    FALSE_ = 293,
    IF_ = 294,
    ELSE_ = 295,
    FOR_ = 296,
    EXCEPT_ = 297
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 12 "src/asin.y" /* yacc.c:1909  */

	char* ident;
	int cent;
	EXPRE expre;

#line 103 "asin.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_ASIN_H_INCLUDED  */
