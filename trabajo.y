%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
int yylex();
void yyerror (char const *);
void * yy_scan_string(const char*);
void success(char* buff1, char* buff2, char* buff3, char* buff4, char* buff5);
char * listOfStrings(char* stringOfTables);
char * quitCorchetes(char* string);
char * atributos;
char * tablas;
char * claves;
char * orden;
char * group_by;
int i = 0;
int join = 0;
int numOfTables = 0;
int numOfRels = 0;
bool rels = false;
int order_by = 0;
%}

%union{
	char *valString;
}

%token <valString> NAME_TABLE NAME_COLUMN COMMA OPEN_KEY CLOSE_KEY
%token ERROR ASC DESC
%type <valString> columns tables keys multiplekeys keys2 order
%start statement

%%
statement:
	columns	{i++;
			if (i==2) //Comprobamos que solo se escriban atributos una vez
				yyerror("Has escrito atributos en vez de tablas");
			else if (i==3)
				yyerror("Has escrito atributos en vez de claves");
			else if (i==5)
				yyerror("No has escrito el orden (ASCENDENTE/DESCENDENTE)");
			else if (i == 1)
				atributos = $1;
			else
				group_by = $1;}
	|tables {i++;
				if (i==1 || i==4) 
					yyerror("Has escrito tablas en vez de atributos");
				
				else if (i==3) 
					yyerror("Has escrito tablas en vez de claves");

				else if (i==5)
					yyerror("Ha escrito tablas en vez de un orden");

				else
					tablas = $1;
			}
	|keys{i++;
			if (i==1 || i==4) 
				yyerror("Has escrito relaciones en vez de atributos");

			else if (i==2) 
				yyerror("Has escrito relaciones en vez de tablas");
			
			else if (i==5)
				yyerror("Ha escrito relaciones en vez de un orden");

			else
				claves = $1;
		}
	|multiplekeys{i++;
					if (i==1 || i==4) 
						yyerror("Has escrito relaciones en vez de atributos");

					else if (i==2) 
						yyerror("Has escrito relaciones en vez de tablas");

					else if (i==5)
						yyerror("Ha escrito relaciones en vez de un orden");

					else
						claves = $1;
				}
	|order{i++;
			if (i==1 || i==4)
				yyerror("Has escrito un orden en vez de solo atributos");
			
			else if (i==2)
				yyerror("Has escrito un orden en vez de tablas");
			
			else if (i==3)
				yyerror("Has escrito un orden en vez de relaciones");
			
			else
				orden = $1;


	}

	|ERROR{yyerror("Parametro incorrecto"); return 0;}
	;

columns:
	NAME_COLUMN	{$1++; $1[strlen($1) - 1] = '\0'; $$ = $1;} /* las dos primeras instrucciones son para quitar las comillas */
	|NAME_COLUMN COMMA columns {$1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, $2), $3); $$ = $1;}
	|NAME_COLUMN COMMA ERROR {yyerror("Nombre de atributo inválido");}
	|ERROR COMMA columns {yyerror("Nombre de atributo de inválido");}
	|ERROR COMMA ERROR {yyerror("Nombres de atributos inválidos");}
	;

tables:
	NAME_TABLE	{numOfTables++;$1++; $1[strlen($1) - 1] = '\0'; $$ = $1;}
	|NAME_TABLE COMMA tables {join=1; numOfTables++; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, $2), $3); $$ = $1;}
	|ERROR COMMA tables {yyerror("Nombre de tabla inválido");}
	|NAME_TABLE COMMA ERROR {yyerror("Nombre de tabla inválido");}
	;

