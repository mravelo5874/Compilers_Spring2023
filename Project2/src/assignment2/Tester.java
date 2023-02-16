package assignment2;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Tester 
{
    private static List<Integer> test_case_exp = Arrays.asList(
        0, 0, 0, 15, 90, 30, 123, 431, 120, 1597, 0, 0, 0, 15, 5, 71, 21, 7, 1066, 78, 0, 1, 65536, 0, 1, 0, 34, 1601, 479001600, 138, 8);
    private static List<String> test_cases = Arrays.asList(
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
        "testcases/good.two-methods.bali",
        "testcases/marco_test1.bali",
        "testcases/marco_test2.bali",
        "testcases/marco_test3.bali",
        "testcases/marco_test4.bali",
        "testcases/marco_test5.bali",
        "testcases/marco_test6.bali",
        "testcases/marco_test7.bali",
        "testcases/marco_test8.bali",
        "testcases/marco_test9.bali",
        "testcases/marco_test10.bali",
        "testcases/marco_test11.bali",
        "testcases/marco_test12.bali",
        "testcases/marco_test13.bali",
        "testcases/marco_test14.bali"
        );

    public static void test_and_report()
    {   
        System.out.println("Testing not implemented for this assignment...");
        return;

        /* 
        int total_testcases = test_cases.size();
        int successful = 0;
        // iterate through each test case and attempt to run compile()
        for (int i = 0; i < total_testcases; i++)
        {
            // get test file
            String test_bali_file = test_cases.get(i);

            // compile test case
            String x86_output_file =  test_bali_file.replace("testcases/", "x86_outputs/").replace(".bali", ".asm");
            if (MyBaliX86Compiler.compile(test_bali_file, x86_output_file, false, test_case_exp.get(i).toString()))
                System.out.println("Converted testcase " + i + " [" + test_bali_file.replace("testcases/", "").replace(".bali", ".sam") + "]...");

            // run sam code
            
            int result = run_sam_code();
            System.out.println("program result: " + result);
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
        */
        // System.out.println("Successfully completed " + successful + "/" + total_testcases + " testcases.");
    }

    // method to run sam code for running test cases
    // borrows from: https://www.geeksforgeeks.org/java-lang-processbuilder-class-java/
    private int run_sam_code()
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
}
