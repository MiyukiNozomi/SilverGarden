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
const string InvalidBody = "10003";
const string InvalidStructure = "10004";
const string InvalidFactor = "10005";
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
		} else if (current.Token == "if" || current.Token == "while") { //generic check operation, can be a loop or not
			IntermediateChunk expression = new IntermediateChunk(current.Token == "while" ? IntermediateOp.WhileStatment : IntermediateOp.IfStatment, "");
			current = scanner.NextToken();

			CheckBlock(expression);
			
			if (!Match("{", "Expected a LPAREN", InvalidBody))
				return;

			IntermediateChunk expBlock = new IntermediateChunk(IntermediateOp.CheckBlock, "");

			Block(expBlock);
			expression.children.add(expBlock);

			Root.children.add(expression);
		} else if (current.Token == "for") {
			current = scanner.NextToken();
			Match("(","Expected a LPAREN", InvalidBody);

			string name, type;

			if(!Definition(name, type)) {
				return;
			}

			IntermediateChunk forDefinement = new IntermediateChunk(IntermediateOp.DefineObject, type ~ "," ~ name ~ ",local");
			writeln(current.Token);
			if (current.Token == "=") {
				Expression(forDefinement);
			} else {
				if(!Match(";", "Expected a semicolon", InvalidStructure)) {
					return;
				}
			}

			IntermediateChunk forCondition = new IntermediateChunk(IntermediateOp.CheckExpression, "");

			Expression(forCondition);

			IntermediateChunk forOperation = new IntermediateChunk(IntermediateOp.CheckExpression, "");

			Expression(forOperation);

		} else if (current.Type == TokenType.AccessModifier) {
			string accessType = current.Token;
			current = scanner.NextToken();

			/*
				quick summary here

				"what the heck is this for?"

				EntryPoint's (a.k.a Main()) are required to 
				match an argument or have none. also, they can't return
				any value

				EntryPoint Examples

				//standard
				public @Entry Main() {
	
				}

				//with args
				public @Entry Main(String[] args) {
	
				}

				fun fact: the name doesn't matter :)
			*/
			if (current.Token == "@Entry") {
				//skip the name, sorry :)
				current = scanner.NextToken();

				//just kidding i won't
				string name = current.Token;

				if (!Match(TokenType.Identifier, "Expected a valid name", UnexpectedToken))
					return; //avoid people doing bullshit like using { as a name.

				if (!Match("(", "Expected a LPAREN", UnexpectedToken))
					return;

				string varName = "";

				//now this is kinda of a turning point.
				if (current.Token == "String") {//requires an argument.
					current = scanner.NextToken();
					if (!Match("[", "Expected an Array.", UnexpectedToken))
						return;
					if (!Match("]", "Expected an Array.", UnexpectedToken))
						return;

					if (current.Type != TokenType.Identifier) { //expect valid names
						PrintError(UnexpectedToken);
						writeln("Expected a valid name.");
						return;
					}

					varName = current.Token;

					current = scanner.NextToken();
					if (!Match(")", "Expected a RPAREN", UnexpectedToken))
						return;
				} else if (current.Token == ")") {
					//no argument. its fine. just skip it
					current = scanner.NextToken();
				}

				if (!Match("{", "Expected a Block.", UnexpectedToken))
					return;


				IntermediateChunk main_func = new IntermediateChunk(IntermediateOp.EntryPoint, (varName != "") ? (name ~ "," ~ varName) : name);

				Block(main_func);

				Root.children.add(main_func);
			} else { // just another generic field, method or class/struct
				string name, type;

				if (!Definition(name, type)) {
					return;
				}

				IntermediateChunk definement;

				if (current.Token == "(") {
					//in case its a method
					definement = new IntermediateChunk(IntermediateOp.DefineMethod, type ~ "," ~ name ~ "," ~ accessType);
					
					while (true) {
						current = scanner.NextToken();
						if (current.Token == ")")
							break;
						if (current.Type == TokenType.EndOfFile) {
							PrintError(InvalidBody);
							writeln("Expected a valid argument body.");
							return;
						}

						if (current.Type == TokenType.Identifier) {
							string atype, aname;

							if(!Definition(aname, atype)) {
								return;
							}

							definement.children.add(new IntermediateChunk(IntermediateOp.ArgumentDefine, atype ~ "," ~ aname));
							
							if (current.Token == ",") {
								//ok
							} else if (current.Token == ")") {
								break;
							} else {
								PrintError(UnexpectedToken);
								writeln("Expected a valid method.");
								return;
							}
						}
					}

					if (!Match(")", "Expected a RPAREN",UnexpectedToken))
						return;
					if (!Match("{", "Expected a BLOCK ENTRY.", UnexpectedToken))
						return;

					Block(definement);
				} else if (current.Token == "=") {
					//in case its an expression
					definement = new IntermediateChunk(IntermediateOp.DefineObject, type ~ "," ~ name ~ "," ~ accessType);

					IntermediateChunk assignOp = new IntermediateChunk(IntermediateOp.Assign, "");
					Expression(assignOp);
					definement.children.add(assignOp);
				} else if (current.Token == ";") {
					//in case its just a field declaration
					definement = new IntermediateChunk(IntermediateOp.DefineObject, type ~ "," ~ name ~ "," ~ accessType);
				} else {
					PrintError(UnexpectedToken);
					writeln("Expected a valid field structure, not \"",current.Token,"\""," type: ", current.Type);
					return;
				}

				Root.children.add(definement);
 			}
		} else {
			PrintError(UnexpectedToken);
			writeln("Unrecognized Token: ",current.Token, " of type: ", current.Type);
		}
	}

	private IntermediateChunk Factor() {
		Token tok = current;
		if (current.Type == TokenType.IntegerLiteral ||
			current.Type == TokenType.FloatLiteral ||
			current.Type == TokenType.DoubleLiteral ||
			current.Type == TokenType.HexadecimalLiteral ||
			current.Type == TokenType.StringLiteral) {
			current = scanner.NextToken();
			
			return new IntermediateChunk(IntermediateOp.Push, tok.Token ~ "," ~ tok.Type);
		} else if (current.Type == TokenType.Identifier) {
			return new IntermediateChunk(IntermediateOp.Push, tok.Token);
		} else {
			PrintError(InvalidFactor);
			writeln("Invalid Factor \"", current.Token, " : ", current.Type,"\"");
		}
		return new IntermediateChunk(IntermediateOp.Push, "0");
	}

	private void BinaryOp(IntermediateChunk root) {
		IntermediateChunk left = Factor();

		while (this.current.Type == TokenType.Operator) {

			string operation = current.Token;
			current = scanner.NextToken();
			IntermediateChunk right = Factor();
			IntermediateChunk newOperation = new IntermediateChunk(IntermediateOp.Operator, operation);
			newOperation.children.add(left.copy);
			newOperation.children.add(right);
			left = newOperation;
		}
		
		root.children.add(left);
	}

	private bool Expression(IntermediateChunk root) {
		current = scanner.NextToken();
		BinaryOp(root);
		if (current.Token != ";") {
			PrintError(UnexpectedToken);
			writeln("Expected a semicolon, not \"", current.Token, "\"");
			return false;
		}
		return true;
	}

	private void CheckBlock(IntermediateChunk root) {
		if(!Match("(", "Expected a RPAREN", InvalidBody))
			return;

		IntermediateChunk checkExpression = new IntermediateChunk(IntermediateOp.CheckExpression, "");

		BinaryOp(checkExpression);

		if (!Match(")", "Expected a LPAREN", InvalidBody))
			return;

		root.children.add(checkExpression);
	}

	private bool Definition(out string name, out string type) {
		//first, type.
		name = "";
		type = "";

		if (current.Type != TokenType.Identifier) {
			PrintError(InvalidStructure);
			writeln("Expected a valid type.");
			return false;
		}

		type = current.Token;

		current = scanner.NextToken();

		if (current.Token == "*") { //aw fack, pointer!
			type ~= "*";
			current = scanner.NextToken();
		}

		if (current.Token == "&") { //aw fack, reference!
			type ~= "&";
			current = scanner.NextToken();
		}

		if (current.Token == "[") { //aw shit, array!
			current = scanner.NextToken();
			if (current.Token == "]") {
				current = scanner.NextToken();
				type ~= "[]";
			} else {
				PrintError(InvalidStructure);
				writeln("tutorial on how to make an array: " ~ type ~ "[], done.");
				return false;
			}
		}

		//now, the name.
		if (current.Type == TokenType.Identifier) { // valid
			name = current.Token;
		} else { // invalid.
			PrintError(InvalidStructure);
			writeln("Expected a valid name :(");
			return false;
		}

		current = scanner.NextToken();

		return true;
	}

	private void Block(IntermediateChunk Root) {
		while (true) {
			if (current.Type == TokenType.EndOfFile) {
				PrintError(InvalidBody);
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