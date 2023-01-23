package assignment1;

import edu.cornell.cs.sam.io.SamTokenizer;
import edu.cornell.cs.sam.io.TokenizerException;
import edu.cornell.cs.sam.io.Tokenizer.TokenType;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.regex.Pattern;

public class BaliCompiler 
{
    static boolean PRINT_COMPLILE = false;

    public static void main(String[] args)
    {
        String input_file;

        if (args.length > 0)
        {
            input_file = args[0];
        }
        else
        {
            input_file = "test1.bali";
        }

        System.out.println("input_file: " + input_file);
        System.out.println("Starting compiler...");
        try 
        {
            SamTokenizer f = new SamTokenizer("testcases/" + input_file);
            String program = getPROGRAM(f);
            System.out.println("Compiler completed with no problems.");
            System.out.println("SaM_code: " + program);
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
        if (PRINT_COMPLILE) { System.out.println("[PROGRAM start]"); }
        // PROGRAM -> METH_DECL*
    
        String pgm = "";
        while (f.peekAtKind() != TokenType.EOF)
        {
            pgm += getMETHOD_DECLARATION(f);
        }
        return pgm;
    }


    static String getMETHOD_DECLARATION(SamTokenizer f) 
    {
        if (PRINT_COMPLILE) { System.out.println("[METH_DECL start]"); }
        // METH_DECL -> TYPE ID '(' FORMALS? ')' BODY

        String method_declaration_str= "";

        f.match("int");
        String method_id = f.getWord();
        if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + method_id + ")"); }
        f.match('(');
        if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }

        // [FORMALS]? skip formals if parenthesis are empty
        if (!f.check(')'))
        {
            String formals = getFORMALS(f); 
            f.match(')');
        }
        if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }
        String body_str = getBODY(f);

        if (PRINT_COMPLILE) { System.out.println("[METH_DECL end]"); }
        return method_declaration_str;
    }

    static String getFORMALS(SamTokenizer f) 
    {
        if (PRINT_COMPLILE) { System.out.println("[FORMALS start]"); }
        // FORMALS -> TYPE ID (',' TYPE ID)*

        String formals_str = "";

        f.check("int");
        String formal_id = f.getWord();
        if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + formal_id + ")"); }

        // recursive getFormals() iff ',' present 
        if (f.check(','))
        {
            formals_str += getFORMALS(f);
        }
        
        if (PRINT_COMPLILE) { System.out.println("[FORMALS end]"); }
        return formals_str;
    }


    static String getBODY(SamTokenizer f)
    {
        if (PRINT_COMPLILE) { System.out.println("[BODY start]"); }
        // BODY -> '{' VAR_DECL* STMT* '}'

        String body_str = "";

        f.match('{');
        if (PRINT_COMPLILE) { System.out.println("\t[ { ]"); }
        if (f.check("int"))
        {
            String var_del_str = getVAR_DECL(f);
        }
        if (!f.check('}'))
        {
            while (!f.check('}'))
            {
                String stmt_str = getSTMT(f);
            }
        }
        if (PRINT_COMPLILE) { System.out.println("\t[ } ]"); }

        if (PRINT_COMPLILE) { System.out.println("[BODY end]"); }
        return body_str;
    }


    static String getVAR_DECL(SamTokenizer f)
    {
        if (PRINT_COMPLILE) { System.out.println("[VAR_DECL start]"); }
        // VAR_DECL -> TYPE ID ('=' EXP)? (',' ID ('=' EXP)?)* ';'
        String var_decl_str = "";

        String var_id = f.getWord();
        if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + var_id + ")"); }

        // ('=' [EXP])?
        if (f.check('='))
        {
            getEXP(f);
        }
        // (',' [ID] ('=' [EXP])?)*
        while (f.check(','))
        {
            var_id = f.getWord(); // [ID] -> var id
            if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + var_id + ")"); }
            if (f.check('='))
            {
                getEXP(f);
            }
        }
        f.match(';'); // ';'
        if (PRINT_COMPLILE) { System.out.println("\t[ ; ]"); }

        if (PRINT_COMPLILE) { System.out.println("[VAR_DECL end]"); }
        return var_decl_str;
    }


    static String getSTMT(SamTokenizer f)
    {
        if (PRINT_COMPLILE) { System.out.println("[STMT start]"); }
        String stmt = "";

        // System.out.println("[LOOK] " + generateMsg(f));
        // System.out.println("[PEEK] " + f.peekAtKind());
        
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
                        getEXP(f);
                        f.match(';');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ; ]"); }
                        break;
                    }
                    // "if" '(' [EXP] ')' [STMT] "else" [STMT]
                    case "if":
                    {
                        if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (if)"); }
                        f.check('(');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }
                        getEXP(f);
                        f.check(')');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }
                        getSTMT(f);
                        f.check("else");
                        getSTMT(f);
                        break;
                    }
                    // "while" '(' [EXP] ')' [STMT]
                    case "while":
                    {
                        if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (while)"); }
                        f.check('(');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }
                        getEXP(f);
                        f.check(')');
                        if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }
                        getSTMT(f);
                        break;
                    }
                    // "break" ';'
                    case "break":
                    {
                        if (PRINT_COMPLILE) { System.out.println("\t[KEYWORD] (break)"); }
                        f.check(';');
                        break;
                    }
                    default:
                    {
                        if (isID(word_id))
                        {
                            if (PRINT_COMPLILE) { System.out.println("[ASSIGN]"); }
                            if (PRINT_COMPLILE) { System.out.println("\t[ID] (" + word_id + ")"); }
                            f.check('=');
                            getEXP(f);
                            f.check(';');
                        }
                        else
                        {
                            throw new TokenizerException("Unexpected word '" + word_id + "' found @ line " + f.lineNo());
                        }
                        break;
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
                        if (PRINT_COMPLILE) { System.out.println("[BLOCK]"); }
                        if (PRINT_COMPLILE) { System.out.println("\t[ { ]"); }
                        while (!f.check('}'))
                        {
                            getSTMT(f);
                        }
                        if (PRINT_COMPLILE) { System.out.println("\t[ } ]"); }
                        break;
                    }
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
        
        if (PRINT_COMPLILE) { System.out.println("[STMT end]"); }
        return stmt;
    }

    
    static String getEXP(SamTokenizer f) 
    {
        if (PRINT_COMPLILE) { System.out.println("[EXP start]"); }
        String exp_str = "";

        switch (f.peekAtKind()) 
        {
            case INTEGER:
            {
                int i = f.getInt();
                if (PRINT_COMPLILE) { System.out.println("\t[LITERAL] -> [INT] (" + i + ")"); }
                break;
            }
            case WORD:
            {
                String word_str = f.getWord();

                // [METHOD] or [LOCATION]
                if (isID(word_str))
                {       
                    // [METHOD] '(' ACTUALS? ')'   
                    if (f.check('('))
                    {
                        if (PRINT_COMPLILE) { System.out.println("[METHOD] -> [ID] (" + word_str + ")"); }
                        if (!f.check(')'))
                        {
                            String actuals_str = getACTUALS(f);
                            f.match(')');
                        }
                    }
                    // [LOCATION] -> [ID]
                    else
                    {
                        if (PRINT_COMPLILE) { System.out.println("[LOCATION] -> [ID] (" + word_str + ")"); }
                    }     
                }
                // [LITERAL] -> [INT] | "true" | "false"
                else if (word_str == "true" || word_str == "false")
                {
                    if (PRINT_COMPLILE) { System.out.println("\t[LITERAL] (" + word_str + ")"); }
                }
                break;
            }
            case OPERATOR:
            {
                f.match('(');
                if (PRINT_COMPLILE) { System.out.println("\t[ ( ]"); }

                if (f.check('-'))
                {
                    String str = getEXP(f);
                    break;
                }
                else if (f.check('!'))
                {
                    String str = getEXP(f);
                    break;
                }
                else
                {
                    String str1 = getEXP(f);
                    Character c = f.getOp();
                    switch (c)
                    {
                        case '+':
                        case '-':
                        case '*':
                        case '/':
                        case '&':
                        case '|':
                        case '<':
                        case '>':
                        case '=':
                            if (PRINT_COMPLILE) { System.out.println("\t[MATH SYMBOL] ( " + c + " )"); }
                            break;
                    }

                    String str2 = getEXP(f);
                }

                f.match(')');
                if (PRINT_COMPLILE) { System.out.println("\t[ ) ]"); }
                break;
            }
            default:
                throw new TokenizerException("Unexpected token found: " + f.peekAtKind() + " value: '" + peep_value(f) + "' @ line " + f.lineNo());
        }

        if (PRINT_COMPLILE) { System.out.println("[EXP end]"); }
        return exp_str;
    }

    static String getACTUALS(SamTokenizer f)
    {
        if (PRINT_COMPLILE) { System.out.println("[ACTUALS start]"); }
        // ACTUALS -> EXP (',' EXP)*
        String actuals_str = "";

        getEXP(f);
        if (f.check(','))
        {
            getEXP(f);
        }

        if (PRINT_COMPLILE) { System.out.println("[ACTUALS end]"); }
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
}
