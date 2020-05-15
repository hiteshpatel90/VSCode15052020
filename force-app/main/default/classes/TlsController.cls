public with sharing class TlsController{
    public string s {get; set;}
    public TlsController(){
        s = ApexPages.currentPage().getHeaders().get('CipherSuite');
    }
}