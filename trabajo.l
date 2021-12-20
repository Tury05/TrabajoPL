%{
#include "trabajo.tab.h"
#include <stdbool.h>
%}
digit               [0-9]
alphabet            [a-zA-Z]
name                ({alphabet}|"_")({alphabet}|{digit})*
between             "entre"|"ENTRE"|"between"|"BETWEEN"
in                  "en"|"dentro de"|"in"|"EN"|"DENTRO DE"|"IN"
null                "nulo"|"NULO"|"NULL"|"null"
is                  "es"|"ES"|"is"|"IS"
not                 "no"|"NO"|"not"|"NOT"|"no esta"|"NO ESTA"
equal               "igual a"|"igual"|"="|"IGUAL A"|"IGUAL"|EQUALS
lower               "menor que"|"menor"|"<"|"MENOR QUE"|"MENOR"
lowereq             "menor o igual que"|"menor o igual"|"<="|"MENOR O IGUAL QUE"|"MENOR O IGUAL"
higher              "mayor que"|"mayor"|">"|"MAYOR QUE"|"MAYOR"
highereq            "mayor o igual que"|"mayor o igual"|">="|"MAYOR O IGUAL QUE"|"MAYORO IGUAL"
distinto            "distinto a"|"distinto"|"<>"|"DISTINTO A"|"DISTINTO"
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
{equal}             {return EQUAL;}
{lower}             {return LOWER;}
{higher}            {return HIGHER;}
{lowereq}           {return LOWEREQ;}
{highereq}          {return HIGHEREQ;}
{between}           {return BETWEEN;}
{in}                {return IN;}
{order_asc}         {return ASC;}
{order_desc}        {return DESC;}
{null}              {return NULO;}
{is}                {return IS;}
{not}               {return NOT;}
{distinto}          {return DISTINTO;}
{digit}+            {yylval.valString = strdup(yytext); return NUMBER;}
{alphabet}+         {yylval.valString = strdup(yytext); return STRING;}
{comma}             {yylval.valString = strdup(yytext); return COMMA;} /*Si hay varias tablas, columnas... se deben separar con comas.*/
.                   {return ERROR;}
%%
