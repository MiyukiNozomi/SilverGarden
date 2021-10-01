import std.stdio;
import std.algorithm;

import silver.utils.coloring;
import silver.utils.helpers;

void main(string[] args) {
	InitConsole();

	Console.setColor(Coloring.LightBlue, Coloring.Black);

	write("\nSilverGarden");

	Console.setColor(Coloring.White, Coloring.Black);

	writeln(" - IL Compiler");

	if (args.length <= 1) {
		Console.setColor(Coloring.LightRed, Coloring.Black);
		write("\nError!");
		Console.setColor(Coloring.White, Coloring.Black);
		writeln(" Expected a filename.");
		writeln(" - When using the SilverGarden compiler, please make sure to follow this structure: ");
		Console.setColor(Coloring.LightBlue, Coloring.Black);
		write("		silverc");
		Console.setColor(Coloring.Gold, Coloring.Black);
		writeln(" [filename (without extension)] [arguments]");
	
		Console.resetColor();
		return;
	}
	writeln();

	import std.file : readText;

	string filename = args[1];

	if (filename.endsWith(".silver")) {
		Console.setColor(Coloring.LightRed, Coloring.Black);
		writeln("Hey! do NOT add an extension!");
		writeln("SilverC will already do the extension job.");
		filename = filename.subString(0, filename.length - 7);
		writeln("Extension removed, it's now: ", filename);
		Console.setColor(Coloring.White, Coloring.Black);
		writeln();
	}

	try {
		string fileContent = readText(filename ~ ".silver");

		writeln("Text: ", fileContent);
		
		writeln();
		Console.setColor(Coloring.LightBlue, Coloring.Black);
		writeln("SilverC exited with exit code: 0");
	} catch(Exception e) {
		Console.setColor(Coloring.LightRed, Coloring.Black);
		write("Error! ");
		Console.setColor(Coloring.White,Coloring.Black);
		writeln("Unable to Stat File: ", filename);
		writeln();
		Console.setColor(Coloring.LightRed, Coloring.Black);
		writeln("SilverC exited with exit code: -3");
	}
	Console.resetColor();
}
