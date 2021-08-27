module ReisenLanguage.Core;

import std.stdio;

import ReisenLanguage.Lexer;
import ReisenLanguage.Helpers;
import ReisenLanguage.Console;
import ReisenLanguage.Intermediate;

class Reisen {
    public:
        Lexer scanner;

        void Compile(string filename, string source) {
            scanner = new Lexer(source);

            while (scanner.HasNextToken()) {
                IntermediateChunk chunk;
                Token t = scanner.NextToken();

                if (t.Token == "namespace") {
                    
                } else {
                    Console.setColor(Coloring.Red, Coloring.White);
                    int line = 1, col = 0;
                    getLocation(source, t.Position, line, col); 
                    write("Error R0004 at ", filename);
                    Console.setColor(Coloring.Black, Coloring.White);
                    write("(", line,",", col, "): ");
                    writeln("Unrecognized Token \"", t.Token, "\" of type \"", t.Type,"\"");
                }
            }
        }
}