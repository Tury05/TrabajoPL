
Autores: Arturo Ramos Rey y Manuel Corujo Muíña

El objetivo de esta práctica es proporcionar una intefaz interactiva al usuario, de modo que le resulte más fácil realizar consultas SQL. 
Se le irán haciendo preguntas y parseando sus respuestas, para finalmente imprimir la conulta resultado (por salida estándar por defecto, en un fichero si se ejecuta make run2).

Los ficheros que componen la práctica son el analizador léxico -trabajo.l- y el analizador sintáctico -trabajo.y-, además de un Makefile para facilitar la compilación y ejecución. 
Para compilar y ejecutar la práctica lo recomendable es hacer uso del Makefile. Este tiene la orden compile para compilar todo, run para ejecución normal (salida por stdout), run2 para ejecución con salida por fichero y clean para eliminar todos los ficheros salvo los fuentes. 
Además, incluye una variable llamada SALIDA en la que se guarda el nombre del archivo en el que se guarda la salida en caso de ejecutar run2.

El analizador léxico es bastante sencillo; tan solo reconoce los tokens necesarios (alguno de ellos con valor semántico) para que los lea el anaizador sintáctico. 
Lo único a comentar es que de algún modo debe diferenciar los nombres de los atributos de los nombres de tabla, para lo que decidimos que los nombres de atributos se deben escribir entre comillas dobles ("") 
y los nombres de tabla entre comillas simples (''). 
El analizador sintáctico ya es más complejo. Su funcionamiento consiste en ir realizando preguntas al usuario, y a medida que ésta vaya respondiendo se va llamando a yyparse() para parsear las respuestas de forma individual. 
Así, por cada respuesta del usuario se produce una llamada a yyparse(). La gramática en un primer vistazo puede parecer muy compleja, pero la razón del elevado número de reglas es el control de errores; si no los controlásemos la gramática se vería mucho más sencilla.

Los errores que se controlan son que las respuestas del usuario sean a las preguntas que se hacen (comprobar que cuando se pide que introduzca nombres de tablas realmente introduzca nombres de tablas y no nombres de atributos, por ejemplo), 
que el número de claves sea igual al número de tablas menos uno, que los nombres de tablas y atributos sean válidos y que para los atributos escritos de la forma "tabla.atributo" esa tabla se indique también en la pregunta de tablas a seleccionar.
