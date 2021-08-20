#include <iostream>

#include "Lexer.h"
#include "Settings.h"
#include "Logging.h"

using namespace ReisenLanguage;
using namespace ReisenLanguage$Lexer;
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

	std::cout << "Settings: singleFileExport = " << GlobalSettings.singleFileExport << std::endl;

	//lexer test

	Lexer* lexer = new Lexer("namespace\"Something$Another\""
"import\"Reisen$Language$Console\""
"class\"Metadata\""
"mainmethod"
"call-from\"Console\"\"print\"args value-str\"Hello, World!\""
"endfunc\0");

	Console.setColor(Coloring::Light_blue, Coloring::Black);

	while (!lexer->HasCodeEnded()) {
		char l = lexer->NextToken();
		std::cout << " " << l;
	}

	Console.resetColor();
	return 0;
}