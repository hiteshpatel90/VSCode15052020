/**@@
#APEX CLASS NAME       :    matrixDemoController
#DESCRIPTION           :    Display matrix on lightning component
@@**/
public class matrixDemoController{
    /**@@
    #DESCRIPTION     : Fetch Column information
    #Paramaters      : None
    @@**/
    @AuraEnabled
    public static List<wrapperListColumn> getColumnList() {
        List<wrapperListColumn> wrapperColumn = new List<wrapperListColumn>();
        wrapperListColumn objWC = new wrapperListColumn();
        objWC.strColumnName = 'FI';
        wrapperColumn.add(objWC);
        
        objWC = new wrapperListColumn();
        objWC.strColumnName = 'MM';
        wrapperColumn.add(objWC);
        
        objWC = new wrapperListColumn();
        objWC.strColumnName = 'IRD';
        wrapperColumn.add(objWC);
        
        objWC = new wrapperListColumn();
        objWC.strColumnName = 'SRT';
        wrapperColumn.add(objWC);
        
        objWC = new wrapperListColumn();
        objWC.strColumnName = 'CMP';
        wrapperColumn.add(objWC);
        
        objWC = new wrapperListColumn();
        objWC.strColumnName = 'RMG';
        wrapperColumn.add(objWC);
        
        objWC = new wrapperListColumn();
        objWC.strColumnName = 'GCF';
        wrapperColumn.add(objWC);
        
        return wrapperColumn;
    }
    
    /**@@
    #DESCRIPTION     : Fetch Row information
    #Paramaters      : None
    @@**/
    @AuraEnabled
    public static List<wrapperListRow> getRowList() {
        List<wrapperListRow> wrapperRow = new List<wrapperListRow>();
        wrapperListRow objWR = new wrapperListRow();
        objWR.strRowName = 'Coverage Name';
        wrapperRow.add(objWR);
        
        objWR = new wrapperListRow();
        objWR.strRowName = 'CIBC Ranking';
        wrapperRow.add(objWR);
        
        objWR = new wrapperListRow();
        objWR.strRowName = 'Main Activities';
        wrapperRow.add(objWR);
        
        objWR = new wrapperListRow();
        objWR.strRowName = 'Relationship Activities';
        wrapperRow.add(objWR);
        
        objWR = new wrapperListRow();
        objWR.strRowName = 'Major Roadblocks/Challenges';
        wrapperRow.add(objWR);
        
        objWR = new wrapperListRow();
        objWR.strRowName = 'Discussion for Management';
        wrapperRow.add(objWR);
        
        objWR = new wrapperListRow();
        objWR.strRowName = 'Other Comments';
        wrapperRow.add(objWR);
        
        return wrapperRow;
    }
    
    
    /**@@
    #DESCRIPTION     : Wrapper Class for Column
    #Paramaters      : None
    @@**/
    public class wrapperListColumn{
        @AuraEnabled
        public string strColumnName;
        
    }
    
    /**@@
    #DESCRIPTION     : Wrapper Class for Row
    #Paramaters      : None
    @@**/
    public class wrapperListRow{
        @AuraEnabled
        public string strRowName;
    }
}