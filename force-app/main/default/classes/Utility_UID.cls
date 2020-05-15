public with sharing class Utility_UID{
 
        //Variable Declarations   
        public static boolean toContinueCSTAR =true; //Static variable to avoid recursive updates on the event of Afterupdate-CSTAR
        public static boolean toContinueDST =true; //Static variable to avoid recursive updates on the event of Afterupdate-DST
        public static boolean toContinueContact=true; //Static variable to avoid recursive updates on the event of Afterupdate-Contact
  
 
        
       /**
         ***Author: Pankaj
         ***Description: This class is used in "viewsearchdetailsController" class for returning a combination of City ,State and Zip field seperated by comma.
       **/
    
       public static string combineCityStateZipCode(string city , string state, string zipcode){//Parameter a refers to City, b refers to State and c refers to Zip
                    string finalString= ''; // Declearing final temp Variable to return City, State and Zip combo seperated by comma              
                    string cityTemp='';
                    string stateTemp='';
                    string zipCodeTemp='';
                    string commaString='';    
                
                    if(city!=null && city!='null'){
                            cityTemp=city;
                            commaString =', ';        
                       
                    }
                     if(state!=null && state!='null'){
                     
                            stateTemp=commaString+state;
                             commaString =' ';        
                   
                    }
                     if(zipcode !=null && zipcode!='null'){
                            zipCodeTemp=commaString+ zipcode;               
                    
                    }
                    if(cityTemp!=null ||stateTemp!=null|| zipcodeTemp!=null){
                            finalString= cityTemp+stateTemp+zipcodeTemp;   
                    } 
                    return  finalString;
             
    }    
    
    
    
    
 
  
       public static string Append_Zero(string str , integer len){
                    String nullStr;
                    if(str!=null && str!=''){
                            str=str.trim();
                    }
                    else{
                            str=nullStr;
                    }
                    if(str!=null && str!='' && str.length()<len){
                            for(integer i = (len-str.length()) ; i>0; i--){          
                                    str = '0'+str.trim();                                  
                            }
                            
                        
                            system.debug('str'+str);
                    }
                    
                    return str;       
        
    }
    
       /**
         ***Author: Nandini
         ***Description: TO check the mailing state is valid or not.
         **/
     
       public static Boolean CheckMailingState(String MailState){
     
                    system.debug('NewContact.MailingState'+MailState.length());
                    if(MailState.length() == 2 ){
                       return true;
                     }else
                       return false;
            
                    
     }
     
     
       /**
         ***Author: Nandini
         ***Description: TO check the mailing state is valid or not.
         **/
     
       public static Boolean CheckPunctuations(String MailStreet){
                    system.debug('MailStreet'+MailStreet+'afterthestreet');
                    
                    system.debug('(Label.Punctuation).contains(MailStreet)'+(Label.Punctuation).contains(MailStreet));
                      
                    IF(String.isempty(MailStreet) || String.isBlank(MailStreet)){
                      
                            System.debug('entry 1');
                               
                            return true;
                       
      }
                    else  if((!sTRING.isempty(MailStreet)|| !sTRING.isblank(MailStreet)) ){
                                integer i;
                                for(i = 0; i<MailStreet.length(); i++){
                                            if((Label.Punctuation).contains(MailStreet.substring(i,i+1))){
                                                        system.debug('true before'+MailStreet.substring(i,i+1));
                                                        system.debug('true after');
                                                        return true;
                                                                                            
                                            }                   
                            }
                                System.debug('entry 2');
                    
                         
                    }
        
                    else
                                System.debug('entry 3');
        
                    return false;  
     }
     
         /**
         ***Author: Nandini
         ***Description: TO check the mailing state is valid or not.
         **/
     


         public static Boolean CheckMailingPostalcode(String MPC){

               System.debug('MPC'+MPC+'after');
                          System.debug('MPC length'+MPC.length());
               
               if(MPC.length()==5 && MPC.isNumeric()){
             
                           System.debug('entry 1' + 'return true');
                             return    true;
               }
               else if(MPC.length()==10 && (MPC.mid(5,1))== '-' && (MPC.substringAfter('-')).isNumeric() && (MPC.substring(0,4)).isNumeric()){
              
                           System.debug('entry 2' +'return true ');
                           
                         
                           return true;
               }
              
               else {
                            System.debug('mid'+ MPC.mid(5,1));
                          
                             System.debug('entry 3' +'return false');
                         
                           return false;
               }
   
  

     }
     
         
             /**
             ***Author: Pankaj
             ***Description: TO Capitalize first letter of every word and and keep rest all small.
             **/
       
            public static string Capitalize(string rawstr)
            {
                         System.debug('rawstr-before'+ rawstr);
                         String[] s= rawstr.tolowercase().split(' ');        
                     
                         string Capitals = '';
                         for(String str:s)
                          {       
                                 string s1 = str.Capitalize(); 
                                 Capitals = Capitals + ' ' + s1;
                          }
                         return Capitals;
            }
            
   
    
      
            /**
             ***Author: Divyashree M 
             ***Description:Performs CRD match for CSTAR and DST - Build an map of CRD _SFDc ID as key and UID as value from DST and CSTAR objects
            **/
            public static Map<String,String> populateCRDMapForRegularFlow(Set<String> CRDSet){
                    
                        Map<String,String>  CRDMap = new map<String, String>();
                        Set<String> firstRemainderCRDSet =new Set<String>();
                        Set<String> secondRemainderCRDSet =new Set<String>();
                        
                        //system.debug('Value of set CRD: '+CRDSet);
                        
                         if(!crdset.isempty() && crdset!=null ){
                        for(Contact AdvisorCRD:[select id,sfdc_id_uid__c,CRD_P__c from Contact where CRD_P__C in:CRDSet and crd_p__c<>null]){
                        
                        CRDMap.put(AdvisorCRD.CRD_P__c,AdvisorCRD.sfdc_id_uid__c+'-'+AdvisorCRD.id);
                        
                        }
                     
                        
                        if(CRDMap ==null){
                        firstRemainderCRDSet=CRDSet;
                        }
                        else{ 
                         for(String s: CRDSet){
                            if(!CRDMap.containskey(s)){
                              firstRemainderCRDSet.add(s);
                            }
                         }    
                       }
                        if(firstRemainderCRDSet!=null){
                        for(CAD_CSTAR_ADVISOR__C CSTARCRD:[select id,uid__c,CRD_P__c from CAD_CSTAR_ADVISOR__C where CRD_P__C in:firstRemainderCRDSet and crd_p__C<>null]){
                        CRDMap.put(CSTARCRD.CRD_P__c,CSTARCRD.UID__c+'-'+CSTARCRD.id);
                       }
                       }
                       if(CRDMap== null){
                       secondRemainderCRDSet=firstRemainderCRDSet;
                       }
                      else {
                       for(String s: firstRemainderCRDSet){
                      if( !CRDMap.containskey(s)){
                       secondRemainderCRDSet.add(s);
                       }
                       }
                      }  
                      
                       if(secondRemainderCRDSet!=null){
                        for(CAD_DST_Advisors__c DSTCRD:[select id,CRD_P__c,UID__C from CAD_DST_Advisors__c where CRD_P__c in:secondRemainderCRDSet and crd_p__c<>null]){
                            CRDMap.put(DSTCRD.CRD_P__C,DSTCRD.uid__c+'-'+DSTCRD.id);
                       
                       } 
                       }
                         }
                      return CRDMap;
                  
                    }
  
         
               /**
              ***Author: Divyashree M
              ***Description:Forms a combination of LastName, City and State by lowering the case and cascades using the '|' as the seperator
              **/
              public static String buildLastNameCityStateLowerCase(String LastName, String City, String State,String FirstName, String FirmName, String Zip){
                    String LNCityStateCombo='';
                    String lnTemp='';
                    String cityTemp='';
                    String stateTemp='';
                    String fnTemp='';
                    String zipTemp='';
                    String firmnameTemp='';
              
                    
                    
                    if(LastName !=null && LastName!=''){
                              lnTemp= LastName.trim().toLowercase();
                 
                    
                    }
                     if(City !=null && City!=''){
                              cityTemp= City.trim().toLowercase();
             
                    }
                     if(State !=null && State!=''){
                              stateTemp= State.trim().toLowercase();
                  
                    
                    }
                     if(FirstName !=null && FirstName!=''){
                              fnTemp= FirstName.trim().toLowercase();
                   
                    
                    }
                     if(FirmName !=null && FirmName!=''){   
                             firmNameTemp= FirmName.trim().toLowercase();
                  
                    
                    }
                     if(Zip !=null && Zip!=''){
                             zipTemp= Zip.trim().toLowercase();
                    
                    
                    }
                    if(lnTemp!=null ||cityTemp!=null|| stateTemp!=null||fnTemp!=null||firmNameTemp!=null||ZipTemp!=null){
                            LNCityStateCombo= fnTemp+'|'+lnTemp+'|'+ cityTemp +'|'+ stateTemp+'|'+ZipTemp+'|'+firmNameTemp;   
                    } 
                    return  LNCityStateCombo;
                    }
       
       
           /**
      ***Author: Divyashree M
      ***Description:Lowers the case of the String
      **/
        public static String buildEmailLowerCase(String Email){
       
        String emailTemp=null;
        
        if(Email !=null && email!=''){
        emailTemp= Email.trim().toLowercase();
        }
       
        return  emailTemp;
        }
        
            
         /**
     ***Author: Pankaj
     ***Description: building  new CAD_Historical_Address__c records after acquiring data from CAD_DST_Advisors__c object records
     ***Date : 29 January 2013
    **/
        public static void buildDSTAddress(List<CAD_DST_Advisors__c> lst)
       {
            
            
            List<CAD_Historical_Address__c> historical_list = new List<CAD_Historical_Address__c>();
            if(toContinueDST){// boolean variable to check recursion
            //itrating over each record and preparing list 
            for(CAD_DST_Advisors__c d: lst)
            {
                CAD_Historical_Address__c hist = new CAD_Historical_Address__c();
                hist.ADDR_1__c = d.REP_OFFICE_ADDR_1__c;
                hist.ADDR_2__c = d.REP_OFFICE_ADDR_2__c;
                hist.CITY__c = d.REP_WORK_CITY__c;
                hist.STATE__c = d.REP_WORK_STATE__c;
                hist.COUNTRY_CODE__c = d.REP_WORK_COUNTRY_CODE__c;
                hist.POSTAL_CODE_1__c = d.REP_WORK_POSTAL_CODE_1__c;
                hist.POSTAL_CODE_2__c = d.REP_WORK_POSTAL_CODE_2__c;
                hist.UID__c = d.UID__c;
                hist.ID__c = d.id;
                hist.SRC_SYS__c='DST SalesConnect';
                hist.record_url__c=URL.getSalesforceBaseUrl().toExternalForm()+'/'+d.id;
                historical_list.add(hist);              
                     
                
            }
            
            System.debug('before historical_list buildDSTAddress'+historical_list);
            
            //Exception handeling Block 
            try
                {   //DML Statement to insert list of Historical address
                    insert historical_list;
                    System.debug('after historical_list buildDSTAddress'+historical_list);
            
                     
                }
                
            catch(DMLException e)
                {
                    e.getMessage();
             }
            }
            toContinueDST=false; 
                
            
            }
            
                /**
     ***Author: Pankaj
     ***Description: building  new CAD_Historical_Address__c records after acquiring data from CAD_CSTAR_Advisor__c object records
     ***Date : 29 January 2013
    **/
        public static void buildCSTARAddress(List<CAD_CSTAR_Advisor__c> lst)
       {
            List<CAD_Historical_Address__c> historical_list = new List<CAD_Historical_Address__c>();
            System.debug('toContinueCSTAR'+toContinueCSTAR);
        if(toContinueCSTAR){// boolean variable to check recursion
            //itreating over each record      
            for(CAD_CSTAR_Advisor__c d: lst)
            {
                CAD_Historical_Address__c hist = new CAD_Historical_Address__c();
                hist.ADDR_1__c = d.Address_1__c;
                
                hist.ADDR_2__c = d.Address_2__c;
                hist.CITY__c = d.CITY__c;
                hist.STATE__c = d.STATE__c;
                hist.COUNTRY_CODE__c = d.COUNTRY__c;
                hist.POSTAL_CODE_1__c = d.ZIP__c;
                hist.UID__c = d.UID__c;
                System.debug('UID__c'+hist.UID__c);
                hist.ID__c = d.id;
                hist.SRC_SYS__c=d.Source_System__c;
                hist.record_url__c=URL.getSalesforceBaseUrl().toExternalForm()+'/'+d.id;
              
                historical_list.add(hist);                          
            }
            
            System.debug('before historical_list buildCSTARAddress'+historical_list);
            
            
            try
                {   //DML Statement to insert list of Historical address
                    insert historical_list;  
                    System.debug('after historical_list buildCSTARAddress'+historical_list);
                               
                }
            catch(DMLException e)
                {
                    e.getMessage();
                }
        }
                toContinueCSTAR=false;
              
                System.debug('CSTAR'+historical_list);
            }
            
            
            /**
     ***Author: Pankaj
     ***Description: building  new CAD_Historical_Address__c records after acquiring data from CAD_CSTAR_Advisor__c object records
     ***Date : 29 January 2013
    **/
        public static void buildContactAddress(List<Contact> lst)
         {       
            List<CAD_Historical_Address__c> historical_list = new List<CAD_Historical_Address__c>();
        if(toContinueContact){// boolean variable to check recursion
            //itreating over each record
            for(Contact d: lst)
            {
                CAD_Historical_Address__c hist = new CAD_Historical_Address__c();
                hist.ADDR_1__c = d.street_holder__c;           
                hist.CITY__c = d.city_holder__c;
                hist.STATE__c = d.state_holder__c;
                
                hist.POSTAL_CODE_1__c = d.zip_holder__c;           
                hist.UID__c = d.SFDC_ID_UID__c;
                hist.ID__c = d.id;
                hist.SRC_SYS__c=d.Source_System__c;
                hist.record_url__c=URL.getSalesforceBaseUrl().toExternalForm()+'/'+d.id;
              
                historical_list.add(hist);                            
            }
            
            System.debug('before historical_list buildContactAddress'+historical_list);
            
            
            try
                {   
                    insert historical_list; // DML statement to insert record in Historical Address object   
                    System.debug('after historical_list buildContactAddress'+historical_list);
                           
                }
            catch(DMLException e)
                {
                    e.getMessage();
         }              
                             
        }
        toContinueContact=false;// setting variable to avoid recursion call of trigger
        }
            
                      
     
        public static void buildContactAddressForSysAdmin(List<Contact> lst)
         {       
            List<CAD_Historical_Address__c> historical_list = new List<CAD_Historical_Address__c>();
        if(toContinueContact){// boolean variable to check recursion
            //itreating over each record
            for(Contact d: lst)
            {
                CAD_Historical_Address__c hist = new CAD_Historical_Address__c();
                        hist.ADDR_1__c = d.MailingStreet;           
                        hist.CITY__c = d.MailingCity;
                        hist.STATE__c = d.MailingState;
                        hist.COUNTRY_CODE__c = d.MailingCountry;
                        hist.POSTAL_CODE_1__c = d.MailingPostalCode;           
                        hist.UID__c = d.SFDC_ID_UID__c;
                        hist.ID__c = d.id;
                        hist.SRC_SYS__c=d.Source_System__c;
                        hist.record_url__c=URL.getSalesforceBaseUrl().toExternalForm()+'/'+d.id;
              
                historical_list.add(hist);                            
            }
            
            System.debug('before historical_list buildContactAddress'+historical_list);
            
            
            try
                {   
                    insert historical_list; // DML statement to insert record in Historical Address object   
                    System.debug('after historical_list buildContactAddress'+historical_list);
                           
                }
            catch(DMLException e)
                {
                    e.getMessage();
         }              
                             
        }
        toContinueContact=false;// setting variable to avoid recursion call of trigger
        }
            
            
       
       /**
     ***Author: Nausheen
     ***Description: 
     ***Date : 05 March 2013
    **/
      //Method for deleting oldest record
        public static void GetOldestRecord_SourceSystem(List<CAD_Historical_Address__c> lst, List<CAD_Historical_Address__c> Source)
                   { 
                    //lst = list of all Historical Address Records
                    //Source = Trigger.new 
                    List<CAD_Historical_Address__c> ct_lst = new List<CAD_Historical_Address__c>();
                    List<CAD_Historical_Address__c> cstar_lst= new List<CAD_Historical_Address__c>();
                    List<CAD_Historical_Address__c> dst_lst= new List<CAD_Historical_Address__c> ();
                    
                   
                    //uids_from_source = List of all UID values coming from Source
                    //Collecting unique UID values into a List
                    List<String> uids_from_source = new List<String>();
                    Set<String> s= new Set<String>();
                    for(CAD_Historical_Address__c HA: Source)
                    {
                            s.add(HA.UID__C);
                    }
            
                    uids_from_source.addAll(s);
                    
                    //uids_from_source is the set of all unique UIDs from Source
                    
                    //Filtering records on the basis of Source System 
                    ct_lst=[select id,uid__c,lastmodifieddate,SRC_SYS__c from CAD_Historical_Address__c where uid__c in: uids_from_source and SRC_SYS__c='Salesforce'];
                    cstar_lst=[select id,uid__c,lastmodifieddate,SRC_SYS__c from CAD_Historical_Address__c where uid__c in: uids_from_source and SRC_SYS__c='CSTAR' ];
                    dst_lst=[select id,uid__c,lastmodifieddate,SRC_SYS__c from CAD_Historical_Address__c where uid__c in: uids_from_source and SRC_SYS__c='DST SalesConnect' ];
                          
                    Map<String,list<CAD_Historical_Address__c>> map_UID = new Map<String,list<CAD_Historical_Address__c>>(); 
                    CAD_Historical_Address__c rec;     
                    List<CAD_Historical_Address__c> oldest_records = new List<CAD_Historical_Address__c>();
                    //Itrating for each list record 
                   
                               
                    
                    for(CAD_Historical_Address__c src :Source)
                    {
                        
                        if(src.SRC_SYS__c == System.Label.Source_System_CSTAR)
                        {
                            
                            for(CAD_Historical_Address__c hst:cstar_lst)
                            {
                                        if(src.UID__c == hst.UID__c)    //if the UID value already exists
                                    {                               
                                            
                                        if(map_UID.containskey(hst.UID__c))
                                            {                           
                                                map_UID.get(hst.UID__c).add(hst);       
                                            }            
                                        else
                                            {
                                            list<CAD_Historical_Address__c> templist = new list<CAD_Historical_Address__c>();   
                                            templist.add(hst);
                                            map_UID.put(hst.UID__c,templist);  // Final Map creation for Records w.r.t their UID's         
                                            } 
                                    }                         
                            }
                        }
                        
                        
                        else if(src.SRC_SYS__c == System.Label.Source_System_DST_SalesConnect)
                        {
                             
                            for(CAD_Historical_Address__c hst:dst_lst)
                            {
                                        if(src.UID__c == hst.UID__c)
                                    {                               
                                        
                                        if(map_UID.containskey(hst.UID__c))
                                            {                           
                                                map_UID.get(hst.UID__c).add(hst);       
                                            }            
                                        else
                                            {
                                            list<CAD_Historical_Address__c> templist = new list<CAD_Historical_Address__c>();   
                                            templist.add(hst);
                                            map_UID.put(hst.UID__c,templist);  // Final Map creation for Records w.r.t their UID's         
                                            } 
                                    }                         
                            }
                        }
                        
                        
                        else if(src.SRC_SYS__c == System.Label.Source_System_Salesforce)
                        {
                            
                            for(CAD_Historical_Address__c hst:ct_lst)
                            {
                                        if(src.UID__c == hst.UID__c)
                                    {                               
                                        
                                        if(map_UID.containskey(hst.UID__c))
                                            {                           
                                                map_UID.get(hst.UID__c).add(hst);       
                                            }            
                                        else
                                            {
                                            list<CAD_Historical_Address__c> templist = new list<CAD_Historical_Address__c>();   
                                            templist.add(hst);
                                            map_UID.put(hst.UID__c,templist);  // Final Map creation for Records w.r.t their UID's         
                                            } 
                                    }                         
                            }
                        }
                        
                    }
                    
                    
                    
                    
                    
                  
                   for(String i : map_UID.keyset())
                   {
                        if(map_UID.get(i).size() > 3)   //If the number of records for the same Source System under one UID value is greater than 3
                            { 
                                 
                            for(CAD_Historical_Address__c cad : map_UID.get(i))
                            {
                            if(rec==null)
                            {
                                
                                 rec=cad;
                            }
                                            
                            else if(rec.lastmodifieddate > cad.lastmodifieddate)
                            {
                                rec=cad;    
                            }        
                            }
                            oldest_records.add(rec); //collecting list of oldest record  
                           }           
                   }
                   
                   try
                   {    // DML statement for deleting oldest record.
                        delete oldest_records;
                   }
                   
                   catch(Exception e)
                   {
              e.getmessage();
                   }
                   
                   
                   }
      
 }