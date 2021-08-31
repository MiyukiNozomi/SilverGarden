module SilverGarden.Intermediate;

import java.util.List;

public enum IntermediateOp {
    DefineNamespace = "dnm",
    ImportNamespace = "nimp",
    ImportExtern = "eimp",
    DefineMethod = "fdef",
    DefineVar = "vdef",
    MainFunc = "mfdef",
    CallObject = "c",
    AssignObject = "aset",
    GetObject = "gv",
    InCaseOfLanguage = "lc",
    Add = "add",
    Subtract = "sub",
    Multiply = "mul",
    Divide = "div",
    DivisionResult = "divres"
}

public class IntermediateChunk {
    public:
        IntermediateOp operation;
        string value;
        List!IntermediateChunk children;

    public this(IntermediateOp operation, string value) {
        children = new ArrayList!IntermediateChunk();
        this.operation = operation;
        this.value = value;
    }
}
