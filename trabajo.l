%{
#include "trabajo.tab.h"
#include <stdbool.h>
%}
%option yylineno
digit               [0-9]
alphabet            [a-zA-Z]
name                ({alphabet}|"_")({alphabet}|{digit})*
namedotname         {name}"."{name}
table_name          \'{name}\'
column_name         \"({name}|{namedotname})\"
comma               ,
delim               [ \t\n]

%%
{delim}+            {}

{table_name}        {yylval.valString = strdup(yytext); return NAME_TABLE;}
{column_name}       {yylval.valString = strdup(yytext); return NAME_COLUMN;}

{comma}             {return COMMA;} /*Si hay varias tablas, columnas... se deben separar con comas.*/
%%