keys:
	OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY {numOfRels++; $2++; $2[strlen($2) - 1] = '\0'; $4++; $4[strlen($4) - 1] = '\0'; strcat(strcat($2, $3), $4); $$ = $2;}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA keys {numOfRels++; $2++; $2[strlen($2) - 1] = '\0'; 
																	$4++; $4[strlen($4) - 1] = '\0'; 
																	strcat(strcat(strcat(strcat($2, $3), $4), $6), $7); 
																	$$ = $2;}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA multiplekeys {numOfRels++; $2++; $2[strlen($2) - 1] = '\0';
																			$4++; $4[strlen($4) - 1] = '\0';
																			strcat(strcat(strcat(strcat($2, $3), $4), $6), $7);
																			$$ = $2;}
	|OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY COMMA keys {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY COMMA multiplekeys {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY COMMA multiplekeys {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY COMMA keys {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA keys {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA multiplekeys {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	;

multiplekeys:	
	OPEN_KEY OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA keys2 CLOSE_KEY {numOfRels++; rels = true; $3++; $3[strlen($3) - 1] = '\0';
																						$5++; $5[strlen($5) - 1] = '\0';
																						strcat(strcat(strcat(strcat(strcat(strcat($1, $3), $4), $5), $7), $8), $9);
																						$$ = $1;}
	|OPEN_KEY OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA keys2 CLOSE_KEY COMMA keys {numOfRels++; rels = true; $3++; $3[strlen($3) - 1] = '\0';
																									$5++; $5[strlen($5) - 1] = '\0';
																									strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcat($1, $3), $4), $5), $7), $8), $9), $10), $11);
																									$$ = $1;}
	|OPEN_KEY OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA keys2 CLOSE_KEY COMMA multiplekeys {numOfRels++; rels = true; $3++; $3[strlen($3) - 1] = '\0';
																									$5++; $5[strlen($5) - 1] = '\0';
																									strcat(strcat(strcat(strcat(strcat(strcat(strcat(strcat($1, $3), $4), $5), $7), $8), $9), $10), $11);
																									$$ = $1;}
	
	|OPEN_KEY OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY COMMA keys2 CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY COMMA keys2 CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA ERROR CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY COMMA ERROR CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY COMMA ERROR CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA keys2 CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA ERROR CLOSE_KEY {yyerror("Clave inválida");}
	;

keys2:
	OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY {$2++; $2[strlen($2) - 1] = '\0'; $4++; $4[strlen($4) - 1] = '\0'; strcat(strcat($2, $3), $4); $$ = $2;}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA keys2 {$2++; $2[strlen($2) - 1] = '\0'; 
																	$4++; $4[strlen($4) - 1] = '\0'; 
																	strcat(strcat(strcat(strcat($2, $3), $4), $6), $7); 
																	$$ = $2;}
	|OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	;

order:
	NAME_COLUMN ASC {order_by=1; $1++; $1[strlen($1) - 1] = '\0'; $$=$1;}
	|NAME_COLUMN DESC {order_by=2; $1++; $1[strlen($1) - 1] = '\0'; $$=$1;}
	|NAME_COLUMN COMMA columns ASC {order_by=1; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, $2), $3); $$=$1;}
	|NAME_COLUMN COMMA columns DESC {order_by=2; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, $2), $3); $$=$1;}
	|ERROR ASC {yyerror("Atributo invalido");}
	|ERROR DESC {yyerror("Atributo invalido");}
	|ERROR COMMA columns ASC {yyerror("Atributo invalido");}
	|ERROR COMMA columns DESC {yyerror("Atributo invalido");}
	|NAME_COLUMN COMMA ERROR ASC {yyerror("Atributo invalido");}
	|NAME_COLUMN COMMA ERROR DESC {yyerror("Atributo invalido");}
	|ERROR COMMA ERROR ASC {yyerror("AtributoS invalido");}
	|ERROR COMMA ERROR DESC {yyerror("AtributoS invalido");}
	;

