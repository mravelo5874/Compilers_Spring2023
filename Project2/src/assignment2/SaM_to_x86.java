package assignment2;

import assignment2.helper_classes.*;

import java.util.ArrayList;
import java.util.List;

public class SaM_to_x86 
{
    private String sam_code;
    private int current_line = -1;

    public SaM_to_x86(String _sam_code)
	{
		this.sam_code = _sam_code;
	}

    public String convert_code()
    {
        // start with required x86 program init
        String program_code = 
        "%include \"io.inc\"\n\n" +
        "section .text\n" +
        "\tglobal CMAIN\n" +
        "CMAIN:\n" +
        "\tpush ebp;" + // set up the frame base register
        "\tmov ebp, esp;" +
        "\tcall main\n" + // call the main function
        "\tadd esp, 4;\n" + // pop parameter
        "\tPRINT_DEC 4, eax\n" + // print return from main
        "\tNEWLINE\n" +
        "\tpop ebp;\n" + // restore frame base register and return
        "\tret\n\n";

        // remove sam code init
        this.sam_code = sam_code.replace(
            "PUSHIMM 0\nLINK\nJSR main\nPOPFBR\nSTOP\n", "");

        // set current line
        current_line = 6;

        // split code into individual methods and respective ends
        List<STR_PAIR> sam_method_end_pairs = split_sam_by_method();

        try
        {
            // convert each method and method end and append to program string
            for (STR_PAIR p : sam_method_end_pairs) 
            {
                // convert method end first,
                // returns an INT_PAIR with (parameters count, locals count)
                INT_PAIR method_vars = convert_method_end(p.get_str_2());
                convert_method(method_vars, p.get_str_1());
            }

            // return complete x86 program
            return program_code;
        }
        catch (ConverterException ce)
        {
            // TODO incorrect return
            ce.toString();
            return "";
        }
        catch (Exception e)
        {
            // TODO incorrect return
            e.toString();
            return "";
        }
    }

    private List<STR_PAIR> split_sam_by_method()
    {
        List<STR_PAIR> method_end_pairs = new ArrayList<STR_PAIR>();
        // split sam code by delimiter "\\method_separator\n"
        String[] methods = this.sam_code.split("//method_separator");
        for (String m : methods) 
        {
            // skip empty strings
            if (m.length() <= 0)
                continue;
            // get method name
            String name = m.split("\n", 0)[1].replace(":", "");
            // split method and method name
            String end_delim = name + "_END:\n";
            String[] method_end = m.split(end_delim);
            // create new string pair and add to list
            method_end_pairs.add(new STR_PAIR(method_end[0].replaceFirst("\n", ""), method_end[1]));
        }
        return method_end_pairs;
    }

    private String convert_method(INT_PAIR ip, String s)
    {
        // split into sam code lines
        String[] lines = s.split("\n");
        //System.out.println("method lines: " + lines.length);

        // set method name as first line
        String x86_code = lines[0] + "\n";

        for (String l : lines) 
        {
            // increment current line
            current_line++;

            // split single line into 1 or 2 parts
            String[] parts = l.split(" ");

            if (parts.length == 1)
            {
                String p1 = convert_1_part(parts[0]);
            }
            else if (parts.length == 2)
            {
                String p2 = convert_2_part(ip, parts[0], parts[1]);
            }
            else
            {
                // throw error?
                throw new ConverterException("Found line with more than 2 parts." , current_line);
            }
        }

        return "";
    }

    private INT_PAIR convert_method_end(String s)
    {
        String[] lines = s.split("\n");
        // lines[1] = storeoff return value offset,
        // we can use this to get the number of parameters in the method!
        int params = Math.abs(Integer.parseInt(lines[1].split(" ")[1].replace("\n", ""))) - 1;

        // lines[2] = addspace command to remove space for locals
        // we can use this to get the number of locals in the method!
        int locals = Math.abs(Integer.parseInt(lines[2].split(" ")[1].replace("\n", "")));

        return new INT_PAIR(params, locals);
    }

    private String convert_1_part(String p)
    {
        // find out what sam command part is
        switch (p)
        {
            case "NOT":     return "\t[not not implemented]\n";
            case "ADD":     return "\t[add not implemented]\n";
            case "SUM":     return "\t[sum not implemented]\n";
            case "TIMES":   return "\t[times not implemented]\n";
            case "DIV":     return "\t[div not implemented]\n";
            case "AND":     return "\t[and not implemented]\n";
            case "OR":      return "\t[or not implemented]\n";
            case "LESS":    return "\t[less not implemented]\n";
            case "GREATER": return "\t[greater not implemented]\n";
            case "EQUAL":   return "\t[equal not implemented]\n";

            case "LINK":    return "\t[link not implemented]\n";
            case "POPFBR":  return "\t[popfbr not implemented]\n";
            case "STOP":    return "\t[stop not implemented]\n";

            default:
                throw new ConverterException("Unexpected line part '" + p + "'" , current_line);
        }
    }

    private String convert_2_part(INT_PAIR ip, String p1, String p2)
    {
        // find out what sam command part 1 is
        switch (p1)
        {
            case "ADDSP":       return "\t[addsp not implemented]\n";
            case "PUSHIMM":     return "\tmov eax, " + p2 + "\n";
            case "STOREOFF":    return "\tmov [ebp" + convert_to_ebp_offset(ip, p2) + "], eax\n"; // mov eax, [ebp+8],
            case "PUSHOFF":     return "\t[pushoff not implemented]\n";
            case "JUMP":        return "\t[jump not implemented]\n";
            case "JUMPC":       return "\t[jumpc not implemented]\n";
            case "JUMPIND":     return "\t[jumpind not implemented]\n";
            case "JSR":         return "\t[jsr not implemented]\n";

            default:
                throw new ConverterException("Unexpected line part '" + p1 + "'" , current_line);
        }
    }

    private String convert_to_ebp_offset(INT_PAIR ip, String num)
    {
        int i = Integer.parseInt(num);

        // if int is positive, it is a local var
        if (i > 0)
        {
            int ebp_offset =  (i - 1) * -4;
            return String.valueOf(ebp_offset);
        }
        // if int is negative, it is a parameter
        else if (i < 0)
        {
            int ebp_offset =  (i + ip.get_int_1() + 2) * 4;
            return String.valueOf(ebp_offset);
        }

        // throw error?
        throw new ConverterException("Error attempting to convert '" + num + "' to ebp offset value." , current_line);
    }
}
