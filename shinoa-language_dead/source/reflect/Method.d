module shinoa.reflect.Method;

import shinoa.util.List;
import shinoa.reflect.Token;
import shinoa.reflect.Variable;

public struct Method {
    public VariableType type;
    public string name;
    public bool isExtern, isStatic, isPublic, isPrivate, isProtected;
    public List!Token args,code;
}