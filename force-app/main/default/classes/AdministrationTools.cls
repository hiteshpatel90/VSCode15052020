public with sharing class AdministrationTools {
    public static PageReference startLocalTests() {
        List<List<ApexClass>> searchList = [FIND '@isTest' IN ALL FIELDS RETURNING ApexClass (Id WHERE NamespacePrefix = NULL AND Status = 'Active')];
        ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
        for(ApexClass myResults : searchList[0]) {
            queueItems.add(new ApexTestQueueItem(ApexClassId=myResults.Id));
        }
        insert queueItems;
        PageReference newocp = new PageReference('/ui/setup/apex/ApexTestQueuePage');
        newocp.setRedirect(true);
        return newocp;
    }
}