%{
#include "trabajo.tab.h"
#include <stdbool.h>
%}
digit               [0-9]
alphabet            [a-zA-Z]
name                ({alphabet}|"_")({alphabet}|{digit})*
namedotname         {name}"."{name}
table_name          \'{name}\'
column_name         \"({name}|{namedotname})\"
comma               ,
open_key            "("
close_key           ")"
order_asc           "ascendente"|"ASCENDENTE"|"Ascendente"|"ASC"|"asc"
order_desc          "descendente"|"DESCENDENTE"|"Descendente"|"DESC"|"desc"
delim               [ \t\n]

%%
{delim}+            {}
{table_name}        {yylval.valString = strdup(yytext); return NAME_TABLE;}
{column_name}       {yylval.valString = strdup(yytext); return NAME_COLUMN;}
{open_key}          {yylval.valString = strdup(yytext); return OPEN_KEY;}
{close_key}         {yylval.valString = strdup(yytext); return CLOSE_KEY;}
{order_asc}         {return ASC;}
{order_desc}        {return DESC;}
{comma}             {yylval.valString = strdup(yytext); return COMMA;} /*Si hay varias tablas, columnas... se deben separar con comas.*/
.                   {return ERROR;}
%%
