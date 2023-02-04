package assignment2.helper_classes;

// pair class used to return two string values simultaneously
public final class STR_PAIR
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
