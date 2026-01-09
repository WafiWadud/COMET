%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

int line_num = 1;

// Helper function to process escape sequences and interpolation in strings
char *process_string(const char *input) {
    char *output = malloc(strlen(input) * 4 + 10);
    int out_idx = 0;
    int i = 1;  // Skip opening quote
    
    // Check for interpolation
    int has_interp = 0;
    for (int j = 1; input[j] && input[j] != '"'; j++) {
        if (input[j] == '$' && input[j+1] == '{') {
            has_interp = 1;
            break;
        }
    }
    
    if (!has_interp) {
        // Simple string without interpolation
        output[out_idx++] = '"';
        while (input[i] && input[i] != '"') {
            if (input[i] == '\\' && input[i+1]) {
                i++;
                switch (input[i]) {
                    case 'n': output[out_idx++] = '\\'; output[out_idx++] = 'n'; break;
                    case 't': output[out_idx++] = '\\'; output[out_idx++] = 't'; break;
                    case 'r': output[out_idx++] = '\\'; output[out_idx++] = 'r'; break;
                    case '\\': output[out_idx++] = '\\'; output[out_idx++] = '\\'; break;
                    case '"': output[out_idx++] = '\\'; output[out_idx++] = '"'; break;
                    default: output[out_idx++] = '\\'; output[out_idx++] = input[i];
                }
            } else {
                output[out_idx++] = input[i];
            }
            i++;
        }
        output[out_idx++] = '"';
    } else {
        // String with interpolation - build concatenation
        output[out_idx++] = '"';
        while (input[i] && input[i] != '"') {
            if (input[i] == '$' && input[i+1] == '{') {
                output[out_idx++] = '"';
                output[out_idx++] = ' ';
                output[out_idx++] = '.';
                output[out_idx++] = '.';
                output[out_idx++] = ' ';
                i += 2;  // Skip ${
                
                // Copy expression until }
                int braces = 1;
                while (input[i] && braces > 0) {
                    if (input[i] == '{') braces++;
                    else if (input[i] == '}') braces--;
                    if (braces > 0) output[out_idx++] = input[i];
                    i++;
                }
                
                output[out_idx++] = ' ';
                output[out_idx++] = '.';
                output[out_idx++] = '.';
                output[out_idx++] = ' ';
                output[out_idx++] = '"';
            } else if (input[i] == '\\' && input[i+1]) {
                i++;
                switch (input[i]) {
                    case 'n': output[out_idx++] = '\\'; output[out_idx++] = 'n'; break;
                    case 't': output[out_idx++] = '\\'; output[out_idx++] = 't'; break;
                    case 'r': output[out_idx++] = '\\'; output[out_idx++] = 'r'; break;
                    case '\\': output[out_idx++] = '\\'; output[out_idx++] = '\\'; break;
                    case '"': output[out_idx++] = '\\'; output[out_idx++] = '"'; break;
                    default: output[out_idx++] = '\\'; output[out_idx++] = input[i];
                }
            } else {
                output[out_idx++] = input[i];
            }
            i++;
        }
        output[out_idx++] = '"';
    }
    
    output[out_idx] = '\0';
    return output;
}
%}

%option noyywrap
%option yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z]
IDENT_START {LETTER}
IDENT_CONT  {LETTER}|{DIGIT}
IDENTIFIER  {IDENT_START}{IDENT_CONT}*

%%

     /* Comments - # only as comment at start of line or after space */
^[ \t]*"#"[^\n]*    { /* ignore line comments */ }
[ \t]+"#"[^\n]*     { /* ignore inline comments after whitespace */ }
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
"otherwise"         { return OTHERWISE; }
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
"#"                 { return LENGTH; }
"<"                 { return LT; }
">"                 { return GT; }
"<="                { return LE; }
">="                { return GE; }
"||"                { return OR; }
"&&"                { return AND; }
".."                { return CONCAT; }
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
                      yylval.str = process_string(yytext); 
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
