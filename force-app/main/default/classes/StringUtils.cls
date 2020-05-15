public class StringUtils {
    static public string MaskString(string inString, List<string> inPatterns, string inMask, integer inVisibleCharacters) {
        // validate the passed in variables
        if (inString == null || instring.length() < 1 || inPatterns == null || inPatterns.size() < 1 || inMask == null) 
            return inString;
        if (inVisibleCharacters < 0) 
            inVisibleCharacters = 0;
        
        // prime the internal variables to be used during processing
        string stringToMask = inString;
        string maskedString = inString;
        
        // iterate through each pattern and mask any matches leaving the last visible characters
        for(string regEx : inPatterns) {
            Pattern p = Pattern.compile(regEx);
            Matcher m = p.matcher(stringToMask);
            while(m.find()) {
                // find the start and end indexes of the match
                integer startIdx = m.start();
                integer endIdx = m.end();
                
                // extract the matched string
                string patternMatch = stringToMask.substring(startIdx, endIdx);                    
                
                // mask the string leaving any visible characters
                string partToBeMasked = patternMatch.substring(0, patternMatch.length() - inVisibleCharacters);                                                             
                string mask = '';                                          
                for(integer i = 0; i < partToBeMasked.length(); i++) {
                    mask += inMask;
                }    
                
                // concatenate mask string with the last visible characters               
                string maskedNumber = mask + patternMatch.substring(patternMatch.length() - inVisibleCharacters);                   
                
                // replace the the card number with masked number
                maskedString = maskedString.replace(patternMatch, maskedNumber);
            }               
        }       
        return maskedString;     
    }
    
    public static Boolean CheckCreditcard(String chatBody, List<string> inPatterns) {    
        // iterate through each pattern and mask any matches leaving the last visible characters
        for(string regEx : inPatterns) {
            Pattern p = Pattern.compile(regEx);
            Matcher m = p.matcher(chatBody);
            while(m.find()) {
                return true;
            }
        }
        return false;
    }
}