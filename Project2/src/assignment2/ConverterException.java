package assignment2;

/**
 * Used for errors with the SaM_to_x86 converter
 */
public class ConverterException extends RuntimeException {

	private String msg = "Converter Exception";
    private int line = -1;

	/*  Constructors */
	public ConverterException(String _msg, int _line) { msg = _msg; line = _line; }

	/* Error Retrieval */
	public String toString() 
    { 
        return "[CONVERTER ERROR] " + msg + " @ line " + line; 
    }
}
