%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

int line_num = 1;
%}

%option noyywrap
%option yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z]
IDENT_START {LETTER}
IDENT_CONT  {LETTER}|{DIGIT}
IDENTIFIER  {IDENT_START}{IDENT_CONT}*

%%

    /* Comments */
#.*                 { /* ignore line comments */ }
"//".*              { /* ignore inline comments */ }

    /* Keywords */
"let"               { return LET; }
"done"              { return DONE; }
"function"          { return FUNCTION; }
"return"            { return RETURN; }
"break"             { return BREAK; }
"continue"          { return CONTINUE; }
"print"             { return PRINT; }
"input"             { return INPUT; }
"until"             { return UNTIL; }
"true"              { return TRUE; }
"false"             { return FALSE; }
"bool"              { return BOOL; }
"number"            { return NUMBER; }
"string"            { return STRING; }
"array"             { return ARRAY; }

    /* Operators */
"=="                { return EQ; }
"!="                { return NEQ; }
"!"                 { return NOT; }
"<"                 { return LT; }
">"                 { return GT; }
"<="                { return LE; }
">="                { return GE; }
"||"                { return OR; }
"&&"                { return AND; }
"+="                { return PLUS_ASSIGN; }
"-="                { return MINUS_ASSIGN; }
"*="                { return MULT_ASSIGN; }
"/="                { return DIV_ASSIGN; }
"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return MULT; }
"/"                 { return DIV; }
"="                 { return ASSIGN; }

    /* Delimiters */
"("                 { return LPAREN; }
")"                 { return RPAREN; }
"["                 { return LBRACKET; }
"]"                 { return RBRACKET; }
":"                 { return COLON; }
";"                 { return SEMICOLON; }
","                 { return COMMA; }
"->"                { return ARROW; }
"?"                 { return QUESTION; }

    /* Literals */
{DIGIT}+            { yylval.num = atoi(yytext); return INT_LITERAL; }
{DIGIT}+\.{DIGIT}+  { yylval.fnum = atof(yytext); return FLOAT_LITERAL; }

\"([^\"\\]|\\.)*\"  { 
                      yylval.str = strdup(yytext); 
                      return STRING_LITERAL; 
                    }

    /* Identifiers */
{IDENTIFIER}        { 
                      yylval.str = strdup(yytext); 
                      return IDENTIFIER; 
                    }

    /* Whitespace */
[ \t]+              { /* ignore whitespace */ }
\n                  { line_num++; }

    /* Anything else is an error */
.                   { 
                      fprintf(stderr, "Unexpected character: %s at line %d\n", 
                              yytext, line_num); 
                    }

%%
