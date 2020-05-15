public class stringMethods{
    public static String toCamelCase(String input) {
        Pattern p = Pattern.compile('_([a-zA-Z])');
        Matcher m = p.matcher( input );
        fflib_StringBuilder sb = new fflib_StringBuilder();
        while (m.find()) {
            sb.add(m.replaceAll(m.group(1).toUpperCase()));
        }
        return sb.toString().uncapitalize();
    }
    
/**
 * @TO_PROPER_CASE
 * turns all words in a text string to proper case except those that should be kept lower case
 * first and last words are always capitalized
 * Example: "sally sue sews shirts" --> "Sally Sue Sews Shirts"
 * this method does not handle parts of names that are kept lowercase of have a capitalized character within the name
 *
 *String str = toProperCase(str);
 */
public static String toProperCase(String str){
   if(str.trim().length() == 0) return str;
   //Set lcaseWords = new Set{'a','an','and','at','but','for','in','nor','of','or','the','to','with'};
   set<String> lcaseWords = new set<String>();
   String[] words = str.toLowerCase().normalizeSpace().split(' ');
   String rslt = words[0].capitalize(); //always capitalize the first word
   for(integer i=1; i<words.size()-1; i++){
      if(lcaseWords.contains(words[i])) rslt += ' ' + words[i];
      else rslt += ' ' + words[i].capitalize();
   }
   rslt += ' ' + words[words.size()-1].capitalize(); //always capitalize the last word
   return rslt;
} //end method toProperCase
}