module shinoa.reflect.Compiler;

import std.stdio;

import shinoa.util.List;

import shinoa.lang.Shinoa;

import shinoa.reflect.Class;
import shinoa.reflect.Field;
import shinoa.reflect.Token;
import shinoa.reflect.Method;
import shinoa.reflect.Variable;
import shinoa.reflect.ImportData;

public class Compiler {

    private Class clazz;
    private string constructorCode = "";  

    public this(Class clazz) {
        this.clazz = clazz;
    }

    public string createHeader() {
        string header = "/* The Shinoa Programming Language\n this C header was made by the Shinoa Compiler.\n this means that this was a class or a struct in the source code,\n now its turned into a C header, and a C file.*/";
        header ~="\n/* Shinoa Version: " ~ Shinoa.getVersion() ~ "*/ \n\n";

        List!Field fields = clazz.getFields();
        List!Method methods = clazz.getMethods();
        List!ImportData imports = clazz.getImports();

        for (int c = 0; c < imports.size(); c++) {
            ImportData imData = imports.get(c);

            if (imData.isExtern)    
                header ~= "#include <" ~ imData.targetModule ~ ">\n";
            else {
                header ~= "#include <shinoac/" ~ imData.targetModule ~ ".h>\n";
            }
        }

        string stringfields = "";
        string staticFields = "";

        for (int i = 0; i < fields.size(); i++) {
            Field f = fields.get(i);
            
            string pbc = "public";

            if (f.isPrivate) pbc = "private";
            if (f.isProtected) pbc = "protected";

            if (!f.isStatic) {
                if (f.expression.size() > 0) {
                    string expr = tokenStreamToString(f.expression);

                    constructorCode ~= "inst->" ~ f.name ~ " = " ~ expr ~ ";\n";
                }
                stringfields ~= "     /* @" ~ pbc ~ " */" ~ getCTypename(f.type) ~ " " ~ f.name ~ ";\n";
            } else {
                if (f.expression.size() > 0) {
                    string expr = tokenStreamToString(f.expression);

                    constructorCode ~= "inst->" ~ f.name ~ " = " ~ expr ~ ";\n";
                }
                staticFields ~= "/* @" ~ pbc ~ " */ static " ~ getCTypename(f.type) ~ " " ~ f.name ~ ";\n";
            }
        }

        header ~= staticFields ~ "\n\n";

        header ~= "typedef struct {\n";
        header ~= stringfields;
        header ~= "}" ~ clazz.getReadableClassName() ~ ";\n\n"; // TODO add user-defined modules.

        header ~= "void constructor_" ~ clazz.getReadableClassName() ~ "(" ~ clazz.getReadableClassName() ~ "* inst);\n";

        for (int e = 0; e < methods.size(); e++) {
            Method m = methods.get(e);

            if (m.isStatic && m.isExtern && m.isPublic && m.name == "main") {
                header ~= "/* int main(); */";
            } else {
                  string pbc = "public";

                if (m.isPrivate) pbc = "private";
                if (m.isProtected) pbc = "protected";
                
                header ~= "/* @" ~ pbc ~ " */ " ~ getCTypename(m.type) ~ " " ~ m.name ~ "(" ~ clazz.getReadableClassName() ~ "* inst";
                
                if (m.args.size() > 0)
                    header ~= "," ~ tokenStreamToString(m.args) ~ ");\n";
                else 
                    header ~= ");\n";
            }
        }

        return header;
    }

    public string createSource() {
        string source = "/* The Shinoa Programming Language\n this C source was made by the Shinoa Compiler.\n this means that this was a class or a struct in the source code,\n now its turned into a C header, and a C file.*/";
        source ~="\n/* Shinoa Version: " ~ Shinoa.getVersion() ~ "*/ \n\n";

        source ~= "#include \"" ~ clazz.getReadableClassName() ~ ".shinoa.h\"\n";

        source ~= "void constructor_" ~ clazz.getReadableClassName() ~ "(" ~ clazz.getReadableClassName() ~ "* inst) {\n";
        source ~= constructorCode ~ "}\n";

        List!Method methods = clazz.getMethods();

        for (int i = 0; i < methods.size(); i++) {
            Method m = methods.get(i);

            if (m.isStatic && m.isExtern && m.isPublic && m.name == "main") {
                source ~= "int main() {";
                source ~= tokenStreamToString(m.code) ~ "\n";
            } else {
                  string pbc = "public";

                if (m.isPrivate) pbc = "private";
                if (m.isProtected) pbc = "protected";
                
                source ~= "/* @" ~ pbc ~ " */ " ~ getCTypename(m.type) ~ " " ~ m.name ~ "(" ~ clazz.getReadableClassName() ~ "* inst";
                if (m.args.size() > 0)
                    source ~= "," ~ tokenStreamToString(m.args) ~ ") {\n";
                else
                    source ~= ") {\n";
                source ~= tokenStreamToString(m.code) ~ "\n";
            }
        }

        return source;
    }

    private string tokenStreamToString(List!Token tokens) {
        string camp;

        for (int i = 0; i < tokens.size(); i++) {
            Token t = tokens.get(i);

            if (getCTypename(getTypeFor(t.getType(), false)) != "auto") {
                camp ~= getCTypename(getTypeFor(t.getType(), false)) ~ " ";
            } else if (t.getType() == TokenType.STRING_LITERAL) {
                camp ~= "\"" ~ t.getToken() ~ "\"";
            } else 
                camp ~= t.getToken() ~ " ";
        }

        return camp;
    }
}