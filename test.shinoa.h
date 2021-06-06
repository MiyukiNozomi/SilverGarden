/* The Shinoa Programming Language
 this C header was made by the Shinoa Compiler.
 this means that this was a class or a struct in the source code,
 now its turned into a C header, and a C file.*/
/* Shinoa Version: 0.1.7*/ 

#include <shinoac/shinoa.console.h>
/* @public */ static int resultOfAnExpression;


typedef struct {
     /* @private */int test;
     /* @private */const char* something;
}test;

void constructor_test(test* inst);
/* @public */ void doSomething(test* inst,const char* a );
/* @public */ int uSuck(test* inst);
/* int main(); */
