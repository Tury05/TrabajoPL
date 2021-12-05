%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror (char const *);
extern int yylineno;
%}

%union{
	char *valString;
}

%token <valString> NAME TABLECOLUMN
%token COMMA
%type <valString> columns tables
%start statement

%%
statement:
	columns
	|tables;


columns:
	NAME
	|NAME COMMA columns
	|TABLECOLUMN
	|TABLECOLUMN COMMA columns;

tables:
	NAME
	|NAME COMMA columns;

%%
void success(){
    printf("Sintaxis XML correcta\n");
}

void yyerror (char const *message) { 
    fprintf (stderr, "%s\n", message);

}

int main(int argc, char *argv[]) {
	char *input = (char*)malloc(256);

	printf("#######SQL CODE CREATOR#######\n\n");
	printf("Mostrar:");
	fgets(input, sizeof(input), stdin);
    yy_scan_string(input);
    yyparse();

	input = (char*)realloc(input, 256);
	printf("Tablas:");
	fgets(input, sizeof(input), stdin);
    yy_scan_string(input);
    yyparse();

	free(input);

	return 0;
}
