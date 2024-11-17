%{
#include "parser.tab.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    char *token_type;
    char *lexeme;
    int line_number;
} Token;

Token token_list[100];
int token_count = 0;
int line_number = 1;

int isPresent(const char *text) {
    for (int i = 0; i < token_count; i++) {
        if(strcmp(text,token_list[i].lexeme) == 0){
            return 0;
        }
    }
    return 1;
}

void store_token(const char *type, const char *text) {
    if(isPresent(text)){
        token_list[token_count].token_type = strdup(type);
        token_list[token_count].lexeme = strdup(text);
        token_list[token_count].line_number = line_number;
        token_count++;
    }
}

%}

%% 
"#include"            {store_token("Keyword", yytext); return PREPROCESSOR; }
[<>]                  {store_token("Punctuation", yytext); return SPECIAL_SYMBOL;}
"iostream"            {store_token("Identifiers", yytext); return HEADER_FILE; }
"stack"               {store_token("Identifiers", yytext); return STACK; }
"int"                 {store_token("DataTypes", yytext); return INT; }
"char*"                 {store_token("DataTypes", yytext); return CHARSTAR; }
"void"                {store_token("Keyword", yytext); return VOID; }
"main"                {store_token("Identifiers", yytext); return MAIN;}
"using"               {store_token("Keyword", yytext); return USING; }
"namespace"           {store_token("Keyword", yytext); return NAMESPACE; }
"std"                 {store_token("Identifiers", yytext); return STD; }
"cout"                {store_token("STL_Function", yytext); return COUT; }
"endl"                {store_token("Keyword", yytext); return ENDL; }
"for"                 {store_token("Keyword", yytext); return FOR; }
"if"                  {store_token("Keyword", yytext); return IF; }
"return"              {store_token("Keyword", yytext); return RETURN; }
"size"                {store_token("Identifiers", yytext); return SIZE; }
"pop"                 {store_token("Identifiers", yytext); return POP; }
"push"                {store_token("Identifiers", yytext); return PUSH; }
"empty"               {store_token("Identifiers", yytext); return EMPTY; }
"top"                 {store_token("Identifiers", yytext); return TOP; }
"\""([^\"\n]+)"\""    {yylval.str = strdup(yytext);store_token("Identifiers", yytext); return STRING_LITERAL; }
"("                   {store_token("Punctuation", yytext); return LPAREN; }
")"                   {store_token("Punctuation", yytext); return RPAREN; }
"{"                   {store_token("Punctuation", yytext); return LBRACE; }
"}"                   {store_token("Punctuation", yytext); return RBRACE; }
";"                   {store_token("Punctuation", yytext); return TERMINATOR_SYMBOL; }
","                   {store_token("Punctuation", yytext); return COMMA; }
"="                   {store_token("Operators", yytext); return ASSIGNMENT_OPERATOR; }
"+"                   {store_token("Operators", yytext); return INCREMENT_OPERATOR;}
"<<"                  {store_token("Operators", yytext); return OPERATOR; }
"["                   {store_token("Punctuation", yytext); return LBRACKET; }
"]"                   {store_token("Punctuation", yytext); return RBRACKET; }
"."                   {store_token("Operators", yytext); return DOT;}
[0-9]+             {yylval.num = atoi(yytext);store_token("Literals", yytext); return NUMBER; }
[A-Za-z_][A-Za-z0-9_]* {yylval.id = strdup(yytext);store_token("Identifiers", yytext); return IDENTIFIER; }
[\n]                   {line_number++;}
[ \t\r]+               {  }
.                      {  }
%%

int yywrap() {
    return 1;
}

void print_tokens() {
    printf("Total Tokens : %d\n",token_count);
    printf("=======================================================\n");
    printf("| %-20s | %-15s | %-10s |\n", "Token Type", "Lexeme","Line No.");
    printf("=======================================================\n");

    // Identifiers
    for (int i = 0; i < token_count; i++) {
        if (strcmp(token_list[i].token_type, "Identifiers") == 0) {
            printf("| %-20s | %-15s | %-10d |\n", token_list[i].token_type, token_list[i].lexeme, token_list[i].line_number);
        }
    }
    printf("_______________________________________________________\n");
    // Operators
    for (int i = 0; i < token_count; i++) {
        if (strcmp(token_list[i].token_type, "Operators") == 0) {
            printf("| %-20s | %-15s | %-10d |\n", token_list[i].token_type, token_list[i].lexeme, token_list[i].line_number);
        }
    }
    printf("_______________________________________________________\n");
    // Punctuation
    for (int i = 0; i < token_count; i++) {
        if (strcmp(token_list[i].token_type, "Punctuation") == 0) {
            printf("| %-20s | %-15s | %-10d |\n", token_list[i].token_type, token_list[i].lexeme, token_list[i].line_number);
        }
    }
    printf("_______________________________________________________\n");
    // Keywords
    for (int i = 0; i < token_count; i++) {
        if (strcmp(token_list[i].token_type, "Keyword") == 0) {
            printf("| %-20s | %-15s | %-10d |\n", token_list[i].token_type, token_list[i].lexeme, token_list[i].line_number);
        }
    }
    printf("_______________________________________________________\n");
    // Literals
    for (int i = 0; i < token_count; i++) {
        if (strcmp(token_list[i].token_type, "Literals") == 0) {
            printf("| %-20s | %-15s | %-10d |\n", token_list[i].token_type, token_list[i].lexeme, token_list[i].line_number);
        }
    }
    printf("_______________________________________________________\n");
    // Standard Library function
    for (int i = 0; i < token_count; i++) {
        if (strcmp(token_list[i].token_type, "STL_Function") == 0) {
            printf("| %-20s | %-15s | %-10d |\n", token_list[i].token_type, token_list[i].lexeme, token_list[i].line_number);
        }
    }
    printf("=======================================================\n\n");
}
