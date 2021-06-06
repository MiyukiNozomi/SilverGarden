/* The Shinoa Programming Language
 this C source was made by the Shinoa Compiler.
 this means that this was a class or a struct in the source code,
 now its turned into a C header, and a C file.*/
/* Shinoa Version: 0.1.7*/ 

#include "Console.shinoa.h"
void constructor_Console(Console* inst) {
}
/* @public */ void log(Console* inst,const char* message ) {
printf ( message , "\n") ; } 

