import std.stdio;

import java.util.List;

import ReisenLanguage.Intermediate;
import ReisenLanguage.Console;
import ReisenLanguage.Lexer;
import ReisenLanguage.Core;

int __reisen__ = 0000001;

//debuging
void PrintAndList(string startTab, List!IntermediateChunk chunkList) {
	for (int i = 0; i < chunkList.size(); i++) {
		IntermediateChunk chunk = chunkList.get(i);

		Console.setColor(Coloring.LightBlue, Coloring.Black);
		write(startTab, chunk.operation, " ");
		Console.setColor(Coloring.White, Coloring.Black);
		writeln(startTab, chunk.value);

		if (chunk.children.size() > 0) {
			PrintAndList(startTab ~ "	",chunk.children);
		}
	}
}

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

	List!IntermediateChunk finalCode = reisen.Compile("Example.reisen", a);

	PrintAndList("", finalCode);

	Console.resetColor();
}