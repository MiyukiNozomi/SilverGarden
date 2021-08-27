import std.stdio;

import ReisenLanguage.Console;
import ReisenLanguage.Lexer;
import ReisenLanguage.Core;

int __reisen__ = 0000001;

void main() {
	InitConsole();

	Console.setColor(Coloring.Purple, Coloring.Black);
	write("DMD Reisen Language Compiler");
	Console.setColor(Coloring.White, Coloring.Black);
	writeln(" - Version ",__reisen__);
	writeln();

	import std.file : readText;

	string a = readText("Example.reisen");

	Reisen reisen = new Reisen();

	reisen.Compile("Example.reisen", a);

	Console.resetColor();
}