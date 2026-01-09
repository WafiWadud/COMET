%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <unistd.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int line_num;

void yyerror(const char *s);

FILE *lua_output;

// Function to emit Lua code
void emit_lua(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vfprintf(lua_output, fmt, args);
    va_end(args);
}

%}

%union {
    int num;
    double fnum;
    char *str;
}

/* Token declarations */
%token LET DONE FUNCTION RETURN BREAK CONTINUE PRINT INPUT UNTIL OTHERWISE
%token TRUE FALSE
%token BOOL NUMBER STRING ARRAY
%token ISNUMBER ISSTRING ISBOOL
%token EQ NEQ LT GT LE GE OR AND NOT LENGTH CONCAT ELLIPSIS PIPE
%token PLUS MINUS MULT DIV ASSIGN
%token PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN
%token LPAREN RPAREN LBRACKET RBRACKET
%token COLON SEMICOLON COMMA DOT ARROW QUESTION
%token <num> INT_LITERAL
%token <fnum> FLOAT_LITERAL
%token <str> STRING_LITERAL IDENTIFIER

/* Non-terminal types */
%type <str> type type_list array_type value expression argument_list array_elements array_element array_value conditional_block conditional_body conditional_statement loop_block loop_statement_list loop_statement assignment parameter_list parameter return_statement

/* Operator precedence */
%left OR
%left AND
%left EQ NEQ
%left LT GT LE GE
%left PLUS MINUS
%left MULT DIV

%%

program:
    /* empty */ { emit_lua("-- Empty program\n"); }
    | statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    variable_declaration
    | function_declaration
    | conditional_block
    | loop_block
    | assignment
    | return_statement
    | function_call
    | IDENTIFIER
    ;

loop_block:
    UNTIL LPAREN expression RPAREN QUESTION 
    { emit_lua("while %s do\n", $3); }
    loop_statement_list DONE
    { emit_lua("::loop_continue::\nend\n"); $$ = strdup(""); }
    ;

loop_statement_list:
    /* empty */ { $$ = strdup(""); }
    | loop_statement { $$ = $1; }
    | loop_statement_list loop_statement { $$ = malloc(256); sprintf($$, "%s%s", $1, $2); }
    ;

loop_statement:
    assignment { $$ = $1; }
    | variable_declaration { $$ = strdup(""); }
    | function_call { $$ = strdup(""); }
    | loop_block { $$ = $1; }
    | conditional_block { $$ = strdup(""); }
    | BREAK opt_semi { emit_lua("break\n"); $$ = strdup(""); }
    | CONTINUE opt_semi { emit_lua("goto loop_continue\n"); $$ = strdup(""); }
    ;

return_statement:
    RETURN expression opt_semi
    { emit_lua("return %s\n", $2); $$ = strdup(""); }
    ;

assignment:
    IDENTIFIER ASSIGN expression opt_semi
    { emit_lua("%s = %s\n", $1, $3); }
    | IDENTIFIER PLUS_ASSIGN expression opt_semi
    { emit_lua("%s = %s + %s\n", $1, $1, $3); }
    | IDENTIFIER MINUS_ASSIGN expression opt_semi
    { emit_lua("%s = %s - %s\n", $1, $1, $3); }
    | IDENTIFIER MULT_ASSIGN expression opt_semi
    { emit_lua("%s = %s * %s\n", $1, $1, $3); }
    | IDENTIFIER DIV_ASSIGN expression opt_semi
    { emit_lua("%s = %s / %s\n", $1, $1, $3); }
    | IDENTIFIER LBRACKET expression RBRACKET ASSIGN expression opt_semi
    { emit_lua("%s[%s] = %s\n", $1, $3, $6); }
    | IDENTIFIER LBRACKET expression RBRACKET PLUS_ASSIGN expression opt_semi
    { emit_lua("%s[%s] = %s[%s] + %s\n", $1, $3, $1, $3, $6); }
    | IDENTIFIER LBRACKET expression RBRACKET MINUS_ASSIGN expression opt_semi
    { emit_lua("%s[%s] = %s[%s] - %s\n", $1, $3, $1, $3, $6); }
    | IDENTIFIER LBRACKET expression RBRACKET MULT_ASSIGN expression opt_semi
    { emit_lua("%s[%s] = %s[%s] * %s\n", $1, $3, $1, $3, $6); }
    | IDENTIFIER LBRACKET expression RBRACKET DIV_ASSIGN expression opt_semi
    { emit_lua("%s[%s] = %s[%s] / %s\n", $1, $3, $1, $3, $6); }
    ;

