# ShinoaCompiler
The Compiler of a programming language that is compiled to C. nothing else.
its class-based, static-typed with all things that C has.

# Things that i have to add.
* comments
* structs
* Import methods from C files
* a lot of important stuff that i can't remember.

# Disclaimer
this thing is still under development, 
for now, there is no C code generation for now.

# Syntax
Example
```java
import "shinoa.console"; //module that contains the Console class.

public class Test { //class definition
	public static native int main() { //main method, requires static and native attributes.
		Console.log("Hello, World!");  //call Console.log(String) with the message "Hello, World!"
		
		return 0; //return 0 :)
	}
}
```

# The Expected Result

the expected result should be this: 
```c
#include <shinoa_console.h>
typedef struct {
} Test;

int main() {
	Console_log("Hello, World!");
	return 0;
}
```

# how it works? 

first, the CLASS-DEFINITION space is only for imports, and for the class definition itself.
there is no user-defined modules and packages for now.

# Breaking a Class into a language that doesn't has classes

# Fields
for fields, they can be just translated into a struct
```java
public class FieldExample {
	public int a;
	public int b;
	public int c;
	public int d;
}
```
to
```c
typedef struct {
	int a;
	int b;
	int c;
	int d;
} FieldExample;
```

# Methods
for non-static methods, in C they will require an instance of the struct that contains the class's fields.
(the extern attribute is only for the main method. for now)
```java
public class MethodAndFieldExample {
	public int a;
	
	public void foo() {
		this.a = 10;
	}
}
```

to C 
```c
typedef struct {
	int a;
} MethodAndFieldExample;

void MethodAndFieldExample_foo(MethodAndFieldExample* instance) {
	instance.a = 10;
}
```

*Important: there are no constructors

# Static Methods and Fields
For both of them, they are just defined in C as a static variable with the class name in the begining

```java
public class StaticMethodsAndFields {
	public static int a;
	
	public static void foo() {
		a = 10;
	}
}
```

in C
```c
static int StaticMethodsAndFields_a;

static void StaticMethodsAndFields_foo() {
	StaticMethodsAndFields_a = 10;
}
```