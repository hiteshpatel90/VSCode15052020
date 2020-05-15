public class bigQueryIntegration{
    //String projectId = 'bigquery-sf-muenzpraeger';
    String projectId = 'focal-balm-132023';
    String datasetId = 'OrderHistory';
    String tableId = 'Salesforce';
    
    
    public List<wrapperQueryData> lstWrapperQueryData {get; set;}
    
    public bigQueryIntegration(){
    
        
        lstWrapperQueryData = new List<wrapperQueryData>();
        wrapperQueryData objWQD;
        
        
    }
    
    public void insertToBigQuery(){
        
        String orderId = '8010H000001qJoJ';
        
        // Get Order record
        List<Order> orders = [SELECT OrderNumber, Status, TotalAmount FROM Order Where Id =: orderId];
        
        if (orders.size()>0) {
            // Setup connector
            GoogleBigQuery google = new GoogleBigQuery(projectId, datasetId, tableId);
            GoogleBigQuery.InsertAll insertAll = new GoogleBigQuery.InsertAll();
            system.debug('@@@@@@@@@@@@@@@@@@'+insertAll);
            insertAll.addObject(orders.get(0));
            if (!google.add(insertAll)) {
               System.debug('Error: ' + google.getResponse());
            }
        }
    }
    
    public class wrapperQueryData{
        public string strArtistName {get; set;}
        public string strReleaseName {get; set;}
        public string strReleaseType {get; set;}
        public string strReleaseDate {get; set;}
        public string strReleaseOwner {get; set;}
        public string strGenre {get; set;}
        public string strMAU {get; set;}
        public decimal FansorFollowers {get; set;}
        public decimal InstagramFollowers {get; set;}
        public string strCompetition {get; set;}
        public string strCulturalRelevance {get; set;}
        public string strRelationship {get; set;}
        public string strContextTotal {get; set;}
        public string strReturns {get; set;}
        public string strWeightedScore {get; set;}
        public string strScore {get; set;}
        public string strMarquee {get; set;}
        public string strHomeBanner {get; set;}
        public string strCRMEmail {get; set;}
        
        public string strPHPTO {get; set;}
        public string strNMFBillboardNYC {get; set;}        
    }
}