conditional_block:
    LPAREN expression RPAREN QUESTION
    { emit_lua("if %s then\n", $2); }
    conditional_body otherwise_part DONE
    { emit_lua("end\n"); }
    ;

otherwise_part:
    /* empty */
    | OTHERWISE QUESTION
      { emit_lua("else\n"); }
      conditional_body
    | OTHERWISE LPAREN expression RPAREN QUESTION
      { emit_lua("elseif %s then\n", $3); }
      conditional_body
      otherwise_part
    ;

conditional_body:
    /* empty */ { $$ = strdup(""); }
    | conditional_statement { $$ = $1; }
    | conditional_body conditional_statement { $$ = malloc(256); sprintf($$, "%s%s", $1, $2); }
    ;

conditional_statement:
    function_call { $$ = strdup(""); }
    | assignment { $$ = $1; }
    | variable_declaration { $$ = strdup(""); }
    | return_statement { $$ = $1; }
    | BREAK opt_semi { emit_lua("break\n"); $$ = strdup(""); }
    | CONTINUE opt_semi { emit_lua("goto loop_continue\n"); $$ = strdup(""); }
    | LPAREN expression RPAREN QUESTION
      { emit_lua("if %s then\n", $2); }
      conditional_body DONE
      { emit_lua("end\n"); }
    ;

variable_declaration:
    LET IDENTIFIER COLON type ASSIGN expression opt_semi
    { emit_lua("local %s = %s\n", $2, $6); }
    | LET IDENTIFIER COLON array_type ASSIGN array_value opt_semi
    { emit_lua("local %s = %s\n", $2, $6); }
    | LET IDENTIFIER ASSIGN expression opt_semi
    { emit_lua("local %s = %s\n", $2, $4); }
    | LET IDENTIFIER ASSIGN array_value opt_semi
    { emit_lua("local %s = %s\n", $2, $4); }
    ;

opt_semi:
    /* empty */
    | SEMICOLON
    ;

type:
    BOOL        { $$ = strdup("bool"); }
    | NUMBER    { $$ = strdup("number"); }
    | STRING    { $$ = strdup("string"); }
    | type PIPE type 
    { $$ = malloc(strlen($1) + strlen($3) + 4); sprintf($$, "%s|%s", $1, $3); }
    ;

array_type:
    type LBRACKET RBRACKET                      { $$ = $1; }
    | type LBRACKET INT_LITERAL RBRACKET        { $$ = $1; }
    | ARRAY LBRACKET RBRACKET                   { $$ = strdup("array"); }
    | ARRAY LBRACKET INT_LITERAL RBRACKET       { $$ = strdup("array"); }
    | ARRAY                                      { $$ = strdup("array"); }
    | FUNCTION LPAREN type_list RPAREN ARROW type
    { $$ = malloc(512); sprintf($$, "function(%s)->%s", $3, $6); }
    | FUNCTION LPAREN RPAREN ARROW type
    { $$ = malloc(256); sprintf($$, "function()->%s", $5); }
    ;

type_list:
    type { $$ = $1; }
    | type_list COMMA type { $$ = malloc(256); sprintf($$, "%s, %s", $1, $3); }
    ;

value:
    INT_LITERAL { $$ = malloc(20); sprintf($$, "%d", $1); }
    | FLOAT_LITERAL { $$ = malloc(20); sprintf($$, "%g", $1); }
    | STRING_LITERAL { $$ = $1; }
    | TRUE { $$ = strdup("true"); }
    | FALSE { $$ = strdup("false"); }
    | IDENTIFIER { $$ = $1; }
    ;

array_value:
    LBRACKET array_elements RBRACKET { $$ = malloc(256); sprintf($$, "{%s}", $2); }
    | LBRACKET RBRACKET { $$ = strdup("{}"); }
    ;

