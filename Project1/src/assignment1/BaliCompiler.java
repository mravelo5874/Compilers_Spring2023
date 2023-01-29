package assignment1;

import edu.cornell.cs.sam.io.SamTokenizer;
import edu.cornell.cs.sam.io.TokenizerException;
import edu.cornell.cs.sam.io.Tokenizer.TokenType;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Pattern;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

// pair class used to return int and string values simultaneously
final class PAIR
{
    private final int num;
    private final String str;

    // real constructor
    public PAIR(int _num, String _str) { this.num = _num; this.str = _str; }

    // default constructor
    public PAIR() { this.num = 0; this.str = ""; }
    // public getters 
    public int get_num() { return this.num; }
    public String get_str() { return this.str; }
}

// pair class used to return two string values simultaneously
final class STR_PAIR
{
    private final String str_1;
    private final String str_2;

    // real constructor
    public STR_PAIR(String _str_1, String _str_2) { this.str_1 = _str_1; this.str_2 = _str_2; }

    // default constructor
    public STR_PAIR() { this.str_1 = ""; this.str_2 = ""; }
    // public getters 
    public String get_str_1() { return this.str_1; }
    public String get_str_2() { return this.str_2; }
}

// class that encapsulates a symbol table for a single method
final class SYMBOL_TABLE
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











public class BaliCompiler 
{
    static boolean PRINT_COMPLILE = false;
    static boolean TRY_ALL_TESTCASES = true;
    static List<Integer> test_case_exp = Arrays.asList(
        0, 0, 0, 15, 90, 30, 123, 431, 120, 1597, 0, 0, 0, 15, 5, 71, 21);
    static List<String> test_cases = Arrays.asList(
        "testcases/test1.bali", 
        "testcases/test2.bali",
        "testcases/test3.bali",
        "testcases/test4.bali",
        "testcases/test5.bali",
        "testcases/test6.bali",
        "testcases/test7.bali",
        "testcases/test8.bali",
        "testcases/test9.bali",
        "testcases/test10.bali",
        "testcases/bad.exp-as-param.bali",
        "testcases/bad.expr-1.bali",
        "testcases/bad.expr-2.bali",
        "testcases/good.break.bali",
        "testcases/good.expr-1.bali",
        "testcases/good.exprs.bali",
        "testcases/good.two-methods.bali");

    public static void main(String[] args)
    {
        // get input and output file names
        String input_file;
        String output_file;
        if (args.length > 1)
        {
            input_file = args[0];
            output_file = args[1];
        }
        else
        {
            input_file = "testcases/test4.bali";
            output_file = "output.sam";
        }

        // dev: try all test cases
        if (TRY_ALL_TESTCASES)
        {
            test_and_report();
            return;
        }

        // normal compilation
        compile(input_file, output_file);
    }

    // method to run sam code for running test cases
    // borrows from: https://www.geeksforgeeks.org/java-lang-processbuilder-class-java/
    static int run_sam_code()
    {
        int result = -1;

        // creating list of commands
        List<String> commands = new ArrayList<String>();
        commands.add("java");
        commands.add("-cp"); 
        commands.add("SaM-2.6.2.jar");
        commands.add("edu.cornell.cs.sam.ui.SamText");
        commands.add("output.sam");

        // creating the process
        ProcessBuilder pb = new ProcessBuilder(commands);
        pb.directory(new File(System.getProperty("user.dir")));

        try
        {
            // start the process
            Process process = pb.start();
            // for reading the output from stream
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String s = null;
            // look for 'Exit Status:' in output stream
            while ((s = stdInput.readLine()) != null) 
            {
                if (s.contains("Exit Status:"))
                {
                    s = s.replace("Exit Status: ", "");
                    s = s.replace("\n", "");
                    result = Integer.parseInt(s);
                    return result;
                }   
            }
        }
        catch (Exception e)
        {
            System.out.println("[Exception] " + e.toString());
        }

        return result;
    }

    static void test_and_report()
    {
        int total_testcases = test_cases.size();
        int successful = 0;
        // iterate through each test case and attempt to run compile()
        for (int i = 0; i < total_testcases; i++)
        {
            // compile test case
            compile(test_cases.get(i), "output.sam");

            // run sam code
            int result = run_sam_code();
            System.out.println("result: " + result);
            System.out.println("expected result: " + test_case_exp.get(i));
            
            // compare to expected result
            if (result == test_case_exp.get(i))
            {
                successful++;
                System.out.println("[Test case " + (i+1) + " returned expected result]\n");
            }
            else
            {
                System.out.println("[Test case " + (i+1) + " failed. Returned unexpected result: " + result + "]\n");
            }
        }
        System.out.println("Successfully completed " + successful + "/" + total_testcases + " testcases.");
    }


