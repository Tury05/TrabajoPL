%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
void yyerror (char const *);
void *yy_scan_string(const char*);
void success(char* buff1, char* buff2);
void success2(char* buff1, char* buff2, char* buff3);
void handleError(int error);
char *listOfStrings(char* stringOfTables);
char* quitCorchetes(char* string);
char * atributos;
char * tablas;
char * claves;
int i = 0;
int join = 0;
int numOfTables = 0;
int numOfRel = 0;
%}

%union{
	char *valString;
}

%token <valString> NAME_TABLE NAME_COLUMN COMMA
%token OPEN_KEY CLOSE_KEY
%token ERROR
%type <valString> columns tables keys
%start statement

%%
statement:
	columns	{i++;
			if (i==2) //Comprobamos que solo se escriban atributos una vez
				handleError(1);
			else if (i==3) //Comprobamos que solo se escriban atributos una vez
				handleError(4);
			else
				atributos = $1;}
	|tables {i++;
				if (i==1) 
					handleError(2);
				
				else if (i==3) 
					handleError(5);

				else{
					if (join == 0){
						tablas = $1;
						success(atributos, tablas);
					}
					else if (join == 1)
						tablas = $1;
				}
			}
	|keys{i++;
			if (i==1) 
				handleError(3);

			else if (i==2) 
				handleError(6);

			else{
				if(numOfTables==2){
					claves = $1;
					success2(atributos, tablas, claves);
				}
				else{
					claves = $1;
					success2(atributos, tablas, claves);
				}
			}
		}
	|ERROR{yyerror("Algo hiciste mal :P"); return 0;}
	;

columns:
	NAME_COLUMN	{$1++; $1[strlen($1) - 1] = '\0'; $$ = $1;} /* las dos primeras instrucciones son para quitar las comillas */
	|NAME_COLUMN COMMA columns {$1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, $2), $3); $$ = $1;}
	|NAME_COLUMN COMMA ERROR {yyerror("Atributo invalido");}
	;

tables:
	NAME_TABLE	{numOfTables++;$1++; $1[strlen($1) - 1] = '\0'; $$ = $1;}
	|NAME_TABLE COMMA tables {join=1; numOfTables++; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, $2), $3); $$ = $1;}
	/* Con el JOIN hay que poner el ON y los dos atributos que son iguales en las tablas, pero creo que es imposible saber cuáles son */
	;

keys:
	OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY {numOfRel++; $2++; $2[strlen($2) - 1] = '\0'; $4++; $4[strlen($4) - 1] = '\0'; strcat(strcat($2, $3), $4); $$ = $2;}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA keys {numOfRel++; $2++; $2[strlen($2) - 1] = '\0'; 
																	$4++; $4[strlen($4) - 1] = '\0'; 
																	strcat(strcat(strcat(strcat($2, $3), $4), $6), $7); 
																	$$ = $2;}
	;

%%
void success(char* buff1, char* buff2){
    printf("Código SQL generado:\n");
	printf("SELECT %s\nFROM %s\n", buff1, buff2);
}

void success2(char* buff1, char* buff2, char* buff3){
	char *save_ptr1, *save_ptr2;
	char *token1 = strtok_r(buff2, ",", &save_ptr1);
	char *token2 = strtok_r(buff3, ",", &save_ptr2);
	printf("\n-----Código SQL generado-----\n");
	printf("SELECT %s\nFROM %s\n", buff1, token1);
	token1 = strtok_r(NULL, ",", &save_ptr1);

	while( token1 != NULL ) {
		printf("JOIN %s ON ", token1);
		if ((numOfTables==(numOfRel+1)) && numOfTables==2){
			printf("%s = ", token2);
			token2 = strtok_r(NULL, ",", &save_ptr2);
			printf("%s\n", token2);
		}
		else if((numOfTables==(numOfRel+1)) && numOfTables>2){
			printf("%s = ", token2);
			token2 = strtok_r(NULL, ",", &save_ptr2);
			printf("%s\n", token2);
			token2 = strtok_r(NULL, ",", &save_ptr2);
		}
		token1 = strtok_r(NULL, ",", &save_ptr1);
	}
}

void yyerror(char const *message){
    fprintf (stderr, "Error: %s\n", message);
	exit(0);
}

void handleError(int error){
	if (error==1)
		yyerror("Has escrito atributos en vez de tablas");
	
	else if (error==2)
		yyerror("Has escrito tablas en vez de atributos");
	
	else if (error==3)
		yyerror("Has escrito claves en vez de atributos");
	
	else if (error==4)
		yyerror("Has escrito atributos en vez de claves");
	
	else if (error==5)
		yyerror("Has escrito tablas en vez de claves");
	
	else if (error==6)
		yyerror("Has escrito claves en vez de tablas");
}

char *listOfStrings(char* string){
	char *save_ptr1;
	char *token = strtok_r(string, ",", &save_ptr1);
	return token;
}

char* quitCorchetes(char* string){
	char * keys = strdup(string);
	keys++;
	keys[strlen(keys) - 1] = '\0';
	return keys;
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
		printf("Relacion FKEY->PKEY: ");
		fgets(input, 2048, stdin);
  		yy_scan_string(input);
  		yyparse();
	}


	free(input);
	return 0;
}
