module shinoa.reflect.Tokenizer;

import std.stdio;
import std.string;
import std.format;
import std.array;
import std.regex;

import shinoa.util.List;
import shinoa.reflect.Token;
import shinoa.reflect.StringUtils;
import shinoa.lang.terminal;

public class Tokenizer {
    
    private:
        List!TokenData tokenDatas;
        bool pushBack;
        
    public: 
        string code;
		string filename;
	    Token lastToken;
        
    public: this(string filename,string input) {
        this.code = input;
        this.filename = filename;

        this.tokenDatas = new ArrayList!TokenData();

        tokenDatas.add(new TokenData("^([a-zA-Z][a-zA-Z0-9]*)",TokenType.IDENTIFIER));
		tokenDatas.add(new TokenData("^((-)?[0-9]+)",TokenType.INT_LITERAL));
		tokenDatas.add(new TokenData("^(\".*\")",TokenType.STRING_LITERAL));
        
        string[] symbols = ["=", "\\(", "\\)","\\{","\\}", "\\.", "\\,","\\:","\\;","\\+","\\-","\\_","\\/","\\%"];
        
		foreach(string t ; symbols) {
			tokenDatas.add(new TokenData("^(" ~ t ~ ")", TokenType.TOKEN));
		}
    }
    
    public: Token nextToken() {
		code = code.strip();
		
		if(pushBack) {
			pushBack = false;
			return lastToken;
		}
		
		if(code.length == 0) {
			return (lastToken = new Token("",0,TokenType.EMPTY));
		}
		
		for (int i = 0; i < tokenDatas.size(); i++) {
            TokenData data = tokenDatas.get(i);
			auto regx = regex(data.getPattern());
            
            auto matcher = match(code,regx);
            
            if(!matcher.empty()) {
				string token = matcher.hit.strip();
				code = code.subString(token.length,code.length);
                
				if(data.getType() == TokenType.STRING_LITERAL) {
					return (lastToken = new Token(token.subString(1, token.length - 1),cast(int) (code.length - token.length), TokenType.STRING_LITERAL));
				} else if (data.getType() == TokenType.IDENTIFIER) {
					TokenType type = getTypeForStr(token);

					return (lastToken = new Token(token,cast(int) (code.length - token.length), type));
				}else {
					return (lastToken = new Token(token,cast(int) (code.length - token.length), data.getType()));
				}
			}
		}

        return null;
	}

	public TokenType getTypeForStr(string str) {

		switch(str) {
			case "import":
				return TokenType.ID_IMPORT;
			case "public":
				return TokenType.ID_PUBLIC;
			case "private":
				return TokenType.ID_PRIVATE;
			case "protected":
				return TokenType.ID_PROTECTED;
			case "class":
				return TokenType.ID_CLASS;
			case "struct":
				return TokenType.ID_STRUCT;
			case "static":
				return TokenType.ID_STATIC;
			case "extern":
				return TokenType.ID_EXTERN;
			case "int":
				return TokenType.ID_INT;
			case "double":
				return TokenType.ID_DOUBLE;
			case "float":
				return TokenType.ID_FLOAT;
			case "long":
				return TokenType.ID_LONG;
			case "String":
				return TokenType.ID_STRING;
			case "char":
				return TokenType.ID_CHAR;
			case "boolean", "bool":
				return TokenType.ID_BOOLEAN;
			case "null":
				return TokenType.ID_NULL;
			case "nullptr":
				return TokenType.ID_NULL;
			case "return":
				return TokenType.ID_RETURN;
			case "unsigned":
				return TokenType.ID_UNSIGNED;
			case "void":
				return TokenType.ID_VOID;
			default:
				return TokenType.IDENTIFIER;
		}
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
