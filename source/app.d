import std.utf;
import std.stdio;
import std.file : readText;

import shinoa.lang.Shinoa;
import shinoa.lang.terminal;
import shinoa.reflect.Token;
import shinoa.reflect.Parser;
import shinoa.reflect.Tokenizer;

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

	if (clazz !is null) {
		writeln(clazz);
	}
}