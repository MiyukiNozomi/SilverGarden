#include "ReisenLanguage.h"

#include <string>
#include <string.h>
#include <sstream>
#include <cstdlib>
#include <stdio.h>

namespace ReisenLanguage$Core {

	//utils 
	bool isWhitespace(char ch) {
		return (ch==' ') || (ch=='\t') || (ch=='\n') || (ch=='\r');
	}

	bool isNumeric(char ch) {
		return (ch>='0') && (ch<='9');
	}
	bool isNumber(const std::string &str) {
		for (size_t i=0;i<str.size();i++)
		  if (!isNumeric(str[i])) return false;
		return true;
	}
	bool isHexadecimal(char ch) {
		return ((ch>='0') && (ch<='9')) ||
			   ((ch>='a') && (ch<='f')) ||
			   ((ch>='A') && (ch<='F'));
	}
	bool isAlpha(char ch) {
		return ((ch>='a') && (ch<='z')) || ((ch>='A') && (ch<='Z')) || ch=='_';
	}

	void replace(std::string &str, char textFrom, const char *textTo) {
		int sLen = strlen(textTo);
		size_t p = str.find(textFrom);
		while (p != std::string::npos) {
			str = str.substr(0, p) + textTo + str.substr(p+1);
			p = str.find(textFrom, p+sLen);
		}
	}

	Lexer::Lexer(const std::string &input) {
		data = _strdup(input.c_str());
		dataOwned = true;
		dataStart = 0;
		dataEnd = strlen(data);
		Reset();
	}
	
	Lexer::Lexer(Lexer *owner, int startChar, int endChar) {
		data = owner->data;
		dataOwned = false;
		dataStart = startChar;
		dataEnd = endChar;
	    Reset();
	}

	Lexer::~Lexer() {
		if (dataOwned)
		    free((void*)data);
	}
	
	void Lexer::Reset() {
		dataPos = dataStart;
		tokenStart = 0;
		tokenEnd = 0;
		tokenLastEnd = 0;
		tk = 0;
		tkStr = "";
		getNextCh();
		getNextCh();
		getNextToken();
	}

	void Lexer::Match(int expected_tk) {
		if (tk!=expected_tk) {
		
			/*std::ostringstream errorString;
			std::cou << "Got " << GetTokenStr(tk) << " expected " << GetTokenStr(expected_tk)
			 << " at " << GetPosition(tokenStart);*/
		}
		getNextToken();
	}

	std::string Lexer::GetTokenStr(int token) {
		if (token>32 && token<128) {
			char buf[4] = "' '";

			buf[1] = (char) token;
			return buf;
		}

		switch (token) {
			case EofToken:
				return "EOF";
			case IdToken:
				return "Identifier";
			case IntegerToken:
				return "Integer";
			case FloatToken:
				return "Float";
			case StringToken:
				return "String";
			case EqualToken:
				return "==";
			case NEqual:
				return "!=";
			case LEqual:
				return "<=";
			case LShift:
				return "<<";
			case LShiftEqual:
				return "<<=";
			case GEqual:
				return ">=";
			case RShift:
				return ">>";
			case RShiftUnsigned:
				return ">>";
			case RShiftEqual:
				return ">>=";
			case PlusEqual:
				return "+=";
			case MinusEqual:
				return "-=";
			case PlusPlus:
				return "++";
			case MinusMinus:
				return "00";
			case AndEqual:
				return "&=";
			case AndAnd:
				return "&&";
			case OrEqual:
				return "|=";
			case OrOr:
				return "||";
			case XorEqual:
				return "^=";
			case ReservedSealed:
				return "sealed";
			case ReservedImport:
				return "public";
			case ReservedPrivate:
				return "private";
			case ReservedProtected:
				return "protected";
			case ReservedVoid:
				return "void";
			case ReservedString:
				return "String";
		}
		
		std::ostringstream msg;
		msg << "?[" << token << "]";
		return msg.str();
	}

	void Lexer::getNextCh() {
		current = next;
		if (dataPos < dataEnd)
			next = data[dataPos];
		else
			next = 0;
		dataPos++;
	}

