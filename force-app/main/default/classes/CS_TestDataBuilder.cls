/**********************************************************
**Description: A class that builds data for test classes
**Parameters:   None
**Returns:   None
**Author:    JBANDOJO - CloudSherpas Inc.
**Date Created:  15-FEB-2015
**********************************************************/
public class CS_TestDataBuilder {
    public  static Case CreateCase(){
        Case testCase = new Case();
        testCase.SuppliedName = 'Test Case';
        testCase.Subject      = 'Test Case Subject';
        testCase.Description  = 'Test Case Description';
        testCase.Reason       = 'New Problem';
        testCase.SuppliedPhone = '0912345678';
        testCase.suppliedEmail = 'testcase@test.com';
        return testCase;
    }
    
    public  static User CreateUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole role = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', FirstName='User1', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testclassstandarduser@test.com');
        return testUser;
    }
    public  static User CreatePartnerUser(Contact c){

        Profile p = [select id from profile where name='AXIS Partner Community User'];
        User testUser = new User(Alias = 'standt', Email='standardpartuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', FirstName='User1', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p.Id, IsActive=true, PortalRole='Manager',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='standardpartuser@test.com',ContactId=c.Id);
        return testUser;
    }    
    public  static Account CreatePractitioner(){
            Account objSurgeonContact = new Account(Name = 'TestSurgeonFirstName TestSurgeonLastName',
                                        Phone = '5556667777',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_SURGEON_CONTACT).getRecordTypeId());
                                        
        return objSurgeonContact;
    }
    public  static Account CreateProvider(){
        Id providerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant.RECORDTYPE_NAME_HEALTH_CARE_PROVIDER).getRecordTypeId();
        Account testAccount = new Account(Name = 'TestProvider', recordTypeId = providerId);
        return testAccount;
    }
    public  static Case_Products__c CreateCaseProducts(Id caseId, Id productId){
        Case_Products__c testCaseProducts = new Case_Products__c(Case__c = caseId, Product__c = productId);
        return testCaseProducts;
    }
    public  static Case__c CreateCases(Id practitionerId, Id providerId, Id productId){
        Case__c testCase = new Case__c(Practitioner__c = practitionerId, Health_Care_Provider__c = providerId, 
                                       Event_End_Date__c = system.today(), Event_Start_Date__c = system.today(),
                                       Product__c = productId);
        return testCase;
    }
    public  static CaseParticipant__c CreateCaseParticipant(Id caseId, Id UsrId){
        CaseParticipant__c testCaseParticipant = new CaseParticipant__c(Case__c = caseId, Participant__c = UsrId);
        return testCaseParticipant;
    }
    public  static Product2 CreateProduct(){
        Product2 testCaseProducts = new Product2(Name= 'Test Product',ProductCode = 'TEST101', Description = 'Product Description');
        return testCaseProducts;
    }
    /*public  static Practitioner_Procedure__c CreatePractitionerProcedure(Id practitionerId, Id procedureId){
        Practitioner_Procedure__c testPractitionerProcedure = new Practitioner_Procedure__c(Practitioner__c= 'Test Product',
                                                                                            Procedure__c = 'TEST101', 
                                                                                            Description = 'Product Description'
                                                                                            );
        return testPractitionerProcedure;
    }*/

    public static Case_Procedure__c CreateCaseProcedure(String caseId, String procedureId) {
        Case_Procedure__c caseProc = new Case_Procedure__c();
        caseProc.Case__c = caseId;
        caseProc.Procedure__c = procedureId;
        return caseProc;
    }

    public  static Procedure__c CreateProcedure(){
        Procedure__c testProcedure = new Procedure__c(Name= 'Test procedure');
        return testProcedure;
    }
    public  static Contact CreateContact(Id AccountId){
        Contact testContact = new Contact(LastName= 'TestLastName', FirstName= 'TestFirstName', accountId = AccountId);
        return testContact;
    }
    public  static Practitioner_Procedure__c CreatePractitionerProcedure(Id PractitionerId, Id procedureId){
        Practitioner_Procedure__c testPractitionerProcedure = new Practitioner_Procedure__c(Practitioner__c= PractitionerId, Procedure__c = procedureId, Pref_Card_Name__c = 'test Pref Card');
        return testPractitionerProcedure;
    }
    public static Territory2Type CreateTerritoryType(){
        Territory2Type territoryType = new Territory2Type(Priority = 1, MasterLabel= 'Arthrex', Description ='Test TerritoryType');
        return territoryType;
    }
    public static Territory2Model CreateTerritoryModel(){
        Territory2Model territoryModel = new Territory2Model(Name= 'Arthrex Model 2', DeveloperName ='Arthrex_Model2' );
        return territoryModel;
    }
    public static Territory2 CreateTerritory(Id terrModel, Id terrType){
        Territory2 territoryModel = new Territory2(Territory2TypeId = terrType, Territory2ModelId = terrModel, Name ='Arthroplasty', DeveloperName='Arthroplasty_Central_Texas');
        return territoryModel;
    }
    public static UserTerritory2Association CreateUserTerritoryAssociation(Id uId, Id terrId){
        UserTerritory2Association territoryModel = new UserTerritory2Association(Territory2Id = terrId, RoleInTerritory2 = 'Executive', userId = uId);
        return territoryModel;
    }
    public  static Case_Pref_Card__c CreateCasePrefCard(Id caseId, Id pracprocId){
        Case_Pref_Card__c testCasePrefCard = new Case_Pref_Card__c();
        testCasePrefCard.Case__c = caseId;
        testCasePrefCard.Practitioner_Procedure__c=pracprocId;
        return testCasePrefCard;
    }
    
    //Code added by Ansu for release 2.2/CID000065
    public  static Affiliation__c CreateAffiliation(Id providerId, Id pracId){
        Affiliation__c testAffiliation = new Affiliation__c(Account_hcp__c = providerId, Account_p__c = pracId);
        return testAffiliation;
    }
     public  static Sales__c CreateSales(Id usr,Product2 prod){
       
        Sales__c testSales = new Sales__c();
        testSales.Product__c=prod.Id;
        testSales.CurrentPeriod__c='Jun 2016';
        testSales.CurrentFiscalYear__c='FY2016';
        testSales.Currency__c='USD';
        testSales.Rep_H0Rev_PriorDay__c=11000.0; 
        testSales.Rep_H0Rev_MTD__c=1111000.0;
        testSales.Rep_Quota_CurrMonth__c=1113000.0;
        testSales.Agent__c=usr;
        testSales.Current_Date__c=Date.today();
        return testSales;
    }
    public  static Axis_Sales_Category__c CreateSalesCategory(Product2 prod){
        Axis_Sales_Category__c testSalesCategory= new Axis_Sales_Category__c();
        testSalesCategory.Name=prod.Name;
        testSalesCategory.Abbreviation__c='SH';
        testSalesCategory.Ordinal__c=1;
        return testSalesCategory;
    }
    //Code added by Ansu ends
   
   
   //Swetha P /jan19/2017/Test Data Creation  
    public static ObjectTerritory2Association createObjectTerritory2Association(String healthCareProviderAccountId, String objTerritoryId){
        ObjectTerritory2Association objAssoc = new ObjectTerritory2Association(objectId = healthCareProviderAccountId,
                                                                                    Territory2Id = objTerritoryId,
                                                                                    AssociationCause = Constant.ASSOCIATIONCAUSE_TERRITORY2MANUAL);
          return objAssoc;
    }
    
    public static UserTerritory2Association createUserTerritory2Association (String portalUserId, String objTerritoryId){
        UserTerritory2Association objTerrAssoc = new UserTerritory2Association(UserId = portalUserId,
                                                                                   Territory2Id = objTerritoryId);
        return objTerrAssoc;
    }
    
    public static Procedure_Relationships__c createProcedureRel(String childProcedureId, String parentProcedureId){
        Procedure_Relationships__c objProcedureRel = new Procedure_Relationships__c(Child_Procedure__c = childProcedureId,
                                                                                        Parent_Procedure__c = parentProcedureId,
                                                                                        TaxonGroupId__c = 'surgical_technique');
        return objProcedureRel;
    }   
    
    
    public static Case_Procedure__c createcaseProc(String parentProcedureId, String objCaseId){
        Case_Procedure__c caseProc = new Case_Procedure__c();
        caseProc.Procedure__c = parentProcedureId;
        caseProc.Case__c = objCaseId;
        return caseProc;
    } 
      //Swetha P /jan19/2017/Test Data Creation
    
    //Contents of the file that will be uploaded as profile picture
    public static String getProfileFileContents(){
    
         String fileContents = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/' + 
                '2wCEAAkGBw8PEBAPDRAPDQ0NEBAPDQ0QDQ8NDQ8PFREWFhURExUYHSggGBolGxUWITEhJSorLi4uFx8zODMsNygtLisBCgoKDg0OFxAQGi0mHyUtLS4tLi0tLS0rLy8rLS0rLS8wLS0rLS0tLS0tLSstLS0tLS0tLS0rLi0tLSsrLSstLf/' +
                'AABEIAMwAzAMBEQACEQEDEQH/xAAbAAEAAgMBAQAAAAAAAAAAAAAAAwQCBQYHAf/EADkQAAICAAMFBgMGBAcAAAAAAAABAgMEESEFBhIxQTJRYXGBkRMisQcjUpKhwRRi0eEVJDNCQ1Pw' + 
                '/8QAGgEBAAIDAQAAAAAAAAAAAAAAAAECAwQFBv/EADQRAQACAQIDBgMHBAMBAAAAAAABAgMEEQUSMRMhMkFRkXGBoRQiQmGx0eEkM5LwFVJTI//aAAwDAQACEQMRAD8A9xAAAAAAAAAAAAD42Bg7orqBj' + 
                '/ER7wM42p9QMwAAAAAAAAAAAAAAAAAAAAAAACrisXGC1YHL7X3phXonm3oktW34IyY8N8k7Vhiy58eKN7zso1XbSv1qws1B8pWyVP6PUz/Z8dfHkj5d7X+1ZLeDHO3rM7fynlgdrLX4VT8FiFn9CIxYP/' + 
                'Sf8f5WnLqIj+3H+X8K09tYvDP/ADeHtqj/ANmXHX+ZaF/sfN/avFvpLF9u5P71Jr+fWPeHQ7I3gruScZJ5+JqXpak7WjaW7TJW8c1Z3hvq7FJaFV2YAAAAAAAAAAAAAAAAAAAAKWPxari22BwuP2jdi7v4fDdp9ub7NcesmbeHTxNe0yd1f1aWo1MxbssXfb6R8f2dJsTYtGFXEl8W99q+aTm34fhXkTly2vHLHdX0hGLDWk8099vWf97m4+Oa' + 
                '/K2ec+OOVHO+SuT0eqfNPVMnlJs5Tbm7azeIwH3N61lUtKrfDLozdx54vHZ5u+PXzhoZdPNJ7TBO0+nlL7uvvF8T7uz5LYaTg+aa0Zr6nTWwz6xPSW1pNXXPHpaOsOzqsUlmjVbbMAAAAAAAAAAAAAAAAAAR32cKbA883y224pwi/mei/qbej03b5Np6R1aWu1UafHvHWeizurh1RQm/' + 
                '9W757H115L0Ruamea20dI7oaGkjkpvPWe+W7WJNbkbfaM1iCOQ7Q/iByHaPjxA5DtGEsSTyHaOM3trdN0MXT8spPhsy5OSXN+a+h0dNEZcc4r9HL1Vpw5a56dfN2W6u2FfXGXVrVdz6o4ubFOK80l38GaubHF6+bpEzEzPoAAAAAAAAAAAAAAAABptv4zgg/' + 
                'IDyHH4l3XOT5cSS8sz02jw9lhiPOe+XkddqO2zzPlHdDtqsRyXcac0b0ZFiGIK8ie0Sq4jlTzvvxiOVPOxleTyo7RDPEE8iO0aXeS3ioku5xa8+LL9zZ01drw1tVbfHKjuZtJ038Dfy2cvCSKcTwc1O0jrH6MnCNRy5Jxz0n9XrmEs4opnBekTgAAAAAAAAAAAAAAAPknoBwW/' + 
                'WN4YSSer0XqbOkx9pmrVq63L2WC1v973nlK1PUS8a6fC4nNJ+BpWptLerk3hequKTVeLrMLCk1W50jmRsnnQ2WFoqrzqttxaKqzdqNr35x4e95v0NjFXad2DNfeNmkrscJKS5xaa9DNesXrNZ82HHeaWi0eT2jdzFKyqElylFNeqPJXrNbTWfJ7elovWLR5tyVWAAAAAAAAAAAAAAAI73lFgeV793ZzUfHM6nCq75LW9IcfjN9sVa+suZoR3ZebhtMJLIxWhkrOzZ0TMMw' + 
                'yRZeqZjmGSJTMqndVukZIhWZUL5mSIY5s1WKeeeZmqxy11nMuo9O+z/EcVEF+HOPszzOury57e71/Dr82mp7eztDUboAAAAAAAAAAAAAABDi+ywPIt9X98vJ/U7PCY8c/BwONz30j4tLhzry4cNlhzHK0NlhzHK8NjQYrMkLEssikLqV5khjlrrzLDHLW4gyQpLW28zJCr0L7OJfdNd05fsef4nH/wB/lD1PCZ/p/nL0BHOdMAAAAAAAAAAAAAAAhxS+VgeSb7wyui/' + 
                'Bo7PCZ8cfBweNR4J+LQ0M7EuDDZYdmOV4bGiRileF6qZjmF4TSsK7J3Vrpl4hWWvvkZYUlrsQzJCktfZzLqvRPs4h9zn3zkee4nO+f5Q9TwmP6ePjLvjnumAAAAAAAAAAAAAAAYWrNMDzHf7DZNS7n9TpcLvtlmPWHJ4xTfDFvSXH1PU77zK/RIpK0NhTMxzC8LddhSYW3SOwjZO6C2ZaIVmVK+ZeIVlr75GSFJUmXQ9Y3Dw3Bh6s+co8Xvr+55bWX5s95/P9HsdDTk09I/' + 
                'Lf3dYazbAAAAAAAAAAAAAAAPjA4/fTAfEqnktcs159DNp8nZ5K29JYNTi7XFanrDyzk/I9XE7vFzG07St0TImCF6qwxzC0LMLCuy27J2kbG6OywtEIVLrC0QiVC6ZkhUwOHdtkK1znJL06/oY82SMdJtPky4MU5claR5y9u2Ph+CuKXRJI8nM7zu9rEbRs2BCQAAAAAAAAAAAAAAABR2ph+ODXgB4/vJs90XS0+SbzXn1R6Lh2ftMfLPWP0eW4ppuzy88dLfq1lcsjfcxbrsKzCU8bCuy27P4g2N0c7CdkbqtthaIQrSeZKHYfZ/' +
                'shzm75LRfLX59X+xx+KZ+mKPjLvcH03XNb4Q9QqjkkjjO8zAAAAAAAAAAAAAAAAAPklmBym9ew1dCWmvNPufeZsGa2G8Xhg1OCufHNLPLMTh5VScJrKUX/AOaPUYstctYtV4/NhvhvNLx3sYzyLsSWNpGyWXxRsMJWjYQylmShd2Ns2WJtVcdI85y7o/1NfVaiuCm89fJt6PS21GTljp5y9j2Ls+NNcYRWSikkjzF7Te02nrL19KVpWK16Q2ZVYAAAAAAAAAAAAAAAAAAEd1aknmB5rv1gYpOeXzLk/' + 
                'U3uH5bVzRWJ7p6udxPDS+C1pjvjo4g9I8o+gMwAHwDs/s6hnOx+MUcTi0/eo9DwWPu3n83qEFojkO2yAAAAAAAAAAAAAAAAAAHxsCpi8dGCebA823y2grU4x11Wfub3D6WnPWYjuhzuKXrXT2rM989Pdx56R5QAAAAHW7i4uNTlxacUll7HD4tE81Z8tnoeCzHJaPPd6dhcXGaWTOS7aymB9AAAAAAAAAAAAAAAxlJICriMfCHNgc7tTeaEc0nqXpjtedqxupkyUxxvedocrj9tWW55NpP3Onh4b55J+UONqOL+WGPnP7Nf8Pizz1' +
                'z5nUpWtI2rGzi5L2yTzXneWpxWHlW8ny6S6MzRO7FMbICyAABlXByaUVm2RvsNzVVwJJc118TDaIt3TDLW00nes7S22ztvWUtKTcorr1OZn4dE9+L2dnTcWmPu5veP2dhsveGFiXzHKvjtSdrRs7ePJTJHNSd4b2nFRlyZRdMmB9AAAAAAAAAADYFPF42MFqwOT2xvVGGaTzfRLmZsOnyZZ+5DXz6nFhje8/u5TGbcut5NxX6nUxcMrHfknf4ONn4xa3dijb85U45vVvN97OjWlaRtWNnKvkvkne87ynhEmVU8IlUpXUpLKSTT5prNFd07K09j1PlxR8np+pbtJRyQj/' +
                'wKP45eyJ7X8kcjOOxa1zcpeqQ7WU8kJ4YaMNIRUfr7leaZTs+TiShXsiWhCJSlF5xbi+9MrfHTJG1o3Xx5b4p3pOza4Hea2rJTzku9c/Y5mbhnnjn5S7GDjHllj5x+zptm72VzyXEs+56M52TT5Mfiq62LVYsvgtEujwm0Yz5Mws68nmB9AAAAAAAA120seq4vUDzXePeSU5OFb85dx09HoO0+/k6enr/Dka/iXZb48fi9fT+XORbbzbbb6vVncisVjasdzzlrWvO9p3lZrQkWa0UlKzXErKViESsrLEIlZlZLGBG6WXARubMXAbmyKcS0ShBOJZVXsRaEK1iLQqq2ovCFaaJR0bDZG3rsPJZyc6+sW82vJmjqdBjyRvXun6OlpOJ5MU7X76/' + 
                'V6nsLa0b4RlF5ppHn70mlprbrD02O9clYtXpLdoquAAAAABBirlGLYHme+G22264PV833I6Gg0va25reGPq5nEtZ2FOWvin6OOR6F5ZPURKVutFZSs1orKVqtFJWhYrRWVlmCKStCeESsylnwEbp2YTiTEiCaLQrKvYi8KyrWItCsq1iLwhVtRaFVWxFoQrssh0m5e1HVb8Jv5LOz4S/ucrien5q9pHWOvwdrhGp5b9lbpPT4vWsLZxRTOE9EmAAAAADm958eq4S1yyTJiJmdoRa0ViZl5Jir3ZOU3zk/0PV4MMYscUh4vU55zZJvKJGZgWKispW6yspWaysrLUCi0LNZSUwswKytCzApK0JSqyKZaESrWF4UlXsLQiVWwvCsq1' + 
                'haFVW0vCsqthaEK8iUPtVjhJSjpKLTXmiL1i1ZrPmtS80tFo6w9n3bxitqhJcpRT90eRvSaWms+T2+O8XrFo827KrgAABhY8kwPNd/MZpw59p5G/w7Hz5on073O4pl5NPMevc4c9G8o+oCeorKVutlZSs1srKVqtlJWhYrZWVlmDKSsnhIrMLJOMjZO7CciYhCvNloVlXsZeFZVrGWhWVaxl4Qq2stCqrYWhCuyyHwD0f7O8ZnVwt6wk4+nNfU85xGnLnmfXveq4Vk59PEenc71Gg6T6AAAQ4t/' + 
                'KwPI99Zt3RXg3+p2eE17rz8HA43bwV+LnDsuEATVsiRarZWVlmtlJStVyKylPCRWVliEiuyyWMyuyd2XGNhjKY2N0U5FoQgnItCqvZItCJVrGWhVWsZeEKtjLQqhJHwDrPs9vaunDpJKS80/wC5x+LU7q2+TucFyfevT5vV6+SOK9AyAAAMLo5rIDzrfTd+yyStq1cU049656eJ0dBq64ZmtukuXxLRWzxFqdY8vVwk4OLakmmuaayaO/W0WjeHmbVms7THexLKs62QLNciqVmuRWUrMJFZWTwkQlNGZXZKRTI2Sy4yNhi5k7G6OUydkIZyJ' + 
                'QgskWhCvORaFVayRaEK02WQjJH2KbeS1b5JasiZ275TETM7Q9B3B2FZW5XWx4XNJQi+ajzbZweI6muSYpTpD0nC9JbFE3v1l6FFZI5jrvoAAAAhuw6lzQGh2puxTd2oRb78tfcy482TH4J2Ycunx5fHWJczjtxFq6pyj4NcSN/HxTJHiiJ+jm5eD4reCZj6tNiN0cVDs8M16xZt04pinxRMNK/' + 
                'Bs0eGYn6Kc9kYmHaql6ameutwW/E1b8P1Nfw+zD4c49qMo+cWjNGSlukx7te2LJXxVmPlKSFhOykTCaEyJhZNGZXY3ZqZGyd33jGyd3xzGyN2Epk7CKUydkIJzLRCJlC23os2+5LNkzMR1RETbp3sobNxFnYqm/OOX1MVtVhr1tDYpotRfpSV7Dbo4qfaUYLxeb9ka1+KYY8O8tzHwfNbxTEN5gdwlo7Zyl4JcKNPJxTJPhjb6t7FwbFXxzM/' + 
                'R0+zN2aKexCKfflnL3NDJnyZPFO7pYtPixeCsQ3lVKjyMTMlAAAAAAAA+OKAjlRF9AIp4GD6ICCeyYPovYCtbsCqXOMX5xRaL2jpKtqVt1iFWe69L/2R9FkZI1GWPxT7sM6XBPWkeyGW6dX4cvcvGszR+JSdBp5/BCKW6Vfj7stGuzeqk8N08/h+rF7pQ/m92T9vzev0V/4vTek+8vi3Rh/N+Zk/b83r9D/i9N6T7yyW6Nfc/dkfbs/qmOGab/r9U0N0qesE/' +
                'PMpOszz+JeNBp4/BCzVuxQv+OH5UzHOfLPW0+7LXTYa9KR7LtWxq48opeiMczM9WaIiOizDAQXREJTxoiugGaigPoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP//Z';
        
        return fileContents;
    
    }
    
    public static Note createNote(string accountId, string noteBody){
        
        Note note = new Note(ParentId = accountId,
                                        Title = 'Account Note',
                                        Body = noteBody);
        return note;
    }// end of createNote
    
    public static List<Practitioner_Procedure_Products__c> createPrefCardProducts(string productId, string pracProcedureId){
        
        Practitioner_Procedure_Products__c ppProduct = new Practitioner_Procedure_Products__c();
        ppProduct.Product__c = productId;
        ppProduct.Practitioner_Procedure__c = pracProcedureId;
        
        list<Practitioner_Procedure_Products__c> lstPractProcedureProducts = new list<Practitioner_Procedure_Products__c>();   
        lstPractProcedureProducts.add(ppProduct);
        
        return lstPractProcedureProducts;
    }// end of createNote
    
    public static Campaign createCampaign(string campaignName){
        Campaign campaign = new Campaign();
        campaign.name = campaignName;
        return campaign;
    }
    
    public static Conference__c createConference(string conferenceName){
        Conference__c  conference = new Conference__c  ();
        conference.name = conferenceName;
        return conference;
    }
    
}