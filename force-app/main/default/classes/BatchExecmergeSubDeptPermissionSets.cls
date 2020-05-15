//Name                   :  BatchExecmergeSubDeptPermissionSets
//Created by             :  
/////////////////////////////////////////////////////////////////////
global class BatchExecmergeSubDeptPermissionSets implements Database.Batchable<sObject>{    
    global String Query;
  private String currentDepartment; 
    public integer intTotalUsers {get; set;}
  PermissionSet permissionSetSO;
    List<FieldPermissions> erroredfieldPermissionList;
    List<ObjectPermissions> erroredObjectPermissionList;
    
    public BatchExecmergeSubDeptPermissionSets() {
        erroredfieldPermissionList = new List<FieldPermissions>();
        erroredObjectPermissionList = new List<ObjectPermissions>();
    }
    
    global List<SObject> start(Database.BatchableContext BC){
        query = 'select count(id), Sub_Department__c dept from User where UserType = \'Standard\' and isActive = true and EmployeeNumber != null and Sub_Department__c != null group by Sub_Department__c Limit 2000';
        List<User> userList = new List<User>();
        for(aggregateResult agr : Database.query(query)) {
            system.debug(string.valueOf(agr.get('dept')));
            User obj = new User(Sub_Department__c = string.valueOf(agr.get('dept')));
            userList.add(obj);
        }
        system.debug(userList.size());
        return userList;
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        system.debug('%%%%%%%%'+scope.size());
    List<User> userList = scope;
    currentDepartment = string.valueOf(userList[0].Sub_Department__c);
        currentDepartment = currentDepartment.replace(' & ', '_');
        currentDepartment = currentDepartment.replace('&', '_');
        currentDepartment = currentDepartment.replace(' - ', '_');
        currentDepartment = currentDepartment.replace(' ', '_');
        String permissionSetName = 'Rice_'+currentDepartment+'_SubDepartment';
        List<PermissionSet> permissionSetList = [SELECT Id, Name from PermissionSet WHERE Name = :permissionSetName limit 1];
        
    if(null == permissionSetList
            || permissionSetList.size() == 0) {
      List<Userlicense> lstuserlicense = [SELECT id, name from Userlicense where Name = 'Salesforce' LIMIT 1];
            if(!lstuserlicense.isEmpty()){
                permissionSetSO = new PermissionSet();
                permissionSetSO.Name = permissionSetName;
                permissionSetSO.Label = permissionSetName;
                permissionSetSO.LicenseId = lstuserlicense[0].id;                
                insert permissionSetSO;
            }
    } else {
      permissionSetSO = permissionSetList[0];
    }
    
        createSubDepartmentPS(permissionSetSO);
    }   
    
    // This method is used to create RICE ALL Users Permission Set
    public void createSubDepartmentPS(PermissionSet permissionSetSO){
  
    //query on user to get total user by department
    Map<Id, User> usermapById = new Map<Id, User>([select Id from User where UserType = 'Standard' and isActive = true and  profile.UserLicenseId = '10050000000IuuOAAS' and EmployeeNumber != '' and Sub_Department__c = :currentDepartment]);
    intTotalUsers = usermapById.size();
    
    //query to get permission sets where assigned users are more then 60%
    // 60% of 555 = 333
        Integer intSixtyPercent = 0;
        if(intTotalUsers > 0){
            intSixtyPercent = (60 * intTotalUsers)/100;
        }
    
    //get List of PermissionSet having more then 60% assignment
    List<AggregateResult> lstAggregateResult = [SELECT count(AssigneeId) totalUsers, PermissionSetId psId, PermissionSet.Name psName from PermissionsetAssignment Where AssigneeId = :usermapById.keySet() group by PermissionSetId, PermissionSet.Name];
        
        Set<Id> permissionSetIds = new Set<Id>();        
        for(AggregateResult agr: lstAggregateResult){
            if(integer.valueOf(agr.get('totalUsers')) >= intSixtyPercent){
                permissionSetIds.add(string.valueOf(agr.get('psId')));
        
            }
        }
        
    Map<String,Id> mapExistingObjPSId = new Map<String,Id>();
        Map<String,FieldPermissions> mapExistingFieldPSId = new Map<String,FieldPermissions>();
        Map<String,Id> mapExistingSetupEntityPSId = new Map<String,Id>();
        
        List<PermissionSet> lstALLUsersPS = [SELECT id,  (SELECT id, SobjectType FROM ObjectPerms),(SELECT SobjectType, Field, PermissionsRead, PermissionsEdit FROM FieldPerms), (SELECT id, SetupEntityId from SetupEntityAccessItems) from PermissionSet WHERE Id =: permissionSetSO.Id LIMIT 1];
        if(!lstALLUsersPS.isEmpty()){                       
            for(ObjectPermissions op: lstALLUsersPS[0].ObjectPerms){
                mapExistingObjPSId.Put(op.SobjectType, op.id);
            }
            
            for(FieldPermissions fp: lstALLUsersPS[0].FieldPerms){
                mapExistingFieldPSId.Put(fp.Field, fp);
            }
            
            for(SetupEntityAccess sea: lstALLUsersPS[0].SetupEntityAccessItems){
                mapExistingSetupEntityPSId.Put(sea.SetupEntityId, sea.id);
            }
        }
    
    List<ObjectPermissions> lstObjectPermissionsInsert = new List<ObjectPermissions>();
    List<FieldPermissions> lstFieldPermissionsInsert = new List<FieldPermissions>();
    List<SetupEntityAccess> lstSetupEntityAccessInsert = new List<SetupEntityAccess>();
      
    Map<String, ObjectPermissions> mapExistingObjPerm = new Map<String, ObjectPermissions>();
    Map<String, FieldPermissions> mapExistingFieldPerm = new Map<String, FieldPermissions>();
    Map<String, SetupEntityAccess> mapExistingSetupEntity = new Map<String, SetupEntityAccess>();
    
    if(0 < permissionSetIds.size()) {
      Map<Id, List<ObjectPermissions>> objectPermissionsByParentId = new Map<Id, List<ObjectPermissions>>();
      for(ObjectPermissions objectPermissionsObj :[SELECT 
                              PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, 
                              PermissionsViewAllRecords, PermissionsModifyAllRecords, SobjectType, ParentId
                            FROM ObjectPermissions 
                            where ParentId = :permissionSetIds]) {
        
        List<ObjectPermissions> ObjectPermissionsList = objectPermissionsByParentId.get(objectPermissionsObj.ParentId);                                        
        if(null == ObjectPermissionsList) {
          ObjectPermissionsList = new List<ObjectPermissions>();
                    objectPermissionsByParentId.put(objectPermissionsObj.ParentId, ObjectPermissionsList);
        }
        ObjectPermissionsList.add(objectPermissionsObj);
        
      }
            
      Map<Id, List<FieldPermissions>> fieldPermissionsByParentId = new Map<Id, List<FieldPermissions>>();
      for(FieldPermissions fieldPermissionsObj :[SELECT 
                              Field, Parent.PermissionsTransferAnyLead, PermissionsRead, 
                              PermissionsEdit, Parentid, SobjectType 
                            FROM FieldPermissions WHERE ParentId = :permissionSetIds]) {
                                                            
        List<FieldPermissions> fieldPermissionsList = fieldPermissionsByParentId.get(fieldPermissionsObj.ParentId);                                        
        if(null == fieldPermissionsList) {
          fieldPermissionsList = new List<FieldPermissions>();
          fieldPermissionsByParentId.put(fieldPermissionsObj.ParentId, fieldPermissionsList);
        }
        fieldPermissionsList.add(fieldPermissionsObj);
        
      }
        
      Map<Id, List<SetupEntityAccess>> setupEntityAccessByParentId = new Map<Id, List<SetupEntityAccess>>();
      for(SetupEntityAccess setupEntityAccessObj :[SELECT 
                              Id, ParentId, Parent.Name, SetupEntityId, SetupEntityType 
                            FROM SetupEntityAccess WHERE ParentId =: permissionSetIds]) {
                            
        List<setupEntityAccess> setupEntityAccessList = setupEntityAccessByParentId.get(setupEntityAccessObj.ParentId);                                        
        if(null == setupEntityAccessList) {
          setupEntityAccessList = new List<setupEntityAccess>();
          setupEntityAccessByParentId.put(setupEntityAccessObj.ParentId, setupEntityAccessList);
        }
        setupEntityAccessList.add(setupEntityAccessObj);
        
      }
    
      for(Id psId: permissionSetIds){
        // Get Custom Object Permissions                
        List<ObjectPermissions> lstObjectPermissions = objectPermissionsByParentId.get(psId);
        
        // Get Custom Field Permissions
        List<FieldPermissions> lstFieldPermissions = fieldPermissionsByParentId.get(psId);
      
        // Get Apex Class, Visualforce Page, Tab Setting Permissions
        List<SetupEntityAccess> lstSetupEntityAccess = setupEntityAccessByParentId.get(psId);
          
        // Provide Custom Object Permissions - Child and Individual Object
        if(lstObjectPermissions != null) {
        for(ObjectPermissions op: lstObjectPermissions){
                
          if(op.PermissionsRead || op.PermissionsCreate || op.PermissionsEdit || op.PermissionsDelete || op.PermissionsViewAllRecords || op.PermissionsModifyAllRecords){
            if(mapExistingObjPerm.containsKey(op.SobjectType) == false){
              ObjectPermissions objP = new ObjectPermissions();
              objP = assignCustomObjPermissions(new ObjectPermissions(), op, mapExistingObjPSId.get(op.SobjectType), permissionSetSO.Id);                            
              system.debug('$$$$$$$$$$$$$'+objP);
              mapExistingObjPerm.Put(op.SobjectType, objP);             
              lstObjectPermissionsInsert.add(objP);
              
            }else if(mapExistingObjPerm.containsKey(op.SobjectType)){
              ObjectPermissions objP = mapExistingObjPerm.get(op.SobjectType);
              objP = assignCustomObjPermissions(objP, op, mapExistingObjPSId.get(op.SobjectType), permissionSetSO.Id);                            
                                    
            }                        
          }
        }
        }
          
        // Provide Custom Field Permissions
        if(lstFieldPermissions != null) {
                    
        for(FieldPermissions fp: lstFieldPermissions){
                    //check the existing permission and skip if they are same
                    FieldPermissions oldFP = mapExistingFieldPSId.get(fp.Field);
                    if(oldFP != null
                      && oldFP.PermissionsEdit == fp.PermissionsEdit
                      && oldFP.PermissionsRead == fp.PermissionsRead) {
                        continue;
                    }
                    //if(fp.Field == 'UserId') { continue; }
          if(fp.PermissionsRead || fp.PermissionsEdit){
            if(mapExistingFieldPerm.containsKey(fp.Field) == false){
              FieldPermissions objFP = new FieldPermissions();
                            objFP = assignCustomFieldPermissions(objFP, fp, (oldFP == null ? null : oldFP.Id), permissionSetSO.Id);                            
              mapExistingFieldPerm.Put(fp.Field, objFP);
              system.debug('@@@@@@@@@@@@'+objFP);                            
              lstFieldPermissionsInsert.add(objFP);
            }else if(mapExistingFieldPerm.containsKey(fp.Field)){      
              FieldPermissions objFP = mapExistingFieldPerm.get(fp.Field);
              objFP = assignCustomFieldPermissions(objFP, fp, (oldFP == null ? null : oldFP.Id), permissionSetSO.Id);                                                  
            }
           }
        }   
        }
        
        // Provide Apex Class, Visualforce Page, Tab Setting Permissions
        if(lstSetupEntityAccess != null) {
        for(SetupEntityAccess sea: lstSetupEntityAccess){
           
           if(mapExistingSetupEntity.containsKey(sea.SetupEntityId) == false && mapExistingSetupEntityPSId.containsKey(sea.SetupEntityId) == false){
             SetupEntityAccess objSEA = new SetupEntityAccess();
             objSEA.ParentId = permissionSetSO.Id;
             objSEA.SetupEntityId = sea.SetupEntityId;
             mapExistingSetupEntity.Put(sea.SetupEntityId, objSEA);
             lstSetupEntityAccessInsert.add(objSEA);
           }
        }
        }
      }
      
      system.debug('#############'+lstObjectPermissionsInsert);
            
      if(!lstObjectPermissionsInsert.isEmpty()){
                
        //upsert lstObjectPermissionsInsert;
        
        //Schema.SObjectField f = ObjectPermissions.Fields.Id;
        List<Database.upsertResult> results = database.upsert(lstObjectPermissionsInsert, false);
                for(Integer i = 0; i < results.size(); i++) {
                    if(results[i].isSuccess()) {
                        continue;
                    }
                    erroredObjectPermissionList.add(lstObjectPermissionsInsert[i]);
                }
      }
      
      system.debug('#############'+lstFieldPermissionsInsert);
      if(!lstFieldPermissionsInsert.isEmpty()){
                List<Database.upsertResult> results = database.upsert(lstFieldPermissionsInsert, false);
                
                for(Integer i = 0; i < results.size(); i++) {
                    if(results[i].isSuccess()) {
                        continue;
                    }
                    erroredfieldPermissionList.add(lstFieldPermissionsInsert[i]);
                }
                
      }
      
      system.debug('#############'+lstSetupEntityAccessInsert);
      if(!lstSetupEntityAccessInsert.isEmpty()){
        insert lstSetupEntityAccessInsert;
      }            
        }
        
    }
    
    public ObjectPermissions assignCustomObjPermissions(ObjectPermissions objP, ObjectPermissions op, String strId, String strPSParentId){
        if(strId != '' && strId != null){
            objP.Id = strId;
        }else{
            if(objP.ParentId == null && objP.Id == null){
                objP.ParentId = strPSParentId;
            }
            if(objP.SobjectType == '' || objP.SobjectType == null){
                objP.SobjectType = op.SobjectType;
            } 
        }
        if(op.SobjectType == 'Idea' || op.SobjectType == 'Product2'){
            system.debug('!!!!!!!!!!'+op);
        }
        if(op.PermissionsRead){
            objP.PermissionsRead = op.PermissionsRead;
        }
        if(op.PermissionsCreate){
            objP.PermissionsCreate = op.PermissionsCreate;
        }
        if(op.PermissionsEdit){
            objP.PermissionsEdit = op.PermissionsEdit;
        }
        if(op.PermissionsDelete){
            objP.PermissionsDelete = op.PermissionsDelete;
        }
        if(op.PermissionsViewAllRecords){
            objP.PermissionsViewAllRecords = op.PermissionsViewAllRecords;
        }
        if(op.PermissionsModifyAllRecords){
            objP.PermissionsModifyAllRecords = op.PermissionsModifyAllRecords;
        }
        
        return objP;
    }
    
    
    public FieldPermissions assignCustomFieldPermissions(FieldPermissions objFP, FieldPermissions fp, String strId, String strPSParentId){
        
        if(strId != '' && strId != null){
            objFP.Id = strId;
        }else{
            if(objFP.ParentId == null && objFP.Id == null){
                objFP.ParentId = strPSParentId;
            }
            if(objFP.SobjectType == '' || objFP.SobjectType == null){
                objFP.SobjectType = fp.SobjectType;
            }
            if(objFP.Field == '' || objFP.Field == null){
                objFP.Field = fp.Field;
            }
        }
        
        system.debug('%%%%%%%%%%%'+objFP.Parentid);
       
        if(objFP.Field == ''){
            
            objFP.Field = fp.Field;
        }                      
        if(fp.PermissionsRead){
            objFP.PermissionsRead = fp.PermissionsRead;
        }
        if(fp.PermissionsEdit){
            objFP.PermissionsEdit = fp.PermissionsEdit;
        }
        
        return objFP;
    }
    
    
    global void finish(Database.BatchableContext BC){
      upsert erroredObjectPermissionList;
        upsert erroredfieldPermissionList;
    }
}