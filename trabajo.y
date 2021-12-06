%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
void yyerror (char const *);
extern int yylineno;
char * atributos;
char * tablas;
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
	columns	{printf("Atributos: %s\n", $1); atributos = $1;}
	|tables {printf("Tablas: %s\n", $1); tablas = $1;}
	;

columns:
	NAME	{$$ = $1;}
	|NAME COMMA columns {strcat($$, $1);}
	|TABLECOLUMN {strcat($$, $1);}
	|TABLECOLUMN COMMA columns {strcat($$, $1);}
	;

tables:
	NAME	{$$ = $1;}
	|NAME COMMA tables {strcat($$, $1);}
	;

%%
void success(){
    printf("Código SQL generado:\n");
	printf("SELECT %s FROM %s\n", atributos, tablas);
}

void yyerror (char const *message) {
    fprintf (stderr, "%s\n", message);
	exit(1);
}

int main(int argc, char *argv[]) {
	char *input = (char*)malloc(256);
	void *yy_scan_string(const char*);

	printf("#######SQL CODE CREATOR#######\n\n");
	printf("Atributos a mostrar: ");
	fgets(input, sizeof(input), stdin);
  	yy_scan_string(input);
  	yyparse();

	input = (char*)realloc(input, 256);
	printf("Tablas a las que pertenecen los atributos: ");
	fgets(input, sizeof(input), stdin);
  	yy_scan_string(input);
  	yyparse();

	success();

	free(input);

	return 0;
}
