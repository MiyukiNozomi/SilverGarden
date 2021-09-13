import std.stdio;
import std.algorithm;

import java.util.List;

import SilverGarden.Core;
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
			PrintAndList(startTab ~ "   ",chunk.children);
		}
	}
}

string code = ""; //temporary

void RecursiveWrite(string startWhitespace,List!IntermediateChunk chunkList) { // TODO remake this.
	for (int i = 0; i < chunkList.size(); i++) {
		IntermediateChunk chunk = chunkList.get(i);

		code ~= startWhitespace ~ chunk.operation ~ " \"" ~ chunk.value ~ "\"\n";

		if (chunk.children.size() > 0) {
			RecursiveWrite(startWhitespace ~ " ", chunk.children);
		}

		code ~= startWhitespace ~ "ret\n";
	}
}

void main(string[] args) {
	InitConsole();

	Console.setColor(Coloring.LightBlue, Coloring.Black);
	write("SilverGarden Compiler");
	Console.setColor(Coloring.White, Coloring.Black);
	writeln(" - Version ",__silver__);
	writeln();

	if (args.length < 2) {
		Console.setColor(Coloring.LightRed, Coloring.Black);
		write("Error: ");
		Console.setColor(Coloring.White, Coloring.Black);
		writeln("Expected a Filename? how am i supposed to compile your code if i don't even know what you want to compile?, you might want to have some medical help.");
		Console.resetColor();
		return;
	}

	import std.file : readText, write;

	List!IntermediateChunk list = new ArrayList!IntermediateChunk();

	SilverCore core = new SilverCore();

	if (args[1].endsWith(".silver")) {
		writeln("Hey! do NOT add an extension!");
		writeln("SilverC will already do the extension job.");
	}

	string filename = args[1];

	core.Compile(readText(filename ~ ".silver"), filename ~ ".silver");

	list.add(core.CurrentCode);

	//PrintAndList("", list); no more debbunging
	RecursiveWrite("",list);

	write(filename ~ ".sclass",code);

	Console.resetColor();
}