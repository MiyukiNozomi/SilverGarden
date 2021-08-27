module ReisenLanguage.Core;

import std.stdio;

import java.util.List;
import ReisenLanguage.Lexer;
import ReisenLanguage.Helpers;
import ReisenLanguage.Console;
import ReisenLanguage.Intermediate;

class Reisen {
    public:
        Lexer scanner;

        List!IntermediateChunk Compile(string filename, string source) {
            scanner = new Lexer(source);
            List!IntermediateChunk intermediateCode = new ArrayList!IntermediateChunk();

            while (scanner.HasNextToken()) {
                IntermediateChunk chunk;
                Token t = scanner.NextToken();

                if (t.Token == "namespace") {
                    t = scanner.NextToken();

                    if (t.Type == TokenType.StringLiteral) {
                        chunk = new IntermediateChunk(IntermediateOp.DefineNamespace, t.Token);
                    } else {   
                        PrintError(source, filename, t, "R0005");
                        writeln("Expected a StringLiteral Token for a namespace definition., not \"", t.Token, "\"");
                    }
                } else if (t.Token == "import") {
                    t = scanner.NextToken();

                    bool isExtern = false;
                    string namespace = "";

                    if (t.Token == "extern") {
                        isExtern = true;
                        t = scanner.NextToken();
                    }

                    if (t.Type == TokenType.StringLiteral) {
                        namespace = t.Token;
                    } else {   
                        PrintError(source, filename, t, "R0005");
                        writeln("Expected a StringLiteral Token for a import statment., not \"", t.Token, "\"");
                        continue;
                    }

                    chunk = new IntermediateChunk(isExtern ? IntermediateOp.ImportExtern : IntermediateOp.ImportNamespace, namespace);
                } else if (t.Type == TokenType.AccessModifier) {
                    chunk = ParseField(source, filename);
                } else {
                    if (t.Token == ";")
                        continue;
                    PrintError(source, filename, t, "R0004");
                    writeln("Unrecognized Token \"", t.Token, "\" of type \"", t.Type,"\"");
                }

                if (chunk !is null) {
                    intermediateCode.add(chunk);
                }
            }

            return intermediateCode;
        }
    private:
        IntermediateChunk ParseField(string source, string filename) {
            Token t = scanner.NextToken();

            if (t.Token == "__EntryPoint")  {
                //main method found mate!
                t = scanner.NextToken();

                if (t.Type != TokenType.Identifier) {
                    PrintError(source, filename, t, "R0006");
                    writeln("Expected a valid entrypoint name, not \"", t.Token, "\"");
                    return null;
                }

                t = scanner.NextToken();

                if (t.Token == "(") {
                    t = scanner.NextToken();
                    if (t.Token != "String") { //require "String[] args" as an argument in entrypoints.
                        PrintError(source, filename, t, "R0007");
                        writeln("Expected a valid entrypoint method. a.k.a add String[] args as an argument :)");
                        return null;
                    }
                    t = scanner.NextToken();
                    if (t.Token != "[") {
                        PrintError(source, filename, t, "R0007");
                        writeln("Expected a valid entrypoint method. a.k.a add String[] args as an argument :)");
                        return null;
                    }
                    t = scanner.NextToken();
                    if (t.Token != "]") {
                        PrintError(source, filename, t, "R0007");
                        writeln("Expected a valid entrypoint method. a.k.a add String[] args as an argument :)");
                        return null;
                    }
                    t = scanner.NextToken();
                    if (t.Type != TokenType.Identifier) {
                        PrintError(source, filename, t, "R0007");
                        writeln("Expected a valid entrypoint method. a.k.a add String[] args as an argument :)");
                        return null;
                    }
                    
                    t = scanner.NextToken();
                    if (t.Token != ")") {
                        PrintError(source, filename, t, "R0007");
                        writeln("Expected a valid entrypoint method. a.k.a make it a function pls :3");
                        return null;
                    }
                } else {
                    PrintError(source, filename, t, "R0007");
                    writeln("Expected a valid entrypoint method. a.k.a make it a function pls :3");
                    return null;
                }
            } else { // just a simple field or method :)
                if (t.Type != TokenType.Identifier) {
                    PrintError(source, filename, t, "R0008");
                    writeln("Expected a valid field or method type, not \"", t.Token,"\" of type \"", t.Type,"\"");
                    return null;
                }

                string type = t.Token;

                t = scanner.NextToken();

                if (t.Type != TokenType.Identifier) {
                    PrintError(source, filename, t, "R0009");
                    writeln("Expected a field or method name, not \"", t.Token,"\" of type \"", t.Type,"\"");
                    return null;
                }

                string name = t.Token;

                t = scanner.NextToken();

                if (t.Token == "(") {

                } else if (t.Token == "=") {
                    IntermediateChunk chunk = new IntermediateChunk(IntermediateOp.DefineVar, type ~ "," ~ name);

                    Token last = t;

                    while (t.Token != ";" && t.Type != TokenType.EndOfFile) {
                        t = scanner.NextToken();
                        if (t.Token == ";" || t.Type == TokenType.EndOfFile)
                            break;                       
                        if (t.Token == "+") {
                            t = scanner.NextToken();
                            if (t.Type == TokenType.Symbol) {
                                PrintError(source, filename, last, "R0012");
                                writeln("Expected a valid mathematical operation.");
                                return null;
                            }

                            chunk.children.add(new IntermediateChunk(IntermediateOp.Add, name ~ "," ~ t.Token));
                        } else {
                            chunk.children.add(new IntermediateChunk(IntermediateOp.AssignObject, name ~ "," ~ t.Token));
                        }
                    }

                    if (t.Type == TokenType.EndOfFile) {
                        PrintError(source, filename, last, "R0011");
                        writeln("Expected a semicolon.");
                        return null;
                    }

                    return chunk;
                } else if (t.Token == ";") {
                    return new IntermediateChunk(IntermediateOp.DefineVar, type ~ "," ~ name);
                } else {
                    PrintError(source, filename, t, "R0010");
                    writeln("Expected a field or method body");
                    return null;
                }
            }   

            return null;               
        }
    
        void PrintError(string source, string filename, Token t, string code) {
            Console.setColor(Coloring.Red, Coloring.White);
            int line = 1, col = 0;
            getLocation(source, t.Position, line, col); 
            write("Error R", code," at ", filename);
            Console.setColor(Coloring.Black, Coloring.White);
            write("(", line,",", col, "): ");
        }
}