array_elements:
    array_element { $$ = $1; }
    | array_elements COMMA array_element { $$ = malloc(512); sprintf($$, "%s, %s", $1, $3); }
    ;

array_element:
    value { $$ = $1; }
    | array_value { $$ = $1; }
    ;

function_declaration:
    FUNCTION IDENTIFIER LPAREN parameter_list RPAREN ARROW type
    { emit_lua("function %s(%s)\n", $2, $4); }
    function_body DONE
    { emit_lua("end\n"); }
    | FUNCTION IDENTIFIER LPAREN RPAREN ARROW type
    { emit_lua("function %s()\n", $2); }
    function_body DONE
    { emit_lua("end\n"); }
    ;

parameter_list:
    parameter { $$ = $1; }
    | parameter_list COMMA parameter { $$ = malloc(256); sprintf($$, "%s, %s", $1, $3); }
    ;

parameter:
    IDENTIFIER COLON type { $$ = $1; }
    | IDENTIFIER COLON array_type { $$ = $1; }
    | ELLIPSIS IDENTIFIER { $$ = strdup("..."); }
    ;

function_body:
    /* empty */
    | statement_list
    ;

function_call:
    PRINT LPAREN expression RPAREN
    { emit_lua("io.write(%s)\n", $3); }
    | IDENTIFIER LPAREN argument_list RPAREN
    { 
      // Handle array functions - map to Lua table functions
      if (strcmp($1, "push") == 0) {
        emit_lua("table.insert(%s)\n", $3);
      } else if (strcmp($1, "pop") == 0) {
        emit_lua("table.remove(%s)\n", $3);
      } else if (strcmp($1, "insert") == 0) {
        emit_lua("table.insert(%s)\n", $3);
      } else {
        emit_lua("%s(%s)\n", $1, $3);
      }
    }
    | IDENTIFIER LPAREN RPAREN
    { emit_lua("%s()\n", $1); }
    ;

argument_list:
    expression { $$ = $1; }
    | argument_list COMMA expression { $$ = malloc(256); sprintf($$, "%s, %s", $1, $3); }
    ;

