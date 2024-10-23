%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <limits.h>

int yylex(void);
int yyerror(const char *s);
extern FILE *yyin;
void print_tokens();

char* current_function_name;

typedef enum { INT_TYPE, VOID_TYPE, CHAR_TYPE, STRING_TYPE, STACK_INT_TYPE,NONE_TYPE } VarType;
typedef enum { NONE,STATIC,STACK_SIZE,STACK_TOP } valueType;

typedef struct {
    char* variable;
    VarType type; 
    char* scope;
    bool isFunction;
    int param_count;
    VarType argument_type;
    valueType val_type;
} Symbol;

VarType argument_type;

Symbol symbol_table[100];
int symbol_count = 0;

int stack_size_count = 0;

int isDeclared(const char* var, const char* scope) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].variable, var) == 0 && strcmp(symbol_table[i].scope, scope) == 0) {
            return i;
        }
    }
    return -1;
}

int isFunctionDeclared(const char* var) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].variable, var) == 0 ) {
            return i;
        }
    }
    return -1;
}

void add_symbol(const char* var, VarType type, const char* scope, bool isFunction) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].variable, var) == 0 && strcmp(symbol_table[i].scope, scope) == 0) {
            printf("\nSemantic Error - Redeclaration of variable '%s' in scope '%s'!!!!\n\n", var, scope);
            exit(0);
        }
    }
    symbol_table[symbol_count].variable = strdup(var);
    symbol_table[symbol_count].type = type;
    symbol_table[symbol_count].scope = strdup(scope);
    symbol_table[symbol_count].isFunction = isFunction;
    symbol_count++;
}

void show_symbol_table() {
    printf("-------------------------------------------------------------------------------------------------------------\n");
    printf("| %-15s | %-10s | %-15s | %-10s | %-15s  | %-10s | %-10s  |\n", "Variable", "Type", "Scope", "Is Func","Total Argument","Value Type","Argu Type");
    printf("-------------------------------------------------------------------------------------------------------------\n");
    for (int i = 0; i < symbol_count; i++) {
        printf("| %-15s | ", symbol_table[i].variable);
        if (symbol_table[i].type == INT_TYPE) {
            printf("%-10s | ", "Integer");
        } else if (symbol_table[i].type == CHAR_TYPE) {
            printf("%-10s | ", "Character");
        } else if (symbol_table[i].type == STRING_TYPE) {
            printf("%-10s | ", "String");
        } else if (symbol_table[i].type == VOID_TYPE) {
            printf("%-10s | ", "Void");
        } else if (symbol_table[i].type == STACK_INT_TYPE) {
            printf("%-10s | ", "Stack");
        }
        printf("%-15s | %-10s | ", symbol_table[i].scope, symbol_table[i].isFunction ? "Yes" : "No");
        if(symbol_table[i].isFunction){
            printf(" %-15d | ",symbol_table[i].param_count);
        }else{
            printf(" %-15s | ","-");
        }
        if (symbol_table[i].val_type == STATIC) {
            printf("%-10s | ", "Static");
        } else if (symbol_table[i].val_type == NONE) {
            printf("%-10s | ", "None");
        } else if (symbol_table[i].val_type == STACK_SIZE) {
            printf("%-10s | ", "Stack Size");
        }
        if(symbol_table[i].isFunction){
              if (symbol_table[i].argument_type == INT_TYPE) {
            printf("%-10s | ", "Integer");
        } else if (symbol_table[i].argument_type == CHAR_TYPE) {
            printf("%-10s | ", "Character");
        } else if (symbol_table[i].argument_type == STRING_TYPE) {
            printf("%-10s | ", "String");
        } else if (symbol_table[i].argument_type == VOID_TYPE) {
            printf("%-10s | ", "Void");
        } else if (symbol_table[i].argument_type == STACK_INT_TYPE) {
            printf("%-10s  | ", "Stack");
        }else if (symbol_table[i].argument_type == NONE_TYPE) {
            printf("%-10s  | ", "none");
        }
        }else{
            printf(" %-10s | ","-");
        }
        
        printf("\n");
    }
    printf("-------------------------------------------------------------------------------------------------------------\n\n");
}
int curr_function_call_index;
%}

%union {
    int num;
    char ch;
    char* str;
    char* id;
}

%token PREPROCESSOR  HEADER_FILE SPECIAL_SYMBOL
%token USING NAMESPACE STD
%token INT VOID MAIN
%token IF ELSE FOR ASSIGNMENT_OPERATOR INCREMENT_OPERATOR
%token RETURN COUT ENDL OPERATOR
%token STACK SIZE POP PUSH EMPTY TOP DOT
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token TERMINATOR_SYMBOL COMMA
%token <id> IDENTIFIER
%token <str> STRING_LITERAL NUMBER

%type <num> function_parameter_list argument_list  stack_size
%type <str> variable_declaration_name function_name

%%

program:
    preprocessor_statement_list std_declaration function_list main_function
    {
        printf("Program processed.\n");
    };

preprocessor_statement_list:
    preprocessor_statement 
    | preprocessor_statement_list preprocessor_statement
    {
        printf("Preprocessor statement_list processed.\n");
    };

