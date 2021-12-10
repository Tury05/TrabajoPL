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
int join = 0;
%}

%union{
	char *valString;
}

%token <valString> NAME_TABLE NAME_COLUMN
%token COMMA OPEN_KEY CLOSE_KEY
%type <valString> columns tables keys
%start statement

%%
statement:
	columns	{i++;
			if (i!=1)
				yyerror("Debe escribir con comillas simples");
			else
				atributos = $1;}
	|tables {if (i == 1) {
				tablas = $1;
				success(atributos, tablas);
			}
			else yyerror("Debe escribir con comillas dobles");}
	|keys
	;

columns:
	NAME_COLUMN	{$1++; $1[strlen($1) - 1] = '\0'; $$ = $1;} /* las dos primeras instrucciones son para quitar las comillas */
	|NAME_COLUMN COMMA columns {$1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, ", "), $3); $$ = $1;}
	;

tables:
	NAME_TABLE	{$1++; $1[strlen($1) - 1] = '\0'; $$ = $1;}
	|NAME_TABLE COMMA tables {$1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, " JOIN "), $3); $$ = $1;}
	/* Con el JOIN hay que poner el ON y los dos atributos que son iguales en las tablas, pero creo que es imposible saber cuáles son */
	;

keys:
	OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA keys
	;

%%
void success(char* buff1, char* buff2){
    printf("Código SQL generado:\n");
	printf("SELECT %s\nFROM %s\n", buff1, buff2);
}

void yyerror (char const *message) {
    fprintf (stderr, "Error: %s\n", message);
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

	if (join == 1){
		input = (char*)realloc(input, 2048);
		printf("Relacion clave-primaria/clave-foranea: ");
		fgets(input, 2048, stdin);
  		yy_scan_string(input);
  		yyparse();
	}


	free(input);
	return 0;
}
