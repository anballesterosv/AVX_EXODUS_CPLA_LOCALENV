public with sharing class Protein_CustMtgReportOppTriggerHandler {
    public static void updateNextStepsPresenceCheckboxInOppty(List<CustomerMeetingReportOpp__c> lstCMROs) {
        Set<Id> oppIDs =  new Set<Id>();
        //Add the Opportunity IDs to oppIDs set.
        for(CustomerMeetingReportOpp__c cmro : lstCMROs)
        {
            oppIDs.add(cmro.Opportunity__c);
        }
        //Get a map of the Opportunities with the number of CMROs.
        Map<Id,Opportunity> mapOpps = new Map<Id,Opportunity>([SELECT Id, Count_of_CMROs__c FROM Opportunity WHERE Id IN :oppIDs]);
        
        //Query the Opps and the related CMROs & add the size of the CMROs to the Count_of_CMROs__c field in opp.
        for(Opportunity opp : [SELECT Id, Name, Count_of_CMROs__c, (SELECT Id FROM Customer_Meeting_Report_Opps__r) FROM Opportunity WHERE Id IN :oppIDs]) {
            mapOpps.get(opp.Id).Count_of_CMROs__c = opp.Customer_Meeting_Report_Opps__r.size();
        }
        System.debug('mapOpps: '+mapOpps);
        try{
            if(!mapOpps.isEmpty())
            {
                update mapOpps.values();
            }
        }
        catch(dmlException ex) {
            System.debug('Error message: ' +ex.getDmlMessage(0));
        }
    }

}