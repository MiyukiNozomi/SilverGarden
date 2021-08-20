module shinoa.reflect.Field;

import shinoa.util.List;
import shinoa.reflect.Token;
import shinoa.reflect.Variable;

public struct Field {
    public VariableType type;
    public string name;
    public bool isStatic,isPublic, isPrivate, isProtected;
    public List!Token expression;
}