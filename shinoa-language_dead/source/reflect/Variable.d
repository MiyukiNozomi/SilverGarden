module shinoa.reflect.Variable;

import std.stdio;

import shinoa.reflect.Token;

public enum VariableType {
    VOID,
    STRING,
    BOOLEAN,
    SIGNED_INT,
    SIGNED_FLOAT,
    SIGNED_DOUBLE,
    SIGNED_LONG,
    SIGNED_CHAR,
    UNSIGNED_INT,
    UNSIGNED_FLOAT,
    UNSIGNED_DOUBLE,
    UNSIGNED_LONG,
    UNSIGNED_CHAR,
    NULL
}

public static string getCTypename(VariableType type) {
    switch(type) {
        case VariableType.UNSIGNED_INT:
            return "unsigned int";
        case VariableType.UNSIGNED_FLOAT:
            return "unsigned float";
        case VariableType.UNSIGNED_DOUBLE:
            return "unsigned double";
        case VariableType.UNSIGNED_LONG:
            return "unsigned long";
        case VariableType.UNSIGNED_CHAR:
            return "unsigned char";
        case VariableType.STRING:
            return "const char*";
        case VariableType.BOOLEAN:
            return "bool";
        case VariableType.SIGNED_INT:
            return "int";
        case VariableType.SIGNED_FLOAT:
            return "float";
        case VariableType.SIGNED_DOUBLE:
            return "double";
        case VariableType.SIGNED_LONG:
            return "long";
        case VariableType.SIGNED_CHAR:
            return "char";
        case VariableType.VOID:
            return "void";
        default:
            return "auto";
    }
}

public static VariableType getTypeFor(TokenType tokenType, bool isUnsigned) {
    VariableType type;
    
    switch (tokenType) {
        case TokenType.ID_INT:
            if (isUnsigned)
                type = VariableType.UNSIGNED_INT;
            else
                type = VariableType.SIGNED_INT;
            break;
        case TokenType.ID_FLOAT:
            if (isUnsigned)
                type = VariableType.UNSIGNED_FLOAT;
            else
                type = VariableType.SIGNED_FLOAT;
            break;
        case TokenType.ID_DOUBLE:
            if (isUnsigned)
                type = VariableType.UNSIGNED_DOUBLE;
            else
                type = VariableType.SIGNED_DOUBLE;
            break;
        case TokenType.ID_LONG:
            if (isUnsigned)
                type = VariableType.UNSIGNED_LONG;
            else
                type = VariableType.SIGNED_LONG;
            break;
        case TokenType.ID_CHAR:
            if (isUnsigned)
                type = VariableType.UNSIGNED_CHAR;
            else
                type = VariableType.SIGNED_CHAR;
            break;
        case TokenType.ID_STRING:
            if (isUnsigned) {
                return VariableType.NULL;
            }

            type = VariableType.STRING;
            break;
        case TokenType.ID_BOOLEAN:
            if (isUnsigned) {
                return VariableType.NULL;
            }
            type = VariableType.BOOLEAN;
            break;
        case TokenType.ID_VOID:
            if (isUnsigned) {
                return VariableType.NULL;
            }
            type = VariableType.VOID;
            break;
        default:
            type = VariableType.NULL;
            break;
    }

    return type;
}
