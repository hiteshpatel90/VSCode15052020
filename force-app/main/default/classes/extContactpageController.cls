public class extContactpageController{

public String country {get;set;}
    public String state {get;set;}
    public Contact cont{get;set;}
    
    public extContactpageController(ApexPages.StandardController controller) {
          cont = new contact();
    }

    public pagereference saveContact(){       
        cont.lastname = cont.lastname ;
        cont.firstName =cont.firstName;
        cont.Couuntry__c = country ;
        cont.State__c = state;
        insert cont;
        PageReference ref= new ApexPages.StandardController(cont).view();        
        return ref;
    }
    
    public void cancelRecord(){
        cont.lastname = '';
        cont.firstName ='';
        Pagereference page = new pagereference('/003/o');
        page.setredirect(true);
    }
    
    public List<SelectOption> getCountryItems(){
        List<SelectOption> options = new List<SelectOption>(); 
            options.add(new SelectOption('','-- None --')); 
            options.add(new SelectOption('US','US')); 
            options.add(new SelectOption('UK','UK')); 
            options.add(new SelectOption('INDIA','INDIA'));
            return options;
    }
    
    public List<SelectOption> getStateItems(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('','-- None --')); 
        if(country == 'US'){            
            options.add(new SelectOption('US1','US1')); 
            options.add(new SelectOption('US2','US2')); 
            options.add(new SelectOption('US3','US3'));
            return options;
        }
        if(country == 'India'){
            options.add(new SelectOption('India1','India1')); 
            options.add(new SelectOption('India2','India2')); 
            options.add(new SelectOption('India3','India3'));
            return options;
        }
        if(country == 'UK'){
            options.add(new SelectOption('uk1','uk1')); 
            options.add(new SelectOption('uk2','uk2')); 
            options.add(new SelectOption('uk3','uk3'));
            return options;
         }
        return options;
    }  
}