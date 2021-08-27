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
        void PrintError(string source, string filename, Token t, string code) {
            Console.setColor(Coloring.Red, Coloring.White);
            int line = 1, col = 0;
            getLocation(source, t.Position, line, col); 
            write("Error R", code," at ", filename);
            Console.setColor(Coloring.Black, Coloring.White);
            write("(", line,",", col, "): ");
        }
}