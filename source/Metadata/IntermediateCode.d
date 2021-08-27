module ReisenLanguage.Intermediate;

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
    InCaseOfLanguage = "lc"
}

public class IntermediateChunk {
    public:
        IntermediateOp operation;
        string value;
        List!IntermediateChunk childs;

    public this(IntermediateOp operation, string value) {
        childs = new ArrayList!IntermediateChunk();
        this.operation = operation;
        this.value = value;
    }
}