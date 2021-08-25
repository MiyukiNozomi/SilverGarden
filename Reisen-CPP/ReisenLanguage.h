#pragma once

#include <string>
#include <iostream>
#include <stdlib.h>
#include <crtdbg.h>
#include <sstream>

namespace ReisenLanguage$Core {

	enum TokenType {
		EofToken = 0,
		IdToken = 256,
		IntegerToken,
		FloatToken,
		StringToken,

		EqualToken,
		NEqual,
		LEqual,
		LShift,
		LShiftEqual,
		GEqual,
		RShift,
		RShiftUnsigned,
		RShiftEqual,
		PlusEqual,
		MinusEqual,
		PlusPlus,
		MinusMinus,
		AndEqual,
		AndAnd,
		OrEqual,
		OrOr,
		XorEqual,
		
		ReservedSealed,
		ReservedImport,
		ReservedPublic,
		ReservedPrivate,
		ReservedProtected,
		ReservedVoid,
		ReservedString,

		TokenListEnd,
	};

	class Lexer {
		public:
			Lexer(const std::string &input);
			Lexer(Lexer *owner, int startChar, int endChar);
			~Lexer();

			char current, next;
			int tk; ///< The type of the token that we have
			int tokenStart; ///< Position in the data at the beginning of the token we have here
			int tokenEnd; ///< Position in the data at the last character of the token we have here
			int tokenLastEnd; ///< Position in the data at the last character of the last token
			std::string tkStr; ///< Data contained in the token we have here
	
			void Match(int expected_tk); ///< Lexical match wotsit
			static std::string GetTokenStr(int token); ///< Get the string representation of the given token
			void Reset(); ///< Reset this lex so we can start again

			std::string GetSubString(int pos); ///< Return a sub-string from the given position up until right now
			Lexer *GetSubLex(int lastPosition); ///< Return a sub-lexer from the given position up until right now

			std::string GetPosition(int pos=-1); ///< Return a string representing the position in lines and columns of the character pos given
			int dataStart, dataEnd; ///< Start and end position in data string

		protected:
			/* When we go into a loop, we use getSubLex to get a lexer for just the sub-part of the
			   relevant string. This doesn't re-allocate and copy the string, but instead copies
			   the data pointer and sets dataOwned to false, and dataStart/dataEnd to the relevant things. */
			char *data; ///< Data string to get tokens from
			bool dataOwned; ///< Do we own this data string?

			int dataPos; ///< Position in data (we CAN go past the end of the string here)

			void getNextCh();
			void getNextToken(); ///< Get the text token from our text string
	};
	
	class CReisen {
		public:
			static CReisen& Ref() {
				static CReisen ref;
				return ref;
			}

			void GenMetadata(char* code);

		private:
			CReisen();
	};

	static CReisen Core = CReisen::Ref();
}