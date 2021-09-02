module SilverGarden.Core;

import std.stdio;

import SilverGarden.Lexer;
import SilverGarden.Console;
import SilverGarden.Helpers;
import SilverGarden.Intermediate;

//error codes
const string UnexpectedToken = "10002";
const string ValidObject = "10003";

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
			Statment(CurrentCode);
		}
	}

	private void Statment(IntermediateChunk root) {
		if (current.Token == "import") { //import statments.
			current = scanner.NextToken();
			bool isExtern = false;

			if (current.Token == "extern") { // in case its extern
				isExtern = true;
				current = scanner.NextToken();
			}

			root.children.add(new IntermediateChunk(isExtern ? IntermediateOp.ImportExtern : IntermediateOp.ImportNamespace, current.Token));

			Match(TokenType.StringLiteral, "Expected a StringLiteral", UnexpectedToken);
		} if (current.Token == "namespace") { //namespace definition.
			current = scanner.NextToken();

			if (current.Type != TokenType.StringLiteral) {
				PrintError(UnexpectedToken);
				return;
			}
			CurrentCode = new IntermediateChunk(IntermediateOp.DefineNamespace, current.Token);
		} else if (current.Token == "ifexp") { //amazing, isn't it?
			current = scanner.NextToken();

			IntermediateChunk langCheck = new IntermediateChunk(IntermediateOp.LanguageCheck, current.Token);

			if (!Match(TokenType.StringLiteral, "Expected a StringLiteral in a Language Check.", UnexpectedToken)) {
				return;
			}
			PushOperation(langCheck);

			if (!Match("{", "Expected a Opening Bracket.", UnexpectedToken))
				return;
				
			Block(langCheck);
		} else if (current.Token == "extern") { //calling a external object.
			IntermediateChunk externObject = new IntermediateChunk(IntermediateOp.ExternObject, "");
			
			current = scanner.NextToken();

			if (!Match(".", "Expected a dot", UnexpectedToken)) {
				return;
			}

			Token object = current;

			if (!Match(TokenType.Identifier, "Expected a valid Object.", ValidObject)) {
				return;
			}

			//checking if its a constant or method.
			if (current.Token == "(") { //its a method.
				while (true) {
					if (current.Type == TokenType.Identifier) {
						externObject.children.add(new IntermediateChunk(IntermediateOp.GetObject, current.Token));
					} else {
						externObject.children.add(new IntermediateChunk(IntermediateOp.Push, current.Token));
					}

					current = scanner.NextToken();

					if (current.Token != ",") {
						break;
					}
				}
				if (!Match(")", "Expected a Close Parenthesis.", UnexpectedToken)) {
					return;
				}
				if (!Match(";", "Expected a semicolon.", UnexpectedToken)) {
					return;
				}
			} else { // its an object.
				externObject.children.add(new IntermediateChunk(IntermediateOp.GetObject, object.Token));
				current = scanner.NextToken();
				if (current.Token != ";") {
					PrintError(UnexpectedToken);
					writeln("Expected a semicolon.");
				}
			}

			root.children.add(externObject);
		} else if (current.Type == TokenType.BeginingOfFile) {
			//ignore...
		} else { //if silverc didn't recognized the token
			PrintError(UnexpectedToken);
			writeln("Unexpected Token: \"", current.Token, "\"\n");
		}

		current = scanner.NextToken();
	}

	/*
		Parses a single block.

		a.k.a: 

		{
		.....
		}
	*/
	private void Block(IntermediateChunk root) {
		while (true) {
			if (current.Token == "}") {
				writeln("AAAAA");
				return;
			} else if (current.Type == TokenType.EndOfFile) {
				PrintError(UnexpectedToken);
				writeln("Expected a method closing bracket, not EOF. ");
				return;
			}
			Statment(root);
		}
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

	private bool Match(string expected,string error, string code) {
		if (current.Token != expected) {
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