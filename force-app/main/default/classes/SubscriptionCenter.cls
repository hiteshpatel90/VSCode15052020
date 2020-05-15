public with sharing class SubscriptionCenter {
 

    public class DecoratedPublication {
        public Publication__c thePub {get; set;} 
        public Subscription__c theSub {get; set;}
        

        public Boolean newSub {get; private set;} 
        public Boolean changedSub {get; private set;}
        
        public Date getSubLastModified() {
            if ( changedSub || newSub) {
                return Date.today();
            }
            
            if ( theSub != null ) {
                return (Date) theSub.LastModifiedDate.date();               
            } else {
                return null;
            }       
        }
        
        public String getSubLastModifiedBy() {
            if (theSub != null ) {
                return theSub.LastModifiedBy.name;
            } else {
                return '';
            }
            
        }
                
        public boolean getContainsSubscription() { return (theSub != null); }
        private SubscriptionCenter sc;
        
        public void setSubscribed(Boolean s) {
            if ( getContainsSubscription() ) {
                if ( theSub.Subscribed__c != s) {
                    theSub.Subscribed__c = s;
                    changedSub = true;
                }           
            } else {
                if ( s == true ) {
                    theSub = new Subscription__c();
                    theSub.Advisor__c = sc.cont.id;
                    theSub.Publication__c = thePub.id;
                    theSub.Subscribed__c = s;
                    changedSub = true;
                    newsub = true;
                }                           
            }
            
        }
        
        public boolean getSubscribed() {
            if ( getContainsSubscription() ) {
                return theSub.Subscribed__c;
            } else {
                return false;
            }           
        }
        
        public boolean selected {get; set;}

        public String getPublicationType() {
            if ( thePub.Type__c == 'Electronic Mutual Fund Publication') {
                return 'EMF';
            } else if ( thePub.Type__c == 'Electronic Publication' ) {
                return 'E';             
            } else if ( thePub.Type__c == 'Print Publication') {
                return 'P';                             
            } else {
                return '';
            }
                                                
        }

        public boolean duplicateName {get; set;}
                
        private DecoratedPublication(Publication__c pub, SubscriptionCenter theSc, boolean dupName) {
            newSub = false;
            changedSub = false;
            sc = theSc;
            
            selected = false;
            duplicateName = dupName;
            
            thePub = pub;
            if (sc.subs.containsKey(thePub.id)) {
                theSub = sc.subs.get(thePub.id);
            } else {
                theSub = null;
            }
        }               
    }



    private final Contact cont;



    
    private List<DecoratedPublication> electronicPubs;
    private List<DecoratedPublication> electronicMutualFundPubs;
    

    public PageReference selectclick() {
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            if (dp.selected && !dp.getSubscribed()) {
                dp.setSubscribed(true);
                dp.selected = false;
            } else {
                dp.selected = false;
            }                           
        }
        
        return null;

    }

    public PageReference unselectclick() {
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            if (dp.selected && dp.getSubscribed()) {
                dp.setSubscribed(false);
                dp.selected = false;
            } else {
                dp.selected = false;
            }                           
        }

        return null;
    }
    
    
    public void setSubscribeTo(String[] s) {
        Set<String> idsToSet = new Set<String>(s);
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            if ( idsToSet.contains(dp.thePub.id)) {
//              dp.setSubscribed(true);
                dp.selected = true;             
            }       
        }       
    }
    
    public String[] getSubscribeTo() {
        String[] s = new String[]{};
        
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            if ( dp.selected ) {
                s.add(dp.thePub.name);
            }           
        }
        
        return s;               
    }
    
    
    public void setUnsubscribeTo(String[] s) {
        Set<String> idsToSet = new Set<String>(s);
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            if ( idsToSet.contains(dp.thePub.id)) {
//              dp.setSubscribed(false);
                dp.selected = true;             
            }       
        }       
    }
    
    public String[] getUnsubscribeTo() {
        String[] s = new String[]{};
        
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            if ( !dp.selected ) {
                s.add(dp.thePub.name);
            }           
        }
        
        return s;               
    }
    
    /*
    public List<SelectOption> getEMFPublications() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            options.add(new SelectOption(dp.thePub.id, dp.thePub.name));            
        }
        
        return options;     
    }
    */
    
    public List<SelectOption> getEMFSubscriptionOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            if ( dp.getSubscribed() ) {
                options.add(new SelectOption(dp.thePub.id, dp.thePub.name));
            }           
        }
        
        return options;     
    }

    public List<SelectOption> getEMFNotSubsciptionOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            if ( !dp.getSubscribed() ) {            
                options.add(new SelectOption(dp.thePub.id, dp.thePub.name));            
            }
        }
        
        return options;     
    }
    
    public void unsubscribeAll() {
        for(DecoratedPublication dp : electronicMutualFundPubs) {
            dp.setSubscribed(false);            
        }

        for(DecoratedPublication dp : electronicPubs) {
            dp.setSubscribed(false);            
        }               
    }
    

    private Map<Id, Subscription__c> subs;

    public SubscriptionCenter(ApexPages.StandardController stdController) {
        this.cont = (Contact)stdController.getRecord();
        loadData(); 
    }
    
    
    
    private void loadData() {
        
        subs = new Map<Id, Subscription__c>();
        electronicPubs = new List<DecoratedPublication>();
        electronicMutualFundPubs = new List<DecoratedPublication>();
        
        for(Subscription__c sub: [SELECT Advisor__c, Subscribed__c, Lead__c, Publication__c, LastModifiedDate, LastModifiedBy.Name FROM Subscription__c where Advisor__c = :cont.id]) {
            if (subs.containsKey(sub.Publication__c) ) {
                System.debug('Duplicate Publication ' +  (String)(sub.Publication__c) );    
            } else {
                subs.put( sub.Publication__c , sub);
            }                               
        }

        String lastName = '';
                
        for(Publication__c pub : [SELECT Id, Delivery_Timeframe__c, Description__c, Name, Plain_Text_Description__c, Type__c FROM Publication__c where Type__c != 'Inactive Publication' order by Name, Type__c ]) {
            
            if ( pub.Type__c == 'Electronic Mutual Fund Publication') {
                electronicMutualFundPubs.add(new DecoratedPublication(pub,this, lastName == pub.Name));
            } else if ( pub.Type__c == 'Electronic Publication' ) {
                electronicPubs.add(new DecoratedPublication(pub,this, lastName == pub.Name));               
            } else if ( pub.Type__c == 'Print Publication') {
                electronicPubs.add(new DecoratedPublication(pub,this, lastName == pub.Name));                               
            }   
            lastName = pub.Name;                        
        }
        
    }
    
    public List<DecoratedPublication> getElectronicPubs() {
        return electronicPubs;      
    }
    
    public List<DecoratedPublication> getElectronicMutualFundPubs() {
        return electronicMutualFundPubs;        
    }

    public PageReference gotoAdvisor() {
        PageReference contPage = new ApexPages.StandardController(cont).view();
            contPage.setRedirect(true);
            return contPage;            
    }
    
    public PageReference save() {
        
        List<Subscription__c> changedSubs = new List<Subscription__c>();
        
        
        for(DecoratedPublication dp: electronicPubs) {
            if ( dp.changedSub ) {
                changedSubs.add(dp.theSub);
            }           
        }

        for(DecoratedPublication dp: electronicMutualFundPubs) {
            if ( dp.changedSub ) {
                changedSubs.add(dp.theSub);
            }                   
        }

        if ( !changedSubs.isEmpty() ) {
            upsert changedSubs;
        }

        update cont;
            
        loadData();
        return null;                    
    }
   
}