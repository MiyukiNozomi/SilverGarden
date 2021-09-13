module SilverGarden.Intermediate;

import java.util.List;

public enum IntermediateOp {
    DefineNamespace = "dnm",
    ImportNamespace = "nimp",
    ImportExtern = "eimp",
    LanguageCheck = "iep",
    EntryPoint = "mn",
    DefineObject = "df",
    DefineMethod = "fdf",
    ArgumentDefine = "ag",
    Assign = "as",
    Push = "psh",
    Operator = "op",
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

    public IntermediateChunk copy() {
        IntermediateChunk chunk =  new IntermediateChunk(operation, value);
        chunk.children = this.children;
        return chunk;
    }
}
