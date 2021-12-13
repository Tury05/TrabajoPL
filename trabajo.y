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
char* getKeys(char* string);
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

%token <valString> NAME_TABLE NAME_COLUMN COMMA OPEN_KEY CLOSE_KEY
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
						tablas = listOfStrings($1);
				}
			}
	|keys{i++;
			if (i==1) 
				handleError(3);

			else if (i==2) 
				handleError(6);

			else{
				if(numOfTables==2){
					claves = getKeys($1);
					success2(atributos, tablas, claves);
				}
				else{
					claves = listOfStrings(getKeys($1));
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
	NAME_TABLE	{$1++; $1[strlen($1) - 1] = '\0'; $$ = $1;}
	|NAME_TABLE COMMA tables {join=1; numOfTables+=2; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, $2), $3); $$ = $1;}
	/* Con el JOIN hay que poner el ON y los dos atributos que son iguales en las tablas, pero creo que es imposible saber cuáles son */
	;

keys:
	OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY {/*$2++;*/ $2[strlen($2) - 1] = '\0'; $4++; /*$4[strlen($4) - 1] = '\0';*/ strcat(strcat($2, $3), $4); $$ = $2;}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA keys {numOfRel+=2;$2++; $2[strlen($2) - 1] = '\0'; 
																	$4++; $4[strlen($4) - 1] = '\0'; 
																	strcat(strcat(strcat(strcat(strcat(($1, $2), $3), $4), $5), $6), $7); 
																	$$ = $1;}
	;

%%
void success(char* buff1, char* buff2){
    printf("Código SQL generado:\n");
	printf("SELECT %s\nFROM %s\n", buff1, buff2);
}

void success2(char* buff1, char* buff2, char* buff3){
	printf("\n-----Código SQL generado-----\n");
	printf("SELECT %s\nFROM %s\n", buff1, buff2);
	buff2 = strtok(NULL, ",");
	
	while( buff2 != NULL ) {
		printf("JOIN %s ON ", buff2);
		if (numOfRel==0){
			buff3 = listOfStrings(buff3);
			printf("%s = ", buff3);
			buff3 = strtok(NULL, ",");
			printf("%s\n", buff3);
		}

		else{
			for(int j=1; j<=numOfRel/2;j++){
				printf("%s = %s AND", buff3, buff2);
			}
			printf("%s = %s", buff3, buff2);
		}
		buff2 = strtok(NULL, ",");
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
	char *token = strtok(string, ",");
	return token;
}

char* getKeys(char* string){
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
