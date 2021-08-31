import std.stdio;

import java.util.List;

import SilverGarden.Intermediate;
import SilverGarden.Console;
import SilverGarden.Lexer;

string __silver__ = "0400001";

//debuging
void PrintAndList(string startTab, List!IntermediateChunk chunkList) {
	for (int i = 0; i < chunkList.size(); i++) {
		IntermediateChunk chunk = chunkList.get(i);

		Console.setColor(Coloring.LightBlue, Coloring.Black);
		write(startTab, chunk.operation, " ");
		Console.setColor(Coloring.White, Coloring.Black);
		writeln(chunk.value);

		if (chunk.children.size() > 0) {
			PrintAndList(startTab ~ "	",chunk.children);
		}
	}
}

void main() {
	InitConsole();

	Console.setColor(Coloring.LightBlue, Coloring.Black);
	write("SilverGarden Compiler");
	Console.setColor(Coloring.White, Coloring.Black);
	writeln(" - Version ",__silver__);
	writeln();

	import std.file : readText;



	Console.resetColor();
}