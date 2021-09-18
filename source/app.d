import std.stdio;
import std.algorithm;

import java.util.List;

import SilverGarden.Core;
import SilverGarden.Intermediate;
import SilverGarden.Console;
import SilverGarden.Lexer;
import SilverGarden.Helpers;

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
			code ~= startWhitespace ~ "ret\n";
		}
	}
}

bool DebugCode = false;

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

	for (int i = 2; i < args.length; i++) {
		if (args[i] == "/debug-c" || args[i] == "--debug-c") {
			DebugCode = true;
		} else {
			Console.setColor(Coloring.Red, Coloring.Black);
			write("Error: ");
			Console.setColor(Coloring.White, Coloring.Black);
			writeln("Unrecognized Option: ", args[i]);
		}
	}

	import std.file : readText, write;

	List!IntermediateChunk list = new ArrayList!IntermediateChunk();

	SilverCore core = new SilverCore();

	string filename = args[1];

	if (filename.endsWith(".silver")) {
		writeln("Hey! do NOT add an extension!");
		writeln("SilverC will already do the extension job.");
		filename = filename.subString(0, filename.length - 7);
		writeln("Extension removed, it's now: ", filename);
	}

	core.Compile(readText(filename ~ ".silver"), filename ~ ".silver");

	list.add(core.CurrentCode);

	if (DebugCode) {
		PrintAndList("", list);
	} else {
		RecursiveWrite("",list);
	}

	write(filename ~ ".sclass",code);

	Console.setColor(Coloring.LightBlue, Coloring.Black);
	writeln("Compilation Finished! :D");

	Console.resetColor();
}