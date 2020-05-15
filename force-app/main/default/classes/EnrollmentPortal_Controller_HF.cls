global virtual with sharing class EnrollmentPortal_Controller_HF {
    public static List<wrapperInvoice> lstwrapperInvoice {get; set;}
    public EnrollmentPortal_Controller_HF(ApexPages.StandardController objStandardController) {
        
    }
    
    public EnrollmentPortal_Controller_HF() {
        objEnrollmentRecord = new EnrollmentRecord();
        objEnrollmentRecord.id = '1234';
        loadInvoices();
        
    }
    public static void loadInvoices(){        
        lstwrapperInvoice = new List<wrapperInvoice>();
        
        wrapperInvoice objwrapperInvoice;
        objwrapperInvoice = new wrapperInvoice();
        objwrapperInvoice.strInvoiceId = '123';
        objwrapperInvoice.strInvoiceNumber = '345621212';
        objwrapperInvoice.invoiceDate = system.today();
        objwrapperInvoice.strinvoiceDate = '11/15/2016';
        lstwrapperInvoice.add(objwrapperInvoice);
        
        objwrapperInvoice = new wrapperInvoice();
        objwrapperInvoice.strInvoiceId = '123';
        objwrapperInvoice.strInvoiceNumber = '345621212';
        objwrapperInvoice.invoiceDate = system.today().adddays(-10);
        objwrapperInvoice.strinvoiceDate = string.valueOf(objwrapperInvoice.invoiceDate);
        lstwrapperInvoice.add(objwrapperInvoice);
    }
    @RemoteAction
    public static List<wrapperInvoice> searchInvoice(string strFromDate, string strToDate){
        List<wrapperInvoice> wrapperInvoices = new List<wrapperInvoice>();
        system.debug('@@@@@@@@'+strFromDate);
        system.debug('@@@@@@@@'+strToDate);
        loadInvoices();
        system.debug('@@@@@@@@'+lstwrapperInvoice);
        //system.debug('@@@@@@@@'+lstwrapperInvoice);
        Date dtFrom;
        Date dtTo;
        if(strFromDate != null && strFromDate != ''){
            string[] arrTempdate = strFromDate.split('/');
            dtFrom = date.newInstance(integer.valueOf(arrTempdate[2]), integer.valueOf(arrTempdate[0]), integer.valueOf(arrTempdate[1]));
        }
        if(strToDate != null && strToDate != ''){
            string[] arrTempdate = strToDate.split('/');
            dtTo = date.newInstance(integer.valueOf(arrTempdate[2]), integer.valueOf(arrTempdate[0]), integer.valueOf(arrTempdate[1]));
        }
        
        for(wrapperInvoice wi: lstwrapperInvoice){
            if(wi.invoiceDate >= dtFrom && wi.invoiceDate <= dtTo){
                wrapperInvoices.add(wi);
            }            
        }
        system.debug('@@@@@@@@'+lstwrapperInvoice);
        return wrapperInvoices;
    }
    
    // Wrapper class for Invoice detail
    public class wrapperInvoice{
        public string strInvoiceId {get; set;}
        public string strInvoiceNumber {get; set;}
        public date invoiceDate {get; set;}
        public string strinvoiceDate {get; set;}
    }
    
    public EnrollmentRecord objEnrollmentRecord {get; set;}
    
    public class EnrollmentRecord{
        public string id {get; set;}
    }
    
}