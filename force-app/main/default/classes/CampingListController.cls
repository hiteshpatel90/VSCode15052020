public class CampingListController {
  
  @auraenabled
  public static List<Camping_Item__c> getItems(){
    List<Camping_Item__c> listCampingItem = [SELECT Id, name,price__c,Quantity__c,Packed__c FROM Camping_Item__c ];
    return listCampingItem;
  }
  
  @auraenabled
  public static Camping_Item__c saveItem(Camping_Item__c objCampingItem){
    insert objCampingItem;
    return objCampingItem;
  }
}