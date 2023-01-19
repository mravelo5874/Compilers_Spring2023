package assignment1;

import edu.cornell.cs.sam.io.SamTokenizer;
import edu.cornell.cs.sam.io.TokenParseException;
import edu.cornell.cs.sam.io.Tokenizer;
import edu.cornell.cs.sam.io.TokenizerException;
import edu.cornell.cs.sam.io.Tokenizer.TokenType;

public class BaliCompiler 
{
    public static void main(String[] args)
    {
        String input_file;

        if (args.length > 0)
        {
            input_file = args[0];
        }
        else
        {
            input_file = "test5.bali";
        }

        System.out.println("input_file: " + input_file);
        String SaM_code = compiler("testcases/" + input_file);
        System.out.println("SaM_code: " + SaM_code);
    }

    static String generateMsg(SamTokenizer f)
    {
        String problemStr = "@ LINE: " + f.lineNo() + ", TOKEN_TYPE: " + f.peekAtKind() + ", VALUE: ";
        switch(f.peekAtKind())
        {
            default:
                problemStr = "[NO VALUE]";
                break;
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
        }
        return problemStr;
    }
    
    static String compiler(String fileName) 
    {
        // returns SaM code for program in file
        try 
        {
            SamTokenizer f = new SamTokenizer(fileName);
            String pgm = getPROGRAM(f);
            return pgm;
        } 
        catch (TokenizerException tpe)
        {
            System.out.println("[TOKENIZER ERROR] " + tpe.toString());
            return "STOP\n";
        }
        catch (Exception e) 
        {
            System.out.println("[COMPILER ERROR] " + e.getMessage());
            return "STOP\n";
        }
    }

    static String getPROGRAM(SamTokenizer f) 
    {
        try 
        {
            String pgm = "";
            while (f.peekAtKind() != TokenType.EOF)
                pgm += getMETHOD(f);
            return pgm;
        } 
        catch (TokenizerException te)
        {
            System.out.println("[TOKEN PARSE ERROR] " + te.toString());
            return "STOP\n";
        }
    }

    static String getMETHOD(SamTokenizer f) 
    {
        // add code to convert a method declaration to SaM code.
        // add appropriate exception handlers to generate useful error msgs.

        String method = "[METH:";


        f.check("int"); // [TYPE] -> "int"
        String method_id = f.getWord(); // [ID] -> method id
        method += method_id + "]";
        f.check('('); // '('

        // [FORMALS]? skip formals if parenthesis are empty
        if (!f.check(')'))
        {
            String formals = getFORMALS(f); 
            if (formals != "")
            {
                method += "[FORMALS]" + formals;
            }
            f.check(")"); // ')'
        }

        System.out.println("[PEEK]: " + generateMsg(f));

        // [BODY]
        f.check('{'); // '{'

        // [VAR_DECL]* 
        String var_del = getVARDECL(f);
        

        // [STMT]*
        String stmt = getSTMT(f);

        f.check('}'); // '}'
        
        // You would need to read in formals if any
        // And then have calls to getDeclarations and getStatements.
        return method;
    }

    static String getSTMT(SamTokenizer f)
    {
        String stmt = "";
        
        switch (f.peekAtKind())
        {
            // [ASSIGN] -> [LOCATION] '=' [EXP]
            case WORD:
            {
                String location_id = f.getWord(); // [ID] -> location id
                f.check('=');
                getEXP(f);
                f.check(';');
                break;
            }
            case STRING:
            {
                String str = f.getString();
                switch (str)
                {
                    // "return" [EXP] ';'
                    case "return":
                    {
                        getEXP(f);
                        f.check(';');
                        break;
                    }
                    // "if" '(' [EXP] ')' [STMT] "else" [STMT]
                    case "if":
                    {
                        f.check('(');
                        getEXP(f);
                        f.check(')');
                        getSTMT(f);
                        f.check("else");
                        getSTMT(f);
                        break;
                    }
                    // "while" '(' [EXP] ')' [STMT]
                    case "while":
                    {
                        f.check('(');
                        getEXP(f);
                        f.check(')');
                        getSTMT(f);
                        break;
                    }
                    // "break" ';'
                    case "break":
                    {
                        f.check(';');
                        break;
                    }
                }
                break;
            }
            case OPERATOR:
            {
                Character c = f.getCharacter();
                switch (c)
                {
                    // [BLOCK] -> '{' [STMT]* '}'
                    case '{':
                    {
                        while (!f.check('}'))
                        {
                            getSTMT(f);
                        }
                        break;
                    }
                    case ';':
                    {
                        break;
                    }
                }
                break;
            }
        }

        return stmt;
    }

    static String getVARDECL(SamTokenizer f)
    {
        String var_decl = "";

        f.check("int"); // [TYPE] -> "int"
        String var_id = f.getWord(); // [ID] -> var id

        // ('=' [EXP])?
        if (f.check('='))
        {
            getEXP(f);
        }
        // (',' [ID] ('=' [EXP])?)*
        while (f.check(','))
        {
            var_id = f.getWord(); // [ID] -> var id
            if (f.check('='))
            {
                getEXP(f);
            }
        }
        
        f.check(';'); // ';'

        return var_decl;
    }

    static String getEXP(SamTokenizer f) 
    {
        switch (f.peekAtKind()) 
        {
            case INTEGER: // E -> integer
                return "PUSHIMM " + f.getInt() + "\n";
            case OPERATOR: 
            {

            }
            default:
                return "ERROR\n";
        }
    }

    static String getFORMALS(SamTokenizer f) 
    {
        String formals = "";

        f.check("int"); // [TYPE] -> "int"

        String formal_id = f.getWord(); // [ID] -> formal id
        formals += "[INT][ID:" + formal_id + "]";
        // recursive getFormals() iff ',' present 
        if (f.check(','))
        {
            formals += getFORMALS(f);
        }
        return formals;
    }
}
