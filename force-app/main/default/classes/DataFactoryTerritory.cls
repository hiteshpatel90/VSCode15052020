public with sharing class DataFactoryTerritory {
    
    public static void setUpTerritoryForTestClasses(){
        
        list<Territory2Type> lstterritoryType   = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Arthrex'];
        //Note : DML is not allowed for Territory2Type but you can perform DML on Territory2Model.
        
        Territory2Model terrModel = new Territory2Model(DeveloperName='TestModelName', Name='TestModelName');
        insert terrModel ;
        
        
         Territory2 objAgencyTerritory = new Territory2(DeveloperName = 'TestAgencyTerritory', 
                                                    Territory2ModelId=terrModel.Id, 
                                                    Name='TestAgencyTerritory',  
                                                    Territory2TypeId=lstterritoryType[0].Id);
         insert objAgencyTerritory;
         
         Territory2 objTeamTerritory1 = new Territory2(DeveloperName = 'TestTeamTerritory1', 
                                                Territory2ModelId=terrModel.Id, 
                                                Name='TestTeamTerritory1',  
                                                PARENTTERRITORY2ID = objAgencyTerritory.Id,
                                                Territory2TypeId=lstterritoryType[0].Id,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
         insert objTeamTerritory1;
         
         Territory2 objTeamTerritory2 = new Territory2(DeveloperName = 'TestTeamTerritory2', 
                                                Territory2ModelId=terrModel.Id, 
                                                Name='TestTeamTerritory2',  
                                                PARENTTERRITORY2ID = objAgencyTerritory.Id,
                                                Territory2TypeId=lstterritoryType[0].Id,
                                                ACCOUNTACCESSLEVEL ='Edit',
                                                OPPORTUNITYACCESSLEVEL = 'Edit',
                                                CASEACCESSLEVEL = 'Edit');
         insert objTeamTerritory2;

    }// end of createHealthCareProviderAccount
    
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
    
}