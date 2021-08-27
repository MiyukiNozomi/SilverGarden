module ReisenLanguage.Lexer;

import java.util.List;

import ReisenLanguage.Helpers;

enum TokenType {
    StringLiteral,
    CharLiteral,
    IntegerLiteral,
    DoubleLiteral,
    HexadecimalLiteral,
    Identifier,
    Symbol,

    EndOfFile,
    ErrorToken
}

public class TokenData {
	private:
        string pattern;
	    TokenType type;

	public: this(string pattern, TokenType type) {
		this.pattern = pattern;
		this.type = type;
	}

	public: string getPattern() {
		return pattern;
	}

	public: TokenType getType() {
		return type;
	}
}

public class Token {
	private:
        string token;
		int index;
	    TokenType type;

	public: this(string token,int index, TokenType type) {
		this.token = token;
		this.type = type;
		this.index = index;
	}
	
	public: string getToken() {
		return token;
	}
	
	public: TokenType getType() {
		return type;
	}

	public: int getIndex() {
		return index;
	}
}

public class Lexer {

    private:
        List!TokenData tokenDatas;
        bool pushBack;
        
    public: 
        string code;
		string start;
	    Token lastToken;
        
    public: this(string input) {
        this.code = input;
        this.start = input;
        
        this.tokenDatas = new ArrayList!TokenData();

        tokenDatas.add(new TokenData("^([a-zA-Z][a-zA-Z0-9]*)",TokenType.Identifier));
		tokenDatas.add(new TokenData("^((-)?[0-9]+)",TokenType.IntegerLiteral));
		tokenDatas.add(new TokenData("^((-)?[0-9].[0-9]+)",TokenType.DoubleLiteral));
		tokenDatas.add(new TokenData("^((-)?0x[0-9]+)",TokenType.HexadecimalLiteral));
		tokenDatas.add(new TokenData("^(\".*\")",TokenType.StringLiteral));
		tokenDatas.add(new TokenData("^(\'.*\')",TokenType.CharLiteral));
        
        string[] symbols = ["=", "\\(", "\\)","\\{","\\}",
                            "\\.", "\\,","\\:","\\;","\\+",
                            "\\-","\\_","\\/","\\%", "\\<",
                            "\\>", "\\^", "\\!", "\\|", "\\&"];
        
		foreach(string t ; symbols) {
			tokenDatas.add(new TokenData("^(" ~ t ~ ")", TokenType.Symbol));
		}
    }
    
    public: Token nextToken() {
		code = code.strip();
		
		if(pushBack) {
			pushBack = false;
			return lastToken;
		}
		
		if(code.length == 0) {
			return (lastToken = new Token("",0,TokenType.EndOfFile));
		}
		
		for (int i = 0; i < tokenDatas.size(); i++) {
            TokenData data = tokenDatas.get(i);
			auto regx = regex(data.getPattern());
            
            auto matcher = match(code,regx);
            
            if(!matcher.empty()) {
				string token = matcher.hit.strip();
				code = code.subString(token.length,code.length);
                
				if(data.getType() == TokenType.StringLiteral || data.getType() == TokenType.CharLiteral) {
					return (lastToken = new Token(token.subString(1, token.length - 1),cast(int) (code.length - token.length), TokenType.StringLiteral));
				} else if (data.getType() == TokenType.Identifier) {
					return (lastToken = new Token(token,cast(int) (code.length - token.length), TokenType.Identifier));
				}else {
					return (lastToken = new Token(token,cast(int) (code.length - token.length), data.getType()));
				}
			}
		}

        return null;
	}
    
    public: bool hasNextToken() {
		return !code.length == 0;
	}
	
	public: void requestPushBack() {
		if(lastToken is null) {
			this.pushBack = true;
        }
	}
}