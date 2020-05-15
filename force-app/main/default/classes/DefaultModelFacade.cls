/*
  * @auther : Srinivas Sattoor, Cloud Sherpas Inc.
  * @date : 03/18/2016
  * @description : This is the facade class for default model.
  */
public class DefaultModelFacade {

    /*
     * @auther : Srinivas Sattoor, Cloud Sherpas Inc.
     * @date : 03/18/2016
     * @description : The facade class for set default owner.
     * @parameters : objList - List of objects.
     * @returns : none
     */
 
    public static void setDefaultOwner(List<SObject> objList) {
        
        try {
            if (objList == null || objList.size() == 0) return;
            
            system.debug('##--setDefaultOwner.objList: '+ objList);
            
            DefaultAbstract defaultImpl = DefaultObjFactory.build(objList[0].id);
           // defaultImpl.setDefaultOwner(objList);  
                
        } catch (DmlException dmle) {
            for(Object obj : objList) {
                ((sObject)obj).addError(dmle.getDmlMessage(0));
            }
        }   
    }
    
   
}