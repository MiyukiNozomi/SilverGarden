module SilverGarden.Core;

import std.stdio;

import SilverGarden.Lexer;
import SilverGarden.Console;
import SilverGarden.Helpers;
import SilverGarden.Intermediate;

public class SilverCore {

	private Lexer scanner;
	private Token current;
	public IntermediateChunk CurrentCode;

	/*
		Compile Method.
		Don't be confused by thinking that
		"Hey look! so this is where it compiles into C++!"
		No.
		this is the front-end compiler, it gets a SilverGarden source code,
		and transpiles it into a sort of Intermediate Code.

		Basically, you have this program:
			namespace "Something"

			import "Silver.Core"

			@EntryPoint
			public void Entry() {
				Console.Println("Hello, World!");
			}
		It will turn your program into:
			DefineNamespace "Something"
			ImportNamespace "Silver.Core"
			EntryPoint
				Get "Console"
					Push "Hello, World!"
					Call "Println"
		This is still a high-level representation, because first, 
		the intermediate code is almost unreadable, because there isn't
		identation, and second, operation names are shorted into 2-6 characters;
		don't expect a .sil file to have any tabs, spaces or even lines. 
	*/
	public void Compile(string code, string filename) {

		scanner = new Lexer(code);
		current = scanner.NextToken();

		while (current.Type != TokenType.EndOfFile) {
			/*
				In this level, SilverC will parse:
				* Methods
				* Objects
				* Constants
				* Export-Language-Checks
				* Classes
			*/
			if (current.Token == "namespace") {
				current = scanner.NextToken();

				if (current.Type != TokenType.StringLiteral) {
					PrintError(code, filename, current, "10001");
					return;
				} else {
					CurrentCode = new IntermediateChunk(IntermediateOp.DefineNamespace, current.Token);
				}
			} else if (current.Token == "ifexp") {

			} else {
				PrintError(code, filename, current, "10002");
				writeln("Unexpected Token: \"", current.Token, "\"\n");
			}

			current = scanner.NextToken();
		}
	}

	private void Block() {

	}

	private void PushOperation(IntermediateChunk operation) {
		if (CurrentCode is null)
			CurrentCode = new IntermediateChunk(IntermediateOp.DefineNamespace, "Default");

		CurrentCode.children.add(operation);
	}

	private void PrintError(string source, string filename, Token t, string code) {
        int line = 1, col = 0;
        getLocation(source, t.Position, line, col); 
        Console.setColor(Coloring.LightRed, Coloring.Black);
        write("S", code, " Error at ", filename);
        Console.setColor(Coloring.White, Coloring.Black);
        write("(", line,",", col, "):\n    ");
        Console.setColor(Coloring.Gray, Coloring.Black);
    }
}