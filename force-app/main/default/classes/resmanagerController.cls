/****************************************************************************
* Type               : Apex Class
* Name               : resmanagerController
* Modified by        : Hitesh Patel
* Modified Date      : 5th June 2015
* Last Modified By   : Hitesh Patel 5th June 2015
* Purpose            : This controller is used to reserve desk on Particular time at Particular office. 
****************************************************************************/
Public class resmanagerController{ 
   
    public List<wrapperDesk> lstwrapperDesk {get; set;}
    public List<wrapperDateRange> lstwrapperDateRange {get; set;}
    
    public Desk__c objDesk {get; set;}
    public Reservation__c objReservation {get; set;}
    public Reservation__c objReservationnew {get; set;}
    
    public resmanagerController() {
         
        lstwrapperDesk = new List<wrapperDesk>();
        objDesk = new Desk__c();
        objReservation = new Reservation__c();
        objReservationnew = new Reservation__c();
        lstwrapperDateRange  = new List<wrapperDateRange>();
    }
    
    public PageReference searchReservation() {
        lstwrapperDesk = new List<wrapperDesk>();
        lstwrapperDateRange  = new List<wrapperDateRange>();
        
        if(objReservation.Start_Date__c == null || objReservation.End_Date__c == null || objDesk.Office__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Please insert search criteria');
            ApexPages.addMessage(myMsg); 
            return null;
        }
        
        if(objReservation.Start_Date__c.daysBetween(objReservation.End_Date__c) > 15){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'You cannot select more that 15 days.');
            ApexPages.addMessage(myMsg); 
            return null;
        }
        
        if(objReservation.Start_Date__c.daysBetween(objReservation.End_Date__c) < 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'End Date must be greater or equal than Start date');
            ApexPages.addMessage(myMsg); 
            return null;
        }
        
        wrapperDesk objwrapperDesk;
        List<Desk__c> lstDesk = [select id, Name, Desk_Number__c, createdby.Name, (select id, Start_Date__c, End_Date__c from Reservations__r) from Desk__c where Office__c =: objDesk.Office__c order by Desk_Number__c asc];
        for(Desk__c dsk: lstDesk){
            objwrapperDesk = new wrapperDesk();
            objwrapperDesk.strDeskNumber = dsk.Desk_Number__c;
            objwrapperDesk.objDesk = dsk;
            map<String, Boolean> mapAvailableTemp = new map<String, Boolean>();
            for(Reservation__c rv: dsk.Reservations__r){
                
                for(integer i = 0; i <= rv.Start_Date__c.daysBetween(rv.End_Date__c);i++){               
                    mapAvailableTemp.Put(String.valueOf(rv.Start_Date__c.adddays(i).month() + '/' + rv.Start_Date__c.adddays(i).day() + '/' + rv.Start_Date__c.adddays(i).year()) + dsk.id, true);
                }
            }
            system.debug('#################'+mapAvailableTemp);
            objwrapperDesk.mapAvailable = mapAvailableTemp;
            objwrapperDesk.intMapSize = mapAvailableTemp.size();
            lstwrapperDesk.add(objwrapperDesk);
        }
        
        
        wrapperDateRange objwrapperDateRange;
                 
        for(integer i = 0; i <= objReservation.Start_Date__c.daysBetween(objReservation.End_Date__c);i++){
            objwrapperDateRange = new wrapperDateRange();
            objwrapperDateRange.objDate = objReservation.Start_Date__c.adddays(i);
            //objwrapperDateRange.isInMap = lstwrapperDesk[i].mapAvailable.containskey(objwrapperDateRange.objDate);
            lstwrapperDateRange.add(objwrapperDateRange);
        }
        return null;
    }
    
    public PageReference createNewReservation(){
        try{
            if(objReservationnew.Start_Date__c == null || objReservationnew.End_Date__c == null){            
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Please select Start Date and End Date.');
                ApexPages.addMessage(myMsg); 
                return null;
            }
            if(objReservationnew.Start_Date__c > system.today().adddays(15) || objReservationnew.End_Date__c > system.today().adddays(15)){            
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'The reservation cannot be made more than two weeks in advance.');
                ApexPages.addMessage(myMsg); 
                return null;
            }
            if(objReservationnew.Start_Date__c.daysBetween(objReservationnew.End_Date__c) > 15){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'You can not create a reservation for a desk that is more than 2 weeks in advance');
                ApexPages.addMessage(myMsg); 
                return null;
            }
            
            List<Reservation__c> lstReservation = [select id from Reservation__c where createdbyId =: system.userinfo.getUserid() and (Start_Date__c =: objReservationnew.Start_Date__c OR End_Date__c =: objReservationnew.End_Date__c)];
            
            if(lstReservation.size() > 0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'You can not be able to create new reservation on same date.');
                ApexPages.addMessage(myMsg); 
                return null;
            }
            List<Reservation__c> lstReservationAlreadyRes = [select id from Reservation__c where Office_Desk__c =: objReservationnew.Office_Desk__c and (Start_Date__c >=: objReservationnew.Start_Date__c and End_Date__c <=: objReservationnew.End_Date__c)];
            if(lstReservationAlreadyRes.size() > 0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Desk is not available. Please select another date.');
                ApexPages.addMessage(myMsg); 
                return null;
            }
            objReservationnew.Reserve_Desk__c = true;
            insert objReservationnew;
        }catch (Exception ex){
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,ex.getMessage());
            //ApexPages.addMessage(myMsg); 
            return null;
        }
        PageReference pr = new PageReference('/a2d?fcf=00B90000009VHkp');
        pr.setRedirect(true);
        return pr;
    }    
    public class wrapperDateRange{
        public Date objDate {get; set;}
        public Boolean isInMap {get; set;}
    }
    public class wrapperDesk{
        public string strDeskNumber {get; set;}
        public Desk__c objDesk {get; set;}
        public map<String, Boolean> mapAvailable {get; set;}
        public integer intMapSize {get; set;}
        public wrapperDesk(){
            intMapSize = 0;
        }
    }
    
}