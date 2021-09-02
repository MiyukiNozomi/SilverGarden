module SilverGarden.Intermediate;

import java.util.List;

public enum IntermediateOp {
    DefineNamespace = "dnm",
    ImportNamespace = "nimp",
    ImportExtern = "eimp",
    LanguageCheck = "iep",
    ExternObject = "exb",
    GetObject = "g",
    Push = "p",
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
