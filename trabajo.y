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
void success(char* buff1, char* buff2, char* buff3, char* buff4, char* buff5, char* buff6);
char * listOfStrings(char* stringOfTables);
char * atributos;
char * tablas;
char * claves = NULL;
char * where = NULL;
char * orden = NULL;
char * group_by = NULL;
int i = 0;
int join = 0;
int numOfTables = 0;
int numOfRels = 0;
bool rels = false;
int order_by = 0;
int where_type;
%}

%union{
	char *valString;
}

%token <valString> NAME_TABLE NAME_COLUMN COMMA OPEN_KEY CLOSE_KEY STRING NUMBER
%token ERROR ASC DESC EQUAL LOWER HIGHER LOWEREQ HIGHEREQ IN BETWEEN NULO IS NOT DISTINTO
%type <valString> columns tables keys multiplekeys keys2 order where string number clauses
%start statement

%%
statement:
	columns	{i++;
			if (i==2) //Comprobamos que solo se escriban atributos una vez
				yyerror("Has escrito atributos en vez de tablas");		
			else if (i==3)
				yyerror("Has escrito atributos en vez de claves");			
			else if (i==4)
				yyerror("Has escrito atributos en vez de cláusulas");		
			else if (i==6)
				yyerror("No has escrito el orden (ASCENDENTE/DESCENDENTE)");			
			else if (i == 1)
				atributos = $1;		
			else
				group_by = $1;}
	|tables {i++;
				if (i==1 || i==5) 
					yyerror("Has escrito tablas en vez de atributos");				
				else if (i==3) 
					yyerror("Has escrito tablas en vez de claves");				
				else if (i==4)
					yyerror("Has escrito tablas en vez de cláusulas");
				else if (i==6)
					yyerror("Ha escrito tablas en vez de un orden");
				else
					tablas = $1;
			}
	|keys{i++;
			if (i==1 || i==5) 
				yyerror("Has escrito relaciones en vez de atributos");
			else if (i==2) 
				yyerror("Has escrito relaciones en vez de tablas");			
			else if (i==4)
					yyerror("Has escrito relaciones en vez de cláusulas");			
			else if (i==6)
				yyerror("Ha escrito relaciones en vez de un orden");
			else
				claves = $1;
		}
	|multiplekeys{i++;
					if (i==1 || i==5) 
						yyerror("Has escrito relaciones en vez de atributos");
					else if (i==2) 
						yyerror("Has escrito relaciones en vez de tablas");				
					else if (i==4)
						yyerror("Has escrito relaciones en vez de cláusulas");
					else if (i==6)
						yyerror("Ha escrito relaciones en vez de un orden");
					else
						claves = $1;
				}
	|order{i++;
			if (i==1 || i==5)
				yyerror("Has escrito un orden en vez de solo atributos");		
			else if (i==2)
				yyerror("Has escrito un orden en vez de tablas");		
			else if (i==3)
				yyerror("Has escrito un orden en vez de relaciones");		
			else if (i==4)
					yyerror("Has escrito un orden en vez de cláusulas");			
			else
				orden = $1;
		}
	|where{i++;
			if (i==1 || i==5)
				yyerror("Has escrito cláusulas en vez de solo atributos");		
			else if (i==2)
				yyerror("Has escrito cláusulas en vez de tablas");		
			else if (i==3)
				yyerror("Has escrito cláusulas en vez de relaciones");		
			else if (i==6)
						yyerror("Ha escrito cláusulas en vez de un orden");
			else
				where = $1;
		}

	|ERROR{yyerror("Parámetro incorrecto"); return 0;}
	;

