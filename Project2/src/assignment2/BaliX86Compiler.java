package assignment2;

import assignment2.SaM_to_x86;
import assignment2.helper_classes.*;

import edu.cornell.cs.sam.io.SamTokenizer;
import edu.cornell.cs.sam.io.TokenizerException;
import edu.cornell.cs.sam.io.Tokenizer.TokenType;

import java.io.IOException;
import java.util.regex.Pattern;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class BaliX86Compiler 
{
    static boolean PRINT_COMPLILE = false;

    public static void main(String[] args)
    {
        // get input and output file names
        String input_file;
        String output_file;

        // get command-line arguments
        if (args.length == 1)
        {
            // run testcases
            if (args[0].equals("--test"))
            {
                System.out.print("Running testcases...\n");
                Tester.test_and_report();
            }
            else
            {
                // print out program requirements
                System.out.print("Program requires two commnad-line arguments: [input file (*.bali)] [output file (*.asm)]\n");
            }
        }
        // normal compilation 
        else if (args.length == 2)
        {
            input_file = args[0];
            output_file = args[1];
            compile(input_file, output_file);
        }
        else
        {
            // print out program requirements
            System.out.print("Program requires two commnad-line arguments: [input file (*.bali)] [output file (*.asm)]\n");
            
            // TODO remove this before submitting
            input_file = "testcases/marco_test1.bali";
            output_file = "output.asm";
            compile(input_file, output_file);
        }
    }

    static Boolean compile(String file_name, String output_file)
    {
        System.out.println("input_file: " + file_name);
        try 
        {
            // convert bali to sam code
            System.out.println("Starting bali to sam compiler...");
            SamTokenizer f = new SamTokenizer(file_name);
            String sam_program = getPROGRAM(f);
            System.out.println("Compiler completed with no problems.");

            // convert sam code to x86
            System.out.println("Starting sam to x86 converter...");
            String x86_program = SaM_to_x86.convert_code(sam_program);
            System.out.println("Converter completed with no problems.");
            
            // output to file
            System.out.println("Writing to output file...");
            write_to_file(output_file, x86_program);
            System.out.println("Program written to: '" + output_file + "'.");
            return true; // return true if program compiled correctly
        } 
        catch (TokenizerException te)
        {
            System.out.println("[TokenizerException] " + te.toString());
        }
        catch (ConverterException ce)
        {
            System.out.println(ce.toString());
        }
        catch (IOException ioe)
        {
            System.out.println("[IOException] " + ioe.toString());
        }
        catch (Exception e) 
        {
            System.out.println("[Exception] " + e.getMessage());
        }

        // TODO uncomment this 
        // output to file
        // write_to_file(output_file, "//error\nSTOP\n");
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
        // check to make sure that main() is declared
        if (!program_str.contains("main:\n"))
        {
            throw new TokenizerException("No 'main' method was declared"); 
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

        // throw error if no return statement is found
        if (return_str == "")
        {
            throw new TokenizerException("No return statement found for method '" + id_str + "' @ line " + f.lineNo());
        }

            if (PRINT_COMPLILE) { System.out.println("\t[ } ]"); }
            if (PRINT_COMPLILE) { System.out.println("BODY end>"); }
            if (PRINT_COMPLILE) { System.out.println("METH_DECL end>"); }

        // reset latest break to check for illegal breaks
        latest_break = "";
            
            if (PRINT_COMPLILE) { System.out.println("Latest break reset!"); }

        // SAM CODE FOR METHOD DECLARATION
        return
        "//method_separator\n" // method separator used for x86 code conversion
        + id_str + ":\n" // label for method start
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
                            + stmt1_str 
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
                        if (isID(word_id, f))
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

                // [LITERAL] -> "true" | "false"
                if (word_str.equals("true"))
                {
                        if (PRINT_COMPLILE) { System.out.println("\t[LITERAL] -> 'true'") ;}

                    return_str = "PUSHIMM 1\n";
                    break;
                }
                else if (word_str.equals("false"))
                {
                        if (PRINT_COMPLILE) { System.out.println("\t[LITERAL] -> 'false'") ;}

                    return_str = "PUSHIMM 0\n";
                    break;
                }   
                else if (isID(word_str, f))
                {      
                    // [METHOD] '(' [ACTUALS]? ')'
                    if (f.check('('))
                    {
                            if (PRINT_COMPLILE) { System.out.println("\t[METHOD] -> [ID] (" + word_str + ")"); }
                        
                        // use PAIR class to get back 2 values
                        MIX_PAIR actuals_pair = new MIX_PAIR(0, "");
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
                    return_str = expr1 + "PUSHIMM -1\nTIMES\n";
                }
                else if (f.check('!'))
                {
                    expr1 = getEXP(f, st);
                    return_str = expr1 + "NOT\n";
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


    static MIX_PAIR getACTUALS(SamTokenizer f, SYMBOL_TABLE st)
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

        return new MIX_PAIR(count, actuals_str);
    }


    ///// HELPER FUNCTIONS /////

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

    static boolean isINT(String str)
    {
        return Pattern.matches("[0-9]+", str);
    }

    static List<String> reserved_words = Arrays.asList(
        "int", "return", "if", "else", "while", "break", "true", "false"
    );

    static boolean isID(String str, SamTokenizer f)
    {
        if (reserved_words.contains(str))
        {
            throw new TokenizerException("Used reserved word '" + str + "' as an identifier @ line " + f.lineNo());
        }
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
