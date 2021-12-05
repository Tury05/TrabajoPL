%{
#include <stdbool.h>
#include "trabajo.tab.h"
%}
%option yylineno
digit               [0-9]
alphabet            [a-zA-Z]
name                ({alphabet}|"_")({alphabet}|{digit})*
namedotname         {name}\.{name}
comillas            [\"\']
comma               ,
delim               [ \t]	

%%
{delim}+            {}
{name}              {yylval.valString = strdup(yytext); return NAME;}
{namedotname}       {yylval.valString = strdup(yytext); return TABLECOLUMN;} /*"TABLA"."COLUMNA" -> (Empleados.idEmpleado)*/
{comillas}          {return COMILLAS;} /*Los nombres de las columnas y tablas deben ir entre comillas*/
{comma}             {return COMMA;} /*Si hay varias tablas, columnas... se deben separar con comas.*/
%%