/****************************************************************************
* Type               : Apex Class
* Name               : LiveChatTranscriptTriggerHelper 
* Created by         : 
* Created Date       : 1st Nov 2016
* Last Modified By   : 
* Purpose            : This is helper class for LiveChatTranscriptTrigger Trigger
* Reference          : http://developer.force.com/cookbook/recipe/text-masking-using-regex
****************************************************************************/
public class LiveChatTranscriptTriggerHelper {
    
    public void scrubCreditCardInformation(list<LiveChatTranscript> lstLCT){
        for(LiveChatTranscript lct: lstLCT){
            list<string> listPatterns = new list<string>();
            // VISA, Mastercard, Discover, American Express Corporate, Diners Club
            listPatterns.add('\\d{4}[- ]*\\d{4}[- ]*\\d{4}[- ]*\\d{4}');
            // Diners
            listPatterns.add('\\d{4}[- ]*\\d{4}[- ]*\\d{4}[- ]*\\d{2}');
            // American Express
            listPatterns.add('\\d{4}[- ]*\\d{6}[- ]*\\d{5}');
            lct.body = StringUtils.MaskString( lct.body, listPatterns, '*', 4);
        }
        
        if(!lstLCT.isEmpty()){
            //update lstLCT;
        }
    }
}