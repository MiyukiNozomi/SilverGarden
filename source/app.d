import std.utf;
import std.stdio;

import shinoa.lang.Shinoa;
import shinoa.lang.terminal;
import shinoa.reflect.Token;
import shinoa.reflect.Parser;
import shinoa.reflect.Tokenizer;
import shinoa.reflect.Compiler;

import shinoa.reflect.Class;

static bool onlyTokens = false;

void main(string[] args) {
	initTerminal();

	console.setColor(Color.magenta, Color.black_background);
	write("Shinoa");
	console.setColor(Color.light_cyan, Color.black_background);
	write("Compiler ");
	console.setColor(Color.white, Color.black_background);

	write("Version ", Shinoa.getVersion());

	writeln();

	if (args.length == 1) {
		writeln();

		console.setColor(Color.red, Color.black_background);
        writeln("No Input Files!");
		console.resetColor();
        writeln();
		return;
	}

	import std.file : readText;
	string file = readText(args[1]);

	for (int i = 2; i < args.length; i++) {
		if (args[i] == "--onlyTokens") {
			onlyTokens = true;
		} else {
			writeln("Unknown Arg: ",args[i]);
		}
	}

	Tokenizer tokenizer = new Tokenizer(args[1],file);
	
	if (onlyTokens) {
		while (tokenizer.hasNextToken()) {
			Token t = tokenizer.nextToken();

			writeln("------------------");
			writeln("TOKEN: ", t.getToken() ,"\n TYPE:", t.getType());
		}
		return;
	}
 
	Parser parser = new Parser();

	Class clazz = parser.parse(tokenizer);
	
	writeln();
	writeln();

	if (clazz !is null) {
		
		import std.file;

		Compiler compiler = new Compiler(clazz);

		string header = compiler.createHeader();
		string implementation = compiler.createSource();

		File fheader = File(args[1] ~ ".h", "w"); 
   		fheader.writeln(header);
   		fheader.close(); 

		File fimpl = File(args[1] ~ ".c", "w"); 
   		fimpl.writeln(implementation);
   		fimpl.close(); 

		console.setColor(Color.light_blue, Color.black_background);
		writeln("The ShinoaCompiler has exited with exit code 0.");
	} else {
		console.setColor(Color.red, Color.black_background);
		writeln("The ShinoaCompiler has exited with exit code -1.");
	}

	console.resetColor();
}