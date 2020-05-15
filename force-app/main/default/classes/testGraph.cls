@isTest
public class testGraph{
    private static testmethod void testGraph(){ 
        RecordType objRecordType = [select id from RecordType where DeveloperName ='Employee_Relations'];
        Case c = new Case();
        c.status ='New';
        insert c;
        
        Case c1 = new Case();
        c1.status ='Working';
        insert c1;
        
        Case c2 = new Case();
        c2.status ='Escalated';
        insert c2;
        
        Case c3 = new Case();
        c3.status ='Closed';
        insert c3;
        
        Graph controller = new Graph();
        List<Graph.barWedgeData> lst =  controller.getBarchartData();
    }
    
}