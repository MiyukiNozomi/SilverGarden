#include <iostream>

#include <fstream>
#include <sstream>
#include <string>

#include "Settings.h"
#include "Logging.h"

#include "ReisenLanguage.h"

#define stringify( name ) # name

using namespace ReisenLanguage;
using namespace ReisenLanguage$Core;
using namespace ReisenLanguage$Logging;

int main(int argc, char** args) {
	
	std::cout << std::endl;

	Console.setColor(Coloring::Purple, Coloring::Black);
	std::cout << "MSVC Reisen Language Compiler";
	Console.setColor(Coloring::White, Coloring::Black);
	std::cout << " - Version " << __reisen__;

	std::cout << std::endl;

	for(int i = 1; i < argc; i++) {
		char* arg = args[i];

		if (strcmp(arg,"/no-single") || strcmp(arg,"/ns")) {
			GlobalSettings.singleFileExport = false;
		} else {
			Console.setColor(Coloring::Light_red, Coloring::Black);
			std::printf("Warning: ");
			Console.setColor(Coloring::White, Coloring::Black);
			std::printf("Unknown Argument: %s :(", arg);
		}
	}

	std::cout << std::endl;

	std::ifstream in("Example.reisen", std::ios::binary);

	const char* code; 

	if (in) {
		std::string contents;
	
		in.seekg(0, std::ios::end);
		contents.resize(in.tellg());
		in.seekg(0, std::ios::beg);
		in.read(&contents[0], contents.size());
		in.close();

		Lexer lexer = Lexer(contents);

		while (lexer.tk != EofToken) {
			Console.setColor(Coloring::Light_blue, Coloring::Black);
			std::cout << "Token: ";
			Console.setColor(Coloring::White, Coloring::Black);
			std::cout << lexer.tkStr << std::endl;
			Console.setColor(Coloring::Light_blue, Coloring::Black);
			std::cout << " Type: ";
			Console.setColor(Coloring::White, Coloring::Black);
			std::cout << lexer.tk << std::endl;
			lexer.Match(lexer.tk);
		}
	} else {
		Console.setColor(Coloring::Red, Coloring::Black);
		std::cout << "Unable to find file: Example.reisen" << std::endl;
	}

	while(true){}
	Console.resetColor();
	return 0;
}