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
%token COMILLAS COMMA
%type <valString> columns tables
%start statement

%%
statement:

%%
void success(){
    printf("Sintaxis XML correcta\n");
}

void yyerror (char const *message) { 
    fprintf (stderr, "%s\n", message);

}

int main(int argc, char *argv[]) {
extern FILE *yyin;

	switch (argc) {
		case 1:	yyin=stdin;
			yyparse();
			break;
		case 2: yyin = fopen(argv[1], "r");
			if (yyin == NULL) {
				printf("ERROR: No se ha podido abrir el fichero.\n");
			}
			else {
				yyparse();
				fclose(yyin);
			}
			break;
		default: printf("ERROR: Demasiados argumentos.\nSintaxis: %s [fichero_entrada]\n\n", argv[0]);
	}

	return 0;
}