	void Lexer::getNextToken() {
		tk = EofToken;
		tkStr.clear();

		while (current && isWhitespace(current)) getNextCh();
		// newline comments
		if (current=='/' && next=='/') {
			while (current && current!='\n') getNextCh();
			getNextCh();
			getNextToken();
			return;
		}
		
		// block comments
		if (current=='/' && next=='*') {
			while (current && (current!='*' || next!='/')) getNextCh();
			getNextCh();
			getNextCh();
			getNextToken();
			return;
		}

		tokenStart = dataPos - 2;

		if (isAlpha(current)) { // IDS
			while (isAlpha(current) || isNumeric(current)) {
				tkStr += current;
				getNextCh();
			}

			tk = IdToken;

			if (tkStr == "sealed") tk = ReservedSealed;
			else if (tkStr == "import") tk = ReservedImport;
			else if (tkStr == "public") tk = ReservedPublic;
			else if (tkStr == "private") tk = ReservedPrivate;
			else if (tkStr == "protected") tk = ReservedProtected;
			else if (tkStr == "void") tk = ReservedVoid;
			else if (tkStr == "String") tk = ReservedString;
		} else if (isNumeric(current)) {
			bool isHex = false;

			if (current == '0') {
				tkStr += current;
				getNextCh();
			}
			if (current == 'x') {
				isHex = true;
				getNextCh();
			}

			tk = IntegerToken;

			while (isNumeric(current) || (isHex && isHexadecimal(current))) {
				tkStr += current;
				getNextCh();
			}

			if (!isHex && current=='.') {
				tk = FloatToken;

				tkStr += ".";
				getNextCh();

				while (isNumeric(current)) {
					tkStr += current;
					getNextCh();
				}
			}

			if (!isHex && (current == 'e' || current == 'E')) {
				tk = FloatToken;

				tkStr += current;
				getNextCh();
				if (current == '-') {
					tkStr += current;
					getNextCh();
				}

				while (isNumeric(current)) {
					tkStr += current;
					getNextCh();
				}
			}
		} else if (current == '"') { //strings..
			getNextCh();
			while (current && current!='"') {
				if (current == '\\') {
					getNextCh();
					switch (current) {
					case 'n' : tkStr += '\n'; break;
					case '"' : tkStr += '"'; break;
					case '\\' : tkStr += '\\'; break;
					default: tkStr += current;
					}
				} else {
					tkStr += current;
				}
				getNextCh();
			}
			getNextCh();
			tk = StringToken;
		} else {
				// single chars
			tk = current;
			if (current) getNextCh();
			if (tk=='=' && current=='=') { // ==
				tk = EqualToken;
				getNextCh();
			} else if (tk=='!' && current=='=') { // !=
				tk = NEqual;
				getNextCh();
			} else if (tk=='<' && current=='=') {
				tk = LEqual;
				getNextCh();
			} else if (tk=='<' && current=='<') {
				tk = LShift;
				getNextCh();
				if (current=='=') { // <<=
					tk = LShiftEqual;
					getNextCh();
				}
			} else if (tk=='>' && current=='=') {
				tk = GEqual;
				getNextCh();
			} else if (tk=='>' && current=='>') {
				tk = RShift;
				getNextCh();
				if (current =='=') { // >>=
					tk = RShiftEqual;
				  getNextCh();
				} else if (current=='>') { // >>>
					tk = RShiftUnsigned;
				  getNextCh();
				}
			}  else if (tk=='+' && current=='=') {
				tk = PlusEqual;
				getNextCh();
			}  else if (tk=='-' && current=='=') {
				tk = MinusEqual;
				getNextCh();
			}  else if (tk=='+' && current=='+') {
				tk = PlusPlus;
				getNextCh();
			}  else if (tk=='-' && current=='-') {
				tk = MinusMinus;
				getNextCh();
			} else if (tk=='&' && current=='=') {
				tk = AndEqual;
				getNextCh();
			} else if (tk=='&' && current=='&') {
				tk = AndAnd;
				getNextCh();
			} else if (tk=='|' && current=='=') {
				tk = OrEqual;
				getNextCh();
			} else if (tk=='|' && current=='|') {
				tk = OrOr;
				getNextCh();
			} else if (tk=='^' && current=='=') {
				tk = XorEqual;
				getNextCh();
			}
		}

		tokenLastEnd = tokenEnd;
		tokenEnd = dataPos - 3;
	}

	std::string Lexer::GetSubString(int lastPosition) {
		 int lastCharIdx = tokenLastEnd+1;
		if (lastCharIdx < dataEnd) {
			/* save a memory alloc by using our data array to create the
			   substring */
			char old = data[lastCharIdx];
			data[lastCharIdx] = 0;
			std::string value = &data[lastPosition];
			data[lastCharIdx] = old;
			return value;
		} else {
			return std::string(&data[lastPosition]);
		}
	}
	
	Lexer *Lexer::GetSubLex(int lastPosition) {
		int lastCharIdx = tokenLastEnd+1;
		if (lastCharIdx < dataEnd)
			return new Lexer(this, lastPosition, lastCharIdx);
		else
			return new Lexer(this, lastPosition, dataEnd);
	}

	
	std::string Lexer::GetPosition(int pos) {
		if (pos<0) pos=tokenLastEnd;
		int line = 1,col = 1;
		for (int i=0;i<pos;i++) {
			char ch;
			if (i < dataEnd)
				ch = data[i];
			else
				ch = 0;
			col++;
			if (ch=='\n') {
				line++;
				col = 0;
			}
		}
		char buf[256];
		sprintf_s(buf, 256, "(line: %d, col: %d)", line, col);
		return buf;
	}

	CReisen::CReisen() {}

	void CReisen::GenMetadata(char* src) {

	}
}