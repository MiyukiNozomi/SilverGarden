module shinoa.reflect.Class;

import shinoa.util.List;
import shinoa.reflect.Field;
import shinoa.reflect.Method;

public class Class {
    
    private bool _struct;
    private string className;

    private List!Field fields;
    private List!Method methods;

    public this(bool _truct,string className) {
        this._struct = _struct;
        this.className = className;
    }

    public bool isStruct() {
        return _struct;
    }

    public string getReadableClassName() {
        return className;
    }

    public List!Field getFields() {
        return fields;
    }

    public List!Method getMethods() {
        return methods;
    }    
}