expression:
    value { $$ = $1; }
    | NOT expression { $$ = malloc(100); sprintf($$, "(not %s)", $2); }
    | LENGTH value { $$ = malloc(100); sprintf($$, "(#%s)", $2); }
    | LENGTH expression { $$ = malloc(100); sprintf($$, "(#%s)", $2); }
    | expression PLUS expression { $$ = malloc(100); sprintf($$, "(%s + %s)", $1, $3); }
    | expression CONCAT expression { $$ = malloc(100); sprintf($$, "(%s .. %s)", $1, $3); }
    | expression MINUS expression { $$ = malloc(100); sprintf($$, "(%s - %s)", $1, $3); }
    | expression MULT expression { $$ = malloc(100); sprintf($$, "(%s * %s)", $1, $3); }
    | expression DIV expression { $$ = malloc(100); sprintf($$, "(%s / %s)", $1, $3); }
    | expression EQ expression { $$ = malloc(100); sprintf($$, "(%s == %s)", $1, $3); }
    | expression NEQ expression { $$ = malloc(100); sprintf($$, "(%s ~= %s)", $1, $3); }
    | expression LT expression { $$ = malloc(100); sprintf($$, "(%s < %s)", $1, $3); }
    | expression GT expression { $$ = malloc(100); sprintf($$, "(%s > %s)", $1, $3); }
    | expression LE expression { $$ = malloc(100); sprintf($$, "(%s <= %s)", $1, $3); }
    | expression GE expression { $$ = malloc(100); sprintf($$, "(%s >= %s)", $1, $3); }
    | expression OR expression { $$ = malloc(100); sprintf($$, "(%s or %s)", $1, $3); }
    | expression AND expression { $$ = malloc(100); sprintf($$, "(%s and %s)", $1, $3); }
    | LPAREN expression RPAREN { $$ = $2; }
    | IDENTIFIER LBRACKET expression RBRACKET { $$ = malloc(256); sprintf($$, "%s[%s]", $1, $3); }
    | expression LBRACKET expression RBRACKET { $$ = malloc(256); sprintf($$, "%s[%s]", $1, $3); }
    | expression DOT ISNUMBER { $$ = malloc(256); sprintf($$, "(type(%s) == \"number\")", $1); }
    | expression DOT ISSTRING { $$ = malloc(256); sprintf($$, "(type(%s) == \"string\")", $1); }
    | expression DOT ISBOOL { $$ = malloc(256); sprintf($$, "(type(%s) == \"boolean\")", $1); }
    | IDENTIFIER LPAREN argument_list RPAREN 
    { 
      // Handle array functions - map to Lua table functions
      if (strcmp($1, "push") == 0) {
        $$ = malloc(256);
        sprintf($$, "table.insert(%s)", $3);
      }
      else if (strcmp($1, "pop") == 0) {
        $$ = malloc(256);
        sprintf($$, "table.remove(%s)", $3);
      }
      else if (strcmp($1, "insert") == 0) {
        $$ = malloc(256);
        sprintf($$, "table.insert(%s)", $3);
      }
      // Handle other builtin functions
      else if (strcmp($1, "tostring") == 0 || strcmp($1, "tonumber") == 0 ||
          strcmp($1, "abs") == 0 || strcmp($1, "floor") == 0 || strcmp($1, "ceil") == 0 ||
          strcmp($1, "min") == 0 || strcmp($1, "max") == 0 || strcmp($1, "sqrt") == 0 ||
          strcmp($1, "run_cmd") == 0) {
        $$ = malloc(256);
        sprintf($$, "%s(%s)", $1, $3);
      } else {
        $$ = malloc(256);
        sprintf($$, "%s(%s)", $1, $3);
      }
    }
    | IDENTIFIER LPAREN RPAREN { $$ = malloc(100); sprintf($$, "%s()", $1); }
    | INPUT LPAREN STRING_LITERAL COMMA type RPAREN 
    { 
      emit_lua("io.write(%s)\n", $3);
      $$ = malloc(100);
      if (strcmp($5, "number") == 0) {
        sprintf($$, "tonumber(io.read())");
      } else {
        sprintf($$, "io.read()");
      }
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", line_num, s);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file> [output_bytecode]\n", argv[0]);
        return 1;
    }
    
    FILE *infile = fopen(argv[1], "r");
    if (!infile) {
        fprintf(stderr, "Could not open file: %s\n", argv[1]);
        return 1;
    }
    yyin = infile;
    
    // Create temporary Lua file
    char lua_file[256];
    snprintf(lua_file, sizeof(lua_file), "/tmp/out_%ld.lua", (long)getpid());
    lua_output = fopen(lua_file, "w");
    if (!lua_output) {
        fprintf(stderr, "Could not create temp Lua file\n");
        fclose(infile);
        return 1;
    }
    
    printf("Parsing...\n");
    int result = yyparse();
    fclose(lua_output);
    fclose(infile);
    
    if (result != 0) {
        fprintf(stderr, "Parsing failed.\n");
        unlink(lua_file);
        return result;
    }
    
    // Determine output bytecode file
    char bytecode_file[256];
    if (argc > 2) {
        snprintf(bytecode_file, sizeof(bytecode_file), "%s", argv[2]);
    } else {
        snprintf(bytecode_file, sizeof(bytecode_file), "a.out");
    }
    
    // Compile to bytecode using luajit
    char cmd[512];
    snprintf(cmd, sizeof(cmd), "luajit -b %s %s", lua_file, bytecode_file);
    printf("Compiling: %s\n", cmd);
    int compile_result = system(cmd);
    
    if (compile_result == 0) {
        printf("Successfully generated bytecode: %s\n", bytecode_file);
        // Copy lua file for inspection
        char lua_copy[256];
        snprintf(lua_copy, sizeof(lua_copy), "%s.lua", bytecode_file);
        char cp_cmd[512];
        snprintf(cp_cmd, sizeof(cp_cmd), "cp %s %s", lua_file, lua_copy);
        system(cp_cmd);
        printf("Lua source: %s\n", lua_copy);
    } else {
        fprintf(stderr, "Failed to compile Lua to bytecode\n");
    }
    
    // Cleanup temp file
    unlink(lua_file);
    
    return compile_result >> 8;
}
