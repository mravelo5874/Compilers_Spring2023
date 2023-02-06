package assignment2;

import assignment2.helper_classes.*;

import java.util.ArrayList;
import java.util.List;

public class SaM_to_x86 
{
    private static int current_line = -1;   // current line in sam code
    private static String next_jumpc = "";  // next jump compare to use

    public static String convert_code(String sam_code)
    {
        // start with required x86 program init
        String program_code = 
        "%include \"io.inc\"\n\n" +
        "section .text\n" +
        "\tglobal CMAIN\n" +
        "CMAIN:\n" +
        "\tpush ebp\n" + // set up the frame base register
        "\tmov ebp, esp\n" +
        "\tcall main\n" + // call the main function
        "\tadd esp, 4\n" + // pop parameter
        "\tPRINT_DEC 4, eax\n" + // print return from main
        "\tNEWLINE\n" +
        "\tpop ebp\n" + // restore frame base register and return
        "\tret\n\n";

        // remove sam code init
        sam_code = sam_code.replace(
            "PUSHIMM 0\nLINK\nJSR main\nPOPFBR\nSTOP\n", "");

        // set current line
        current_line = 6;

        // split code into individual methods and respective ends
        List<STR_PAIR> sam_method_end_pairs = split_sam_by_method(sam_code);

        // convert each method and method end and append to program string
        for (STR_PAIR p : sam_method_end_pairs) 
        {
            // convert method end first,
            // returns an INT_PAIR with (parameters count, locals count)
            INT_PAIR method_vars = convert_method_end(p.get_str_2());
            program_code += convert_method(method_vars, p.get_str_1());
        }

        // return complete x86 program
        return program_code;
    }

