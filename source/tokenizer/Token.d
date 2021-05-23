module shinoa.reflect.Token;

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

public enum TokenType {

	ID_IMPORT,
	ID_PUBLIC,
	ID_PRIVATE,
	ID_PROTECTED,
	ID_CLASS,
	ID_STRUCT,
	ID_STATIC,
	ID_EXTERN,
	ID_INT,
	ID_DOUBLE,
	ID_FLOAT,
	ID_LONG,
	ID_STRING,
	ID_CHAR,
	ID_BOOLEAN,
	ID_SIGNED,
	ID_UNSIGNED,
	ID_NULL,
	ID_NULLPTR,
	ID_RETURN,

	EMPTY,
	TOKEN,
	IDENTIFIER,
	INT_LITERAL,
	STRING_LITERAL
}