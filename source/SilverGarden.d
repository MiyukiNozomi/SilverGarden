module SilverGarden.Core;

import std.stdio;

import SilverGarden.Lexer;
import SilverGarden.Console;
import SilverGarden.Helpers;
import SilverGarden.Intermediate;

/*
	quick explanation from docs/ErrorCodes.html

	"
		Errors have their codes bettwen 10000-19999
		Warnings have their codes bettwen 20000-29999
		Informations have their codes bettwen 30000-39999
	                        								"
*/

//error codes
const string UnexpectedToken = "10002";
const string ValidObject = "10003";

//warning codes
const string DeprecatedOperation = "20001";

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
		indentation, and second, operation names are shorted from 2 to 6 characters, so
		don't expect a .sil file to have any tabs, spaces or even multiple lines. 
	*/
	public void Compile(string code, string filename) {
		this.source = code;
		this.filename = filename;

		scanner = new Lexer(code);
		current = new Token("", 0, 0, TokenType.BeginingOfFile);


		/*
			In this Phase, SilverC will parse everything in the global space.
			this has almost the same functionallity as the Block() method.
			the difference is instead of working with {}, it works from the 
			Begining of the file, to the end of the ifle.
		*/
		while (true) {
			current = scanner.NextToken();
			if (current.Type == TokenType.EndOfFile)
				break;

			if (CurrentCode is null) {
				CurrentCode = new IntermediateChunk(IntermediateOp.DefineNamespace, "Default"); // avoid problems
			}
			Statment(CurrentCode);
		}
	}

	private void Statment(IntermediateChunk Root) {
		if (current.Token == "namespace") {
			current = scanner.NextToken();

			if (current.Type == TokenType.StringLiteral) 
				CurrentCode = new IntermediateChunk(IntermediateOp.DefineNamespace, current.Token);
			else 
				Match(TokenType.StringLiteral, "Expected a StringLiteral.", UnexpectedToken);
		} else if (current.Token == "import") {
			current = scanner.NextToken();

			bool isExtern = false;

			if (current.Token == "extern") {
				current = scanner.NextToken();
				isExtern = true;
			}

			string namespace = current.Token;

			if (current.Type == TokenType.StringLiteral) {
				Root.children.add(new IntermediateChunk(isExtern ? IntermediateOp.ImportExtern : IntermediateOp.ImportNamespace, namespace));
			} else {
				PrintError(UnexpectedToken);
				writeln("Expected a StringLiteral that Represents a namespace.");
			}
		} else if (current.Token == "ifexp") {
			current = scanner.NextToken();

			IntermediateChunk languageCheck;

			string lang = current.Token;

			if (Match(TokenType.StringLiteral, "Expected a String Literal", UnexpectedToken)) {

				if (!Match("{", "Expected a LPAREN", UnexpectedToken))
					return;
				languageCheck = new IntermediateChunk(IntermediateOp.LanguageCheck, lang);

				Block(languageCheck);

				Root.children.add(languageCheck);
			}
		} else {
			PrintError(UnexpectedToken);
			writeln("Unrecognized Token: ",current.Token, " of type: ", current.Type);
		}
	}

	private void Block(IntermediateChunk Root) {
		while (true) {
			if (current.Type == TokenType.EndOfFile) {
				PrintError(UnexpectedToken);
				writeln("Expected a RPAREN.");
				break;
			}
			if (current.Token == "}") {
				break; // just break it. the current block is done ;)
			}

			Statment(Root);
			current = scanner.NextToken();
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

	private void PrintWarn(string code) {
        int line = 1, col = 0;
        getLocation(source, current.Position, line, col); 
        Console.setColor(Coloring.Yellow, Coloring.Black);
        write("S", code, " Error at ", filename);
        Console.setColor(Coloring.White, Coloring.Black);
        write("(", line,",", col, "):\n    ");
        Console.setColor(Coloring.Gray, Coloring.Black);
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