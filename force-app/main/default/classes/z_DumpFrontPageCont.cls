public with sharing class z_DumpFrontPageCont {
    
    final private Id batch1ClassId, batch2ClassId, batch3ClassId;
    final public String NOT_START = 'not_start';
    final public String PROCESSING = 'processing';
    final public String FINISHED = 'finished';

    public String batch1Status {get;set;}
    
    public String batch2Status {get;set;}   

    public String batch3Status {get;set;}   
    
    public Id batch1Id {get;set;}
    
    public Id batch2Id {get;set;}
    
    public Id batch3Id {get;set;} 
    
    public String message {get;set;}
    
	public Integer messageCode {get;set;}        
    
    public integer errornum {get;set;}  
    
    public boolean getDisableDumpBtn() {
        if(batch1Status == PROCESSING || batch2Status == PROCESSING || batch3Status == PROCESSING)
            return true;
        return false;
    }   
    
    public boolean getShowProgressBar() {
        if(batch1Status == PROCESSING || batch2Status == PROCESSING || batch3Status == PROCESSING)
            return true;
        return false;
    }
    
    public boolean getShowStatusBlock() {
        if(batch1Status == NOT_START && batch2Status == NOT_START && batch3Status == NOT_START)
            return false;
        return true;
    }

    public z_DumpFrontPageCont(){
        batch1ClassId = [Select Name, Id From ApexClass Where Name = 'z_BatchableMetadataDump1' Limit 1][0].id;
        batch2ClassId = [Select Name, Id From ApexClass Where Name = 'z_BatchableMetadataDump2' Limit 1][0].id;
        batch3ClassId = [Select Name, Id From ApexClass Where Name = 'z_BatchableMetadataDump3' Limit 1][0].id;     
        init();
    }
    
    private void init() {
        batch1Status = NOT_START;
        batch2Status = NOT_START;
        batch3Status = NOT_START;               
        batch1Id = null;
        batch2Id = null;
        batch3Id = null; 
        errornum = 0;
        message = '';  
        messageCode = 0;   
    }
        
    public BatchJob[] getJobs() {
        List<AsyncApexJob> apexJobs = 
            [Select TotalJobItems, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, Id, JobType, ApexClassId, CreatedDate From AsyncApexJob Where (ApexClassId =: batch1ClassId) OR (ApexClassId =: batch2ClassId) OR (ApexClassId =: batch3ClassId) Order by CreatedDate DESC];
        
        if(apexJobs.size() == 0) {
            return new List<BatchJob>();
        }

        List<BatchJob> jobs = new List<BatchJob>();      
        for(AsyncApexJob job : apexJobs) {
            if(job.id != batch1Id && job.id != batch2Id && job.id != batch3Id)
                continue;
                
            BatchJob bj = new BatchJob();
            bj.isCompleted = false;
            
            /*
            if(job.ApexClassId == batch1ClassId) {
                bj.Job_Type = 'z_BatchableMetadataDump1';
            } else if(job.ApexClassId == batch2ClassId) {
                bj.Job_Type = 'z_BatchableMetadataDump2';
            } else {
                bj.Job_Type = 'z_BatchableMetadataDump3';
            }
            */
            if(job.ApexClassId == batch1ClassId) {
                bj.Job_Type = 'Process 1';
            } else if(job.ApexClassId == batch2ClassId) {
                bj.Job_Type = 'Process 2';
            } else {
                bj.Job_Type = 'Process 3';
            }            

            bj.aj = job;

            // NOT START YET
            if(job.jobItemsProcessed == 0) {
                bj.Percent= 0;
                jobs.add(bj);
                continue;
            }

            Decimal d = job.jobItemsProcessed;
            d = d.divide(job.TotalJobItems, 2)*100;
            bj.Percent= d.intValue();

            // PROCESSING
            if(bj.Percent != 100){
                jobs.add(bj);
                continue;
            }

            // FINISED
            if(job.ApexClassId == batch1ClassId) {
                batch1Status = FINISHED;    
            } else if(job.ApexClassId == batch2ClassId){
                batch2Status = FINISHED;    
            } else {
                batch3Status = FINISHED;
            }
            
            errornum += job.NumberOfErrors;
            bj.isCompleted = true;
            jobs.add(bj);           
        }
        return jobs;
    }
   
    public PageReference updateProgress() {
        if(batch1Status == FINISHED && batch2Status == NOT_START && batch3Status == NOT_START) {
            batch2Id = z_Util.executeBatchableMetadataDump2(false);
            batch2Status = PROCESSING;
            return null;
        }
        
        if(batch1Status == FINISHED && batch2Status == FINISHED && batch3Status == NOT_START) {
            batch3Id = z_Util.executeBatchableMetadataDump3();
            batch3Status = PROCESSING;
            return null;
        }       

        if(batch1Status == FINISHED && batch2Status == FINISHED && batch3Status == FINISHED) {
            message = 'COMPLETED';
            messageCode = 0;
        }

        return null;
    }
    
    public void executeDump() {
    	List<z_MetaDumpSetting__c> settings = [Select id, name__c From z_MetaDumpSetting__c limit 10000];
    	if(settings.size() == 0) {
    		message = 'no setting';
    		messageCode = 2;
    		return;
    	}
    	
        init();
        batch1Id = z_Util.executeBatchableMetadataDump1(false);
        batch1Status = PROCESSING;
    }
           
    public class BatchJob{
        public AsyncApexJob aj {get;set;}
        public Integer Percent {get;set;}
        public String Job_Type {get;set;}
        public Boolean isCompleted {get;set;}
        public BatchJob(){}     
    }
}