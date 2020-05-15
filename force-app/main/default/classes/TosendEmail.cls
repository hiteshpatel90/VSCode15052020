public class TosendEmail {
   public list<wrapperClassEx> wrapperList{get;set;}
   public TosendEmail(ApexPages.StandardController controller){
   } 
    public List<wrapperClassEx> getwrapperObj() {
    List<opportunitycontactrole> conList= [select Id,Contact.Name ,Contact.Email from opportunitycontactrole    where OpportunityId = '0062800000EriYb'] ;
   wrapperList = new list<wrapperClassEx>();
   for(opportunitycontactrole con: conList ){
    wrapperList.add(new wrapperclassEx(con,false));
    }
    return wrapperList;
   } 
   
 // wrapper class  
 public class wrapperClassEx {
   public opportunitycontactrole conobj { get; set;}
   public boolean checkbox { get; set;}
   public wrapperClassEx (opportunitycontactrole conRec ,boolean selectedBox) {
    conObj = conRec;
    checkbox = selectedBox ;
  }  
 }   
// send method action=send
  public void send() {
  List<Messaging.SingleEmailMessage> lstEmailId = new List<Messaging.SingleEmailMessage >();
  for(wrapperClassEx w : wrapperList) {
    if(w.checkbox==true) {
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     mail.setToAddresses(new String [] { w.conObj.Contact.Email});      
    mail.setSubject ('Test Email' ) ;       
    mail.setPlainTextBody('Hello How are u?  Hope you are enjoying the  training?. ');
    Messaging.sendEmail( new Messaging.SingleEmailMessage[] {mail});   
      
      }
     }
    }
 }