preprocessor_statement:
    PREPROCESSOR SPECIAL_SYMBOL HEADER_FILE SPECIAL_SYMBOL 
    | PREPROCESSOR SPECIAL_SYMBOL STACK SPECIAL_SYMBOL
    {
        printf("Processed preprocessor statement.\n");
    };

std_declaration:
    USING NAMESPACE STD TERMINATOR_SYMBOL
    {
        printf("Processed std statement.\n");
    };

function_list:
    function
    | function_list function
    {
        printf("function_list processed.\n");
    };

function:
    function_signature function_definition
    {
        printf("function processed.\n");
    };

function_signature:
    function_declaration_name LPAREN RPAREN
    {
        symbol_table[symbol_count - 1].param_count = 0;
    }
    | function_declaration_name LPAREN function_parameter_list RPAREN
    {
        symbol_table[symbol_count - ($3+1)].param_count = $3;
    }

function_declaration_name:
    VOID IDENTIFIER
    {
        current_function_name = strdup($2);
        add_symbol($2, VOID_TYPE, current_function_name, true); 
        symbol_table[symbol_count - 1].val_type = NONE;
    }
    | INT IDENTIFIER
    {
       current_function_name = strdup($2);
        add_symbol($2, VOID_TYPE, current_function_name, true); 
        symbol_table[symbol_count - 1].val_type = NONE;
    };

variable_declaration_name:
    VOID IDENTIFIER
    {
        add_symbol($2, VOID_TYPE, current_function_name, false); 
        symbol_table[symbol_count - 1].param_count = 1;
    }
    | INT IDENTIFIER
    {
        add_symbol($2, INT_TYPE, current_function_name, false); 
        symbol_table[symbol_count - 1].param_count = 1;
    };

function_parameter_list:
    function_parameter 
    {
        $$ = 1;
    }
    | function_parameter_list COMMA function_parameter
    {
        $$ = $1 + 1;
    };

function_parameter:
    STACK SPECIAL_SYMBOL INT SPECIAL_SYMBOL IDENTIFIER 
    {
        printf("function parameter\n");
        add_symbol($5, STACK_INT_TYPE, current_function_name, false);
        symbol_table[symbol_count - 1].param_count = 1;
        symbol_table[symbol_count - 1].val_type = STATIC;
        symbol_table[symbol_count - 2].argument_type = STACK_INT_TYPE;
    }
    | INT IDENTIFIER
    {
        add_symbol($2, INT_TYPE, current_function_name, false);
        symbol_table[symbol_count - 1].param_count = 1;
        symbol_table[symbol_count - 1].val_type = STATIC;
        symbol_table[symbol_count - 2].argument_type = INT_TYPE;
    }
    | ''
    ;

function_definition:
    LBRACE statement_list RBRACE
    {
        printf("function definition processed\n");
    };

function_call:
    function_name LPAREN argument_list RPAREN TERMINATOR_SYMBOL
    {
        int index = isFunctionDeclared($1);
        if (index == -1) {
            printf("\nFunction %s is not declared!!!!\n", strdup($1));
            exit(0);
        }
        if(symbol_table[index].param_count != $3){
            printf("\nFunction %s Argument Mismatch error!!!! Expected %d arguments, got %d.\n\n", 
                   strdup($1), symbol_table[index].param_count, $3);
            exit(0);
        }
      
        if(symbol_table[index].argument_type != argument_type){
            printf("\nFunction Argument Type Mismatch error!!!!");
            exit(0);
        }
    }
    | function_name LPAREN RPAREN TERMINATOR_SYMBOL
    {
        int index = isFunctionDeclared($1);
        if (index == -1) {
            printf("\nFunction %s is not declared!!!!\n", strdup($1));
            exit(0);
        }else if(symbol_table[index].param_count != 0){
             printf("\nFunction %s Argument Mismatch error!!!! Expected %d arguments, got 0.\n\n", 
                   strdup($1), symbol_table[index].param_count);
            exit(0);
        }
    }
    ;
function_name:
    IDENTIFIER
    {
        $$ = $1;
    }
argument_list:
    argument 
    {
        $$ = 1;
    }
    | argument_list COMMA argument
    {
        $$ = $1 + 1;
    }

argument:
    IDENTIFIER
    {
        int argumentIndex = isDeclared($1, current_function_name);
        if (argumentIndex==-1) {
            printf("\nVariable %s is not declared!!!!\n", strdup($1));
            exit(0);
        }
        argument_type = symbol_table[argumentIndex].type;
    }

statement_list:
    statement 
    | statement_list statement 
    ;

statement: 
    for_loop
    | stack_top
    | stack_pop
    | stack_declaration
    | stack_push
    | function_call
    | return_statement
    | variable_declaration
    ;

variable_declaration:
    variable_declaration_name TERMINATOR_SYMBOL
    {
        symbol_table[symbol_count - 1].param_count = 1;
    }
    | variable_declaration_name ASSIGNMENT_OPERATOR variable_value TERMINATOR_SYMBOL
    {
        symbol_table[symbol_count - 1].param_count = 1;
    }

