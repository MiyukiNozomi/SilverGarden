module ReisenLanguage.Core;

import std.stdio;

import ReisenLanguage.Lexer;
import ReisenLanguage.Console;

class Reisen {
    public:
        Lexer scanner;

        void Compile(string source) {
            scanner = new Lexer(source);

            while (scanner.HasNextToken()) {
                Token t = scanner.NextToken();

                Console.setColor(Coloring.Gold, Coloring.Black);
                write(t.Type, ": ");
                Console.setColor(Coloring.White, Coloring.Black);
                writeln(t.Token);
            }
        }
}