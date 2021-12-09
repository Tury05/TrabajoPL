%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
void yyerror (char const *);
void *yy_scan_string(const char*);
void success(char* buff1, char* buff2);
extern int yylineno;
char * atributos;
char * tablas;
int i = 0;
%}

%union{
	char *valString;
}

%token <valString> NAME_TABLE NAME_COLUMN
%token COMMA
%type <valString> columns tables
%start statement

%%
statement:
	columns	{i++;
			if (i>1)
				yyerror("Debe escribir con comillas simples");
			else
				atributos = $1;}
	|tables {tablas = $1;
			success(atributos, tablas);}
	;

columns:
	NAME_COLUMN	{$$ = $1;}
	|NAME_COLUMN COMMA columns {strcat($1, $3); $$ = $1;}
	;

tables:
	NAME_TABLE	{$$ = $1;}
	|NAME_TABLE COMMA tables {strcat($1, $3); $$ = $1;}
	;

%%
void success(char* buff1, char* buff2){
    printf("Código SQL generado:\n");
	printf("SELECT %s\nFROM %s\n", buff1, buff2);
}

void yyerror (char const *message) {
    fprintf (stderr, "Error: %s\n", message);
	exit(1);
}

int main(int argc, char *argv[]) {
	char *input = (char*)malloc(2048);

	printf("#######SQL CODE CREATOR#######\n\n");
	printf("Atributos a mostrar (\"\"): ");
	fgets(input, 2048, stdin);
	yy_scan_string(input);
	
  	yyparse();

	input = (char*)realloc(input, 2048);
	printf("Tablas a las que pertenecen los atributos (''): ");
	fgets(input, 2048, stdin);
  	yy_scan_string(input);
  	yyparse();

	free(input);
	return 0;
}