variable_value:
    NUMBER
    {
        if((int)$1>INT_MAX || (int)$1<INT_MIN){
            printf("\nInteger Range Exceeded!!!!!\n\n");
        }
        symbol_table[symbol_count - 1].val_type = STATIC;
    }
    | stack_size
    {
        if((int)$1>INT_MAX || (int)$1<INT_MIN){
            printf("\nInteger Range Exceeded!!!!!\n\n");
        }
        symbol_table[symbol_count - 1].val_type = STACK_SIZE;
    }

for_loop_signature:
    FOR LPAREN initialization_block TERMINATOR_SYMBOL condition_block TERMINATOR_SYMBOL action_block RPAREN
    ;

initialization_block:
    INT IDENTIFIER ASSIGNMENT_OPERATOR NUMBER
    {
        add_symbol($2, INT_TYPE, current_function_name, false);
        symbol_table[symbol_count - 1].param_count = 1;
        symbol_table[symbol_count - 1].val_type = STATIC;
    }
    | IDENTIFIER ASSIGNMENT_OPERATOR NUMBER
    {
        if (isDeclared($1, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n", strdup($1));
            exit(0);
        }
    }
    | 

condition_block:
    IDENTIFIER SPECIAL_SYMBOL IDENTIFIER
    {
        if (isDeclared($1, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n", strdup($1));
            exit(0);
        }
        if (isDeclared($3, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n", strdup($3));
            exit(0);
        }
    }
    | IDENTIFIER ASSIGNMENT_OPERATOR IDENTIFIER
    {
        if (isDeclared($1, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n", strdup($1));
            exit(0);
        }
         if (isDeclared($3, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n", strdup($3));
            exit(0);
        }
    }
    | 

action_block:
    IDENTIFIER INCREMENT_OPERATOR INCREMENT_OPERATOR
    {
        if (isDeclared($1, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n", strdup($1));
            exit(0);
        }
    }
    | 

for_loop:
    for_loop_signature LBRACE statement_list RBRACE
    ;

stack_declaration:
    STACK SPECIAL_SYMBOL INT SPECIAL_SYMBOL IDENTIFIER TERMINATOR_SYMBOL
    {
        add_symbol($5, STACK_INT_TYPE, current_function_name, false);
        symbol_table[symbol_count - 1].param_count = 1;
        symbol_table[symbol_count - 1].val_type = STATIC;
    };

stack_push:
    IDENTIFIER DOT PUSH LPAREN variable_value RPAREN TERMINATOR_SYMBOL
    {
        if (isDeclared($1, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n\n", strdup($1));
            exit(0);
        }
        stack_size_count++;
        printf("Processed stack push statement.\n");
    };
    
stack_size:
    IDENTIFIER DOT SIZE LPAREN RPAREN
    {
        if (isDeclared($1, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n\n", strdup($1));
            exit(0);
        }
        $$ = stack_size_count;
        printf("Processed stack size statement.\n");
    };
    
stack_pop:
    IDENTIFIER DOT POP LPAREN RPAREN TERMINATOR_SYMBOL
    {
        if (isDeclared($1, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n\n", strdup($1));
            exit(0);
        }
        if(stack_size_count<0){
            printf("\nStack %s - Stack Underflow Error!!!!\n\n", strdup($1));
            exit(0);
        }
        stack_size_count--;
        printf("Processed stack pop statement.\n");
    };

stack_top:
    COUT OPERATOR IDENTIFIER DOT TOP LPAREN RPAREN OPERATOR ENDL TERMINATOR_SYMBOL
    {
        if (isDeclared($3, current_function_name)==-1) {
            printf("\nVariable %s is not declared!!!!\n\n", strdup($3));
            exit(0);
        }
        printf("Processed stack top statement.\n");
    };
    
main_function:
    main_function_signature main_function_definition
    {
        printf("main function declaration\n");
    };

main_function_signature:
    INT MAIN LPAREN RPAREN
    {
        current_function_name = strdup("main");
        add_symbol("main", INT_TYPE, "main", true); 
        symbol_table[symbol_count - 1].param_count = 0;
        symbol_table[symbol_count - 1].val_type = NONE;
        symbol_table[symbol_count - 1].argument_type = NONE_TYPE;
    };

main_function_definition:
    LBRACE statement_list RBRACE
    ;

return_statement:
    RETURN NUMBER TERMINATOR_SYMBOL
    | RETURN TERMINATOR_SYMBOL
    {
       printf("Processed return statement.\n");
    };

%%


int main(void) {
    
    FILE *file = fopen("input.txt", "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    yyin = file;

    printf("\n====*Parser Comments*====\n\n");

    yyparse();

    printf("\n\n====*Tokens Found*=====\n\n");
    print_tokens();

    printf("\n\n====*Variables & Functions*=====\n\n");
    show_symbol_table();
    fclose(file);

    return 0;
}

int yyerror(const char *s) {
    printf("Error: %s\n\n", s);
    return 0; // No need to exit; you might want to continue parsing.
}
