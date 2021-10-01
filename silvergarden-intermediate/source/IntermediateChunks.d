/*
    Intermediate Chunks, represents blobs of operations.
*/
module silver.intermediate.chunks;

import silver.utils.list;
import silver.intermediate.defs;

public class IntermediateChunk {
    
    public List!IntermediateChunk children;
    public IntermediateOp operation;
    public string argument;

    public this(IntermediateOp op, string argument) {
        this.operation = op;
        this.argument = argument;
        this.children = new ArrayList!IntermediateChunk();
    }
}