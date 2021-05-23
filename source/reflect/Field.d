module shinoa.reflect.Field;

import shinoa.reflect.Variable;

public struct Field {
    public VariableType type;
    public string name;
    public bool isProtected,isPrivate,isPublic;
}