%%
void success(char* buff1, char* buff2, char* buff3, char* buff4, char* buff5){
	char *save_ptr1, *save_ptr2;
	char *token1 = strtok_r(buff2, ",", &save_ptr1);
	char *token2;
	
	if (numOfTables>(numOfRels+1))								//Verifica que cada dos tablas haya una relacion(de una o varias parejas de claves)
		yyerror("Faltan relaciones FKEY->PKEY");
	
	else if(numOfTables<(numOfRels+1))
		yyerror("Has escrito demasiadas relaciones FKEY->PKEY");

	printf("\n-----Código SQL generado-----\n");
	printf("SELECT %s\nFROM %s\n", buff1, token1);		
		
	if (join == 0) exit(0); // Si solo hay una tabla acaba aquí la ejecución
	token1 = strtok_r(NULL, ",", &save_ptr1);

	if(buff3 != NULL)
		token2 = strtok_r(buff3, ",", &save_ptr2);

	while(token1 != NULL) {										//Bucle para imprimir joins hasta que no queden tablas
		printf("JOIN %s ON ", token1);
		if(!rels){												//Relacion con solo una pareja de claves(keys)
			if ((numOfTables==(numOfRels+1)) && numOfTables==2){
				printf("%s = ", token2);
				token2 = strtok_r(NULL, ",", &save_ptr2);
				printf("%s", token2);
			}
			else if((numOfTables==(numOfRels+1)) && numOfTables>2){
				printf("%s = ", token2);
				token2 = strtok_r(NULL, ",", &save_ptr2);
				printf("%s", token2);
				token2 = strtok_r(NULL, ",", &save_ptr2);
			}
		}
		else{													//Relacion con varias parejas de claves(multiplekeys)
			if(token2[0] == '('){
				token2++;							
				printf("%s = ", token2);
				token2 = strtok_r(NULL, ",", &save_ptr2);
				if(token2[strlen(token2) - 1] == ')'){
					yyerror("Solo una pareja de claves dentro del doble parentesis");
				}
				else{
					printf("%s", token2);
					token2 = strtok_r(NULL, ",", &save_ptr2);
				}
				while(token2[strlen(token2) - 1] != ')') {			//Bucle para escribir todas las claves de una misma relacion(JOIN tabla ON clave1=clave2 AND clave3 = clave4)
					printf(" AND ");
					printf("%s = ", token2);
					token2 = strtok_r(NULL, ",", &save_ptr2);
					if(token2[strlen(token2) - 1] == ')'){
						token2[strlen(token2) - 1] = '\0';
						printf("%s", token2);
						token2[strlen(token2) - 1] = ')';
					}
					else{
						printf("%s", token2);
						token2 = strtok_r(NULL, ",", &save_ptr2);
					}
				}
				token2 = strtok_r(NULL, ",", &save_ptr2);
			}
			else {
				printf("%s = ", token2);
				token2 = strtok_r(NULL, ",", &save_ptr2);
				printf("%s", token2);
				token2 = strtok_r(NULL, ",", &save_ptr2);
			}
		}
		printf("\n");
		token1 = strtok_r(NULL, ",", &save_ptr1);
	}
	if(buff5 != NULL)
		printf("GROUP BY %s\n", buff5);
	
	if(order_by!=0){
		char *save_ptr3;
		char *token3 = strtok_r(buff4, ",", &save_ptr3);
		printf("ORDER_BY %s", token3);
		token3 = strtok_r(NULL, ",", &save_ptr3);
		while(token3 != NULL){
			printf(", %s", token3);
			token3 = strtok_r(NULL, ",", &save_ptr3);
		}
		if (order_by==1)
			printf(" ASC\n");
		else
			printf(" DESC\n");
	}
}

void yyerror(char const *message){
    fprintf (stderr, "Error: %s\n", message);
	exit(0);
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
	bool file = false;
	FILE *f;
	int fd;
	if (argc == 3 && strcmp(argv[1], "-f") == 0) {
		fd = dup(fileno(stdout));
		f = freopen(argv[2], "a", stdout);
		file = true;
	}

	dprintf(fd, "#######SQL CODE CREATOR#######\n\n");
	dprintf(fd, "Atributos a mostrar (\"\"): ");
	fgets(input, 2048, stdin);
	yy_scan_string(input);
	
  	yyparse();

	input = (char*)realloc(input, 2048);
	dprintf(fd, "Tablas a las que pertenecen los atributos (''): ");
	fgets(input, 2048, stdin);
  	yy_scan_string(input);
  	yyparse();

	if (join == 1){
		input = (char*)realloc(input, 2048);
		dprintf(fd, "Relacion FKEY->PKEY: ");
		fgets(input, 2048, stdin);
  		yy_scan_string(input);
  		yyparse();
	}
	else
		i++;				//Para seguir controlando el orden de los inputs

	input = (char*)realloc(input, 2048);
	printf("Agrupar por atributos (opcional): ");
	fgets(input, 2048, stdin);
	if (strlen(input) > 1){
		yy_scan_string(input);
  		yyparse();
	}

	input = (char*)realloc(input, 2048);
	printf("Orden ASCENDENTE/DESCENDENTE por atributos (opcional): ");
	fgets(input, 2048, stdin);
	if (strlen(input) > 1){
		yy_scan_string(input);
  		yyparse();
	}

	if(atributos != NULL && tablas!= NULL){
		if(claves != NULL){
			if(group_by != NULL){
				if(orden!=NULL)
					success(atributos, tablas, claves, orden, group_by);
				else
					success(atributos, tablas, claves, NULL, group_by);
			}
			else{
				if(orden!=NULL)
					success(atributos, tablas, claves, orden, NULL);
				else
					success(atributos, tablas, claves, NULL, NULL);
			}
		}
		else{
			if(group_by != NULL){
				if(orden!=NULL)
					success(atributos, tablas, NULL, orden, group_by);
				else
					success(atributos, tablas, NULL, NULL, group_by);
			}
			else{
				if(orden!=NULL)
					success(atributos, tablas, NULL, orden, NULL);
				else
					success(atributos, tablas, NULL, NULL, NULL);
			}
		}
	}

	if (file) fclose(f);
	free(input);
	return 0;
}
