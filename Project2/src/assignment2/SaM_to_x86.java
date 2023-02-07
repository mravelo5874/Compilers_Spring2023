package assignment2;

import assignment2.helper_classes.*;

import java.util.ArrayList;
import java.util.List;

public class SaM_to_x86 
{
    private static int current_line = -1;   // current line in sam code
    private static String next_jumpc = "";  // next jump compare to use
    private static boolean ADD_DEBUG_PRINTS = true; // used to print to SASM console for debugging
    private static String DEBUG_PRINT_EAX =     "\n" + "\tPRINT_STRING eax_v\n" + "\tPRINT_DEC 4, eax\n" + "\tNEWLINE\n\n"; // string used for printing eax value
    private static String DEBUG_PRINT_EBX =     "\n" + "\tPRINT_STRING ebx_v\n" + "\tPRINT_DEC 4, ebx\n" + "\tNEWLINE\n\n"; // string used for printing eax value
    private static String DEBUG_PRINT_EPB =     "\n" + "\tPRINT_STRING ebp_v\n" + "\tPRINT_DEC 4, ebp\n" + "\tNEWLINE\n\n"; // string used for printing epb value
    private static String DEBUG_PRINT_ESP =     "\n" + "\tPRINT_STRING esp_v\n" + "\tPRINT_DEC 4, esp\n" + "\tNEWLINE\n\n"; // string used for printing esp value
    private static String DEBUG_PRINT_START =   "\n" + "\tPRINT_STRING m_start\n" + "\tNEWLINE\n\n"; // print starting new method
    private static String DEBUG_PRINT_END =     "\n" + "\tPRINT_STRING m_end\n" + "\tNEWLINE\n\n"; // print ending method
    private static String DEBUG_PRINT_STACK =   "\n" + "\tPRINT_STRING stack\n" + "\tpop ebx\n" + "\tPRINT_DEC 4, ebx\n" + "\tpush ebx\n" + "\tNEWLINE\n\n"; // print top of stack

    public static String convert_code(String sam_code)
    {
        // start with required x86 program init
        String program_code = 
        "%include \"io.inc\"\n\n" +
        "section .data\n" +
        "\tres db 'result: ', 0\n";

        // variables for printing ouy debug strings
        if (ADD_DEBUG_PRINTS)
        {
            program_code +=
            "\teax_v db 'eax val: ', 0\n" +
            "\tebx_v db 'ebx val: ', 0\n" +
            "\tebp_v db 'ebp val: ', 0\n" +
            "\tesp_v db 'esp val: ', 0\n" +
            "\tm_start db 'start method', 0\n" +
            "\tm_end db 'end method', 0\n" +
            "\tstack db 'stack: ', 0\n";
        }
       
        // CMAIN program
        program_code +=
        "section .text\n" +
        "\tglobal CMAIN\n" +

        "CMAIN:\n" +
        "\tpush ebp\n" + // set up the frame base register
        "\tmov ebp, esp\n\n" +

        "\tcall main\n" + // call the main function
        "\tPRINT_STRING res\n" +
        "\tPRINT_DEC 4, eax\n" + // print return from main
        "\tNEWLINE\n\n" +

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
        List<String> line_list = new ArrayList<String>();
        for (String l : lines)
        {
            // remove any "PUSHIMM 0" used as return values for method uses
            if (!l.contains("//rv"))
            {
                line_list.add(l);
            }
        }

        // set method name as first line
        String x86_code = lines[0].toLowerCase() + "\n";
        
        // print to console for debugging
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_START; }
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EAX; }
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EBX; }
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_STACK; }

        x86_code += "\tpush ebp\n" + "\tmov ebp, esp\n\n";

        int count = 0;
        for (String l : line_list) 
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

                // print to console for debugging
                if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EAX; }
                if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EBX; }
                if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_STACK; }
            }
            else if (parts.length == 2)
            {
                String p2 = convert_2_part(ip, parts[0], parts[1]);
                x86_code += p2;

                // print to console for debugging
                if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EAX; }
                if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EBX; }
                if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_STACK; }
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
        x86_code += lines[0].replace(":", "_end:\n").toLowerCase();

        // print to console for debugging
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EAX; }
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EBX; }
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_STACK; }
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_END; }
        
        x86_code += "\tpop ebp\n" + "\tret\n\n";

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
            case "NOT":     return "\tnot eax\n";
            case "ADD":     return "\tpop ebx\n" + "\tadd eax, ebx\n";
            case "SUB":     return "\tpop ebx\n" + "\tsub eax, ebx\n";
            case "TIMES":   return "\tpop ebx\n" + "\timul eax, ebx\n";
            case "DIV":     return "\tpop ebx\n" + "\tidiv eax, ebx\n";
            case "AND":     return "\tpop ebx\n" + "\tand eax, ebx\n";
            case "OR":      return "\tpop ebx\n" + "\tor eax, ebx\n";

            case "LESS":        next_jumpc = "jl";    
            case "GREATER":     next_jumpc = "jg";
            case "EQUAL":       next_jumpc = "je";
                return "\tpop ebx\n" + "\tcmp eax, ebx\n";

            case "LINK":    return ""; // "\tpush ebp\n";
            case "POPFBR":  return ""; // "\tmov ebp, esp\n";
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
            case "PUSHIMM":     return "\tmov dword ebx, " + p2 + "\n" + "\tpush ebx\n";
            case "STOREOFF":    return "\tmov dword [ebp" + convert_to_ebp_offset(ip, p2) + "], eax\n";
            case "PUSHOFF":     return "\tmov dword ebx, [ebp" + convert_to_ebp_offset(ip, p2) + "]\n" + "\tpush ebx\n";
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
