module shinoa.reflect.Parser;

import std.stdio;

import shinoa.reflect.Class;
import shinoa.reflect.Token;
import shinoa.reflect.Tokenizer;
import shinoa.reflect.Field;
import shinoa.reflect.Method;
import shinoa.reflect.Variable;

import shinoa.lang.terminal;

public class Parser {

    private Tokenizer tokenizer;
    private Class clazz;

    public Class parse(Tokenizer t) {
        this.tokenizer = t;

        if (!parseClassDefinition()) {
            console.setColor(Color.light_red, Color.black_background);
            writeln();
            writeln();
            writeln("Parser: Failed at CLASS-DEFINITION space.");
            console.resetColor();
            return null;
        }

        if(!parseClassBody()) {
            console.setColor(Color.light_red, Color.black_background);
            writeln();
            writeln();
            writeln("Parser: Failed at CLASS-BODY space.");
            console.resetColor();
            return null;
        }

        return clazz;
    }

    public bool parseClassDefinition() {
        while (tokenizer.hasNextToken()) {
            Token t = tokenizer.nextToken();

            if (t.getType() == TokenType.ID_IMPORT) {
                t = tokenizer.nextToken();

                if (t.getType() != TokenType.STRING_LITERAL) {
                    printErrorHeader();
                    write("in an import statment, it was expected a STRING_LITERAL not a ", t.getToken());
                    return false;
                }

                t = tokenizer.nextToken();

                if (t.getToken() != ";") {
                    printErrorHeader();
                    write("in an import statment, it was expected a semicolon, not ", t.getToken());
                    return false;
                }
            } else if (t.getType() == TokenType.ID_PUBLIC) {
                t = tokenizer.nextToken();

                bool isStruct;
                if (t.getType() == TokenType.ID_CLASS) {
                    isStruct = false;
                } else if (t.getType() == TokenType.ID_STRUCT) {
                    isStruct = true;
                } else {
                    printErrorHeader();
                    write("in this class/struct definition, it was expected a class or struct identifier. not ", t.getToken());
                    return false;
                }

                t = tokenizer.nextToken();

                if (t.getType() != TokenType.IDENTIFIER) {
                    printErrorHeader();
                    write("in this class/struct definition, it was expected an identifier. not ", t.getToken());
                    return false;
                }

                clazz = new Class(isStruct, t.getToken());

                t = tokenizer.nextToken();

                if (t.getToken() != "{") {
                    printErrorHeader();
                    write("in this class/struct definition, it was expected a block opening. not ", t.getToken());
                    return false;
                }

                return true;
            } else {
                printErrorHeader();
                if (t.getType() == TokenType.ID_PUBLIC || t.getType() == TokenType.ID_PROTECTED || t.getType() == TokenType.ID_PRIVATE) {
                    write("Invalid usage of an access modifier.");
                } else {
                    write("Unexpected token: ", t.getToken()," of type: ", t.getType());
                }
                return false;
            }
        }

        printErrorHeader();
        write("Missing class definition.");
        return false;
    } 

    public bool parseClassBody() {
        if (clazz is null) {
            writeln();
            printErrorHeader();
            write("missing class.");
            return false;
        }

        bool endOfTheClass = false;
        int skip = 0;

        while (!endOfTheClass) {
            Token t = tokenizer.nextToken();

            if (t.getType() == TokenType.EMPTY) {
                printErrorHeader();
                write("Bad Formated class Structure.");
                return false;
            }

            if(!parseClassField()) {
                return false;
            }

            if (t.getToken() == "{") {
                skip++;
            }

            if (t.getToken() == "}") {
                if (skip == 0)
                    endOfTheClass = true;
                else
                    skip--;
            }
        }

        return true;
    }

    public bool parseClassField() {
        bool isPrivate,isProtected,isPublic, isStatic, isExtern;

        Token t = tokenizer.lastToken;

        VariableType type;


        switch(t.getType()) {
            case TokenType.ID_PRIVATE:
                isPrivate = true:
                break;
            case TokenType.ID_PUBLIC:
                isPublic = true;
                break;
            case TokenType.ID_PROTECTED:
                isProtected = true;
                break;
            default:
                printErrorHeader()
                write("in a field or method declaration, its expected an access modifier, not ", t.getToken());
                return false;
        }

        t = tokenizer.nextToken();

        if (t.getType() == TokenType.ID_STATIC) {
            isStatic = true;
            t = tokenizer.nextToken();
        }

        if (t.getType() == TokenType.ID_EXTERN) {
            isExtern = true;
            t = tokenizer.nextToken();
        }

        bool isUnsigned = false;

        if (t.getType() == TokenType.ID_UNSIGNED) {
            isUnsigned = true;
            t = tokenizer.nextToken();
        }

        switch(t.getType()) {
            case TokenType.ID_INT:
                if (isUnsigned) type = VariableType.UNSIGNED_INT; else type = VariableType.SIGNED_INT;
                break;
            case TokenType.ID_FLOAT:
                if (isUnsigned) type = VariableType.UNSIGNED_FLOAT; else type = VariableType.SIGNED_FLOAT;
                break;
            case TokenType.ID_DOUBLE:
                if (isUnsigned) type = VariableType.UNSIGNED_DOUBLE; else type = VariableType.SIGNED_DOUBLE;
                break;
            case TokenType.ID_LONG:
                if (isUnsigned) type = VariableType.UNSIGNED_LONG; else type = VariableType.SIGNED_LONG;
                break;
            case TokenType.ID_CHAR:
                if (isUnsigned) type = VariableType.UNSIGNED_CHAR; else type = VariableType.SIGNED_CHAR;
                break;
            case TokenType.ID_STRING:
                if (isUnsigned) {
                    printErrorHeader();
                    write("invalid usage of unsigned at ", t.getToken());
                    return false;
                }

                type = VariableType.STRING;
                break;
            case TokenType.ID_BOOLEAN:
                if (isUnsigned) {
                    printErrorHeader();
                    write("invalid usage of unsigned at ", t.getToken());
                    return false;
                }
                type = VariableType.BOOLEAN;
                break;
            default:
                printErrorHeader();
                write("Expected a valid statment type, not ", t.getToken());
                return false;
        }

        t = tokenizer.nextToken();

        if (t.getType() != TokenType.IDENTIFIER) {
            printErrorHeader();
            write("Expected a valid field name, not ", t.getToken());
            return false;
        }

        string name = t.getToken();

        t = tokenizer.nextToken();

        if (t.getToken() == ";") {
            return true;
        } else if (t.getToken() == "(") {
            return true;
        } else {
            writeln("Expected a semicolon or a bracket (semicolon for a field, and bracket for a method)");
            return false;
        }
    }

    private void printErrorHeader() {
        writeln();
        console.setColor(Color.white, Color.black_background);
        write(tokenizer.filename, "(0,0)");
        console.setColor(Color.red, Color.black_background);
        write(" Error: ");
        console.setColor(Color.white, Color.black_background);
    }
}
