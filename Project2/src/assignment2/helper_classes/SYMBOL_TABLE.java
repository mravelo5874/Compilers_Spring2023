package assignment2.helper_classes;

import java.util.ArrayList;
import java.util.List;

import edu.cornell.cs.sam.io.SamTokenizer;
import edu.cornell.cs.sam.io.TokenizerException;

// class that encapsulates a symbol table for a single method
public final class SYMBOL_TABLE
{
    private List<String> parameters;
    private List<String> locals;

    public SYMBOL_TABLE()
    {
        // initialize variables
        this.parameters = new ArrayList<String>();
        this.locals = new ArrayList<String>();
        // add return value as first symbol
        this.parameters.add("rv");
    }   

    // public count getters
    public int get_param_count() { return parameters.size(); }
    public int get_local_count() { return locals.size(); }

    // add a new parameter
    public void add_param(String str, SamTokenizer f)
    {
        if (is_symbol(str))
        {
            throw new TokenizerException("Found repeat symbol declaration for '" + str + "' @ line " + f.lineNo());
        }
        this.parameters.add(str);
    }   

    // add a new local
    public void add_local(String str, SamTokenizer f)
    {
        if (is_symbol(str))
        {
            throw new TokenizerException("Found repeat symbol declaration for '" + str + "' @ line " + f.lineNo());
        }
        this.locals.add(str);
    }

    // check if symbol already exists
    public boolean is_symbol(String str)
    {
        return parameters.contains(str) || locals.contains(str);
    }

    // get offset for a variable (local or parameter)
    public int get_offset(String str, SamTokenizer f)
    {
        if (is_symbol(str))
        {
            // check parameter
            if (parameters.contains(str))
            {
                return (-1 * parameters.size()) + parameters.indexOf(str);
            }
            else if (locals.contains(str))
            {
                return locals.indexOf(str) + 2;
            }
        }
        throw new TokenizerException("Attempt to get offset for non-existing symbol '" + str + "' @ line " + f.lineNo());
    }
}
