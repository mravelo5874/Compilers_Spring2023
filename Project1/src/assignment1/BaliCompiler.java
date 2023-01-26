package assignment1;

import edu.cornell.cs.sam.io.SamTokenizer;
import edu.cornell.cs.sam.io.TokenizerException;
import edu.cornell.cs.sam.io.Tokenizer.TokenType;

import java.io.IOException;
import java.util.regex.Pattern;
import java.io.FileWriter;
import java.util.Arrays;
import java.util.List;

public class BaliCompiler 
{
    static boolean PRINT_COMPLILE = false;
    static boolean TRY_ALL_TESTCASES = false;
    static List<Boolean> test_case_exp = Arrays.asList(
        false, false, false, true, true, true, true, true, true, true, false, false, false, true, true, true, true);
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
        "examples/bad.exp-as-param.bali",
        "examples/bad.expr-1.bali",
        "examples/bad.expr-2.bali",
        "examples/good.break.bali",
        "examples/good.expr-1.bali",
        "examples/good.exprs.bali",
        "examples/good.two-methods.bali");

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


    static void test_and_report()
    {
        int total_testcases = test_cases.size();
        int successful = 0;
        // iterate through each test case and attempt to run compile()
        for (int i = 0; i < total_testcases; i++)
        {
            if (compile(test_cases.get(i), "output.sam") == test_case_exp.get(i))
            {
                successful++;
                System.out.println("[Test case " + (i+1) + " returned expected result]\n");
            }
            else
            {
                System.out.println("[Test case " + (i+1) + " errored out]\n");
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
            //System.out.println("SaM_code: " + program);
            System.out.println("Writing to output file...");
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
        
        // load code to set up call to main
        String program_str = "PUSHIMM 0\nLINK\nJSR main\nPOPFBR\nSTOP\n";
        // continue to translate tokens until EOF
        while (f.peekAtKind() != TokenType.EOF)
        {
            program_str += getMETHOD_DECLARATION(f);
        }
        return program_str;
    }


    static String getMETHOD_DECLARATION(SamTokenizer f) 
    {
        // [METH_DECL] -> [TYPE] [ID] '(' [FORMALS]? ')' [BODY]
        if (PRINT_COMPLILE) { System.out.println("<METH_DECL start"); }
        
        String method_declaration_str= "";

        f.match("int");
        String method_id = f.getWord();
        method_declaration_str += "METHOD " + method_id + "\n";
        if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + method_id + ")"); }
        f.match('(');
        if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }

        // [FORMALS]? skip formals if parenthesis are empty
        if (!f.check(')'))
        {
            String formals = getFORMALS(f); 
            f.match(')');
            method_declaration_str += formals;
        }
        if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }
        String body_str = getBODY(f);
        method_declaration_str += body_str;

        if (PRINT_COMPLILE) { System.out.println("METH_DECL end>"); }
        return method_declaration_str;
    }


    static String getFORMALS(SamTokenizer f) 
    {
        // [FORMALS] -> [TYPE] [ID] (',' [TYPE] [ID])*
        if (PRINT_COMPLILE) { System.out.println("<FORMALS start]"); }

        String formals_str = "";

        f.check("int");
        String formal_id = f.getWord();
        formals_str += "FORMAL " + formal_id + "\n";
        if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + formal_id + ")"); }

        // recursive getFormals() iff ',' present 
        if (f.check(','))
        {
            formals_str += getFORMALS(f);
        }
        
        if (PRINT_COMPLILE) { System.out.println("FORMALS end>"); }
        return formals_str;
    }


    static String getBODY(SamTokenizer f)
    {
        // [BODY] -> '{' [VAR_DECL]* [STMT]* '}'
        if (PRINT_COMPLILE) { System.out.println("<BODY start"); }

        String body_str = "";

        f.match('{');
        if (PRINT_COMPLILE) { System.out.println("\t[ { ]"); }
        if (f.check("int"))
        {
            body_str += getVAR_DECL(f);
        }
        if (!f.check('}'))
        {
            while (!f.check('}'))
            {
                body_str += getSTMT(f);
            }
        }
        if (PRINT_COMPLILE) { System.out.println("\t[ } ]"); }

        if (PRINT_COMPLILE) { System.out.println("BODY end>"); }
        return body_str;
    }


    static String getVAR_DECL(SamTokenizer f)
    {
        // [VAR_DECL] -> [TYPE] [ID] ('=' [EXP])? (',' [ID] ('=' [EXP])?)* ';'
        if (PRINT_COMPLILE) { System.out.println("<VAR_DECL start"); }
        
        String var_decl_str = "";

        String var_id = f.getWord();
        if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + var_id + ")"); }

        // ('=' [EXP])?
        if (f.check('='))
        {
            String exp1_str = getEXP(f);
            var_decl_str = "VAR " + var_id + " " + exp1_str;
        }
        // (',' [ID] ('=' [EXP])?)*
        while (f.check(','))
        {
            var_id = f.getWord(); // [ID] -> var id
            if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + var_id + ")"); }
            if (f.check('='))
            {
                String exp_str = getEXP(f);
                var_decl_str += "VAR " + var_id + " " + exp_str;
            }
        }
        f.match(';'); // ';'
        if (PRINT_COMPLILE) { System.out.println("\t[ ; ]"); }

        if (PRINT_COMPLILE) { System.out.println("VAR_DECL end>"); }
        return var_decl_str;
    }


    static String getSTMT(SamTokenizer f)
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
                        String exp_str = getEXP(f);
                        f.match(';');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ; ]"); }

                        stmt_str = exp_str + "RETURN\n";
                        break;
                    }
                    // "if" '(' [EXP] ')' [STMT] "else" [STMT]
                    case "if":
                    {
                        if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (if)"); }
                        f.check('(');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }
                        String exp1_str = getEXP(f);
                        f.check(')');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }
                        String stmt1_str = getSTMT(f);
                        f.check("else");
                        String stmt2_str = getSTMT(f);
                        
                        
                        stmt_str = "IF\n" + exp1_str + stmt1_str + "ELSE\n" + stmt2_str;
                        break;
                    }
                    // "while" '(' [EXP] ')' [STMT]
                    case "while":
                    {
                        if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (while)"); }
                        f.check('(');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }
                        String exp1_str = getEXP(f);
                        f.check(')');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }
                        String stmt1_str = getSTMT(f);
                        
                        
                        stmt_str = "WHILE\n" + exp1_str + stmt1_str;
                        break;
                    }
                    // "break" ';'
                    case "break":
                    {
                        if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (break)"); }
                        f.check(';');

                        stmt_str = "BREAK\n";
                        break;
                    }
                    default:
                    {
                        if (isID(word_id))
                        {
                            if (PRINT_COMPLILE) { System.out.println("\t[ASSIGN] -> [ID] (" + word_id + ")"); }
                            f.check('=');
                            String exp1_str = getEXP(f);
                            f.check(';');

                            stmt_str = exp1_str + "ASSIGN " + word_id + "\n";
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
                            block_str += getSTMT(f);
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

    
    static String getEXP(SamTokenizer f) 
    {
        if (PRINT_COMPLILE) { System.out.println("<EXP start"); }
        String return_str = "";

        switch (f.peekAtKind()) 
        {
            // [LITERAL] -> [INT]
            case INTEGER:
            {
                int i = f.getInt();
                if (PRINT_COMPLILE) { System.out.println("\t[LITERAL] -> [INT] (" + i + ")\nEXP end>"); }
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
                        String actuals_str = "";
                        if (!f.check(')'))
                        {
                            actuals_str = getACTUALS(f);
                            f.match(')');
                        }
                        return_str = "METHOD " + word_str + "\n" + "ACTUALS\n" + actuals_str;
                        break;
                    }
                    // [LOCATION] -> [ID]
                    else
                    {
                        if (PRINT_COMPLILE) { System.out.println("\t[LOCATION] -> [ID] (" + word_str + ")"); }
                        return_str = "PUSHOFF " + getOffset(word_str) + "\n";
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
                    expr1 = getEXP(f);
                    return_str = "PUSHIMM -" + expr1 + "\n";
                }
                else if (f.check('!'))
                {
                    expr1 = getEXP(f);
                    return_str = "NOT\n" + "PUSHIMM " + expr1 + "\n";
                }
                else
                {
                    String operation = "";
                    expr1 = getEXP(f);
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

                    expr2 = getEXP(f);
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


    static String getACTUALS(SamTokenizer f)
    {
        // [ACTUALS] -> [EXP] (',' [EXP])*
        if (PRINT_COMPLILE) { System.out.println("<ACTUALS start"); }

        String actuals_str = "";

        actuals_str += getEXP(f);
        while (f.check(','))
        {
            actuals_str += getEXP(f);
        }

        if (PRINT_COMPLILE) { System.out.println("ACTUALS end>"); }
        return actuals_str;
    }


    static boolean isINT(String str)
    {
        return Pattern.matches("[0-9]+", str);
    }


    static boolean isID(String str)
    {
        return Pattern.matches("[a-zA-Z]([a-zA-Z]|[0-9]|_)*$", str);
    }

    static int getOffset(String id)
    {
        // TODO this
        return -1;
    }
}