    private static List<STR_PAIR> split_sam_by_method(String sam_code)
    {
        List<STR_PAIR> method_end_pairs = new ArrayList<STR_PAIR>();
        // split sam code by delimiter "\\method_separator\n"
        String[] methods = sam_code.split("//method_separator");
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

    private static String convert_method(INT_PAIR ip, String s)
    {
        // split into sam code lines
        String[] lines = s.split("\n");
        //System.out.println("method lines: " + lines.length);

        // set method name as first line
        String x86_code = lines[0] + "\n";

        int count = 0;
        for (String l : lines) 
        {
            // skip first method line (method name)
            if (count == 0)
            {
                count++;
                continue;
            }
            // increment current line
            current_line++;

            // split single line into 1 or 2 parts
            String[] parts = l.split(" ");

            if (parts.length == 1)
            {
                String p1 = convert_1_part(parts[0]);
                x86_code += p1;
            }
            else if (parts.length == 2)
            {
                String p2 = convert_2_part(ip, parts[0], parts[1]);
                x86_code += p2;
            }
            else
            {
                // throw error?
                throw new ConverterException("Found line with more than 2 parts." , current_line);
            }
            // increment line count
            count++;
        }

        // add method end code
        x86_code += lines[0].replace(":", "_end:\n");
        x86_code += "\tmov eax, 1\n" + "\tpop ebp\n" + "\tret\n\n";

        // return method code
        return x86_code;
    }

    private static INT_PAIR convert_method_end(String s)
    {
        String[] lines = s.split("\n");
        
        // lines[0] = storeoff return value offset,
        // we can use this to get the number of parameters in the method!
        int params = Math.abs(Integer.parseInt(lines[0].split(" ")[1].replace("\n", ""))) - 1;

        // lines[1] = addspace command to remove space for locals
        // we can use this to get the number of locals in the method!
        int locals = Math.abs(Integer.parseInt(lines[1].split(" ")[1].replace("\n", "")));

        return new INT_PAIR(params, locals);
    }

    private static String convert_1_part(String p)
    {
        // find out what sam command part is
        switch (p)
        {
            case "NOT":     return "\tpop eax\n" + "\tnot eax\n" + "\tpush eax\n";
            case "ADD":     return "\tpop eax\n" + "\tpop ebx\n" + "\tadd eax, ebx\n" + "\tpush eax\n";
            case "SUB":     return "\tpop eax\n" + "\tpop ebx\n" + "\tsub eax, ebx\n" + "\tpush eax\n";
            case "TIMES":   return "\tpop eax\n" + "\tpop ebx\n" + "\timul eax, ebx\n" + "\tpush eax\n";
            case "DIV":     return "\tpop eax\n" + "\tpop ebx\n" + "\tidiv eax, ebx\n" + "\tpush eax\n";
            case "AND":     return "\tpop eax\n" + "\tpop ebx\n" + "\tand eax, ebx\n" + "\tpush eax\n";
            case "OR":      return "\tpop eax\n" + "\tpop ebx\n" + "\tor eax, ebx\n" + "\tpush eax\n";

            case "LESS":        next_jumpc = "jl";    
            case "GREATER":     next_jumpc = "jg";
            case "EQUAL":       next_jumpc = "je";
                return "\tpop eax\n" + "\tpop ebx\n" + "\tcmp eax, ebx\n" + "\tpush eax\n";

            case "LINK":    return "\tpush ebp\n";
            case "POPFBR":  return "\tmov ebp, esp\n";
            case "STOP":    return "";

            default:
                throw new ConverterException("Unexpected line part '" + p + "'" , current_line);
        }
    }

    private static String convert_2_part(INT_PAIR ip, String p1, String p2)
    {
        p2 = p2.toLowerCase();

        // match part 1 and add respective code
        switch (p1)
        {
            case "ADDSP":       return get_add_space_code(p2);
            case "PUSHIMM":     return "\tmov dword eax, " + p2 + "\n" + "\tpush eax\n";
            case "STOREOFF":    return "\tmov dword [ebp" + convert_to_ebp_offset(ip, p2) + "], eax\n";
            case "PUSHOFF":     return "\tmov dword eax, [ebp" + convert_to_ebp_offset(ip, p2) + "]\n" + "\tpush eax\n";
            case "JUMP":        return "\tjmp " + p2 + "\n";
            case "JUMPC":       return "\t" + next_jumpc + " " + p2 + "\n";
            case "JUMPIND":     return "\tpop ebp\n" + "\tret\n";
            case "JSR":         return "\tcall " + p2 + "\n";

            default:
                throw new ConverterException("Unexpected line part '" + p1 + "'" , current_line);
        }
    }

    private static String get_add_space_code(String num)
    {
        int i = Integer.parseInt(num);
        String add_space_code = "";
        
        // add space for local variables
        if (i > 0)
        {
            for (int x = 1; x <= i; x++)
            {
                add_space_code += "\tmov dword [ebp" + convert_to_ebp_offset(x) + "], 0\n";
            }
        }

        return add_space_code;
    }

    private static String convert_to_ebp_offset(int num)
    {
        // if no INT_PAIR is provided, return local ebp offset
        if (num > 0)
        {
            int ebp_offset =  (num) * -4;
            String s = String.valueOf(ebp_offset);
            if (ebp_offset > 0)
                s = "+" + s;
            return s;
        }
        // throw error?
        throw new ConverterException("Error attempting to convert '" + num + "' to ebp offset value." , current_line);
    }

    private static String convert_to_ebp_offset(INT_PAIR ip, String num)
    {
        int i = Integer.parseInt(num);
        int ebp_offset = 0;

        // if int is positive, it is a local var
        if (i > 0)
        {
            ebp_offset =  (i - 1) * -4;
        }
        // if int is negative, it is a parameter
        else if (i < 0)
        {
            ebp_offset =  (i + ip.get_int_1() + 2) * 4;
        }
        else
        {
            // throw error?
            throw new ConverterException("Error attempting to convert '" + num + "' to ebp offset value." , current_line);
        }

        String s = String.valueOf(ebp_offset);
        if (ebp_offset > 0)
                s = "+" + s;
            return s;
    }
}
