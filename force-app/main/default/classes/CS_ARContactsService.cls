public with sharing class CS_ARContactsService {
 
    Private Static FINAL String fixedFileName = 'surgeon_Profile_Pic.png';
 
    public static List<Account> retrievePractitioners() {
        
        String defaultProfilePic = CS_ARProfileService.getPathToDefaultSurgeonProfileImage();
        List<Account> practitioners = CS_ARSearch.searchSurgeonsInMyTeamTerritory('');

        // set a default profile pic if one doesn't exist

        for ( Account acct : practitioners ) {
            if ( acct != null && ( acct.Profile_Picture__c == null || acct.Profile_Picture__c.length() == 0 || acct.Profile_Picture__c.contains('/profilephoto/005/') ) ){
                acct.Profile_Picture__c = defaultProfilePic;
            }
        }

        return practitioners;
        
    }

    public static Account retrievePractitioner(String accountId) {
        
        system.debug('##--retrievePractitioner.accountId:'+ accountId);
        Account acct  = [select Id,Name, Organization__c, Preferred_Name__c,
            Profile_Picture__c, Phone, Email__c, Fax,Provider__r.Id, Provider__r.Name,
            Practice_Name__c,Native_Language__c,Gender__c,
            Residencies__c,Fellowships__c, Sport_Interests__c, Education__c,
            Internship__c, Certifications__c, Awards__c,Professional_Societies__c,Competitions__c,Personal_Intrest__c,
            Competitors__c, Customer_Number__c, Graduate_Education__c,Undergraduate_Education__c,
            Doctorate_Education__c, Family_Information__c, website
            from Account 
            where Id=:accountId
            order by Name DESC];
            system.debug('##--retrievePractitioner.acct:'+ acct);
        if ( acct != null && ( acct.Profile_Picture__c == null || acct.Profile_Picture__c.contains('/profilephoto/005/') ) ){
            acct.Profile_Picture__c = CS_ARProfileService.getPathToDefaultSurgeonProfileImage();
        }

        return acct;

    }    

    public static void updateProvider(Map<String,Object> providerFields) {

        String id = (String)providerFields.get('id');
        Account provider = [select Id, Preferred_Name__c, Website,Credentialing_Company__c,Representative_Parking__c,Required_to_Change_Scrubs__c,
            Sign_In_Location__c,Business_Hours_Start__c,Business_Hours_End__c,Sterile_Processing_Location__c,Operating_Room_Location__c,Other_Attire_Notes__c,
            Sterile_Processing_Hours_Start__c,Sterile_Processing_Hours_End__c,Account_Fiscal_Year_Start_Day__c,Account_Fiscal_Year_Start_Month__c,
            Account_Fiscal_Year_End_Month__c,Account_Fiscal_Year_End_Day__c  from Account where Id=:id];//Field added to query by Ansu for release 2.2 account tab redesign 
        if ( provider != null ) {
            
            // preferred name
            String nick = (String)providerFields.get('nickname');
            //if ( nick != null || nick == ' ' ) {
                provider.Preferred_Name__c = nick;           
            //}
            
            string strWebsite = (String)providerFields.get('website');
            if ( strWebsite != null ) {
                provider.WebSite = strWebsite;           
            }
            //Code added by Ansu for release 2.2 account tab redesign 
            string strCredComp = (String)providerFields.get('credentialcompany');
            if ( strCredComp != null ) {
                provider.Credentialing_Company__c = strCredComp ;           
            }
            
            string strRepPar = (String)providerFields.get('RepresentativeParking');
            if ( strRepPar != null ) {
                provider.Representative_Parking__c= strRepPar ;           
            }
            
            string strChangeScrub = (String)providerFields.get('RequiredtoChangeScrubs');
            if ( strChangeScrub  != null && strChangeScrub  != ' ') {
                provider.Required_to_Change_Scrubs__c= strChangeScrub ;           
            }
            if ( strChangeScrub  == ' '){
                provider.Required_to_Change_Scrubs__c= null ;  
            }
            
            string strStrlHr = (String)providerFields.get('SterileProcessingLocation');
            if ( strStrlHr != null ) {
                provider.Sterile_Processing_Location__c= strStrlHr ;           
            }
            
            string strOpLoc = (String)providerFields.get('OperatingRoomLocation');
            if ( strOpLoc != null ) {
                provider.Operating_Room_Location__c= strOpLoc ;           
            }
            string strSignIn = (String)providerFields.get('SignInLocation');
            if ( strSignIn != null ) {
                provider.Sign_In_Location__c = strSignIn ;           
            }
            
            string strOthrAttr = (String)providerFields.get('OtherAttireNotes');
            if ( strOthrAttr != null ) {
                provider.Other_Attire_Notes__c = strOthrAttr ;           
            }
            string strBusinessHourStrt = (String)providerFields.get('businessHourStartTime');
            string strBusinessHourEnd = (String)providerFields.get('businessHourEndTime');
            if ( strBusinessHourStrt != null ) {
                if(strBusinessHourStrt==' '){
                    provider.Business_Hours_Start__c=null;
                }
                else
                    provider.Business_Hours_Start__c= strBusinessHourStrt ;
                
                }
            if ( strBusinessHourEnd != null ) {
                if(strBusinessHourEnd ==' '){
                    provider.Business_Hours_Start__c=null;
                }
                else
                    provider.Business_Hours_End__c= strBusinessHourEnd ; 
                }          
            
            string strSterileProcHourStrt = (String)providerFields.get('SterileProcessingHourStartTime');
             string strSterileProcHourEnd = (String)providerFields.get('SterileProcessingHourEndTime');
            if ( strSterileProcHourStrt != null ) {
                if(strSterileProcHourStrt ==' '){
                    provider.Sterile_Processing_Hours_Start__c=null;
                }
                else
                provider.Sterile_Processing_Hours_Start__c= strSterileProcHourStrt ;
                }
            if ( strSterileProcHourEnd != null ) {   
                if(strSterileProcHourEnd ==' '){
                    provider.Sterile_Processing_Hours_End__c=null;
                }
                else 
                provider.Sterile_Processing_Hours_End__c= strSterileProcHourEnd ; 
                }   
                
            string strAccFiscalStrtDay = (String)providerFields.get('AccountFiscalYearStartDay');
            string strAccFiscalStrtMonth = (String)providerFields.get('AccountFiscalYearStartMonth');
            if ( strAccFiscalStrtDay != null ) {
                if(strAccFiscalStrtDay ==' '){
                    provider.Account_Fiscal_Year_Start_Day__c=null;
                }
                else
                provider.Account_Fiscal_Year_Start_Day__c= strAccFiscalStrtDay ;
                }
            if ( strAccFiscalStrtMonth != null ) {   
                if(strAccFiscalStrtMonth ==' '){
                    provider.Account_Fiscal_Year_Start_Month__c=null;
                }
                else 
                provider.Account_Fiscal_Year_Start_Month__c= strAccFiscalStrtMonth ; 
                }  
                
            string strAccFiscalEndDay = (String)providerFields.get('AccountFiscalYearEndDay');
            string strAccFiscalEndMonth = (String)providerFields.get('AccountFiscalYearEndMonth');
            if ( strAccFiscalEndDay != null ) {
                if(strAccFiscalEndDay ==' '){
                    provider.Account_Fiscal_Year_End_Day__c=null;
                }
                else
                provider.Account_Fiscal_Year_End_Day__c= strAccFiscalEndDay ;
                }
            if ( strAccFiscalEndMonth != null ) {   
                if(strAccFiscalEndMonth ==' '){
                    provider.Account_Fiscal_Year_End_Month__c=null;
                }
                else 
                provider.Account_Fiscal_Year_End_Month__c= strAccFiscalEndMonth ; 
                }   
                                  
           
            //Code added by Ansu for release 2.2 account tab redesign ends
            
            update provider;
        }
    }

    public static void updatePractitionerDemographics(Map<String,Object> surgeon) {


        Account practitioner = CS_ARContactsService.retrievePractitioner( (String)surgeon.get('id') );
        if ( practitioner != null ) {

            Date birthDate = null;
            if ( surgeon.get('birthDate') != null ) {
                birthDate = DateTime.newInstance( Long.valueOf( (String)surgeon.get('birthDate') )).date();
            }

            //practitioner.NPI__pc = (String)surgeon.get('npi');
            //practitioner.PersonBirthdate = birthDate;
          //  practitioner.FirstName = (String)surgeon.get('firstName');

           // if ( surgeon.containsKey('lastName') ) {practitioner.LastName = (String)surgeon.get('lastName'); }
            //if ( surgeon.containsKey('email') ) { practitioner.PersonEmail = (String)surgeon.get('email'); }
            
            //Commented by Mimansha for Release 2.2 as Do Not Email field is now non-editable
            /*            
            boolean optedOut = false;
            if ( surgeon.containsKey('hasOptedOutOfEmail')) {optedOut = (Boolean)surgeon.get('hasOptedOutOfEmail'); }

            practitioner.PersonHasOptedOutOfEmail = optedOut;
            */
            if ( surgeon.containsKey('arthrexMarkEmail')) {
                //practitioner.PersonHasOptedOutOfEmail = boolean.valueOf(surgeon.get('arthrexMarkEmail'));
            }
           // practitioner.Assigned_Sales_Rep_Email__pc = (String)surgeon.get('assignedSalesRepEmail');

            practitioner.Practice_Name__c = (String)surgeon.get('practiceName');
            practitioner.Native_Language__c = (String)surgeon.get('lang');
            //practitioner.PersonTitle = (String)surgeon.get('title');
          // commented by -Swetha P -April 13 - for Name 
          //  String salutationStr = '--None--';
            
          //  practitioner.Salutation = salutationStr;

            /*practitioner.Gender__c = (String)surgeon.get('gender');            
            
            practitioner.User_Type__pc = (String)surgeon.get('userType');
            practitioner.PersonMailingState = (String)surgeon.get('mState');
            practitioner.Focus_of_my_practice__pc = (String)surgeon.get('practiceFocus');
            system.debug('##--updatePractitionerDemographics.surgeon: ' +  surgeon);
            system.debug('##--updatePractitionerDemographics.designation: ' + (String)surgeon.get('designation'));
            
            practitioner.Designation__pc = (String)surgeon.get('designation');
            practitioner.Arthrex_com_Surgeon_Specialty__pc = (String)surgeon.get('specialty');
            practitioner.Phone = (String)surgeon.get('phone');
            practitioner.PersonMobilePhone = (String)surgeon.get('mobilePhone');
            practitioner.PersonMailingStreet = (String)surgeon.get('mStreet');
            practitioner.PersonMailingCity = (String)surgeon.get('mCity');
            practitioner.PersonMailingPostalCode = (String)surgeon.get('mZip');
            practitioner.Surgery_Days__pc = (String)surgeon.get('surgeryDays'); 
            practitioner.Clinic_Days__pc = (String)surgeon.get('clinicDays'); 
            practitioner.Preferred_Name__c = (String)surgeon.get('preferredName');
            system.debug('##--updatePractitionerDemographics.practitioner: ' + practitioner);
            //updated by Srinivas Sattoor on 6.28.2017 for 4.1 CID-000334
            ClsStaticVariables.ProcessPractitionerGeoCodeCalculation = true;
            update practitioner;*/
            
    
        }
    
    }

    public static void updatePractitionerBio(Map<String,Object> practitionerBio ) {

        String practionerId = (String)practitionerBio.get('id');
        system.debug('##-- practitionerBio: '+ practitionerBio);
        Account practitioner = CS_ARContactsService.retrievePractitioner(practionerId);
        if ( practitioner != null ) {
            
           /* system.debug('##-- undergraduateId: '+ (String)practitionerBio.get('undergraduateId'));
            practitioner.Graduate_Institution__pc = (String)practitionerBio.get('graduateId') == '' ? null : (String)practitionerBio.get('graduateId');
            practitioner.Undergraduate_Institution__pc = (String)practitionerBio.get('undergraduateId') == '' ? null : (String)practitionerBio.get('undergraduateId');
            practitioner.Doctorate_Institution__pc = (String)practitionerBio.get('doctorateId') == '' ? null : (String)practitionerBio.get('doctorateId');

            practitioner.Internship__c = (String)practitionerBio.get('internship');
            practitioner.Residencies__c = (String)practitionerBio.get('residencies');
            practitioner.Fellowships__c = (String)practitionerBio.get('fellowships');
            practitioner.Certifications__c = (String)practitionerBio.get('certifications');
            practitioner.Awards__c = (String)practitionerBio.get('awards');
            practitioner.Professional_Societies__c = (String)practitionerBio.get('professionalSocieties');
            practitioner.Sport_Interests__c = (String)practitionerBio.get('sportsTeamsAffiliations');
            practitioner.Personal_Intrest__c = (String)practitionerBio.get('personalInterest');
            practitioner.Family_Information__c = (String)practitionerBio.get('spouseAndChildren');
            
            system.debug('##-- Practitioner: '+ Practitioner);
            update Practitioner;*/
    
        }
    
    }    


    public static Contact saveContact(Map<String,Object> contactMap) {
        
        Contact c = null;
        String id = (String)contactMap.get('id');
        system.debug('##--saveContact.id: '+ id);
        if ( id == null || id == '') {
            // new related contact

            c = new Contact();

        } else {

            c = [select FirstName,LastName,Email,Description, Phone,MobilePhone,MailingStreet, MailingState, MailingPostalCode, MailingCity, AccountId,Title from Contact where Id=:id];
            
        }
        
        c.FirstName = (String)contactMap.get('firstName');

        if ( contactMap.containsKey('lastName') ) {
            // only update if the map contains the key, last name is required
            c.LastName = (String)contactMap.get('lastName');
        }

        c.Email = (String)contactMap.get('email');
        c.Phone = (String)contactMap.get('phone');
        c.MobilePhone = (String)contactMap.get('mobile');
        c.MailingStreet = (String)contactMap.get('street');
        c.MailingCity = (String)contactMap.get('city');
        c.MailingCountry = (String)contactMap.get('country');
        c.MailingState = (String)contactMap.get('state');
        c.MailingPostalCode = (String)contactMap.get('zip');
        c.AccountId = (String)contactMap.get('accountId');
        c.Title = (String)contactMap.get('title');
        c.Description = (String)contactMap.get('notes');

        upsert c;
        
        return c;

    }   

    public static List<Account> retrieveProviders(Integer pageNum, Integer rowsPerPage) {

        // paging is not used, just here for a placeholder
        if ( pageNum == null ) { pageNum = 1; }
        if ( rowsPerPage == null ) { rowsPerPage = 20; }
        
        return CS_ARSearch.searchProvidersInMyTeamTerritory('');
        
        
    }    

    public static Account retrieveProvider(String providerId) {
        
        List<Id> availProviderIds = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
        //Fields added to query by Ansu
        list<Account> lstAccounts = [select Id,Name, Preferred_Name__c, BillingStreet, BillingPostalCode, BillingState, 
                    BillingCity, BillingCountryCode, BillingCountry, Website,Sterile_Processing_Location__c,Operating_Room_Location__c,Other_Attire_Notes__c,
            ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, ShippingCountryCode, ShippingCountry,
            Phone, Fax, Customer_Number__c,Credentialing_Company__c,Representative_Parking__c,Required_to_Change_Scrubs__c,
            Sign_In_Location__c,Business_Hours_Start__c,Business_Hours_End__c,Disposables__c,Sutures__c,Biologics__c,Equipment__c,Equipment_Notes__c,
            Sterile_Processing_Hours_Start__c,Sterile_Processing_Hours_End__c,Account_Fiscal_Year_Start_Day__c,Account_Fiscal_Year_Start_Month__c,
            Account_Fiscal_Year_End_Month__c,Account_Fiscal_Year_End_Day__c,BillingLatitude,BillingLongitude,ShippingLatitude,ShippingLongitude,AccountNumber from Account where Id=:providerId and Id in :availProviderIds];
        //Field addition ends    
        if(lstAccounts.size() == 0){
            
            return new Account();
            
        }
        Account acct = lstAccounts[0];

        if ( acct != null && acct.Preferred_Name__c == null ) {
            // use name if preferred name is not available
            acct.Preferred_Name__c = acct.Name;
        }

        return acct;
        
    }      

    public static List<Contact> retrieveProviderContacts(String providerId) {
        
        List<Id> availProviderIds = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
        List<Contact> contacts = [select Id, LastName, FirstName, Description, Title, Email, Phone, MobilePhone, MailingStreet,  MailingState, MailingCity,  MailingPostalCode from Contact  where AccountId=:providerId and AccountId in :availProviderIds order by LastName Asc];
        if ( contacts == null ) { contacts = new List<Contact>(); }

        return contacts;
        
    }   
    
    //Portal users can only delete contacts if they are owners
    //Below has been written so that portal users can delete
    //contacts on health care providers.
    public without sharing class deleteProviderContactc{
        
        public void deleteContacts(Contact contactTobeDeleted){
            
            delete contactTobeDeleted;
            
        }   //  end of deleteContacts
    }// end of deleteProviderContactc//
    //Swetha Penmethsa -Release 3.2 - delete contact
    //Portal users can only delete contacts if they are owners
    //Below has been written so that portal users can delete
    //contacts on health care providers.
    public without sharing class deleteProviderAccounts{
        
        public void deleteAccounts(Account accountTobeDeleted){
            
            delete accountTobeDeleted;
            
        }   //  end of deleteContacts
        //Swetha Penmethsa -Release 3.2 - delete contact
    }// end of deleteProviderContactc//
    
    
    public without sharing class deletePrefcardProcedures{
        
        public void c_deletePrefcardProcedures(list<Preference_Card_Procedures__c> lstPrefCardProcs){
            
            delete lstPrefCardProcs;
            
        }   //  end of c_deletePrefcardProcedures
    }// end of deletePrefcardProcedures//
    
    public static void deleteProviderContact(String contactId) {

        List<Id> availProviderIds = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
        list<Contact> lstContacts = [select Id from Contact  where Id=:contactId and AccountId in :availProviderIds order by LastName Asc];
        
        if(lstContacts.size() == 0){
            return;
        }
        Contact objcontact = lstContacts[0];
        
        deleteProviderContactc cls = new deleteProviderContactc();
        cls.deleteContacts(objcontact);
        //delete contact;

    }    
    //Swetha Penmethsa -Release 3.2 - delete contact
    public static void deleteRelatedContact(String contactId) {
        List<Surgeon_Related_Contacts__c> lstSRContacts = [select id from Surgeon_Related_Contacts__c where Surgeon_Contact__c =: contactId LIMIT 1];
        delete lstSRContacts;
        
        List<Id> availProviderIds = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
        list<Account> lstAccounts = [select Id from Account where Id=:contactId and id in :availProviderIds];
        
        if(lstAccounts.size() == 0){
            return;
        }
        Account objAccount = lstAccounts[0];
        
        deleteProviderAccounts cls = new deleteProviderAccounts();
        cls.deleteAccounts(objAccount);
        //delete contact;
        //Swetha Penmethsa -Release 3.2 - delete contact
    } 
    
    //Modified by Mimansha Samal for Component CID-000283 in Release 4.1 on 6/15/2017
    //Active Pref Cards will only be fetched to AXIS and Pref Cards to be sorted
    public static List<Practitioner_Procedure__c> retrievePractitionerPrefCards(String practitionerId) {

        List<Practitioner_Procedure__c> prefCards = [select Id,Pref_Card_Name__c,Procedure__c,
                                     Procedure__r.Name, Surgical_Technique__c,
                                     Surgical_Technique__r.Name
                                     from Practitioner_Procedure__c where Practitioner__c=:practitionerId
                                     AND Inactive__c =:false];
        if ( prefCards != null ) {
            prefCards.sort(); 
        }
                                  
        if ( prefCards == null ) { prefCards = new List<Practitioner_Procedure__c>(); }

        return prefCards;
    }
    
    //Modified by Mimansha Samal for Component CID-000283 in Release 4.1 on 6/21/2017
    //Active Pref Cards will only be fetched to AXIS
    public static List<Practitioner_Procedure__c> retrievePractitionerPrefCardsFromCal(String practitionerId, string caseId) {
        
        
       //Swetha Penmethsa
        List<Practitioner_Procedure__c> prefCards = new List<Practitioner_Procedure__c>();
        Map<Id, Practitioner_Procedure__c> prefCardsTemp = new Map<Id, Practitioner_Procedure__c>([select Id,Pref_Card_Name__c,Procedure__c,
                                                                 Procedure__r.Name, Surgical_Technique__c,
                                                                 Surgical_Technique__r.Name
                                                                 from Practitioner_Procedure__c where Practitioner__c=:practitionerId AND Inactive__c =:false order by Pref_Card_Name__c ASC]);
        List<Case_Pref_Card__c> lstCasePRefCard = [SELECT id, Practitioner_Procedure__c 
                                        FROM Case_Pref_Card__c 
                                        WHERE Case__c =: caseId
                                        AND Practitioner_Procedure__c =: prefCardsTemp.keyset()];
        
        set<Id> sDonotIncludePRef = new set<Id>();
        for(Case_Pref_Card__c cpc: lstCasePRefCard){
            sDonotIncludePRef.add(cpc.Practitioner_Procedure__c);
        }
        
        List<Practitioner_Procedure__c> prefCardsSort = prefCardsTemp.values();
        prefCardsSort.sort();
        for(Practitioner_Procedure__c pp: prefCardsSort){
            if(!sDonotIncludePRef.contains(pp.id)){
                prefCards.add(pp);
            }
        }
        //Swetha P 
                                                                
        if ( prefCards == null ) { prefCards = new List<Practitioner_Procedure__c>(); }

        return prefCards;
    }

    public static CS_PreferenceCardWrapper retrievePractitionerPrefCard(String cardId) {
        
        /*list<Practitioner_Procedure__c> lstPractitionerProcedures = new list<Practitioner_Procedure__c> ();
        lstPractitionerProcedures = [select Id,Pref_Card_Name__c, Procedure__r.Name, Surgical_Technique__c,Practitioner__c,
                        Surgical_Technique__r.Name, Surgical_Technique__r.Id, Disposables__c, Equipment__c, 
                        Equipment_Notes__c, Medications__c,Position__c, Sutures__c 
                        from Practitioner_Procedure__c where Id=:cardId ];
        if(lstPractitionerProcedures.size() > 0){
            return lstPractitionerProcedures[0];
        }else{
            return new Practitioner_Procedure__c();
        }*/
        
        return buildCS_AROpportunityWrapper(cardId);
    }    

    public static List<Practitioner_Procedure_Products__c> retrievePractitionerPrefCardProducts(String cardId) {
        return [select Product__r.Id, Product__r.Name, Product__r.Material_Number__c, Quantity__c, UnitPrice__c, TotalPrice__c, Product__r.Material_Group_Number__c, Product__r.Material_Group_Type__c from Practitioner_Procedure_Products__c where Practitioner_Procedure__c=:cardId ];
    }    

    public static List<String> retrievePractitionerTasks(String practitionerId) {        

        Id currentUserId = UserInfo.getUserId();

        // test data for demo
        String axisActivity = '';
        String marketingInteractions = '';
        String medicalTrainingActivity = '';
        String arthrexEvents = '';

        List<String> taskStrings = new List<String>();
        taskStrings.add(axisActivity);
        taskStrings.add(marketingInteractions);
        taskStrings.add(medicalTrainingActivity);
        taskStrings.add(arthrexEvents);

        return taskStrings;
        
    }

    public static void saveNewSurgeonRequest(String npi, String firstName, String lastName) {

        // creates the queue if it doesn't alread exist
        List<Group> groupList = [Select Id, Name FROM Group WHERE Name = 'New Surgeons' AND Type = 'Queue'];
        Id surgeonGroupId;
        if( groupList.isEmpty() ) {
            Group newSurgeonsGroup = new Group(Name='New Surgeons', type='Queue');
            insert newSurgeonsGroup;
            
            surgeonGroupId = newSurgeonsGroup.Id;
            QueuesObject q1 = new QueueSObject( QueueID = surgeonGroupId, SobjectType = 'Case' );
            insert q1;
        
        } else {
            surgeonGroupId = groupList[0].Id;
        
        }
        
        // create the case
        if(npi != '' && firstName != '' && lastName !='') {
            Case createNewSurgeon = new Case();
            createNewSurgeon.OwnerId = surgeonGroupId;
            createNewSurgeon.Subject = 'New Surgeon Request ('+npi+') '+lastName +', '+firstName;
            createNewSurgeon.Status = 'New';
            createNewSurgeon.Origin = 'Web';
            createNewSurgeon.Description = 'FirstName: '+ firstName 
                                        + '\n LastName: '+ lastName
                                        + '\n NPI: '+ npi;
            insert createNewSurgeon;
            
        system.debug('#--saveNewSurgeonRequest.createNewSurgeon: '+ createNewSurgeon);

        }
        
    
    }
    
    /* Modified By- Mimansha Samal
       Date Modified:- 6/20/2017
       Release- 4.1
       Component ID - CID-000283
       Purpose:- Do not hard delete the Pref Cards. Only the Inactive field is set to true
    */
    // deletes a practioner procedure and any associate products
    public static void deletePractitionerProcedure(String id) {
        Practitioner_Procedure__c pp = [select Id,Pref_Card_Name__c,Disposables__c, Equipment__c, Equipment_Notes__c, Medications__c,Position__c, Sutures__c,Procedure__r.Name  from Practitioner_Procedure__c where Id=:id];
        /*if ( pp != null ) {
            List<Practitioner_Procedure_Products__c> productList = [select Id from Practitioner_Procedure_Products__c where Practitioner_Procedure_Products__c.Practitioner_Procedure__c=:pp.Id];
            delete productList;

            delete pp;

        }*/
        
        if ( pp != null ) {
            pp.Inactive__c = true;
            update pp;
        }
    }

    // retrieves a list of products pre-associated to a procedure
    public static List<ProcedureProduct__c> retrieveProductsByProcedure(String procedureId) {
        
        List<ProcedureProduct__c> procProds = [select Product__r.Id, Product__r.Name from ProcedureProduct__c where Procedure__c=:procedureId];
        if ( procProds == null ) { procProds = new List<ProcedureProduct__c>(); }
        return procProds;
    }

    // tests to see if the preference card name is unique for this practitioner
    public static boolean isUniquePractitionerProcedureName(String practId, String name) {
        List<Practitioner_Procedure__c> prefCards = [select Id from Practitioner_Procedure__c where Pref_Card_Name__c=:name AND Practitioner__c=:practId];        
        return (prefCards == null || prefCards.size() == 0 );
    }

    // saves or updates a Practioner_Procedure__c object and syncs associated Practioner_Procedure_Products__c records
    public static CS_PreferenceCardWrapper csavePractitionerProcedure(String id, 
                                                                    String name, 
                                                                    String practitionerId,
                                                                    list<string> lstProcedureIds,   
                                                                    list<string> lstSurgicalTechniqueIds, 
                                                                    String disposables,
                                                                    String equipment,
                                                                    String equipmentNotes, 
                                                                    String medications,
                                                                    String sutures, 
                                                                    String position, 
                                                                    List<String> productIdList) { 
        Set<String> productIds = new Set<String>(productIdList);
        list<Practitioner_Procedure_Products__c> lstPractProcedureProducts = new list<Practitioner_Procedure_Products__c>();
        list<Preference_Card_Procedures__c> lstPrefCardProcedures = new list<Preference_Card_Procedures__c>();
        list<Preference_Card_Procedures__c> lstExistingPrefCardProc = new list<Preference_Card_Procedures__c>();

        Practitioner_Procedure__c pp = null;
        if ( id != null ) {
            pp = [select Id,Pref_Card_Name__c,Disposables__c, Surgical_Technique__c, Equipment__c, Equipment_Notes__c, Medications__c,Position__c, Sutures__c,Procedure__r.Name  from Practitioner_Procedure__c where Id=:id];
            lstExistingPrefCardProc = [SELECT Id,Taxonomy__c FROM Preference_Card_Procedures__c WHERE Preference_Card__c = :Id];
        } else {
            pp = new Practitioner_Procedure__c();
            pp.Practitioner__c = practitionerId; 
        }
        
        
        
        pp.Pref_Card_Name__c = name;
        pp.Disposables__c = disposables;
        pp.Equipment__c = equipment;
        pp.Equipment_Notes__c = equipmentNotes;
        pp.Medications__c = medications;
        pp.Position__c = position;
        pp.Sutures__c = sutures;

        if ( id != null ) {
            update pp;
        } else {
            insert pp;
        }
        
        if(lstExistingPrefCardProc.size() > 0){ 
            
             deletePrefcardProcedures d_deletePrefcardProcedures = new deletePrefcardProcedures();
             d_deletePrefcardProcedures.c_deletePrefcardProcedures(lstExistingPrefCardProc);
            //delete lstExistingPrefCardProc;
        }
        
        for(string objString : lstProcedureIds){
            
            string[] lstTaxononmy = objString.split('::');
            string procedureId = lstTaxononmy[1];
            Id ProductTeamId = lstTaxononmy[0];
            string procedureName = lstTaxononmy[2];
            system.debug('##--csavePractitionerProcedure.procedureId: '+ procedureId);
            Preference_Card_Procedures__c objPrefCardProcs = new Preference_Card_Procedures__c();
            if(procedureId.endsWithIgnoreCase('newId')){
                
                Procedure__c objProc = new Procedure__c(Procedure_Name__c = procedureName, 
                                                        Name = procedureName,  
                                                        TaxonGroupId__c = 'Procedure', 
                                                        Type__c = 'Other');
                
                insert objProc;
                
                procedureId = objProc.Id;
            }
            
            objPrefCardProcs.Product_Team__c = ProductTeamId;
            objPrefCardProcs.Taxonomy__c = procedureId;
            objPrefCardProcs.Preference_Card__c = pp.Id;
            lstPrefCardProcedures.add(objPrefCardProcs);
            
        }// end of for-each lstProcedureIds
        
        if(lstSurgicalTechniqueIds != null 
            && lstSurgicalTechniqueIds.size() > 0){
        
            for(string objString : lstSurgicalTechniqueIds){
                
                string[] lstTaxononmy = objString.split('::');
                Id surgicalTechniqueId = lstTaxononmy[1];
                Id ProductTeamId = lstTaxononmy[0];
                string procedureName = lstTaxononmy[2];
                
                Preference_Card_Procedures__c objPrefCardSurgTechs = new Preference_Card_Procedures__c();
                objPrefCardSurgTechs.Product_Team__c = ProductTeamId;
                objPrefCardSurgTechs.Taxonomy__c = surgicalTechniqueId;
                objPrefCardSurgTechs.Preference_Card__c = pp.Id;
                lstPrefCardProcedures.add(objPrefCardSurgTechs);
                
            }// end of for-each lstSurgicalTechniqueIds
        }
        
        system.debug('##--csavePractitionerProcedure.lstPrefCardProcedures' + lstPrefCardProcedures);
        if(lstPrefCardProcedures.size() > 0){
            
            insert lstPrefCardProcedures;
        }

        // products mapped to this practioner procedure
        Set<Practitioner_Procedure_Products__c> productList = new Set<Practitioner_Procedure_Products__c>([select Id,Product__c from Practitioner_Procedure_Products__c where Practitioner_Procedure_Products__c.Practitioner_Procedure__c=:pp.Id]);
        list<Practitioner_Procedure_Products__c> lstPractitionerProcedureProducts = new list<Practitioner_Procedure_Products__c>();
        if ( productList == null ) { 
            productList = new Set<Practitioner_Procedure_Products__c>(); 
        }
        
        // Step 1-2 remove all existing products, will replace them with what is coming in
        for ( Practitioner_Procedure_Products__c existingProduct : productList ) {
            //delete existingProduct;
            lstPractitionerProcedureProducts.add(existingProduct);
        }
        
        if(lstPractitionerProcedureProducts.size() > 0){
            deletePractitionerProcProds d_deletePractitionerProcProds = new deletePractitionerProcProds();
            d_deletePractitionerProcProds.c_deletePractitionerProcProds(lstPractitionerProcedureProducts);
        }
        
        // Step 2-2. add products in productIds 
        for ( String productId : productIds ) {
            
            // new product to add
            Practitioner_Procedure_Products__c ppProduct = new Practitioner_Procedure_Products__c();
            ppProduct.Product__c = productId;
            ppProduct.Practitioner_Procedure__c = pp.Id;
            lstPractProcedureProducts.add(ppProduct);
           // insert ppProduct;
            
        }
        
        if(lstPractProcedureProducts.size() > 0){
            insert lstPractProcedureProducts;
        }
        
        return buildCS_AROpportunityWrapper(pp.Id);
        //return [select Id,Pref_Card_Name__c,Disposables__c, Equipment__c, Equipment_Notes__c, Medications__c,Position__c, Sutures__c,Procedure__r.Name  from Practitioner_Procedure__c where Id=:pp.Id];

    }    
    
    public without sharing class deletePractitionerProcProds{
        
        public void c_deletePractitionerProcProds(list<Practitioner_Procedure_Products__c> lstPractitionerProcedureProds){
            
            delete lstPractitionerProcedureProds;
            
        }// end of c_deletePractitionerProcProds
        
    }// end of deletePractitionerProcProds

    // gecodes an address and upates the account via Google MAPS API aynchronosouly
    @future(callout=true)
    public static void geocodeAsync(String id, String street, String state, String city, String postalCode, String country ) {
        
        System.debug('Geocoding using a Google MAPS key belonging to chad.armstrong@cloudsherpas.com');
        String key = 'AIzaSyBV1fTgLwFGMx3zNAU4UvcV8EEGJp0JANY';

        // create an address string
        String address = '';
        if (street != null)
            address += street +', ';
        if (city != null)
            address += city +', ';
        if (state != null)
            address += state +' ';
        if (postalCode != null)
            address += postalCode +', ';
        if (country != null)
            address += country;
 
        address = EncodingUtil.urlEncode(address, 'UTF-8');
        key = EncodingUtil.urlEncode(key, 'UTF-8');
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&key='+key);
        req.setMethod('GET');
        req.setTimeout(60000);
 
        try {
            // callout
            HttpResponse res = h.send(req);
            System.debug(res.getBody());
            
            JSONParser parser = JSON.createParser(res.getBody());
            double lat = 0.0;
            double lon = 0.0;

            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'location')){
                       parser.nextToken(); // object start
                       while (parser.nextToken() != JSONToken.END_OBJECT){
                           String txt = parser.getText();
                           parser.nextToken();
                           if (txt == 'lat')
                               lat = parser.getDoubleValue();
                           else if (txt == 'lng')
                               lon = parser.getDoubleValue();
                       }
 
                }
            }
            
            if ( lat != 0.0 && lon != 0.0 ) {
                Account a = [select Geolocation__c from Account where Id=:id];
                a.Geolocation__Latitude__s = lat;
                a.Geolocation__Longitude__s = lon;
                update a;
            }
        } catch (Exception e) {
            system.debug(e);
        }     
                 
    }

    public static List<selectOption> getPickValues(Sobject object_name, String field_name, String first_val) {
          
          List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
          if (first_val != null) { //if there is a first value being provided
             options.add(new selectOption(first_val, first_val, false)); //add the first option
          }
          Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
          Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
          Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
          if(field_map != null && field_map.containsKey(field_name)){
              List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
              for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                          
                    options.add(new selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
              }
          }
          return options; //return the List
    }
    
    //Code added by AR for updating surgeon profile picture
    public static void updateProfilePicture(Map<String,Object> profile,Id practitionerId ) {
            
        String encodedFileContents = (String)profile.get('encodedFileContents');

        String fileMimeType = encodedFileContents.substring(5, encodedFileCOntents.indexOf(';') );
        Blob fileContents = EncodingUtil.base64Decode(encodedFileContents.substring( (encodedFileContents.indexOf(',')+1) ));
        String fileName = (String)profile.get('fileName');

        ConnectApi.BinaryInput uploadedImage = new ConnectApi.BinaryInput( fileContents, fileMimeType, fileName);
        System.debug('practitionerId --'+practitionerId );
        //Id ConId=[Select PersonContactId from Account where Id=:practitionerId limit 1].PersonContactId ;
        //System.debug('ConId--'+ConId);
        //Id UserId=[Select Id from User where ContactId=:ConId limit 1].Id;
        //System.debug('UserId--'+UserId);
        //ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), UserId , uploadedImage);        
        
    }

    //end of code by AR
    
    //Release 2.2
    //Component ID:- CID000064
    //Developer:- Mimansha Samal
    //Date:- 12/6/2016
    //Purpose:- Retrieving Assigned Territories that the practitioner is assigned to.
    public static List<String> retrieveTerritoryForPractitioner(String accountId) {
        
         List<String> territoryNames = new List<String>();
         List<ObjectTerritory2Association> assocs= [SELECT ObjectId, Territory2Id, Territory2.Name, Territory2.ParentTerritory2Id FROM ObjectTerritory2Association where ObjectId=:accountId];
         
         for ( ObjectTerritory2Association t : assocs) {
            territoryNames.add(t.Territory2.Name);
         }            
         
         return territoryNames;
    }
    
    //Release 2.2
    //Component ID:- CID000064
    //Developer:- Mimansha Samal
    //Date:- 12/6/2016
    //Purpose:- Retrieving Account Affiliations that the practitioner is associated to.
    
    public static List<CS_AccountAffiliationWrapper> retrieveAccountAffiliationsByPractitioner(String practitionerId) {
       /* system.debug('##-- retrieveAccountAffiliationsByPractitioner.PractitionerId--'+ practitionerId);
        List<Affiliation__c> lstAffiliations = [SELECT Id, Name, Account_hcp__r.Name, Account_hcp__r.Preferred_Name__c, Account_hcp__r.Customer_Number__c, Account_hcp__r.Phone, Account_hcp__r.PersonEmail, Account_hcp__r.Id, Account_hcp__r.AccountNumber FROM Affiliation__c where Account_p__c =:practitionerId ORDER BY Name desc];
        
        if ( lstAffiliations == null || lstAffiliations.size() == 0 ) { 
            lstAffiliations = new List<Affiliation__c>(); 
        } 
        system.debug('##--retrieveAccountAffiliationsByPractitioner.Affiliation--'+ lstAffiliations);
        return lstAffiliations;*/
        
        cls_RetrieveAccountAffiliationsByPractitioner cls = new cls_RetrieveAccountAffiliationsByPractitioner();
        Set<Id> foundHCO = CS_ARSearch.searchHCOInMyTeamTerritory();
        
        List<CS_AccountAffiliationWrapper> lstAccAffiliation = new List<CS_AccountAffiliationWrapper>();
        CS_AccountAffiliationWrapper objAccAffiliation;
        string strNickName = '';
        for(Affiliation__c Aff: cls.c_retrieveAccountAffiliationsByPractitioner(practitionerId)){
            strNickName = Aff.Account_hcp__r.Name;
            if(Aff.Account_hcp__r.Preferred_Name__c != null &&  Aff.Account_hcp__r.Preferred_Name__c != ''){
                strNickName = Aff.Account_hcp__r.Preferred_Name__c;
            }
            if(foundHCO.contains(Aff.Account_hcp__c)){
                objAccAffiliation = new CS_AccountAffiliationWrapper(Aff, true, strNickName);            
                lstAccAffiliation.add(objAccAffiliation);
            }else{
                objAccAffiliation = new CS_AccountAffiliationWrapper(Aff, false, strNickName);            
                lstAccAffiliation.add(objAccAffiliation);
            }
        }
        return lstAccAffiliation;         
    }
    
    public class CS_AccountAffiliationWrapper{
        public Affiliation__c objAff {get; set;}
        public boolean editable {get; set;}
        public String strNickName {get; set;}
        public CS_AccountAffiliationWrapper(Affiliation__c p_objAff, boolean p_editable, string p_strNickName){
            objAff= p_objAff;
            editable = p_editable;
            strNickName = p_strNickName;
        }
    }
    //Release 2.2
    //Component ID:- CID000064
    //Developer:- Mimansha Samal
    //Date:- 12/9/2016
    //Purpose:- Delete Account Affiliation for the practitioner
    public static void deleteAccountAffiliation(String affiliationId) {
        
        /*System.debug('Affiliation ID------'+ affiliationId);
        list<Affiliation__c> lstAffiliations = [select Id, Name from Affiliation__c where Id=:affiliationId];
        
        if(lstAffiliations.size() == 0){
            return;
        }
        Affiliation__c objAffiliation = lstAffiliations[0];
        System.debug('Affiliation Name to be deleted------'+ objAffiliation.Name);
        
        delete objAffiliation;*/
        
        Affiliation__c objAffiliation = new Affiliation__c(Id = affiliationId);
        
        deleteAccountAffiliation clsDeleteAccountAffiliation =new deleteAccountAffiliation();
        clsDeleteAccountAffiliation.c_deleteAccountAffiliation(objAffiliation);

    }
    
    public without sharing class deleteAccountAffiliation{
        
        public void c_deleteAccountAffiliation(Affiliation__c objAffiliation){
            
            delete objAffiliation;
            
        }// end of deleteAccountAffiliation
        
    }// end of deleteAccountAffiliation
    
    //Release 2.2
    //Component ID:- CID000064
    //Developer:- Mimansha Samal
    //Date:- 12/19/2016
    //Purpose:- Save Account Affiliations for the practitioner
    public static void cSaveAccountAffiliation(String practitionerId,
                                                    list<Id> lstAccountIds){
        
        list<Affiliation__c> lstAccountAffiliation = new list<Affiliation__c>();
        for(Id accountId :lstAccountIds){
            Affiliation__c objAccountAffliation = new Affiliation__c(Account_p__c = practitionerId,
                                                                                Account_hcp__c = accountId);
            lstAccountAffiliation.add(objAccountAffliation);
        }
        
        insert lstAccountAffiliation;
       
    }// end of cSaveAccountAffiliation
    
    
    
    public static List<ObjectTerritory2Association> retrieveTerritoryForPractitioners(String accountId) {
    
        List<String> names = new List<String>();
        List<Affiliation__c > lstAffiliation =[SELECT Id, Name, Account_p__r.Phone, Account_p__r.Id FROM Affiliation__c where Account_hcp__r.Id=:accountId ORDER BY Name desc];
        Set<Id> practitionerIdSet = new Set<Id>();
        for(Affiliation__c  af:lstAffiliation  )
        {
            practitionerIdSet.add(af.Account_p__r.Id);          
        }
        System.debug('practitionerIdSet --'+ practitionerIdSet );
        List<ObjectTerritory2Association> assocs= [SELECT ObjectId, Territory2Id, Territory2.Name, Territory2.ParentTerritory2Id FROM ObjectTerritory2Association where ObjectId in: practitionerIdSet ];
         
        for ( ObjectTerritory2Association t : assocs) {
            names.add(t.Territory2.Name);
        }            
        System.debug('assocs--'+ assocs);

        return assocs;
    } 
    
    
    // Delete Surgeon Affiliation for the account
    public static void deleteSurgeonAffiliation(String affiliationId) {
       
        Affiliation__c objAffiliation = new Affiliation__c(Id = affiliationId);
        
        deleteSurgeonAffiliation clsDeleteSurgeonAffiliation =new deleteSurgeonAffiliation();
        clsDeleteSurgeonAffiliation.c_deleteSurgeonAffiliation(objAffiliation);

    }
    
    public without sharing class deleteSurgeonAffiliation{
        
        public void c_deleteSurgeonAffiliation(Affiliation__c objAffiliation){
            
            delete objAffiliation;
            
        }// end of deleteSurgeonAffiliation
        
    }// end of deleteSurgeonAffiliation
    
    public static void cSaveSurgeonsAffiliation(string accountId,
                                                    list<Id> lstSurgeonIds){
        
        list<Affiliation__c> lstSurgeonAffiliation = new list<Affiliation__c>();
        for(Id surgeonId :lstSurgeonIds){
            Affiliation__c objSurgeonAffltn = new Affiliation__c(Account_hcp__c= accountId,
                                                                                Account_p__c= surgeonId);
            lstSurgeonAffiliation.add(objSurgeonAffltn);
        }
        
        insert lstSurgeonAffiliation ;
       
    }// end of cSaveOpportunitySurgeon 
    
    //Code added by Ansu ends
     
    public class CS_PreferenceCardWrapper{
        
        public Practitioner_Procedure__c objPrefCard {get;set;}
        public list<CS_PreferenceCardProceduresWrapper> lstPrefCardProcs {get;set;} 
        
        public CS_PreferenceCardWrapper(){} //  default constructor
        public CS_PreferenceCardWrapper(Practitioner_Procedure__c p_objPrefCard){
            objPrefCard = p_objPrefCard;
            lstPrefCardProcs = new list<CS_PreferenceCardProceduresWrapper>();
        }
        public CS_PreferenceCardWrapper(Practitioner_Procedure__c p_objPrefCard, 
                                        list<CS_PreferenceCardProceduresWrapper> p_lstPrefCardProcs){
            
            objPrefCard = p_objPrefCard;
            lstPrefCardProcs = p_lstPrefCardProcs; 
            
        }
    }// end of CS_OpportunityActivityWrapper
    
    public class CS_PreferenceCardProceduresWrapper{
        
        string productId {get;set;}
        string productName {get;set;}
        map<string, string> mapProcedures {get;set;}
        map<string, string> mapSurgicalTechniques {get;set;}
        
        public CS_PreferenceCardProceduresWrapper(){}   //  default constructor
        
        public CS_PreferenceCardProceduresWrapper(string p_productId, string p_productName){
            
            productId = p_productId;
            productName = p_productName;
            mapProcedures = new Map<String, String>();
            mapSurgicalTechniques = new Map<String, String>();
            
        }
        
    }// end of CS_PreferenceCardProceduresWrapper
    
    public static CS_PreferenceCardWrapper buildCS_AROpportunityWrapper(Id preferenceCardId) {
        
        CS_PreferenceCardWrapper prefCardWrapper = new CS_PreferenceCardWrapper();
        CS_PreferenceCardProceduresWrapper prodWrapper=null;
        String productName='';
        system.debug('##--buildCS_AROpportunityWrapper.preferenceCardId: '+ preferenceCardId);
        if(preferenceCardId == null){
            return prefCardWrapper;
        }
        Practitioner_Procedure__c wrapperPrefCard = [SELECT Id,Pref_Card_Name__c,Procedure__c, 
                                                             Procedure__r.Name, Surgical_Technique__c,Practitioner__c,Practitioner__r.Name,
                                                            Surgical_Technique__r.Name, Surgical_Technique__r.Id, Disposables__c, Equipment__c, 
                                                            Equipment_Notes__c, Medications__c,Position__c, Sutures__c, CreatedBy.Name, CreatedDate, LastModifiedBy.Name, LastModifiedDate,
                                                                (SELECT Id, Preference_Card__c, Product_Team__c, 
                                                                    Product_Team__r.Name, Taxonomy__c, Taxonomy__r.Name, Taxonomy__r.TaxonGroupId__c
                                                                    FROM Preference_Card_Procedures__r ORDER BY Product_Team__c) 
                                                                 FROM Practitioner_Procedure__c WHERE Id=:preferenceCardId  ];
                                                                 
        prefCardWrapper = new CS_PreferenceCardWrapper(wrapperPrefCard);
        
        for(Preference_Card_Procedures__c obj :wrapperPrefCard.Preference_Card_Procedures__r){
            if(String.isBlank(productName) || ! productName.equalsIgnoreCase(obj.Product_Team__r.Name)){
                productName = obj.Product_Team__r.Name;
                
                if(prodWrapper != null){
                    prefCardWrapper.lstPrefCardProcs.add(prodWrapper); 
                }
                prodWrapper = new CS_PreferenceCardProceduresWrapper(obj.Product_Team__c, obj.Product_Team__r.Name);
            }   //  end of outer IF
            
            if('Procedure'.equalsIgnoreCase(obj.Taxonomy__r.TaxonGroupId__c)  || 'product_category'.equalsIgnoreCase(obj.Taxonomy__r.TaxonGroupId__c)){
                prodWrapper.mapProcedures.put(obj.Taxonomy__c, obj.Taxonomy__r.Name);
            } else{
                
                prodWrapper.mapSurgicalTechniques.put(obj.Taxonomy__c, obj.Taxonomy__r.Name);
            }
            
        }   //  end of for-each
        
            //  Add the last one if the name is not empty
        if(String.isNotBlank(productName)){
            prefCardWrapper.lstPrefCardProcs.add(prodWrapper);
        }
                                                                 
        //CS_PreferenceCardWrapper objWrapper = new CS_PreferenceCardWrapper(wrapperPrefCard);
        
        return prefCardWrapper;
    
    }
    
    public static List<CS_PreferenceCardWrapper> buildCS_AROpportunityWrapperListByObjectId(List<String> ids, String objectName) {

        List<CS_PreferenceCardWrapper> returnList = new List<CS_PreferenceCardWrapper>();
        
        List<Practitioner_Procedure__c> wrapperPrefCards = null;

        if ( objectName == 'Practitioner_Procedure__c' ) {

            wrapperPrefCards = [SELECT Id,Pref_Card_Name__c,Procedure__c, 
                                                             Procedure__r.Name, Surgical_Technique__c,Practitioner__c,
                                                            Surgical_Technique__r.Name, Surgical_Technique__r.Id, Disposables__c, Equipment__c, 
                                                            Equipment_Notes__c, Medications__c,Position__c, Sutures__c ,
                                                                (SELECT Id, Preference_Card__c, Product_Team__c, 
                                                                    Product_Team__r.Name, Taxonomy__c, Taxonomy__r.Name, Taxonomy__r.TaxonGroupId__c
                                                                    FROM Preference_Card_Procedures__r ORDER BY Product_Team__c) 
                                                                 FROM Practitioner_Procedure__c WHERE Id in :ids  ];
        } else if ( objectName == 'Practitioner__c' ) {

            wrapperPrefCards = [SELECT Id,Pref_Card_Name__c,Procedure__c, 
                                                             Procedure__r.Name, Surgical_Technique__c,Practitioner__c,
                                                            Surgical_Technique__r.Name, Surgical_Technique__r.Id, Disposables__c, Equipment__c, 
                                                            Equipment_Notes__c, Medications__c,Position__c, Sutures__c ,
                                                                (SELECT Id, Preference_Card__c, Product_Team__c, 
                                                                    Product_Team__r.Name, Taxonomy__c, Taxonomy__r.Name, Taxonomy__r.TaxonGroupId__c
                                                                    FROM Preference_Card_Procedures__r ORDER BY Product_Team__c) 
                                                                 FROM Practitioner_Procedure__c WHERE Practitioner__c in :ids  ];

        }   

        if ( wrapperPrefCards == null ) { wrapperPrefCards = new List<Practitioner_Procedure__c>(); }

        for(Practitioner_Procedure__c wrapperPrefCard : wrapperPrefCards ) {

            CS_PreferenceCardProceduresWrapper prodWrapper = null;
            String productName='';

        
            CS_PreferenceCardWrapper prefCardWrapper = new CS_PreferenceCardWrapper(wrapperPrefCard);
            
            for(Preference_Card_Procedures__c obj :wrapperPrefCard.Preference_Card_Procedures__r){
                if(String.isBlank(productName) || ! productName.equalsIgnoreCase(obj.Product_Team__r.Name)){
                    productName = obj.Product_Team__r.Name;
                    
                    if(prodWrapper != null){
                        prefCardWrapper.lstPrefCardProcs.add(prodWrapper); 
                    }
                    prodWrapper = new CS_PreferenceCardProceduresWrapper(obj.Product_Team__c, obj.Product_Team__r.Name);
                }   //  end of outer IF
                
                if('Procedure'.equalsIgnoreCase(obj.Taxonomy__r.TaxonGroupId__c)  || 'product_category'.equalsIgnoreCase(obj.Taxonomy__r.TaxonGroupId__c)){
                    prodWrapper.mapProcedures.put(obj.Taxonomy__c, obj.Taxonomy__r.Name);
                } else{
                    
                    prodWrapper.mapSurgicalTechniques.put(obj.Taxonomy__c, obj.Taxonomy__r.Name);
                }
                
            }   //  end of for-each
            
                //  Add the last one if the name is not empty
            if(String.isNotBlank(productName)){
                prefCardWrapper.lstPrefCardProcs.add(prodWrapper);
            }
            


            returnList.add(prefCardWrapper);
        }

        return returnList;
    
    } 
     
    public static list<Procedure__c> c_getAllRelatedProcedures(String productTeam) {
        
        list<Procedure__c> lstProcedures = new list<Procedure__c>();
        set<Id> setShoulderProceduresForOsteoarthritis = getAllShoulderProceduresForOsteoarthritis();
        set<Id> setKneeProceduresForArthritis = getAllKneeProceduresForArthritis();
        
        system.debug('##--setShoulderProceduresForOsteoarthritis: '+ setShoulderProceduresForOsteoarthritis);
        system.debug('##--setKneeProceduresForArthritis: '+ setKneeProceduresForArthritis);
        if(productTeam == 'Arthroplasty'){
            
            return [SELECT Id, Name, Product_Category__c FROM Procedure__c WHERE Id IN :setShoulderProceduresForOsteoarthritis OR Id IN: setKneeProceduresForArthritis];
        }
        
        if(productTeam == 'Orthobiologics'
            || productTeam == 'Imaging & Resection'){
                
                return [SELECT Id, Name, Product_Category__c 
                                                        FROM Procedure__c 
                                                        WHERE TaxonGroupId__c = 'product_category' 
                                                        AND Product_Category__c = :productTeam
                                                        ORDER BY Name];
            
        }
        for(Procedure__c objProcedure : [SELECT Id, Name, Product_Category__c 
                                                        FROM Procedure__c 
                                                        WHERE TaxonGroupId__c = 'procedure'   
                                                        AND Product_Category__c = :productTeam
                                                        ORDER BY Name]){
            
            if(productTeam == 'Shoulder'
                && setShoulderProceduresForOsteoarthritis.contains(objProcedure.Id)){
                continue;       
            }
            if(productTeam == 'Knee'
                && setKneeProceduresForArthritis.contains(objProcedure.Id)){
                continue;       
            } 
            lstProcedures.add(objProcedure);
        }    
        return lstProcedures;
        
    }   //  end of getAllRelatedProcedures
     
    public static list<Procedure__c> c_getAllRelatedSurgicalTechniques(String productTeam) {
        
        return [SELECT Id, Name, Product_Category__c 
                                    FROM Procedure__c 
                                    WHERE TaxonGroupId__c = 'surgical_Technique' 
                                    AND Product_Category__c = :productTeam
                                    ORDER BY Name]; 
        
    }   //  end of getAllRelatedSurgicalTechniques
    
     
    public static list<Procedure__c> c_getAllProductTeams() {
        
        List<Procedure__c> lstOrigProds = new List<Procedure__c>();
        lstOrigProds = [SELECT Id, Name, Product_Category__c 
                                    FROM Procedure__c 
                                    WHERE TaxonGroupId__c = 'team'
                                    ORDER BY Name];
        
        return reOrderProductTeams(lstOrigProds);
        
    }   //  end of getAllProductTeams
    
    
    private static List<Procedure__c> reOrderProductTeams(List<Procedure__c> lstOrigProds){
        List<String> lstOrderList = new List<String> {'Shoulder', 'Elbow', 'Knee', 'Hip', 'Foot/Ankle', 'Hand/Wrist', 'Orthobiologics', 'Imaging/Resection', 'Arthroplasty'};
        List<Procedure__c> lstReorderedProds = new List<Procedure__c>();
        
        for(String prod : lstOrderList){
            String prodName='';
            
            for(Procedure__c objProd : lstOrigProds){
                prodName = objProd.Name;
                if(prodName.containsIgnoreCase('&') || prodName.containsIgnoreCase('&amp;')){
                    prodName = prodName.replaceAll('\\s(&||&amp;)\\s', '/');
                }
                
                
                if(prod.equalsIgnoreCase(prodName)){
                    lstReorderedProds.add(objProd);
                }
                
            }   //  end of for-each given Product
            
        }   //  end of for-each ordered Prod Name
        
        return lstReorderedProds;
    }   //  end of reOrderProductTeams
    
    private static set<Id> getAllShoulderProceduresForOsteoarthritis(){
        
        set<Id> setShoulderProceduresForOsteoarthritis = new set<Id>();
        for(Procedure_Relationships__c objProcRel : [SELECT Id, Child_Procedure__c FROM Procedure_Relationships__c
                                                            WHERE Parent_Procedure__r.Name = 'Osteoarthritis'
                                                            AND Parent_Procedure__r.Product_Category__c = 'Shoulder'
                                                            AND Parent_Procedure__r.TaxonGroupId__c = 'Diagnosis']){
                                                                
            setShoulderProceduresForOsteoarthritis.add(objProcRel.Child_Procedure__c);                                                  
        }// end of for-each
        system.debug('##--getAllShoulderProceduresForOsteoarthritis.setShoulderProceduresForOsteoarthritis: '+ setShoulderProceduresForOsteoarthritis);
        return setShoulderProceduresForOsteoarthritis;
    }//getAllShoulderProcedures
    
    private static set<Id> getAllKneeProceduresForArthritis(){
            
        set<Id> setKneeProceduresForArthritis = new set<Id>();
        for(Procedure_Relationships__c objProcRel : [SELECT Id, Child_Procedure__c FROM Procedure_Relationships__c
                                                            WHERE Parent_Procedure__r.Name = 'Arthritis'
                                                            AND Parent_Procedure__r.Product_Category__c = 'Knee'
                                                            AND Parent_Procedure__r.TaxonGroupId__c = 'Diagnosis']){
                                                                
            setKneeProceduresForArthritis.add(objProcRel.Child_Procedure__c);                                                   
        }// end of for-each
        
        system.debug('##--getAllKneeProceduresForArthritis.setKneeProceduresForArthritis: '+ setKneeProceduresForArthritis);
        return setKneeProceduresForArthritis;
    }//getAllKneeProceduresForArthritis
    
    public static Procedure__c c_CheckIfProcedureAlreadyExists(string procedureName){
        
        list<Procedure__c> lstProcedures  = new list<Procedure__c>();
         lstProcedures = [SELECT Id, Name FROM Procedure__c WHERE Name =:procedureName];
        
        if(lstProcedures.size() > 0 ){
            return lstProcedures[0];
        }
        
        return new Procedure__c();
    }// end of c_CheckIfProcedureAlreadyExists
    
    public static List<Opportunity> retrieveOpportunitiesByAccountId(String accountId) {
        
        
         List<Opportunity> lstOpportunities= [SELECT Name,Type FROM Opportunity where Account.Id=:accountId];
         
         System.debug('lstOpportunities--'+ lstOpportunities);

         return lstOpportunities;
    } 
    
    public static CS_AccountActivityWrapper createAccCaseHistoryWrapper(Case__History objAccCaseFieldHistory, 
                                                                          Case__c objAccCase){
        
        string wrapperNotes ='';
        if(CS_AROpportunityService.retrieveFieldName('Case__c', objAccCaseFieldHistory.Field) == 'Created'){
            wrapperNotes = objAccCaseFieldHistory.CreatedBy.Name + ' added case'; //objOppCase.Case__r.Name;
        }else{
            wrapperNotes = objAccCaseFieldHistory.CreatedBy.Name + ' changed ' + CS_AROpportunityService.retrieveFieldName('Case__c', objAccCaseFieldHistory.Field);
            if(objAccCaseFieldHistory.OldValue != null){
                wrapperNotes += ' from ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccCaseFieldHistory.OldValue));
                
            }
            system.debug('##--wrapperNotes1: '+ wrapperNotes);
            wrapperNotes += ' to ';
            wrapperNotes += objAccCaseFieldHistory.NewValue == null?'':CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccCaseFieldHistory.NewValue));
            system.debug('##--wrapperNotes2: '+ wrapperNotes);
        
        }
        CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper (objAccCaseFieldHistory.Id,objAccCaseFieldHistory.CreatedBy.Name,objAccCaseFieldHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG', ''); 
       return objWrapper;
        
    }// end of createAccCaseHistoryWrapper
    
    public static list<AccountWrapper> retrieveAccountActivity(string activityType, 
                                                                       Id accountId){
        
        list<CS_AccountActivityWrapper> lstCS_AccountActivityWrapper = new list<CS_AccountActivityWrapper>();
        list<AccountWrapper> lstSortedAccountWrapper= new list<AccountWrapper>();
        
        for(Account objAcc :[SELECT Id, 
                                    (SELECT Id, IsDeleted, AccountId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Histories order by CreatedDate), // fetching history
                                    (SELECT Id, Health_Care_Provider__r.Name, Practitioner__c, Practitioner__r.Name, Event_Start_Date__c, CreatedBy.Name FROM Cases__r order by Event_Start_Date__c), //fetching surgical cases
                                    (SELECT Id, Health_Care_Provider__r.Name, Practitioner__c, Practitioner__r.Name, Event_Start_Date__c, CreatedBy.Name FROM Cases1__r order by Event_Start_Date__c), //fetching surgical cases
                                    (SELECT Id, CreatedDate, Body, CreatedBy.Name FROM Notes order by CreatedDate), //fetching logs
                                    (SELECT Id, CreatedDate, CreatedBy.Name, Subject, Description,ActivityDate FROM Tasks order by CreatedDate),// fetching tasks
                                    (SELECT Id, CreatedDate, CreatedBy.Name, Name, Description,closedate, stageName FROM Opportunities order by CreatedDate),
                                    (SELECT Id, CreatedDate, CreatedBy.Name, Name, Opportunity__c, Opportunity__r.Name, Opportunity__r.CloseDate, Opportunity__r.StageName FROM Opportunity_Surgeons__r order by CreatedDate) // fetching Opportunity Surgeons
                                    
                                    //(SELECT Id, User.Name, CreatedDate,CreatedBy.Name FROM OpportunityTeamMembers order by CreatedDate), //fetching oppteammembers
                                    //(SELECT Id, CreatedDate, Contact.Name, CreatedBy.Name, IsPrimary FROM OpportunityContactRoles order by CreatedDate), // fetching opportunityContactRoles
                                    //(SELECT Id, CreatedDate, CreatedBy.Name, deleted_by__c, deleted_by__r.Name, Lastmodifieddate, Contact__r.Name FROM Key_Contacts_Opportunity_logs__r order by CreatedDate asc) // fetching deleted opportunityContactRoles
                                    FROM Account WHERE Id = : accountId]){
               
            // adding account history   
            
            if(activityType == 'All Activities' || activityType == 'Log'){                  
                for(AccountHistory objAccHistory :objAcc.Histories){
                    string wrapperNotes ='';
                    
                    if(CS_AROpportunityService.checkIfFieldValueIsId(string.valueof(objAccHistory.NewValue))){
                        continue;
                    }
                    if(CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field) == 'Created'){
                        wrapperNotes = objAccHistory.CreatedBy.Name + ' ' + CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field) ;
                    }else if(objAccHistory.NewValue != null){
                        wrapperNotes = objAccHistory.CreatedBy.Name + ' changed ' + CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field);
                        if(objAccHistory.OldValue != null){
                           if(objAccHistory.OldValue != 'Surgeon - Orthopaedic - List' && objAccHistory.OldValue != 'Surgeon - Endoscopic - List' && objAccHistory.OldValue != 'Surgeon - Podiatric - List' && objAccHistory.OldValue != 'Surgeon - Veterinary - List:' && objAccHistory.OldValue != 'Surgeon - Plastic Surgery - List'){
                                wrapperNotes += ' from ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccHistory.OldValue));
                            }else{
                                string strOLDValue = '';
                                string[] arrOLDValue = string.valueof(objAccHistory.OldValue).split('-');
                                strOLDValue = arrOLDValue[1].trim();
                                wrapperNotes += ' from ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(strOLDValue));                           
                            }
                            
                        }
                        system.debug('##--wrapperNotes1: '+ wrapperNotes);
                        wrapperNotes += ' to ';
                       if(objAccHistory.NewValue != 'Surgeon - Orthopaedic - List' && objAccHistory.NewValue != 'Surgeon - Endoscopic - List' && objAccHistory.NewValue != 'Surgeon - Podiatric - List' && objAccHistory.NewValue != 'Surgeon - Veterinary - List:' && objAccHistory.NewValue != 'Surgeon - Plastic Surgery - List'){                            
                            wrapperNotes += objAccHistory.NewValue == null?'':CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccHistory.NewValue));
                        }else{
                             string strNEWValue = '';
                             string[] arrNEWValue = string.valueof(objAccHistory.NewValue).split('-');
                             strNEWValue = arrNEWValue[1].trim();
                             wrapperNotes += objAccHistory.NewValue == null?'':CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(strNEWValue));                         
                        }
                        system.debug('##--wrapperNotes2: '+ wrapperNotes);
                    
                    }else if(objAccHistory.NewValue == null){
                        
                       if(objAccHistory.OldValue != 'Surgeon - Orthopaedic - List' && objAccHistory.OldValue != 'Surgeon - Endoscopic - List' && objAccHistory.OldValue != 'Surgeon - Podiatric - List' && objAccHistory.OldValue != 'Surgeon - Veterinary - List:' && objAccHistory.OldValue != 'Surgeon - Plastic Surgery - List'){                           
                            if(CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field) != 'Designation'){
                                wrapperNotes = 'Deleted ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccHistory.OldValue)) + ' in ' + CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field);
                            }else{
                                wrapperNotes = 'Updated ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(objAccHistory.OldValue)) + ' in ' + CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field);
                            }
                       }else{
                            string strOLDValue = '';
                            string[] arrOLDValue = string.valueof(objAccHistory.OldValue).split('-');
                            strOLDValue = arrOLDValue[1].trim();                           
                            wrapperNotes = 'Deleted ' + CS_AROpportunityService.retriveRecordNameForLookUps(string.valueof(strOLDValue)) + ' in ' + CS_AROpportunityService.retrieveFieldName('Account', objAccHistory.Field);                       
                        }
                        
                    }
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objAccHistory.Id,objAccHistory.CreatedBy.Name,objAccHistory.CreatedDate,
                                                                                             wrapperNotes,
                                                                                             'LOG', '');        
                       lstCS_AccountActivityWrapper.add(objWrapper);   
                    
                }// end of for -each history
                
                
                /*for(Affiliation__c objAccSurgeon : [SELECT Id, Account_hcp__c, Account_p__r.Name,isDeleted, Lastmodifieddate, LastModifiedBy.Name,
                                                                (SELECT Id, ParentId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Histories order by CreatedDate)
                                                        FROM Affiliation__c WHERE Account_hcp__c= :accountId ALL ROWS]){
                    if(objAccSurgeon.Histories.size() > 0){                                 
                        for(Affiliation__History objAccSurgFieldHistory :objAccSurgeon.Histories){
                            lstCS_AccountActivityWrapper.add(createAccSurgeonHistoryWrapper(objAccSurgFieldHistory , objAccSurgeon));  
                          
       
                        }
                    }
                    if(objAccSurgeon.isDeleted){
                        String strNote = objAccSurgeon.LastModifiedBy.Name + ' deleted ' + objAccSurgeon.Account_p__r.Name;
                        CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objAccSurgeon.Lastmodifieddate, strNote, 'LOG');
                        lstCS_AccountActivityWrapper.add(objWrapper);
                    }
                    
                }*/// end of for-each Affiliation__c 
                
                for(Case__c objAccCase: [SELECT Id, Health_Care_Provider__c , Name,
                                                                (SELECT Id, ParentId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM Histories order by CreatedDate)
                                                        FROM Case__c WHERE Health_Care_Provider__c = :accountId ALL ROWS]){
                    if(objAccCase.Histories.size() > 0){                                    
                        for(Case__History objAccCaseHistory :objAccCase.Histories){
                            lstCS_AccountActivityWrapper.add(createAccCaseHistoryWrapper(objAccCaseHistory , objAccCase));  
                        }
                    }
                    
                }// end of for-each Opportunity_Case__c 
                 
            } 
            
            //adding surgical cases
            if(activityType == 'All Activities' || activityType == 'Surgical Case'){
                for(Case__c objAccCase :objAcc.Cases__r){
                    
                    string surgicalCaseNote = objAccCase.Practitioner__r.Name + '-' + objAccCase.Health_Care_Provider__r.Name;
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objAccCase.Id,objAccCase.CreatedBy.Name,objAccCase.Event_Start_Date__c,
                                                                                             surgicalCaseNote,
                                                                                             'SURGICAL CASE', '');      
                        lstCS_AccountActivityWrapper.add(objWrapper);   
                }// end of for-each case
            }
              //adding surgical cases-swetha penmethsa
            if(activityType == 'All Activities' || activityType == 'Surgical Case'){
                for(Case__c objAccCase :objAcc.Cases1__r){
                    
                    string surgicalCaseNote = objAccCase.Practitioner__r.Name + '-' + objAccCase.Health_Care_Provider__r.Name;
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objAccCase.Id,objAccCase.CreatedBy.Name,objAccCase.Event_Start_Date__c,
                                                                                             surgicalCaseNote,
                                                                                             'SURGICAL CASE', '');      
                        lstCS_AccountActivityWrapper.add(objWrapper);   
                }// end of for-each case
            }
            
            if(activityType == 'All Activities' || activityType == 'Note'){
                for(Note objNote : objAcc.Notes){
                    
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objNote.Id,objNote.CreatedBy.Name,objNote.CreatedDate,
                                                                                             objNote.Body,
                                                                                             'NOTE', '');       
                        lstCS_AccountActivityWrapper.add(objWrapper);   
                    
                }
            }
            
            if(activityType == 'All Activities' || activityType == 'Task'){
                for(Task objTask : objAcc.Tasks){
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objTask.Id,objTask.CreatedBy.Name,objTask.ActivityDate,
                                                                                             objTask.Description,
                                                                                             'TASK', '');       
                        lstCS_AccountActivityWrapper.add(objWrapper);
                    
                }
            }
            
            if(activityType == 'All Activities' || activityType == 'OPPORTUNITY'){
                DateTime oppCloseDateTime;
                for(Opportunity objOpp : objAcc.Opportunities){
                    oppCloseDateTime = DateTime.newInstance(objOpp.closedate.year(), objOpp.closedate.month(), objOpp.closedate.day(), 0, 0, 0);
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objOpp.Id,objOpp.CreatedBy.Name, oppCloseDateTime,
                                                                                             objOpp.Name,
                                                                                             'OPPORTUNITY', objOpp.stageName);     
                        lstCS_AccountActivityWrapper.add(objWrapper);
                }
                DateTime oppCloseDateTimeNew;
                for(Opportunity_Surgeons__c objOppSurg : objAcc.Opportunity_Surgeons__r){
                    oppCloseDateTimeNew = DateTime.newInstance(objOppSurg.Opportunity__r.closedate.year(), objOppSurg.Opportunity__r.closedate.month(), objOppSurg.Opportunity__r.closedate.day(), 0, 0, 0);
                    CS_AccountActivityWrapper objWrapper = new CS_AccountActivityWrapper(objOppSurg.Opportunity__c, objOppSurg.CreatedBy.Name,oppCloseDateTimeNew,
                                                                                             objOppSurg.Opportunity__r.Name,
                                                                                             'OPPORTUNITY', objOppSurg.Opportunity__r.stageName);     
                        lstCS_AccountActivityWrapper.add(objWrapper);
                }
            }
            
        }
        
        for(CS_AccountActivityWrapper objWrapper : lstCS_AccountActivityWrapper ){
            
            lstSortedAccountWrapper.add(new AccountWrapper(objWrapper));
        }
        lstSortedAccountWrapper.sort();
        return lstSortedAccountWrapper;
    
    }// end of retrieveAccountFieldHistory
    
    public static void createNote(string accountId, string noteBody){
        
        Note accountNote = new Note(ParentId = accountId,
                                        Title = 'Account Note',
                                        Body = noteBody);
        insert accountNote ;
    }// end of createNote
    
    public class CS_AccountActivityWrapper{
        
        public datetime logDate {get;set;}
        public string notes {get;set;}
        public string activityType {get;set;}
        public string logOwner{get;set;}
        public string recId{get;set;}
        public string stage {get;set;}
        
        public CS_AccountActivityWrapper(string p_Id,string p_owner,datetime p_logDate, 
                                        string p_notes,
                                         string p_activityType, string p_stage){
            recId=p_Id;
            logOwner = p_owner;
            logDate = p_logDate;
            notes = p_notes;
            activityType = p_activityType;
            stage = p_stage;    
        }
    }// end of CS_AccountActivityWrapper
    
    public class AccountWrapper implements Comparable {

        public CS_AccountActivityWrapper acc;
        
        // Constructor
        public AccountWrapper (CS_AccountActivityWrapper ac) {
            acc = ac;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            AccountWrapper compareToAcc = (AccountWrapper )compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (acc.logDate < compareToAcc.acc.logDate) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (acc.logDate > compareToAcc.acc.logDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    public static void updateNote(string noteId,string note){
            
        Note accountNote = [Select Id,Body from Note where Id=:noteId limit 1];
        accountNote.body=note;
        update accountNote ;
    }// end of createNote
        
    public static void deleteNote(string noteId){
            
        Note accountNote = [Select Id,Body from Note where Id=:noteId limit 1];            
        delete accountNote ;
    }//
    
    public static List<Account> retrieveSurgeonRelatedContacts(String providerId) {
        set<Id> sAccId = new set<Id>();
        List<Surgeon_Related_Contacts__c> lstSurgeonRelatedCon = [select id, Surgeon_Contact__c from Surgeon_Related_Contacts__c where Surgeon__c =: providerId];
        for(Surgeon_Related_Contacts__c src: lstSurgeonRelatedCon){
            sAccId.add(src.Surgeon_Contact__c);
        }
        // LastName, FirstName, PersonEmail, PersonTitle
        List<Account> relatedAccounts;/* = [select Id, Name, Description, LastName, FirstName, PersonEmail, Phone, PersonMobilePhone, PersonTitle, Preferred_Name__c, AccountNumber from Account where id IN: sAccId];// and AccountId in :availProviderIds order by LastName Asc];
        if ( relatedAccounts == null ) { relatedAccounts = new List<Account>(); }*/

        return relatedAccounts;        
    }
    
   
     
    //Release 3.2
    //Developer:- Mimansha Samal
    //Date:- 21/3/2017
    //Purpose:- Save the Preference Cards
    // saves or updates a Practioner_Procedure__c object and syncs associated Practioner_Procedure_Products__c records
    public static CS_PreferenceCardWrapper csavePractitionerPreferenceCards(String id, 
                                                                    String name, 
                                                                    String practitionerId,
                                                                    list<string> lstProcedureIds,   
                                                                    list<string> lstSurgicalTechniqueIds, 
                                                                    String disposables,
                                                                    String equipment,
                                                                    String equipmentNotes, 
                                                                    String medications,
                                                                    String sutures, 
                                                                    String position, 
                                                                    List<Practitioner_Procedure_Products__c> prefCardProdList) { 
        
        list<Practitioner_Procedure_Products__c> lstPractProcedureProducts = new list<Practitioner_Procedure_Products__c>();
        list<Preference_Card_Procedures__c> lstPrefCardProcedures = new list<Preference_Card_Procedures__c>();
        list<Preference_Card_Procedures__c> lstExistingPrefCardProc = new list<Preference_Card_Procedures__c>();

        Practitioner_Procedure__c pp = null;
        if ( id != null ) {
            pp = [select Id,Pref_Card_Name__c,Disposables__c, Surgical_Technique__c, Equipment__c, Equipment_Notes__c, Medications__c,Position__c, Sutures__c,Procedure__r.Name  from Practitioner_Procedure__c where Id=:id];
            lstExistingPrefCardProc = [SELECT Id,Taxonomy__c FROM Preference_Card_Procedures__c WHERE Preference_Card__c = :Id];
        } else {
            pp = new Practitioner_Procedure__c();
            pp.Practitioner__c = practitionerId; 
        }
        
        
        
        pp.Pref_Card_Name__c = name;
        pp.Disposables__c = disposables;
        pp.Equipment__c = equipment;
        pp.Equipment_Notes__c = equipmentNotes;
        pp.Medications__c = medications;
        pp.Position__c = position;
        pp.Sutures__c = sutures;

        if ( id != null ) {
            update pp;
        } else {
            insert pp;
        }
        
        if(lstExistingPrefCardProc.size() > 0){ 
            
             deletePrefcardProcedures d_deletePrefcardProcedures = new deletePrefcardProcedures();
             d_deletePrefcardProcedures.c_deletePrefcardProcedures(lstExistingPrefCardProc);
            //delete lstExistingPrefCardProc;
        }
        
        for(string objString : lstProcedureIds){
            
            string[] lstTaxononmy = objString.split('::');
            string procedureId = lstTaxononmy[1];
            Id ProductTeamId = lstTaxononmy[0];
            string procedureName = lstTaxononmy[2];
            system.debug('##--csavePractitionerProcedure.procedureId: '+ procedureId);
            Preference_Card_Procedures__c objPrefCardProcs = new Preference_Card_Procedures__c();
            if(procedureId.endsWithIgnoreCase('newId')){
                
                Procedure__c objProc = new Procedure__c(Procedure_Name__c = procedureName, 
                                                        Name = procedureName,  
                                                        TaxonGroupId__c = 'Procedure', 
                                                        Type__c = 'Other');
                
                insert objProc;
                
                procedureId = objProc.Id;
            }
            
            objPrefCardProcs.Product_Team__c = ProductTeamId;
            objPrefCardProcs.Taxonomy__c = procedureId;
            objPrefCardProcs.Preference_Card__c = pp.Id;
            lstPrefCardProcedures.add(objPrefCardProcs);
            
        }// end of for-each lstProcedureIds
        
        if(lstSurgicalTechniqueIds != null 
            && lstSurgicalTechniqueIds.size() > 0){
        
            for(string objString : lstSurgicalTechniqueIds){
                
                string[] lstTaxononmy = objString.split('::');
                Id surgicalTechniqueId = lstTaxononmy[1];
                Id ProductTeamId = lstTaxononmy[0];
                string procedureName = lstTaxononmy[2];
                
                Preference_Card_Procedures__c objPrefCardSurgTechs = new Preference_Card_Procedures__c();
                objPrefCardSurgTechs.Product_Team__c = ProductTeamId;
                objPrefCardSurgTechs.Taxonomy__c = surgicalTechniqueId;
                objPrefCardSurgTechs.Preference_Card__c = pp.Id;
                lstPrefCardProcedures.add(objPrefCardSurgTechs);
                
            }// end of for-each lstSurgicalTechniqueIds
        }
        
        system.debug('##--csavePractitionerProcedure.lstPrefCardProcedures' + lstPrefCardProcedures);
        if(lstPrefCardProcedures.size() > 0){
            
            insert lstPrefCardProcedures;
        }

        // products mapped to this practioner procedure
        Set<Practitioner_Procedure_Products__c> productList = new Set<Practitioner_Procedure_Products__c>([select Id,Product__c from Practitioner_Procedure_Products__c where Practitioner_Procedure_Products__c.Practitioner_Procedure__c=:pp.Id]);
        list<Practitioner_Procedure_Products__c> lstPractitionerProcedureProducts = new list<Practitioner_Procedure_Products__c>();
        if ( productList == null ) { 
            productList = new Set<Practitioner_Procedure_Products__c>(); 
        }
        
        // Step 1-2 remove all existing products, will replace them with what is coming in
        for ( Practitioner_Procedure_Products__c existingProduct : productList ) {
            //delete existingProduct;
            lstPractitionerProcedureProducts.add(existingProduct);
        }
        
        if(lstPractitionerProcedureProducts.size() > 0){
            deletePractitionerProcProds d_deletePractitionerProcProds = new deletePractitionerProcProds();
            d_deletePractitionerProcProds.c_deletePractitionerProcProds(lstPractitionerProcedureProducts);
        }
        
        // Step 2-2. add products in productIds               
        for(Practitioner_Procedure_Products__c objPracProd :prefCardProdList){
                objPracProd.Practitioner_Procedure__c = pp.Id;
                lstPractProcedureProducts.add(objPracProd);
        }
        
        if(lstPractProcedureProducts.size() > 0){
            insert lstPractProcedureProducts;
        }
        
        return buildCS_AROpportunityWrapper(pp.Id);
        //return [select Id,Pref_Card_Name__c,Disposables__c, Equipment__c, Equipment_Notes__c, Medications__c,Position__c, Sutures__c,Procedure__r.Name  from Practitioner_Procedure__c where Id=:pp.Id];

    }
    
    
    //Release 3.2
    //Developer:- Mimansha Samal
    //Date:- 4/4/2017
    //Purpose:- Check if the price book entry for the product is active
    public static List<PriceBookEntry> checkIfProductActive(String productId) {
        
                
        string priceBookQuery = 'SELECT Id, IsActive, Product2.Name, Product2Id ' +
                                  ' FROM PriceBookEntry WHERE Product2Id = :productId ';
                              
        priceBookQuery += ' ORDER BY Product2.Name DESC LIMIT 1 ';
        
        list<PriceBookEntry> foundPriceBookEntries =Database.Query(priceBookQuery);
       
        system.debug('##--foundActivePriceBookEntries: '+ foundPriceBookEntries);
        return foundPriceBookEntries;
        
    }// end of checkIfProductActive
    
    
    public static Account saveRelatedContact(Map<String,Object> accountMap){
        
        SaveRelatedContact objClass = new SaveRelatedContact();
        
        return objClass.c_saveRelatedContact(accountMap);
        
    }// end of saveRelatedContact
    
    public without sharing class SaveRelatedContact {

        public Account c_saveRelatedContact(Map<String,Object> accountMap) {
            Account c = null;
            String id = (String)accountMap.get('id');
            system.debug('##--saveAccount.id: '+ id);
            c = new Account();
            if ( id == null || id == '') {
                // new related contact
    
                
            } else {
     
                c = [select Id, Description, Phone from Account where Id=:id];
            }
            
            /*c.FirstName = (String)accountMap.get('firstName');
    
            if ( accountMap.containsKey('lastName') ) {
                // only update if the map contains the key, last name is required
                c.LastName = (String)accountMap.get('lastName');
            }

            c.PersonEmail = (String)accountMap.get('email');
            c.Phone = (String)accountMap.get('phone');
            c.PersonMobilePhone = (String)accountMap.get('mobile');
            c.BillingStreet = (String)accountMap.get('street');
            c.BillingCity = (String)accountMap.get('city');
            c.BillingState = (String)accountMap.get('state');
            c.BillingCountry = 'United States';
            c.BillingPostalCode = (String)accountMap.get('zip');
           // c.AccountId = (String)accountMap.get('accountId');
           c.PersonTitle = (String)accountMap.get('title');
            //c.Description = (String)accountMap.get('notes');
            c.ownerid = userinfo.getuserid();
            Id surgeonConRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_SURGEON_CONTACT).getRecordTypeId();
    
            c.RecordTypeId = surgeonConRecTypeId;
            //upsert c;
            if ( id == null || id == '') {
            AccountShare objAccShare = new AccountShare();
            objAccShare.AccountId = c.id;
            objAccShare.AccountAccessLevel = 'Read';
            objAccShare.CaseAccessLevel = 'Read';
           // objAccShare.ContactAccessLevel = 'Read';
            objAccShare.OpportunityAccessLevel = 'Read';
            objAccShare.UserOrGroupId = system.userinfo.getuserid();
            insert objAccShare; 
             }     */
            List<Surgeon_Related_Contacts__c> lstSurgeonRelatedCon = new List<Surgeon_Related_Contacts__c>();
            Surgeon_Related_Contacts__c objSRC = new Surgeon_Related_Contacts__c();
            objSRC.Surgeon__c = (String)accountMap.get('accountId');
            objSRC.Surgeon_Contact__c = c.id;
            lstSurgeonRelatedCon.add(objSRC);
            insert lstSurgeonRelatedCon;
            
            return c;
        }
    }// end of RelatedContactService
    
    //Release 2.2
    //Component ID:- CID000064
    //Developer:- Mimansha Samal
    //Date:- 12/6/2016
    //Purpose:- Retrieving Account Affiliations that the practitioner is associated to.
    public without sharing class cls_RetrieveAccountAffiliationsByPractitioner {

        public  List<Affiliation__c> c_retrieveAccountAffiliationsByPractitioner(String practitionerId) {
            system.debug('##-- retrieveAccountAffiliationsByPractitioner.PractitionerId--'+ practitionerId);
            List<Affiliation__c> lstAffiliations = [SELECT Id, Name, Account_hcp__r.Name, Account_hcp__r.Preferred_Name__c, Account_hcp__r.Customer_Number__c, Account_hcp__r.Phone,  Account_hcp__r.Id, Account_hcp__r.AccountNumber FROM Affiliation__c where Account_p__c =:practitionerId ORDER BY Name desc];
            
            if ( lstAffiliations == null || lstAffiliations.size() == 0 ) { 
                lstAffiliations = new List<Affiliation__c>(); 
            } 
            system.debug('##--retrieveAccountAffiliationsByPractitioner.Affiliation--'+ lstAffiliations);
            return lstAffiliations;
             
        }// end of c_retrieveAccountAffiliationsByPractitioner
        
    }// end of cls_RetrieveAccountAffiliationsByPractitioner
     
    //Code added by Ansu for getting Surgeon Affiliations to an account in release 2.2. 
    //Code modified by Ansu release 3.2 to include all surgeons affiliated with an account 
    public without sharing class cls_RetrieveSurgeonAffiliationsByAccount {  
        public List<Affiliation__c> retrieveSurgeonAffiliationsByAccount(String accountId) {
            List<Affiliation__c> lstAffiliations = [SELECT Id, Name, Full_Name__c, Account_p__r.Name, Surgeon_Designation__c, Surgeon_Phone__c,Surgeon_Type__c, Person_Email__c,Account_p__r.Id,Account_p__c FROM Affiliation__c where Account_hcp__r.Id=:accountId ORDER BY Name desc];
             
            if ( lstAffiliations== null || lstAffiliations.size() == 0 ) { 
                lstAffiliations= new List<Affiliation__c>(); 
            }
            System.debug('All Surgeon Affiliation--'+ lstAffiliations);
            
            return lstAffiliations;
        }
    }  
    
      
    public without sharing class saveSurgeonProfilePicWrapper{
        public string c_saveSurgeonProfilePicWrapper(String accountId, String attachmentBody){
            string strProfilePic = '';
            strProfilePic = '/servlet/servlet.FileDownload?file=';
            system.debug('@@@@@@@@@@@@@'+accountId);
            system.debug('@@@@@@@@@@@@@'+attachmentBody);
            
            List<attachment> currentPictures = [SELECT Id FROM Attachment WHERE parentId = :accountId AND name = :fixedFileName LIMIT 1];
            if(currentPictures.size() != 0) {              
                delete currentPictures;               
            }
                       
            if(attachmentBody != null) {
                String newBody = '';
                newBody = attachmentBody;
                blob profilePicFile = EncodingUtil.base64Decode(newBody);
                // Now, we save the new blob
                Attachment a = new Attachment(parentId = accountId, name = fixedFileName, body = profilePicFile);
                insert a;
                
                system.debug('@@@@@@@@@@@@@'+a);
                strProfilePic += a.id;
                
                Account ObjAcc = new Account(id=accountId);
                ObjAcc.Profile_Picture__c = strProfilePic;
                update ObjAcc;
            }
            return strProfilePic;
        }
    }
   
    
    public without sharing class deleteSurgeonProfilePicWrapper{
        public void c_deleteSurgeonProfilePic(String accountId) {
            List<attachment> currentPictures = [SELECT Id FROM Attachment WHERE parentId = :accountId AND name = :fixedFileName];
            delete currentPictures;
            
            Account ObjAcc = new Account(id=accountId);
            ObjAcc.Profile_Picture__c = '';
            update ObjAcc;
        }
    }
}