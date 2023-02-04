package assignment2.helper_classes;

// pair class used to return int and string values simultaneously
public final class MIX_PAIR
{
    private final int num;
    private final String str;

    // real constructor
    public MIX_PAIR(int _num, String _str) { this.num = _num; this.str = _str; }

    // default constructor
    public MIX_PAIR() { this.num = 0; this.str = ""; }
    // public getters 
    public int get_num() { return this.num; }
    public String get_str() { return this.str; }
}
