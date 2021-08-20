module shinoa.reflect.Class;

import shinoa.util.List;
import shinoa.reflect.Field;
import shinoa.reflect.Method;
import shinoa.reflect.ImportData;

public class Class {
    
    private bool _struct;
    private string className;

    private List!Field fields;
    private List!Method methods;
    private List!ImportData imports;

    public this(bool _struct,string className, List!ImportData importData) {
        this._struct = _struct;
        this.className = className;

        this.fields = new ArrayList!Field();
        this.methods = new ArrayList!Method();
        this.imports = importData;
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

    public List!ImportData getImports() {
        return imports;
    }
}