    static Boolean compile(String file_name, String output_file)
    {
        System.out.println("input_file: " + file_name);
        System.out.println("Starting compiler...");
        try 
        {
            SamTokenizer f = new SamTokenizer(file_name);
            String program = getPROGRAM(f);
            System.out.println("Compiler completed with no problems.");
            System.out.println("Writing to output file...");
            // output to file
            write_to_file(output_file, program);
            return true; // return true if program compiled correctly
        } 
        catch (TokenizerException te)
        {
            System.out.println("[TokenizerException] " + te.toString());
        }
        catch (IOException ioe)
        {
            System.out.println("[IOException] " + ioe.toString());
        }
        catch (Exception e) 
        {
            System.out.println("[Exception] " + e.getMessage());
        }

        // output to file
        write_to_file(output_file, "//error\nSTOP\n");
        return false; // return false if program errored out
    }

    static void write_to_file(String file_name, String data)
    {
        try
        {
            FileWriter file = new FileWriter(file_name);
            file.write(data);
            file.close();
        }
        catch (Exception e)
        {
            System.out.println("[Exception] " + e.toString());
        }
    }

    static String peep_value(SamTokenizer f)
    {
        String problemStr = "";
        switch(f.peekAtKind())
        {
            case INTEGER:
                problemStr += f.getInt();
                break;
            case FLOAT:
                problemStr += f.getFloat();
                break;
            case WORD:
                problemStr += f.getWord();
                break;
            case STRING:
                problemStr += f.getString();
                break;
            case CHARACTER:
                problemStr += f.getCharacter();
                break;
            case OPERATOR:
                problemStr += f.getOp();
                break;
            case COMMENT:
                problemStr += f.getComment();
                break;
            default:
                problemStr = "[NO VALUE]";
                break;
        }
        f.pushBack();
        return problemStr;
    }


    static String getPROGRAM(SamTokenizer f) 
    {
        // [PROGRAM] -> [METH_DECL]*

            if (PRINT_COMPLILE) { System.out.println("[PROGRAM start]"); }
        
        // SAM CODE: load code to set up call to main
        String program_str = 
        "PUSHIMM 0\n" // rv slot for main return
        + "LINK\n" // save FBR
        + "JSR main\n"  // call main function
        + "POPFBR\n" 
        + "STOP\n"; // stop program execution
        // continue to translate tokens until EOF
        while (f.peekAtKind() != TokenType.EOF)
        {
            program_str += getMETHOD_DECLARATION(f);
        }
        return program_str;
    }


