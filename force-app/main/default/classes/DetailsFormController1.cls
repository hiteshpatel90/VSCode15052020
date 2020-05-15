public class DetailsFormController1 {
    public Integer ShowPage { get; set; }
    public Account objAccount { get; set; }
    public boolean Selected{ get; set; }
    
    public DetailsFormController1(){
        objAccount =new Account(Name ='Dell', Industry = 'Technology');
        system.debug('@@@@@@@@'+objAccount);
        //         objAccount= [select Name,BillStreet__c,BillCity__c,BillState__c from Account where Name='Raja123'];
        ShowPage=1;     
    }   
    public PageReference Previous() {
        ShowPage --; 
        return null;
    }
    public PageReference Next() {
        ShowPage ++ ;
        return null ;
    }
    
    public PageReference Save() {
        try  {
            insert objAccount ;
            objAccount.AddError('Record inserted successfully'); 
            return null;        
        }catch(Exception e) {
            objAccount.AddError(e);
            return null;      
        }    
    }
    
    public PageReference CopyFields() {
        if(objAccount!= null && objAccount.id != null){
            if(objAccount.BillStreet__c != null && objAccount.BillStreet__c != ''){            
                objAccount.ShipStreet__c=objAccount.BillStreet__c;
            }            
            update objAccount;        
        } else {        
            objAccount.AddError('Record inserted successfully');
        
        }   // objAccount.ShipStreet__c=objAccount.BillStreet__c;}
        
        return null;
    }
}