%{
#include <stdio.h>
#include <stdlib.h>
#include<string.h>

int yylex(void);
int yyerror(const char *s);
extern FILE *yyin;
void print_tokens();

char* current_function_name;

typedef enum { INT_TYPE, CHAR_TYPE, STRING_TYPE,FUNCTION } VarType;

typedef struct {
    char* variable;
    VarType type; 
    char* scope;
    union {         
        int intValue;
        char charValue;
        char* strValue;
    } value;
    int refCount;   
} Symbol;


Symbol symbol_table[100];
int symbol_count = 0;

void insertValue(int symbol_count,VarType type,void* value){
     if (type == INT_TYPE) {
        symbol_table[symbol_count].value.intValue = *(int*)value;
    } else if (type == CHAR_TYPE) {
        symbol_table[symbol_count].value.charValue = *(char*)value;
    } else if (type == STRING_TYPE || type == FUNCTION) {
        symbol_table[symbol_count].value.strValue = strdup((char*)value); 
    }
}

void add_symbol(const char* var, VarType type, void* value, const char* scope) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].variable, var) == 0 && strcmp(symbol_table[i].scope, scope) == 0) {
            printf("\nSemantic Error - Redeclaration of variable '%s' in scope '%s'!!!!\n", var, scope);
            exit(0);
        }
    }

    insertValue(symbol_count, type, value);
    
    symbol_table[symbol_count].variable = strdup(var);  
    symbol_table[symbol_count].type = type;
    symbol_table[symbol_count].scope = strdup(scope);
    symbol_table[symbol_count].refCount = 1;

    symbol_count++;
}


void show_symbol_table() {
    printf("\n*Symbol Table\n");
    printf("Variable\tType\t\tValue\t\tScope\t\tRef Count\n");
    printf("---------------------------------------------------------\n");

    for (int i = 0; i < symbol_count; i++) {
        printf("%-10s\t", symbol_table[i].variable);

        if (symbol_table[i].type == INT_TYPE) {
            printf("Integer\t\t%d\t\t", symbol_table[i].value.intValue);
        } else if (symbol_table[i].type == CHAR_TYPE) {
            printf("Character\t%c\t\t", symbol_table[i].value.charValue);
        } else if (symbol_table[i].type == STRING_TYPE) {
            printf("String\t\t%s\t\t", symbol_table[i].value.strValue);
        }
        else if (symbol_table[i].type == FUNCTION) {
            printf("Function\t\t%s\t", symbol_table[i].value.strValue);
        }

        printf("%s\t\t", symbol_table[i].scope);  // Display the scope
        printf("%d\n", symbol_table[i].refCount);
    }
}


%}

%union {
    int num;
    char ch;
    char* str;
    char* id;
}

%token PREPROCESSOR  HEADER_FILE SPECIAL_SYMBOL MAIN
%token USING NAMESPACE STD
%token INT VOID
%token IF ELSE FOR ASSIGNMENT_OPERATOR INCREMENT_OPERATOR
%token RETURN COUT ENDL OPERATOR
%token STACK SIZE POP PUSH EMPTY TOP DOT
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token TERMINATOR_SYMBOL COMMA
%token <id> IDENTIFIER 
%token <str> STRING_LITERAL
%token <num> NUMBER


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
    VOID IDENTIFIER LPAREN RPAREN
    {
        current_function_name = strdup($2);
        printf("%s",current_function_name);
        add_symbol($2, FUNCTION, "N/A", $2); 
    };
    | INT IDENTIFIER LPAREN RPAREN
    {
        current_function_name = strdup($2); 
        add_symbol($2, FUNCTION, "N/A", $2); 
    };
    | VOID IDENTIFIER LPAREN function_parameter_list RPAREN
    {
        current_function_name = strdup($2);
        printf("%s",current_function_name);
        add_symbol($2, FUNCTION, "N/A", $2);
    };
    | INT IDENTIFIER LPAREN function_parameter_list RPAREN
    {
        current_function_name = strdup($2);
        printf("%s",current_function_name);
        add_symbol($2, FUNCTION, "N/A", $2);
    };
    
function_parameter_list:
    function_parameter 
    | function_parameter_list COMMA function_parameter
    {
        printf("function parameter processed.\n");
    }

function_parameter:
    STACK SPECIAL_SYMBOL INT SPECIAL_SYMBOL IDENTIFIER 
    | INT IDENTIFIER 
    | ''

function_definition:
    LBRACE statement_list RBRACE
    {
        printf("function defination processed\n");
    };

function_call:
    IDENTIFIER LPAREN IDENTIFIER RPAREN TERMINATOR_SYMBOL
    | IDENTIFIER LPAREN  RPAREN TERMINATOR_SYMBOL

statement_list:
    statement 
    | statement_list statement 

statement: 
    for_loop
    | stack_top
    | stack_pop
    | stack_declaration
    | stack_push
    | function_call
    | return_statement
    | variable_declaration

variable_declaration:
    INT IDENTIFIER ASSIGNMENT_OPERATOR variable_value
    {
        printf("Variable addition : %s",current_function_name);
        add_symbol($2, INT_TYPE, "", current_function_name); 
    }

variable_value:
    NUMBER
    | STRING_LITERAL
    | function_call
    | stack_size

for_loop_signature:
    FOR LPAREN INT IDENTIFIER ASSIGNMENT_OPERATOR NUMBER TERMINATOR_SYMBOL IDENTIFIER SPECIAL_SYMBOL IDENTIFIER TERMINATOR_SYMBOL IDENTIFIER INCREMENT_OPERATOR INCREMENT_OPERATOR RPAREN

for_loop:
    for_loop_signature LBRACE statement_list RBRACE

stack_declaration:
    STACK SPECIAL_SYMBOL INT SPECIAL_SYMBOL IDENTIFIER TERMINATOR_SYMBOL

stack_push:
    IDENTIFIER DOT PUSH LPAREN NUMBER RPAREN TERMINATOR_SYMBOL
    {
        printf("Processed stack push statement.\n");
    };
    
stack_size:
    IDENTIFIER DOT SIZE LPAREN RPAREN TERMINATOR_SYMBOL
    {
        printf("Processed stack size statement.\n");
    };
    
stack_pop:
    IDENTIFIER DOT POP LPAREN RPAREN TERMINATOR_SYMBOL
    {
        printf("Processed stack pop statement.\n");
    };

stack_top:
    COUT OPERATOR IDENTIFIER DOT TOP LPAREN RPAREN OPERATOR ENDL TERMINATOR_SYMBOL
    {
        printf("Processed stack top statement.\n");
    };
    

main_function:
    main_function_signature main_function_definition
    {
        printf("main function declaration\n");
    }

main_function_signature:
    INT MAIN LPAREN RPAREN

main_function_definition:
    LBRACE statement_list RBRACE

return_statement:
    RETURN NUMBER TERMINATOR_SYMBOL
    | RETURN TERMINATOR_SYMBOL
    {
       printf("Processed return statement.\n");
    }
%%


int main(void) {
    
    FILE *file = fopen("code.txt", "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    yyin = file;

    printf("\n====*Parser Comments*====\n\n");

    yyparse();

    printf("\n\n====*Tokens Found*=====\n\n");
    print_tokens();
    show_symbol_table();
    fclose(file);

    return 0;
}


int yyerror(const char *s) {
    printf("Error: %s\n", s);
    return 0;
}
