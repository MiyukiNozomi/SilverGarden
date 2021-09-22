/*
	this was originally from "BasicCodings"
	Scripting Language tutorial, but a little bit improved
	to not stop the entire program in case of a invalid character.

	i still have to make more reviews here.
	but its already good enough.
*/

module SilverGarden.Lexer;

import std.string;
import std.regex;
import std.algorithm;
import java.util.List;

import SilverGarden.Helpers;

enum TokenType {
    StringLiteral = "STR",
    CharLiteral = "CHR",
    IntegerLiteral = "INT",
	FloatLiteral = "FLT",
    DoubleLiteral = "DLT",
    HexadecimalLiteral = "HEX", 
    Identifier = "ID",
    Symbol = "SYB",

	Operator = "op",

	// for standartization
	AccessModifier = "am",

	BeginingOfFile = "bof",
    EndOfFile = "eof",
    Invalid = "iv"
}

public class TokenData {
	private:
    	string pattern;
		TokenType type;

	public this(string pattern, TokenType type) {
		this.pattern = pattern;
		this.type = type;
	}

	public string getPattern() {
		return pattern;
	}

	public TokenType getType() {
		return type;
	}
}

public class Token {
	public:
        string Token;
		int Length, Position;
	    TokenType Type;

	public this(string token,int position, int length, TokenType type) {
		this.Token = token;
		this.Type = type;
		this.Length = length;
        this.Position = position;
	}
}

public class Lexer {

    private:
        List!TokenData tokenDatas;
        bool pushBack;
        int lastPos;
        
    public: 
        string code;
		string start;
	    Token lastToken;
        
    public: this(string input) {
        this.code = input;
        this.start = input;
        
        this.tokenDatas = new ArrayList!TokenData();

        tokenDatas.add(new TokenData("^([@_a-zA-Z][a-zA-Z0-9_]*)",TokenType.Identifier));
		tokenDatas.add(new TokenData("^((-)?[0-9]\\.[0-9]+)f",TokenType.FloatLiteral));
		tokenDatas.add(new TokenData("^((-)?[0-9]\\.[0-9]+)",TokenType.DoubleLiteral));
		tokenDatas.add(new TokenData("^((-)?0x[0-9]+)",TokenType.HexadecimalLiteral));
		tokenDatas.add(new TokenData("^((-)?[0-9]+)",TokenType.IntegerLiteral));
		tokenDatas.add(new TokenData("^(\".*\")",TokenType.StringLiteral));
		tokenDatas.add(new TokenData("^(\'.*\')",TokenType.CharLiteral));
        
        string[] symbols = ["\\{","\\}","\\[","\\]","\\(","\\)",";","\\,"];
        
		foreach(string t ; symbols) {
			tokenDatas.add(new TokenData("^(" ~ t ~ ")", TokenType.Symbol));
		}

        string[] operators = ["\\+\\+","\\-\\-", "\\%\\%", "\\*\\*", "\\^\\^",
							  "\\+","\\-","\\%","\\/", "\\*","\\^", "\\=",
							  "\\+\\=","\\-\\=","\\%\\=","\\/\\=", "\\*\\=", "\\^=",
							  "\\>","\\>\\=", "\\<", "\\=<"];
        
		foreach(string t ; operators) {
			tokenDatas.add(new TokenData("^(" ~ t ~ ")", TokenType.Operator));
		}
    }
    
    public: Token NextToken() {
		code = code.strip();
		
		if(pushBack) {
			pushBack = false;
			return lastToken;
		}
		
		if(code.length == 0) {
			return (lastToken = new Token("",lastPos + 1, 0,TokenType.EndOfFile));
		}
		
		for (int i = 0; i < tokenDatas.size(); i++) {
            TokenData data = tokenDatas.get(i);
			auto regx = regex(data.getPattern());
            
            auto matcher = match(code,regx);
            
            if(!matcher.empty()) {
				string token = matcher.hit.strip();
				code = code.subString(token.length,code.length);
                lastPos += token.length;
                
				if(data.getType() == TokenType.StringLiteral || data.getType() == TokenType.CharLiteral) {
					return (lastToken = new Token(token.subString(1, token.length - 1),lastPos,cast(int) (code.length - token.length), TokenType.StringLiteral));
				} else if (data.getType() == TokenType.Identifier) {
					TokenType type = TokenType.Identifier;

					if (token == "public" || token == "private" || token == "protected")
						type = TokenType.AccessModifier;
					
					return (lastToken = new Token(token, lastPos, cast(int) (code.length - token.length), type));
				} else {
					return (lastToken = new Token(token, lastPos,cast(int) (code.length - token.length), data.getType()));
				}
			}
		}

        lastPos += 1;
		code = code.subString(1,code.length);
        return (lastToken = new Token("", lastPos, 1, TokenType.Invalid));
	}
    
    public: bool HasNextToken() {
		return !code.length == 0;
	}
	
	public: void RequestPushBack() {
		if(lastToken is null) {
			this.pushBack = true;
        }
	}
}