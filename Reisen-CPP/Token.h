#pragma once

namespace ReisenLanguage$Lexer {
	enum TokenType {
		Whitespace,
		Identifier,
		Number,

		Invalid
	};
	
	struct Token {
		TokenType type;
		const void* value;
		int line, position;
	};
}