module ReisenLanguage.Core;

import std.stdio;

import ReisenLanguage.Lexer;

class Reisen {
    public:
        Lexer scanner;

        void Compile(string source) {
            scanner = new Lexer();

            
        }
}