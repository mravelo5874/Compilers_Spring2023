package assignment2;

import assignment2.helper_classes.*;

import java.util.ArrayList;
import java.util.List;

// class to keep track of method data
final class METHOD_DATA
{
    private String method_name;
    private int params;
    private int locals;

    public METHOD_DATA(String _method_name, int _params, int _locals)
    {
        this.method_name = _method_name;
        this.params = _params;
        this.locals = _locals;
    }

    public String get_name() { return this.method_name; }
    public int get_params() { return this.params; }
    public int get_locals() { return this.locals; }
}

public class SaM_to_x86 
{
    // list of method data objects to store data for each method
    private static List<METHOD_DATA> method_data;

    private static int get_method_params(String method)
    {
        for (METHOD_DATA m : method_data)
        {
            if (m.get_name().equals(method))
                return m.get_params();
        }
        throw new ConverterException("Could not find method '" + method + "' in method_data.", current_line);
    }

    private static int get_method_locals(String method)
    {
        for (METHOD_DATA m : method_data)
        {
            if (m.get_name().equals(method))
                return m.get_locals();
        }
        throw new ConverterException("Could not find method '" + method + "' in method_data.", current_line);
    }

    private static int current_line = -1;           // current line in sam code
    private static String next_jumpc = "";          // next jump compare to use
    private static boolean ADD_DEBUG_PRINTS = false; // used to print to SASM console for debugging
    private static String DEBUG_PRINT_EAX =     "\n" + "\tPRINT_STRING eax_v\n" + "\tPRINT_DEC 4, eax\n" + "\tNEWLINE\n\n"; // string used for printing eax value
    private static String DEBUG_PRINT_START =   "\n" + "\tPRINT_STRING m_start\n" + "\tNEWLINE\n\n"; // print starting new method
    private static String DEBUG_PRINT_END =     "\n" + "\tPRINT_STRING m_end\n" + "\tNEWLINE\n\n"; // print ending method
    // DEPRICATED LOL
    //private static String DEBUG_PRINT_EBX =     "\n" + "\tPRINT_STRING ebx_v\n" + "\tPRINT_DEC 4, ebx\n" + "\tNEWLINE\n\n"; // string used for printing eax value
    //private static String DEBUG_PRINT_EPB =     "\n" + "\tPRINT_STRING ebp_v\n" + "\tPRINT_DEC 4, ebp\n" + "\tNEWLINE\n\n"; // string used for printing epb value
    //private static String DEBUG_PRINT_ESP =     "\n" + "\tPRINT_STRING esp_v\n" + "\tPRINT_DEC 4, esp\n" + "\tNEWLINE\n\n"; // string used for printing esp value
    //private static String DEBUG_PRINT_STACK =   "\n" + "\tPRINT_STRING stack\n" + "\tpop ebx\n" + "\tPRINT_DEC 4, ebx\n" + "\tpush ebx\n" + "\tNEWLINE\n\n"; // print top of stack

    public static String convert_code(String sam_code, String expected_result)
    {
        // start with required x86 program init
        String program_code = 
        "%include \"io.inc\" ; expected result: " + expected_result + "\n\n" +
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

        "\tcall my_main\n" + // call the main function
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

        // create list of METHOD_DATA to store data about each method
        method_data = new ArrayList<METHOD_DATA>();

        // first pass through ends to gather method data
        for (STR_PAIR p : sam_method_end_pairs)
        {
            String method_name = p.get_str_1().split("\n")[0].toLowerCase().replace(":", "");
            // System.out.println("method name: " + method_name);
            method_data.add(convert_method_end(p.get_str_2(), method_name));
        }
            
            
        // second pass through methods to convert sam code
        for (STR_PAIR p : sam_method_end_pairs)
            program_code += convert_method(p.get_str_1());

        // return complete x86 program
        return program_code;
    }