columns:
	NAME_COLUMN	{$1++; $1[strlen($1) - 1] = '\0'; $$ = $1;} /* las dos primeras instrucciones son para quitar las comillas */
	|NAME_COLUMN COMMA columns {$1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, ", "), $3); $$ = $1;}
	|NAME_COLUMN COMMA ERROR {yyerror("Nombre de atributo inválido");}
	|ERROR COMMA columns {yyerror("Nombre de atributo inválido");}
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
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY {yyerror("Claves inválidas");}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY COMMA keys {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY COMMA multiplekeys {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY COMMA multiplekeys {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY COMMA keys {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA keys {yyerror("Claves inválidas");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA multiplekeys {yyerror("Claves inválidas");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA ERROR {yyerror("Claves inválidas");}
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
	|OPEN_KEY OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY COMMA ERROR CLOSE_KEY {yyerror("Claves inválidas");}
	|OPEN_KEY OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY COMMA ERROR CLOSE_KEY {yyerror("Claves inválidas");}
	|OPEN_KEY OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA keys2 CLOSE_KEY {yyerror("Claves inválidas");}
	|OPEN_KEY OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA ERROR CLOSE_KEY {yyerror("Claves inválidas");}
	;

keys2:
	OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY {$2++; $2[strlen($2) - 1] = '\0'; $4++; $4[strlen($4) - 1] = '\0'; strcat(strcat($2, $3), $4); $$ = $2;}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA keys2 {$2++; $2[strlen($2) - 1] = '\0'; 
																	$4++; $4[strlen($4) - 1] = '\0'; 
																	strcat(strcat(strcat(strcat($2, $3), $4), $6), $7); 
																	$$ = $2;}
	|OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY {yyerror("Claves inválidas");}
	|OPEN_KEY NAME_COLUMN COMMA NAME_COLUMN CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	|OPEN_KEY ERROR COMMA ERROR CLOSE_KEY COMMA ERROR {yyerror("Claves inválidas");}
	|OPEN_KEY ERROR COMMA NAME_COLUMN CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	|OPEN_KEY NAME_COLUMN COMMA ERROR CLOSE_KEY COMMA ERROR {yyerror("Clave inválida");}
	;

order:
	NAME_COLUMN ASC {order_by=1; $1++; $1[strlen($1) - 1] = '\0'; $$=$1;}
	|NAME_COLUMN DESC {order_by=2; $1++; $1[strlen($1) - 1] = '\0'; $$=$1;}
	|NAME_COLUMN COMMA columns ASC {order_by=1; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, $2), $3); $$=$1;}
	|NAME_COLUMN COMMA columns DESC {order_by=2; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, $2), $3); $$=$1;}
	|ERROR ASC {yyerror("Atributo inválido");}
	|ERROR DESC {yyerror("Atributo inválido");}
	|ERROR COMMA columns ASC {yyerror("Atributo inválido");}
	|ERROR COMMA columns DESC {yyerror("Atributo inválido");}
	|NAME_COLUMN COMMA ERROR ASC {yyerror("Atributo inválido");}
	|NAME_COLUMN COMMA ERROR DESC {yyerror("Atributo inválido");}
	|ERROR COMMA ERROR ASC {yyerror("Atributos inválidos");}
	|ERROR COMMA ERROR DESC {yyerror("Atributos inválidos");}
	;

where:
	NAME_COLUMN EQUAL clauses {where_type = 1; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, ","), $3); $$=$1;}         											
	|NAME_COLUMN LOWER NUMBER {where_type = 2; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, ","), $3); $$=$1;}
	|NAME_COLUMN HIGHER NUMBER {where_type = 3; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, ","), $3); $$=$1;}
	|NAME_COLUMN LOWEREQ NUMBER {where_type = 4; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, ","), $3); $$=$1;}
	|NAME_COLUMN HIGHEREQ NUMBER {where_type = 5; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, ","), $3); $$=$1;}
	|NAME_COLUMN DISTINTO clauses {where_type = 6; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat($1, ","), $3); $$=$1;}
	|NAME_COLUMN IN STRING COMMA string {where_type = 7; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat(strcat(strcat($1, ","), $3), $4), $5); $$=$1;}
	|NAME_COLUMN IN NUMBER COMMA number {where_type = 7; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat(strcat(strcat($1, ","), $3), $4), $5); $$=$1;}
	|NAME_COLUMN BETWEEN STRING COMMA STRING {where_type = 8; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat(strcat(strcat($1, ","), $3), $4), $5); $$=$1;}
	|NAME_COLUMN BETWEEN NUMBER COMMA NUMBER {where_type = 8; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat(strcat(strcat($1, ","), $3), $4), $5); $$=$1;}
	|NAME_COLUMN NOT IN STRING COMMA string {where_type = 9; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat(strcat(strcat($1, ","), $4), $5), $6); $$=$1;}
	|NAME_COLUMN NOT IN NUMBER COMMA number {where_type = 9; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat(strcat(strcat($1, ","), $4), $5), $6); $$=$1;}
	|NAME_COLUMN NOT BETWEEN STRING COMMA STRING {where_type = 10; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat(strcat(strcat($1, ","), $4), $5), $6); $$=$1;}
	|NAME_COLUMN NOT BETWEEN NUMBER COMMA NUMBER {where_type = 10; $1++; $1[strlen($1) - 1] = '\0'; strcat(strcat(strcat(strcat($1, ","), $4), $5), $6); $$=$1;}
	|NAME_COLUMN IS NOT NULO {where_type = 11; $1++; $1[strlen($1) - 1] = '\0'; $$=$1;}
	|NAME_COLUMN NOT IS NULO {where_type = 11; $1++; $1[strlen($1) - 1] = '\0'; $$=$1;}
	|NAME_COLUMN IS NULO {where_type = 12; $1++; $1[strlen($1) - 1] = '\0'; $$=$1;}
	;

clauses:
	STRING {$$ = $1;}
	|NUMBER {$$ = $1;}
	;

string:
	STRING {$$ = $1;}
	|STRING COMMA string {strcat($1, $3); $$ = $1;}
	;

number:
	NUMBER {$$ = $1;}
	|NUMBER COMMA number {strcat($1, $3); $$ = $1;}
	;


