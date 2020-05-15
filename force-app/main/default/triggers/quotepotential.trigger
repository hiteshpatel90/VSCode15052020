trigger quotepotential on Quote_Line_Item__c (after insert,after update) {
    Set<Id> quoteIds = new Set<Id>();
    List<Quote__c> quotes = new List<Quote__c>();
    for (Quote_Line_Item__c record: Trigger.new) {
        if (record.Quote2__c != null){
            quoteIds.add(record.Quote2__c);
        }
    }
    for(AggregateResult ar:[SELECT Quote2__c, SUM(Max_Batch__c)sumMax FROM Quote_Line_Item__c WHERE Quote2__c=:quoteIds GROUP BY Quote2__c]) {
        quotes.add(new Quote__c(Id=(Id) ar.get('Quote2__c'),Potential__c = (Decimal) ar.get('sumMax')));
    }
    if (quotes.isempty() == false) {
        update quotes;
    }
}