    static String getMETHOD_DECLARATION(SamTokenizer f) 
    {
            if (PRINT_COMPLILE) { System.out.println("<METH_DECL start"); }
        
        // [METH_DECL] -> [TYPE] [ID] '(' [FORMALS]? ')' [BODY]

        f.match("int");

        // create new symbol table for formals
        String id_str = f.getWord();
        SYMBOL_TABLE st = new SYMBOL_TABLE();
        List<String> params = new ArrayList<String>();
        f.match('(');

            if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + id_str + ")"); }
            if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }

        // [FORMALS]? skip formals if parenthesis are empty
        if (!f.check(')'))
        {
            params.addAll(getFORMALS(f));
            f.match(')');
        }
        // add parameters to symbol table
        for (String p : params) 
        {
            st.add_param(p, f);
        }

            if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }
            if (PRINT_COMPLILE) { System.out.println("<BODY start"); }
        
        // [BODY] -> '{' [VAR_DECL]* [STMT]* '}'
        List<STR_PAIR> locals = new ArrayList<STR_PAIR>();
        String stmts_str = "";
        String return_str = "";

        f.match('{');

            if (PRINT_COMPLILE) { System.out.println("\t[ { ]"); }
        
        // get variable declarations
        while (f.check("int"))
        {
            locals.addAll(getVAR_DECL(f, st));
        }
        // create locals string
        String locals_str = "";
        for (STR_PAIR pair : locals) 
        {
            // only add to local string iff expression is not empty
            if (pair.get_str_2() != "")
                locals_str += pair.get_str_2() + "STOREOFF " + st.get_offset(pair.get_str_1(), f) + "\n";
        }

        // get statements until return statement is found
        if (!f.check('}'))
        {
            while (!f.check('}'))
            {
                String stmt_str = getSTMT(f, st);
                // check for return stmt
                if (stmt_str.startsWith("//return\n"))
                {
                    return_str = stmt_str.replace("//return\n", "");
                }
                else
                {
                    stmts_str += stmt_str;
                }
            }
        }

            if (PRINT_COMPLILE) { System.out.println("\t[ } ]"); }
            if (PRINT_COMPLILE) { System.out.println("BODY end>"); }
            if (PRINT_COMPLILE) { System.out.println("METH_DECL end>"); }

        // reset latest break to check for illegal breaks
        latest_break = "";
            
            if (PRINT_COMPLILE) { System.out.println("Latest break reset!"); }

        // SAM CODE FOR METHOD DECLARATION
        return
        id_str + ":\n" // label for method start
        + "ADDSP " + st.get_local_count() + "\n" // add space for local variables
        + locals_str // assign locals
        + stmts_str // body stmts
        + return_str // return exp
        + "JUMP " + id_str + "_END\n" // label for method end
        + id_str + "_END:\n" // label for method end
        + "STOREOFF " + st.get_offset("rv", f) + "\n" // return value offset
        + "ADDSP -" + st.get_local_count() + "\n" // remove space for locals
        + "JUMPIND\n"; // return to calle
    }


    static List<String> getFORMALS(SamTokenizer f)
    {
        // [FORMALS] -> [TYPE] [ID] (',' [TYPE] [ID])*

            if (PRINT_COMPLILE) { System.out.println("<FORMALS start]"); }

        List<String> params = new ArrayList<String>();

        f.check("int");
        String formal_id = f.getWord();
        params.add(formal_id);
        
        if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + formal_id + ")"); }

        // recursive getFormals() iff ',' present 
        if (f.check(','))
        {
            params.addAll(getFORMALS(f));
        }

            if (PRINT_COMPLILE) { System.out.println("FORMALS end>"); }

        return params;
    }


    static List<STR_PAIR> getVAR_DECL(SamTokenizer f, SYMBOL_TABLE st)
    {
        // [VAR_DECL] -> [TYPE] [ID] ('=' [EXP])? (',' [ID] ('=' [EXP])?)* ';'

            if (PRINT_COMPLILE) { System.out.println("<VAR_DECL start"); }
        
        List<STR_PAIR> locals = new ArrayList<STR_PAIR>();
        String var_id = f.getWord();
        st.add_local(var_id, f);

            if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + var_id + ")"); }

        // ('=' [EXP])?
        if (f.check('='))
        {
            // store variable name and expression string
            String exp1_str = getEXP(f, st);
            locals.add(new STR_PAIR(var_id, exp1_str));
        }
        else
        {
           // store variable name with empty expression
           locals.add(new STR_PAIR(var_id, ""));
        }
        // (',' [ID] ('=' [EXP])?)*
        while (f.check(','))
        {
            var_id = f.getWord(); // [ID] -> var id
            st.add_local(var_id, f);

                if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + var_id + ")"); }

            if (f.check('='))
            {
                // store variable name and expression string
                String exp1_str = getEXP(f, st);
                locals.add(new STR_PAIR(var_id, exp1_str));
            }
            else
            {
                // store variable name with empty expression
                locals.add(new STR_PAIR(var_id, ""));
            }
        }
        f.match(';'); // ';'

            if (PRINT_COMPLILE) { System.out.println("\t[ ; ]"); }
            if (PRINT_COMPLILE) { System.out.println("VAR_DECL end>"); }

        return locals;
    }


    static String getSTMT(SamTokenizer f, SYMBOL_TABLE st)
    {
            if (PRINT_COMPLILE) { System.out.println("<STMT start"); }

        String stmt_str = "";
        
        switch (f.peekAtKind())
        {
            case WORD:
            {
                String word_id = f.getWord();
                switch (word_id)
                {
                    // "return" [EXP] ';'
                    case "return":
                    {
                            if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (return)"); }

                        String exp_str = getEXP(f, st);
                        f.match(';');

                            if (PRINT_COMPLILE) { System.out.println("\t[ ; ]"); }

                        stmt_str = "//return\n" + exp_str;
                        break;
                    }
                    // "if" '(' [EXP] ')' [STMT] "else" [STMT]
                    case "if":
                    {
                            if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (if)"); }
                        
                        // get labels for code creation
                        String label_1 = getLABEL();
                        String label_2 = getLABEL();
                        String break_label = getBREAK();
                        latest_break = break_label;
    
                            if (PRINT_COMPLILE) { System.out.println("Latest break set as '" + latest_break + "'"); }

                        f.check('(');

                            if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }

                        String exp1_str = getEXP(f, st);
                        f.check(')');

                            if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }

                        String stmt1_str = getSTMT(f, st);
                        f.check("else");
                        String stmt2_str = getSTMT(f, st);
                        
                        // SAM CODE FOR IF ELSE
                        stmt_str = 
                            exp1_str 
                            + "JUMPC " + label_1 + "\n" 
                            + stmt2_str 
                            + "JUMP " + label_2 + "\n" 
                            + label_1 + ":\n" 
                            +  stmt1_str 
                            + label_2 + ":\n"
                            + break_label + ":\n";
                        break;
                    }
                    // "while" '(' [EXP] ')' [STMT]
                    case "while":
                    {
                            if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (while)"); }
                        
                        // get labels for code creation
                        String label_1 = getLABEL();
                        String label_2 = getLABEL();
                        String break_label = getBREAK();
                        latest_break = break_label;

                            if (PRINT_COMPLILE) { System.out.println("Latest break set as '" + latest_break + "'"); }

                        f.check('(');

                            if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }

                        String exp1_str = getEXP(f, st);
                        f.check(')');

                            if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }

                        String stmt1_str = getSTMT(f, st);

                        // SAM CODE FOR WHILE
                        stmt_str = 
                            "JUMP " + label_1 + "\n"
                            + label_2 + ":\n"
                            + stmt1_str
                            + label_1 + ":\n"
                            + exp1_str
                            + "JUMPC " + label_2 + "\n"
                            + break_label + ":\n";
                        break;
                    }
                    // "break" ';'
                    case "break":
                    {
                            if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (break)"); }

                        f.check(';');
                        
                        // check to make sure breaking here is legal
                        if (latest_break != "")
                        {
                            stmt_str = "JUMP " + latest_break + "\n";
                        }
                        else
                        {
                            throw new TokenizerException("Illegal break found @ line " + f.lineNo());
                        }
                        break;
                    }
                    default:
                    {
                        if (isID(word_id))
                        {
                                if (PRINT_COMPLILE) { System.out.println("\t[ASSIGN] -> [ID] (" + word_id + ")"); }

                            f.check('=');
                            String exp1_str = getEXP(f, st);
                            f.check(';');

                            // SAM CODE FOR ASSIGNING VAR W/ EXP
                            stmt_str +=
                            exp1_str
                            + "STOREOFF " + st.get_offset(word_id, f) + "\n";
                            break;
                        }
                        else
                        {
                            throw new TokenizerException("Unexpected word '" + word_id + "' found @ line " + f.lineNo());
                        }
                    }
                }
                break;
            }
            case OPERATOR:
            {
                Character c = f.getOp();
                switch (c)
                {
                    // [BLOCK] -> '{' [STMT]* '}'
                    case '{':
                    {
                            if (PRINT_COMPLILE) { System.out.println("\t[BLOCK]"); }
                            if (PRINT_COMPLILE) { System.out.println("\t[ { ]"); }

                        String block_str = "";
                        while (!f.check('}'))
                        {
                            block_str += getSTMT(f, st);
                        }

                            if (PRINT_COMPLILE) { System.out.println("\t[ } ]"); }

                        stmt_str = block_str;
                        break;
                    }
                    // ';'
                    case ';':
                    {
                            if (PRINT_COMPLILE) { System.out.println("\t[ ; ]"); }

                        break;
                    }
                    default:
                        throw new TokenizerException("Unexpected character '" + c + "' found @ line " + f.lineNo());
                }
                break;
            }
            default:
                throw new TokenizerException("Unexpected token found: " + f.peekAtKind() + " value: '" + peep_value(f) + "' @ line " + f.lineNo());
        }
        
            if (PRINT_COMPLILE) { System.out.println("STMT end>"); }

        return stmt_str;
    }

    static String getEXP(SamTokenizer f, SYMBOL_TABLE st)
    {
            if (PRINT_COMPLILE) { System.out.println("<EXP start"); }

        String return_str = "";

        switch (f.peekAtKind()) 
        {
            // [LITERAL] -> [INT]
            case INTEGER:
            {
                int i = f.getInt();

                    if (PRINT_COMPLILE) { System.out.println("\t[LITERAL] -> [INT] (" + i + ")"); }

                return_str = "PUSHIMM " + i + "\n";
                break;
            }
            case WORD:
            {
                String word_str = f.getWord();

                // [METHOD] or [LOCATION]
                if (isID(word_str))
                {       
                    // [METHOD] '(' [ACTUALS]? ')'
                    if (f.check('('))
                    {
                            if (PRINT_COMPLILE) { System.out.println("\t[METHOD] -> [ID] (" + word_str + ")"); }
                        
                        // use PAIR class to get back 2 values
                        PAIR actuals_pair = new PAIR(0, "");
                        if (!f.check(')'))
                        {
                            actuals_pair = getACTUALS(f, st);
                            f.match(')');
                        }
                        int param_count = actuals_pair.get_num();
                        String exps_str = actuals_pair.get_str();

                        // SAM CODE FOR METHOD
                        return_str = 
                        "PUSHIMM 0\n"
                        + exps_str
                        + "LINK\n"
                        + "JSR " + word_str + "\n"
                        + "POPFBR\n"
                        + "ADDSP -" + param_count + "\n";
                        break;
                    }
                    // [LOCATION] -> [ID]
                    else
                    {
                            if (PRINT_COMPLILE) { System.out.println("\t[LOCATION] -> [ID] (" + word_str + ")"); }

                        return_str = "PUSHOFF " + st.get_offset(word_str, f) + "\n";
                        break;
                    }     
                }
                // [LITERAL] -> "true" | "false"
                else if (word_str == "true" || word_str == "false")
                {
                        if (PRINT_COMPLILE) { System.out.println("\t[LITERAL] (" + word_str + ")"); }

                    if (word_str == "true")
                    {
                        return_str = "PUSHIMM 1\n";
                    }
                    else if (word_str == "false")
                    {
                        return_str = "PUSHIMM 0\n";
                    }
                }
                break;
            }
            case OPERATOR:
            {
                f.match('(');

                    if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }

                String expr1 = "";
                String expr2 = "";

                if (f.check('-'))
                {
                    expr1 = getEXP(f, st);
                    return_str = "PUSHIMM -" + expr1 + "\n";
                }
                else if (f.check('!'))
                {
                    expr1 = getEXP(f, st);
                    return_str = "NOT\n" + "PUSHIMM " + expr1 + "\n";
                }
                else
                {
                    String operation = "";
                    expr1 = getEXP(f, st);
                    Character c = f.getOp();
                    switch (c)
                    {
                        case '+':
                            operation = "ADD\n";
                            break;
                        case '-':
                            operation = "SUB\n";
                            break;
                        case '*':
                            operation = "TIMES\n";
                            break;
                        case '/':
                            operation = "DIV\n";
                            break;
                        case '&':
                            operation = "AND\n";
                            break;
                        case '|':
                            operation = "OR\n";
                            break;
                        case '<':
                            operation = "LESS\n";
                            break;
                        case '>':
                            operation = "GREATER\n";
                            break;
                        case '=':
                            operation = "EQUAL\n";
                            break;
                        default:
                            throw new TokenizerException("Unexpected operation found: " + peep_value(f) + "' @ line " + f.lineNo());
                    }

                        if (PRINT_COMPLILE) { System.out.println("\t[MATH SYMBOL] ( " + c + " )"); }

                    expr2 = getEXP(f, st);
                    return_str = expr1 + expr2 + operation;
                }

                f.match(')');

                    if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }

                break;
            }
            default:
                throw new TokenizerException("Unexpected token found: " + f.peekAtKind() + " value: '" + peep_value(f) + "' @ line " + f.lineNo());
        }

            if (PRINT_COMPLILE) { System.out.println("EXP end>"); }

        return return_str;
    }


    static PAIR getACTUALS(SamTokenizer f, SYMBOL_TABLE st)
    {
        // [ACTUALS] -> [EXP] (',' [EXP])*

            if (PRINT_COMPLILE) { System.out.println("<ACTUALS start"); }

        int count = 1;
        String actuals_str = "";

        actuals_str += getEXP(f, st);
        while (f.check(','))
        {
            actuals_str += getEXP(f, st);
            count++;
        }

            if (PRINT_COMPLILE) { System.out.println("ACTUALS end>"); }

        return new PAIR(count, actuals_str);
    }

    // HELPER FUNCTIONS

    static boolean isINT(String str)
    {
        return Pattern.matches("[0-9]+", str);
    }

    static boolean isID(String str)
    {
        return Pattern.matches("[a-zA-Z]([a-zA-Z]|[0-9]|_)*$", str);
    }

    static int label_count = 0;
    static int break_count = 0;
    static String latest_break = "";

    static String getLABEL()
    {
        String label = "auto_label_" + label_count ;
        label_count++;
        return label;
    }

    static String getBREAK()
    {
        String label = "auto_break_" + break_count ;
        break_count++;
        return label;
    }
}
