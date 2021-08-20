#pragma once

#include <string.h>
#include <cctype>
#include <cstring>

#include "Token.h"

#define _current GetCurrent()

namespace ReisenLanguage$Lexer {
	class Lexer {
		public:
			Lexer(const char* text);

			const char* text;
		
			bool HasCodeEnded();
			Token NextToken();
		private:
			int position, currentLine;

		private:
			char GetCurrent();
			void Next();
	};
}