    private static METHOD_DATA convert_method_end(String s, String method_name)
    {
        String[] lines = s.split("\n");
        
        // lines[0] = storeoff return value offset,
        // we can use this to get the number of parameters in the method!
        int params = Math.abs(Integer.parseInt(lines[0].split(" ")[1].replace("\n", ""))) - 1;

        // lines[1] = addspace command to remove space for locals
        // we can use this to get the number of locals in the method!
        int locals = Math.abs(Integer.parseInt(lines[1].split(" ")[1].replace("\n", "")));

        //System.out.println("params: " + params + ", locals: " + locals);
        return new METHOD_DATA(method_name, params, locals);
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

    private static String convert_method(String s)
    {
        // split into sam code lines
        String[] lines = s.split("\n");
        List<String> line_list = new ArrayList<String>();
        
        for (String l : lines)
        {
            line_list.add(l);
        }

        // set method name as first line
        String method_name = lines[0].toLowerCase().replace(":", "");
        String x86_code = "my_" + method_name + ":\n";
        
        // print to console for debugging
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_START; }
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EAX; }

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
            }
            else if (parts.length == 2)
            {
                String p2 = convert_2_part(parts[0], parts[1], method_name);
                x86_code += p2;

                // print to console for debugging
                if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EAX; }
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
        x86_code += "my_" + lines[0].replace(":", "_end:\n").toLowerCase();

        // print to console for debugging
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_EAX; }
        if (ADD_DEBUG_PRINTS) { x86_code += DEBUG_PRINT_END; }

        // add pop into eax
        x86_code += "\tpop dword eax\n";

        // remove space for local variables
        if (get_method_locals(method_name) > 0)
        {
            x86_code += get_add_space_code(get_method_locals(method_name) * -1);
        }
        
        x86_code += "\tpop ebp\n" + "\tret\n\n";

        // return method code
        return x86_code;
    }

    private static String convert_1_part(String p)
    {
        // find out what sam command part is
        switch (p)
        {
            case "NOT":     return set_up_not();
            case "AND":     return set_up_and();
            case "OR":      return set_up_or();

            case "ADD":     return "\tpop dword ebx\n" + "\tpop dword eax\n" + "\tadd eax, ebx\n" + "\tpush dword eax\n";
            case "SUB":     return "\tpop dword ebx\n" + "\tpop dword eax\n" + "\tsub eax, ebx\n" + "\tpush dword eax\n";
            case "TIMES":   return "\tpop dword ebx\n" + "\tpop dword eax\n" + "\timul eax, ebx\n" + "\tpush dword eax\n";
            case "DIV":     return set_up_idiv();

            case "LESS":    next_jumpc = "jl"; return "\tpop dword ebx\n" + "\tpop dword eax\n" + "\tcmp eax, ebx\n";
            case "GREATER": next_jumpc = "jg"; return "\tpop dword ebx\n" + "\tpop dword eax\n" + "\tcmp eax, ebx\n";
            case "EQUAL":   next_jumpc = "je"; return "\tpop dword ebx\n" + "\tpop dword eax\n" + "\tcmp eax, ebx\n";

            case "LINK":    return "";
            case "POPFBR":  return "";
            case "STOP":    return "";
            case "JUMPIND": return "";

            default:
                // check if part is label
                if (p.endsWith(":")) return "my_" + p + "\n";
                // else throw converter exception
                throw new ConverterException("Unexpected line part '" + p + "'" , current_line);
        }
    }

    private static String convert_2_part(String p1, String p2, String method_name)
    {
        p2 = p2.toLowerCase();

        // match part 1 and add respective code
        switch (p1)
        {
            case "ADDSP":       return get_add_space_code(p2);
            case "PUSHIMM":     return "\tpush dword " + p2 + "\n";
            case "STOREOFF":    return "\tpop dword eax\n" + "\tmov dword [ebp" + convert_to_ebp_offset(p2, method_name) + "], eax\n";
            case "PUSHOFF":     return "\tpush dword [ebp" + convert_to_ebp_offset(p2, method_name) + "]\n";
            case "JUMP":        return "\tjmp my_" + p2 + "\n";
            case "JUMPC":       return "\t" + next_jumpc + " my_" + p2 + "\n";
            case "JSR":         return "\tcall my_" + p2 + "\n" + "\tmov dword [esp" + get_rv_esp_offset(get_method_params(p2)) + "], eax\n"; // "\tmov dword [esp" + convert_to_ebp_offset(ip.get_int_2() + 1) + "]

            default:
                throw new ConverterException("Unexpected line part '" + p1 + "'" , current_line);
        }
    }

    /* DEPRICATED LOL
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
    */

    private static String get_add_space_code(String num)
    {
        int i = Integer.parseInt(num);
        return get_add_space_code(i);
    }

    private static String get_add_space_code(int i)
    {
        String add_space_code = "";
        
        // add space for local variables
        if (i > 0)
        {
            for (int x = 1; x <= i; x++)
            {
                add_space_code += "\tpush dword 0\n";
            }
        }
        else if (i < 0)
        {
            for (int x = 0; x > i; x--)
            {
                add_space_code += "\tpop dword ecx\n";
            }
        }
        return add_space_code;
    }

    private static String get_rv_esp_offset(int params)
    {
        // want to get stack pointer of return value
        int rv_offset = 0 + params;
        rv_offset *= 4;
        // convert to string
        String rv_offset_string = String.valueOf(rv_offset);
        // add '+' if greater than -1
        if (rv_offset > -1)
        {
            rv_offset_string = "+" + rv_offset_string;
        }
        return rv_offset_string;
    }

    private static String convert_to_ebp_offset(String num, String method_name)
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
            ebp_offset =  (i + get_method_params(method_name) + 2) * 4;
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

    static int div_label_counter = 0;
    private static String set_up_idiv()
    {
        // get next div label
        String div_label = String.valueOf(div_label_counter);
        div_label_counter++;

        String idiv_string = 
        "\tmov dword eax, [esp+4]\n" +
        "\tcmp eax, 0\n" +
        "\tjl idiv_neg_label_" + div_label + "\n" +
        "\tmov dword edx, 0\n" +
        "\tjmp idiv_op_" + div_label + "\n" +
        "idiv_neg_label_" + div_label + ":\n" +
        "\tmov dword edx, -1\n" +
        "\tjmp idiv_op_" + div_label + "\n" +
        "idiv_op_" + div_label + ":\n" +
        "\tpop dword ebx\n" + 
        "\tpop dword eax\n" + 
        "\tidiv dword ebx\n" + 
        "\tpush dword eax\n";

        return idiv_string;
    }

    static int not_label_counter = 0;
    private static String set_up_not()
    {
        // get next and label
        String not_label = String.valueOf(not_label_counter);
        not_label_counter++;

        String not_string =
        "\tpop dword eax\n" +
        "\tcmp eax, 0\n" + 
        "\tje not_label_a" + not_label + "\n" +
        "\tpush dword 0\n" +
        "\tjmp not_label_b" + not_label + "\n" +
        "not_label_a" + not_label + ":\n" +
        "\tpush dword 1\n" +
        "\tjmp not_label_b" + not_label + "\n" +
        "not_label_b" + not_label + ":\n";

        return not_string;
    }

    static int and_label_counter = 0;
    private static String set_up_and()
    {
        // get next and label
        String and_label = String.valueOf(and_label_counter);
        and_label_counter++;

        String and_string = 
        // convert ebx to 1 or 0
        "\tpop dword ebx\n" + 
        "\tcmp ebx, 0\n" +
        "\tjne and_label_a" + and_label + "\n" +
        "\tjmp and_label_b" + and_label + "\n" +
        "and_label_a" + and_label + ":\n" +
        "\tmov dword ebx, 1\n" +
        "\tjmp and_label_b" + and_label + "\n" +
        "and_label_b" + and_label + ":\n" +
        // convert eax to 1 or 0
        "\tpop dword eax\n" +
        "\tcmp eax, 0\n" +
        "\tjne and_label_c" + and_label + "\n" +
        "\tjmp and_label_d" + and_label + "\n" +
        "and_label_c" + and_label + ":\n" +
        "\tmov dword eax, 1\n" +
        "\tjmp and_label_d" + and_label + "\n" +
        "and_label_d" + and_label + ":\n" +
        // compute AND logic
        "\tcmp eax, ebx\n" +
        "\tje and_label_e" + and_label + "\n" +
        "\tpush dword 0\n" +
        "\tjmp and_label_f" + and_label + "\n" +
        "and_label_e" + and_label + ":\n" +
        "\tpush dword 1\n" +
        "\tjmp and_label_f" + and_label + "\n" +
        "and_label_f" + and_label + ":\n";

        return and_string;
    }

    static int or_label_counter = 0;
    private static String set_up_or()
    {
        // get next or label
        String or_label = String.valueOf(or_label_counter);
        and_label_counter++;

        String or_string = 
        // convert ebx to 1 or 0
        "\tpop dword ebx\n" + 
        "\tcmp ebx, 0\n" +
        "\tjne or_label_a" + or_label + "\n" +
        "\tjmp or_label_b" + or_label + "\n" +
        "or_label_a" + or_label + ":\n" +
        "\tmov dword ebx, 1\n" +
        "\tjmp or_label_b" + or_label + "\n" +
        "or_label_b" + or_label + ":\n" +
        // convert eax to 1 or 0
        "\tpop dword eax\n" +
        "\tcmp eax, 0\n" +
        "\tjne or_label_c" + or_label + "\n" +
        "\tjmp or_label_d" + or_label + "\n" +
        "or_label_c" + or_label + ":\n" +
        "\tmov dword eax, 1\n" +
        "\tjmp or_label_d" + or_label + "\n" +
        "or_label_d" + or_label + ":\n" +
        // compute OR logic
        "\tadd eax, ebx\n" +
        "\tcmp eax, 0\n" +
        "\tjg or_label_e" + or_label + "\n" +
        "\tpush dword 0\n" +
        "\tjmp or_label_f" + or_label + "\n" +
        "or_label_e" + or_label + ":\n" +
        "\tpush dword 1\n" +
        "\tjmp or_label_f" + or_label + "\n" +
        "or_label_f" + or_label + ":\n";

        return or_string;
    }
}