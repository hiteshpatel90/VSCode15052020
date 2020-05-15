//Name                   :  BatchExecmergePermissionSets
//Created by             :  
/////////////////////////////////////////////////////////////////////
global without sharing class BatchExecmergePermissionSets implements Database.Batchable<sObject>{    
    global String Query;
    global String strPermissionSetId; 
    set<Id> sPermissionId;
    List<FieldPermissions> erroredfieldPermissionList;
    List<ObjectPermissions> erroredObjectPermissionList;
    
    global BatchExecmergePermissionSets(String strPSId, set<Id> sPermissionIdParam){    
        
        this.strPermissionSetId = strPSId;
        sPermissionId = sPermissionIdParam;
        erroredfieldPermissionList = new List<FieldPermissions>();
        erroredObjectPermissionList = new List<ObjectPermissions>();
       
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT id, name from Permissionset where id IN: sPermissionId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<PermissionSet> lstPs = [SELECT id from PermissionSet WHERE id in: sPermissionId];
        //List<PermissionSet> lstPs = [SELECT id from PermissionSet WHERE id = '0PSi00000011IXO'];
        
        createRiceALLUsersPS(lstPs);
        
    }   
    
    // This method is used to create RICE ALL Users Permission Set
    public void createRiceALLUsersPS(List<PermissionSet> lstPermissionSets){
        
        Map<String,Id> mapExistingObjPSId = new Map<String,Id>();
        Map<String,FieldPermissions> mapExistingFieldPSId = new Map<String,FieldPermissions>();
        Map<String,Id> mapExistingSetupEntityPSId = new Map<String,Id>();
        List<PermissionSet> lstALLUsersPS = [SELECT id,  (SELECT id, SobjectType FROM ObjectPerms),(SELECT SobjectType, Field, PermissionsRead, PermissionsEdit FROM FieldPerms), (SELECT id, SetupEntityId from SetupEntityAccessItems) from PermissionSet WHERE id =: strPermissionSetId];
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
        system.debug('################'+lstPermissionSets);
        //sPermissionId.add('0PSi0000000NmQk');
        if(!lstPermissionSets.isEmpty()){
            system.debug('@@@@@@@@@'+lstPermissionSets.size());
            
            Set<Id> permissionSetIDs = new Set<Id>();
            for(PermissionSet permissionSetObj :lstPermissionSets) {
                permissionSetIDs.add(permissionSetObj.Id);
            }         
            
            List<ObjectPermissions> lstObjectPermissionsInsert = new List<ObjectPermissions>();
            List<FieldPermissions> lstFieldPermissionsInsert = new List<FieldPermissions>();
            List<SetupEntityAccess> lstSetupEntityAccessInsert = new List<SetupEntityAccess>();
             
            Map<String, ObjectPermissions> mapExistingObjPerm = new Map<String, ObjectPermissions>();
            Map<String, FieldPermissions> mapExistingFieldPerm = new Map<String, FieldPermissions>();
            Map<String, SetupEntityAccess> mapExistingSetupEntity = new Map<String, SetupEntityAccess>();
            
            Map<Id, List<ObjectPermissions>> objectPermissionsByParentId = new Map<Id, List<ObjectPermissions>>();
            for(ObjectPermissions objectPermissionsObj :[SELECT 
                                                            PermissionsRead, ParentId, PermissionsCreate, PermissionsEdit, PermissionsDelete, 
                                                            PermissionsViewAllRecords, PermissionsModifyAllRecords, SobjectType
                                                        FROM ObjectPermissions 
                                                        where ParentId =: permissionSetIDs]) {
                                                        
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
                                                        FROM FieldPermissions WHERE ParentId =: permissionSetIDs]) {
                                                        
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
                                                        FROM SetupEntityAccess WHERE ParentId =: permissionSetIDs]) {
                                                        
                List<setupEntityAccess> setupEntityAccessList = setupEntityAccessByParentId.get(setupEntityAccessObj.ParentId);                                        
                if(null == setupEntityAccessList) {
                    setupEntityAccessList = new List<setupEntityAccess>();
                    setupEntityAccessByParentId.put(setupEntityAccessObj.ParentId, setupEntityAccessList);
                }
                setupEntityAccessList.add(setupEntityAccessObj);
                
            }    

            for(PermissionSet ps: lstPermissionSets){
            
                // Get Custom Object Permissions                
                List<ObjectPermissions> lstObjectPermissions = objectPermissionsByParentId.get(ps.Id);//[SELECT PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords, SobjectType FROM ObjectPermissions where ParentId =: ps.id];
                
                // Get Custom Field Permissions
                List<FieldPermissions> lstFieldPermissions = fieldPermissionsByParentId.get(ps.Id);//[SELECT Field, Parent.PermissionsTransferAnyLead, PermissionsRead, PermissionsEdit, Parentid, SobjectType FROM FieldPermissions WHERE ParentId =: ps.id];
            
                // Get Apex Class, Visualforce Page, Tab Setting Permissions
                List<SetupEntityAccess> lstSetupEntityAccess = setupEntityAccessByParentId.get(ps.Id);//[SELECT Id, ParentId, Parent.Name, SetupEntityId, SetupEntityType FROM SetupEntityAccess WHERE ParentId =: ps.id];
            
                // Provide Custom Object Permissions - Child and Individual Object
                if(lstObjectPermissions != null && !lstObjectPermissions.isEmpty()){
                    for(ObjectPermissions op: lstObjectPermissions){
                        if(op.PermissionsRead || op.PermissionsCreate || op.PermissionsEdit || op.PermissionsDelete || op.PermissionsViewAllRecords || op.PermissionsModifyAllRecords){
                            if(mapExistingObjPerm.containsKey(op.SobjectType) == false){
                                ObjectPermissions objP = new ObjectPermissions();
                                objP = assignCustomObjPermissions(new ObjectPermissions(), op, mapExistingObjPSId.get(op.SobjectType), strPermissionSetId);                            
                                system.debug('$$$$$$$$$$$$$'+objP);
                                mapExistingObjPerm.Put(op.SobjectType, objP);             
                                lstObjectPermissionsInsert.add(objP);
                                
                            }else if(mapExistingObjPerm.containsKey(op.SobjectType)){
                                ObjectPermissions objP = mapExistingObjPerm.get(op.SobjectType);
                                objP = assignCustomObjPermissions(objP, op, mapExistingObjPSId.get(op.SobjectType), strPermissionSetId);                            
                                                                            
                            }                        
                        }
                }
                }
                
                // Provide Custom Field Permissions
                if(lstFieldPermissions != null && !lstFieldPermissions.isEmpty()){
                    for(FieldPermissions fp: lstFieldPermissions){
                        FieldPermissions oldFP = mapExistingFieldPSId.get(fp.Field);
                        if(oldFP != null
                          && oldFP.PermissionsEdit == fp.PermissionsEdit
                          && oldFP.PermissionsRead == fp.PermissionsRead) {
                            continue;
                        }
                        if(fp.PermissionsRead || fp.PermissionsEdit){
                            if(mapExistingFieldPerm.containsKey(fp.Field) == false){
                                FieldPermissions objFP = new FieldPermissions();
                                objFP = assignCustomFieldPermissions(objFP, fp, (oldFP == null ? null : oldFP.Id), strPermissionSetId);                            
                                
                                mapExistingFieldPerm.Put(fp.Field, objFP);
                                system.debug('@@@@@@@@@@@@'+objFP);                            
                                lstFieldPermissionsInsert.add(objFP);
                            }else if(mapExistingFieldPerm.containsKey(fp.Field)){      
                                FieldPermissions objFP = mapExistingFieldPerm.get(fp.Field);
                                objFP = assignCustomFieldPermissions(objFP, fp, (oldFP == null ? null : oldFP.Id), strPermissionSetId);                                                  
                            }
                         }
                     }
                 }
                 
                 // Provide Apex Class, Visualforce Page, Tab Setting Permissions
                 if(lstSetupEntityAccess != null && !lstSetupEntityAccess.isEmpty()){
                     for(SetupEntityAccess sea: lstSetupEntityAccess){
                         
                         if(mapExistingSetupEntity.containsKey(sea.SetupEntityId) == false && mapExistingSetupEntityPSId.containsKey(sea.SetupEntityId) == false){
                             SetupEntityAccess objSEA = new SetupEntityAccess();
                             objSEA.ParentId = strPermissionSetId;
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