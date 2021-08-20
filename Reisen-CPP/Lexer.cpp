#include "Lexer.h"

namespace ReisenLanguage$Lexer {
	Lexer::Lexer(const char* text) : text(text), currentLine(1), position(0) {
	}

	char Lexer::GetCurrent() {
		if (position >= strlen(text))
                    return '\0';
		
        return text[position];
	}

	Token Lexer::NextToken() {
		if (std::isspace(_current)) {
			//for whitespacing, yes i do use this type of token, instead of ignoring them.
			//(only required in Reisen source, not in Reisen Metadata files.)
			if (_current == '\n') {
				currentLine++;
			}

			Token whitespace = {};
			whitespace.line = this->currentLine;
			whitespace.position = this->position;
			whitespace.type = TokenType::Whitespace;
			char c = _current;
			whitespace.value = &c;
			Next();
			return whitespace;
		} else if (std::isalpha(_current)) {
			//for numbers.


			
		}

		Token invalidToken = {};

		invalidToken.type = TokenType::Invalid;
		invalidToken.position = this->position;
		invalidToken.line = this->currentLine;
		invalidToken.value = "";
		Next();
		return invalidToken;
	}

	void Lexer::Next() {
		position++;
	}

	bool Lexer::HasCodeEnded() {
		return (position >= strlen(text));
	}
}