%%
void success(char* buff1, char* buff2, char* buff3, char* buff4, char* buff5, char* buff6){
	char *save_ptr1, *save_ptr2;
	char *token1 = strtok_r(buff2, ",", &save_ptr1);
	char *token2;
	
	if (numOfTables>(numOfRels+1))								//Verifica que cada dos tablas haya una relacion(de una o varias parejas de claves)
		yyerror("Faltan relaciones FKEY->PKEY");
	
	else if(numOfTables<(numOfRels+1))
		yyerror("Demasiadas relaciones FKEY->PKEY");

	printf("\n-----Código SQL generado-----\n");
	printf("SELECT %s\nFROM %s\n", buff1, token1);		
		
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

	if (buff6 != NULL){
		char *save_ptr3;
		char *token3 = strtok_r(buff6, ",", &save_ptr3);
		printf("WHERE %s ", token3);
		switch(where_type){
			case 1:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("= %s", token3);
				break;
			case 2:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("< %s", token3);
				break;
			case 3:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("> %s", token3);
				break;
			case 4:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("<= %s", token3);
				break;
			case 5:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf(">= %s", token3);
				break;
			case 6:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("<> %s", token3);
				break;
			case 7:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("IN (%s", token3);
				while (token3!=NULL){
					token3 = strtok_r(NULL, ",", &save_ptr3);
					printf(", %s", token3);
				}
				printf(")");
				break;
			case 8:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("BETWEEN %s AND ", token3);
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("%s", token3);
				break;
			case 9:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("NOT IN (%s", token3);
				while (token3!=NULL){
					token3 = strtok_r(NULL, ",", &save_ptr3);
					printf(", %s", token3);
				}
				printf(")");
				break;
			case 10:
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("NOT BETWEEN %s AND ", token3);
				token3 = strtok_r(NULL, ",", &save_ptr3);
				printf("%s", token3);
				break;
			case 11:
				printf("IS NOT NULL");
				break;
			case 12:
				printf("IS NULL");
				break;
		}
		printf("\n");
	}

	if(buff5 != NULL)
		printf("GROUP BY %s\n", buff5);
	
	if(order_by!=0){
		char *save_ptr4;
		char *token4 = strtok_r(buff4, ",", &save_ptr4);
		printf("ORDER_BY %s", token4);
		token4 = strtok_r(NULL, ",", &save_ptr4);
		while(token4 != NULL){
			printf(", %s", token4);
			token4 = strtok_r(NULL, ",", &save_ptr4);
		}
		if (order_by==1)
			printf(" ASC\n");
		else
			printf(" DESC\n");
	}
	printf(";\n");
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

void check_attributes(char* buff1, char* buff2) {
	char str1[50];
	char str2[50];
	int i = 0, j = 0, k = 0, l = 0, start = 0, success = 1;
	while (buff1[i] != '\0') {
		if (buff1[i] == '.') {
			j = i;
			while ((buff1[j-1] != ',') && j>0) {
				j--;
			}
			k = 0;
			while ((buff2[k] != '\0')) {
				if (buff2[k] == buff1[j]) {
					l = 0;
					while ((buff2[k] != ',') && (buff2[k] != '\0')) {
						str1[l] = buff1[j];
						str2[l] = buff2[k];
						l++;
						j++;
						k++;
					}
					success = strcmp(str1, str2);
				}
				if (success == 0) {
					break;
				}
				k++;
			}
			if (success != 0) {
				yyerror("La tabla indicada en los atributos no fue seleccionada en las tablas");
			}
		}
		if (success == 0) success++;
		i++;
	}
}

int main(int argc, char *argv[]) {
	char *input = (char*)malloc(2048);
	bool file = false;
	FILE *f;
	int fd = dup(fileno(stdout));
	
	if (argc == 3 && strcmp(argv[1], "-f") == 0) {
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

	check_attributes(atributos, tablas);

	if (join == 1){
		input = (char*)realloc(input, 2048);
		dprintf(fd, "Relación FKEY->PKEY: ");
		fgets(input, 2048, stdin);
  		yy_scan_string(input);
  		yyparse();
	}
	else
		i++;				//Para seguir controlando el orden de los inputs

	input = (char*)realloc(input, 2048);
	dprintf(fd, "Cláusulas where (opcional): ");
	fgets(input, 2048, stdin);
	if (strlen(input) > 1){
		yy_scan_string(input);
  		yyparse();
	}
	else	
		i++;

	input = (char*)realloc(input, 2048);
	dprintf(fd, "Agrupar por atributos (opcional): ");
	fgets(input, 2048, stdin);
	if (strlen(input) > 1){
		yy_scan_string(input);
  		yyparse();
	}
	else	
		i++;

	input = (char*)realloc(input, 2048);
	dprintf(fd, "Orden ASCENDENTE/DESCENDENTE por atributos (opcional): ");
	fgets(input, 2048, stdin);
	if (strlen(input) > 1){
		yy_scan_string(input);
  		yyparse();
	}
	else	
		i++;

	success(atributos, tablas, claves, orden, group_by, where);

	if (file) {
		dprintf(fd, "\nConsulta SQL escrita correctamente en %s\n", argv[2]);
		fclose(f);
	}
	free(input);
	return 0;
}
