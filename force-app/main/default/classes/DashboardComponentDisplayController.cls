public class DashboardComponentDisplayController{
   public String selectedComponent {get;set;}
   public boolean showframe {get;set;}
   public boolean showPieChart{get;set;}
   public boolean showbarGraphType {get;set;}
   public boolean showVolumeByLOB {get;set;}
   public boolean showVolumeByOwner {get;set;}
   public boolean showVolumeByCountry {get;set;}
   public boolean showVolumeCaseStatus {get;set;}
   public boolean showVolumeByLastIssuedOutcome {get;set;}
   
   public String selected {get;set;}
   public boolean showAll {get;set;}
   public boolean showVolumeByCaseOpenLastMonth{get;set;}
   public boolean showVolumeByLastIssuedOutcomeLastMonth{get;set;}
   public boolean showVolumebyOwnerLastmonth{get;set;}
   
   public DashboardComponentDisplayController(){
           selectedComponent ='';
           showframe = false;
           showPieChart = false;
           showbarGraphType = false;
           showVolumeByLOB = false;
           showVolumeByOwner = false;
           showVolumeByCountry = false;
           showVolumeCaseStatus = false;
           showVolumeByLastIssuedOutcome=false;
           
           selected ='';
           showAll = false;
           showVolumeByCaseOpenLastMonth = false;
           showVolumeByLastIssuedOutcomeLastMonth = false;
           showVolumebyOwnerLastmonth = false;
       }
   
   
   public list<SelectOption> getRecordTypes(){
        list<SelectOption> options = new list<SelectOption>();
        if(selected =='ER Case Volume Summary Dashboard - Current Year'){
            options.add(new SelectOption('--None--', '--None--'));
            options.add(new SelectOption('VolumeByOwner', 'Volume By Owner'));
            options.add(new SelectOption('PieChart', 'Volume by Source Initiation'));
            options.add(new SelectOption('VolumeCaseStatus', 'Volume Case Status'));
            options.add(new SelectOption('barGraphType', 'Volume By Type'));
            options.add(new SelectOption('VolumeByCountry', 'Volume By Country'));
            options.add(new SelectOption('VolumeByLastIssuedOutcome', 'Volume by Last Issued Outcome'));
            options.add(new SelectOption('VolumebyLOB', 'Volume by LOB'));
        }else{
            options.add(new SelectOption('--None--', '--None--'));
            options.add(new SelectOption('VolumebyOwnerLastmonth', 'Case Volume by Owner for Last Month'));
            options.add(new SelectOption('VolumeByCaseOpenLastMonth', 'Types of Cases Opened Last Month'));
            options.add(new SelectOption('VolumeByLastIssuedOutcomeLastMonth', 'Outcomes for Closed Cases Last Month'));
            
        }        
        return options;        
    }
    public list<SelectOption> getTypes(){
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('--None--', '--None--'));
        options.add(new SelectOption('ER Case Volume Summary Dashboard - Current Year', 'ER Case Volume Summary Dashboard - Current Year'));
        options.add(new SelectOption('ER Monthly ScoreCard', 'ER Monthly ScoreCard'));
                
        return options;
      
    }  
   
    public void Component(){              
        showAll = true;
        selectedComponent = null;
        updateComponent();
    }      
   public void updateComponent(){
       showframe = true;
       showPieChart = false;
       showbarGraphType = false;
       showVolumeByLOB = false;
       showVolumeByOwner = false;
       showVolumeByCountry = false;
       showVolumeCaseStatus = false;
       showVolumeByLastIssuedOutcome = false;
       showVolumeByCaseOpenLastMonth = false;
       showVolumeByLastIssuedOutcomeLastMonth = false;
       showVolumebyOwnerLastmonth = false; 
       
       if (selectedComponent=='PieChart'){
           showPieChart = true;}
       
       if (selectedComponent=='VolumebyLOB'){
           showVolumeByLOB = true;}
           
       if (selectedComponent=='VolumeByOwner'){
           showVolumeByOwner = true;}   
           
       if (selectedComponent=='VolumeByCountry') {
               showVolumeByCountry = true;}     
           
                                  
          if (selectedComponent=='barGraphType') {
               showbarGraphType = true;}
               
               
          if (selectedComponent=='VolumeCaseStatus') {
               showVolumeCaseStatus = true;}     
               
         
         if (selectedComponent=='VolumeByLastIssuedOutcome') {
               showVolumeByLastIssuedOutcome = true; }
         
         if (selectedComponent=='VolumeByCaseOpenLastMonth'){
            showVolumeByCaseOpenLastMonth= true;}
        
         if (selectedComponent=='VolumeByLastIssuedOutcomeLastMonth'){
            showVolumeByLastIssuedOutcomeLastMonth = true;}
            
         if (selectedComponent=='VolumebyOwnerLastmonth'){
            showVolumebyOwnerLastmonth = true;}  
               
   }       
   
}