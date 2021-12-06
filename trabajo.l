%{
#include "trabajo.tab.h"
#include <stdbool.h>
%}
%option yylineno
digit               [0-9]
alphabet            [a-zA-Z]
name                ({alphabet}|"_")({alphabet}|{digit})*
namedotname         {name}\.{name}
table_name          (Table-)({name})
column_name         (Column-)({name})
comillas            [\"\']
comma               ,
delim               [ \t\n]

%%
{delim}+            {}

{name}              {yylval.valString = strdup(yytext); return NAME;}

{table_name}        {/*yylval.valString = strdup(yytext); return NAME_TABLE;*/}
{column_name}       {/*yylval.valString = strdup(yytext); return NAME_COLUMN;*/}

{namedotname}       {yylval.valString = strdup(yytext); return TABLECOLUMN;} /*"TABLA"."COLUMNA" -> (Empleados.idEmpleado)*/
{comma}             {return COMMA;} /*Si hay varias tablas, columnas... se deben separar con comas.*/
%%
