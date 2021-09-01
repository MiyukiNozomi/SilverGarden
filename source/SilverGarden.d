module SilverGarden.Core;

import std.stdio;

import SilverGarden.Lexer;
import SilverGarden.Console;
import SilverGarden.Helpers;
import SilverGarden.Intermediate;

//error codes
const string UnexpectedToken = "10002";

public class SilverCore {

	private Lexer scanner;
	private Token current;
	public IntermediateChunk CurrentCode;
	private string source, filename;

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
		this.source = code;
		this.filename = filename;

		scanner = new Lexer(code);
		current = new Token("", 0, 0, TokenType.BeginingOfFile);


		/*
			In this Phase, SilverC will parse:
			* Methods
			* Objects
			* Constants
			* Export-Language-Checks
			* Classes
		*/
		while (current.Type != TokenType.EndOfFile) {
			current = scanner.NextToken();

			if (current.Token == "namespace") {
				current = scanner.NextToken();

				if (current.Type != TokenType.StringLiteral) {
					PrintError(UnexpectedToken);
					return;
				} else {
					CurrentCode = new IntermediateChunk(IntermediateOp.DefineNamespace, current.Token);
				}
			} else if (current.Token == "ifexp") {
				current = scanner.NextToken();

				IntermediateChunk langCheck = new IntermediateChunk(IntermediateOp.LanguageCheck, current.Token);

				Match(TokenType.StringLiteral, "Expected a StringLiteral in a Language Check.", "10002");
				
				PushOperation(langCheck);
			} else {
				PrintError(UnexpectedToken);
				writeln("Unexpected Token: \"", current.Token, "\"\n");
			}
		}
	}

	private void Block() {

	}

	//just to have a clean parser 
	private bool Match(TokenType expected,string error, string code) {
		if (current.Type != expected) {
			PrintError(code);
			writeln(error);
			current = scanner.NextToken();
			return false;
		}
		current = scanner.NextToken();
		return true;
	}

	private void PushOperation(IntermediateChunk operation) {
		if (CurrentCode is null)
			CurrentCode = new IntermediateChunk(IntermediateOp.DefineNamespace, "Default");

		CurrentCode.children.add(operation);
	}

	private void PrintError(string code) {
        int line = 1, col = 0;
        getLocation(source, current.Position, line, col); 
        Console.setColor(Coloring.LightRed, Coloring.Black);
        write("S", code, " Error at ", filename);
        Console.setColor(Coloring.White, Coloring.Black);
        write("(", line,",", col, "):\n    ");
        Console.setColor(Coloring.Gray, Coloring.Black);
    }
}