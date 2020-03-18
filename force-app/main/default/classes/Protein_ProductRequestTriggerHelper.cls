/**
@Author : Sri harshitha Bandi
@name : Protein_ProductRequestTriggerHelper
@CreateDate : Aug 8, 2019
@Description : Helper class for Product Request trigger
@Version <1.0>
@Modifiedby : Sri harshitha Bandi, 
@ModifiedDate: Oct 11, 2019
*/
public with sharing class Protein_ProductRequestTriggerHelper {
    
    //This method deletes all the existing Product Groups under an Opportunity when a new Product Request is created.
    public static void deleteAllProdGroups(List<Product_Request__c> oppList) {
        Set<Id> oppIds = new Set<Id>();
        List<Product_Group__c> lstDeletePGs = new List<Product_Group__c>();
        
        for(Product_Request__c pr : oppList){
            oppIds.add(pr.Related_Opportunity__c);
        }
        for(Product_Group__c pg : [SELECT Id FROM Product_Group__c WHERE Opportunity__c IN :oppIds]){
            lstDeletePGs.add(pg);
        }
        try{
            if(Schema.sObjectType.Product_Group__c.isDeletable()) {
            delete lstDeletePGs;
            }
        }
        catch(exception ex){
            System.debug('Error message: ' + ex.getMessage());
        }
    }
    
    //This method will calculate the Sum of Volumes for all the associated Product Request records
    public static void volumeRollUpMethod(List<Product_Request__c> oppList) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Double> mapOppWithVolume = new Map<Id,Double>();
        Boolean hasProdRequest = false;
        Decimal annualVolSum = 0;
        List<Opportunity> lstOppsToUpdate = new List<Opportunity>();
        
        for(Product_Request__c pr : oppList){
            oppIds.add(pr.Related_Opportunity__c);
        }
        System.debug('oppIds: '+oppIds);
        for(AggregateResult q : [SELECT Related_Opportunity__c, SUM(Annual_Volume__c) FROM Product_Request__c WHERE Related_Opportunity__c IN :oppIds GROUP BY Related_Opportunity__c]){
            System.debug('@@@Q--->'+q);
            mapOppWithVolume.put((Id)q.get('Related_Opportunity__c'),(Double)q.get('expr0'));
            hasProdRequest = True;
        }
        System.debug('mapOppWithVolume: '+mapOppWithVolume);
        for(Opportunity opp : [SELECT Id, Volume__c, HasOpportunityLineItem, HasOpportunityProductRequest__c FROM Opportunity WHERE Id IN :oppIds]){
            if(checklineItems(opp)){
                parametersWrapper pw = new parametersWrapper();
                pw.opp = opp;
                pw.annualVolSum = annualVolSum;
                pw.hasProdRequest = hasProdRequest;
                executeIfOppHasLineItems(pw, mapOppWithVolume, lstOppsToUpdate);
            }
            else{
                if (mapOppWithVolume.containsKey(opp.Id)){
                    System.debug('hasProdRequest--->'+hasProdRequest);
                    hasProdRequest = True;
                    opp.HasOpportunityProductRequest__c = hasProdRequest;
                    lstOppsToUpdate.add(opp);
                }
                else{
                    System.debug('hasProdRequest--->'+hasProdRequest);
                    opp.HasOpportunityProductRequest__c = hasProdRequest;
                    lstOppsToUpdate.add(opp);
                }
            }
            if(!lstOppsToUpdate.isEmpty()) {
                try{
                    if(Schema.sObjectType.Opportunity.isUpdateable()) {
                    Database.update(lstOppsToUpdate, false);
                    }
                }
                catch(exception ex){
                    System.debug('Error message: ' + ex.getMessage());
                }
            }
        }
    }

    private static boolean checklineItems(opportunity opp){
        return (!opp.HasOpportunityLineItem);
    }
    
    //Declaring a wrapper class to pass the parameters as a single wrapper in 'executeIfOppHasLineItems' method.
    public class parametersWrapper{
        public Opportunity opp;
        public Decimal annualVolSum;
        public Boolean hasProdRequest;
        
    }

    private static void executeIfOppHasLineItems(parametersWrapper pw, Map<Id,Double> mapOppWithVolume, List<Opportunity> lstOppsToUpdate) {
        if (mapOppWithVolume.containsKey(pw.opp.Id)){
                    pw.annualVolSum = mapOppWithVolume.get(pw.opp.Id);
                    System.debug('@@@annualVolSum--->'+pw.annualVolSum);
                    pw.hasProdRequest = True;
        }
        System.debug('@@@opp--->'+pw.opp +'-'+pw.hasProdRequest);
        if(pw.annualVolSum != null){
            pw.opp.Volume__c = pw.annualVolSum;
        }
        pw.opp.HasOpportunityProductRequest__c = pw.hasProdRequest;
        lstOppsToUpdate.add(pw.opp);
        System.debug('lstOppsToUpdate: '+lstOppsToUpdate);
        System.debug ('@@@HasOpportunityProductRequest__c--->'+pw.opp.HasOpportunityProductRequest__c);
    }
}