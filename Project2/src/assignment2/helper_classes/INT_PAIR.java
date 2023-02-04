package assignment2.helper_classes;

// pair class used to return two int values simultaneously
public final class INT_PAIR 
{
    private final int int_1;
    private final int int_2;

    // real constructor
    public INT_PAIR(int _int_1, int _int_2) { this.int_1 = _int_1; this.int_2 = _int_2; }

    // default constructor
    public INT_PAIR() { this.int_1 = 0; this.int_2 = 0; }
    // public getters 
    public int get_int_1() { return this.int_1; }
    public int get_int_2() { return this.int_2; }
}
