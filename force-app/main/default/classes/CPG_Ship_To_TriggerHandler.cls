/**
Class Name: CPG_Ship_To_TriggerHandler
Created Date: Nov-07-2017
Created By: Cognizant
This class is  helper class for updating Commercial Account details for Ship To data.
**/
public class CPG_Ship_To_TriggerHandler{
//Method to set up Commercial Accounts
public static void setupShipToCommercialAccounts(){
    map<id,id> mapPayerCommercial = new map<id,id>();
    map<id,id> mapPayerGlobal = new map<id,id>();
    set<id> setPayers= new set<id>();
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        for(Ship_To__c sh:(list<ship_to__c>)Trigger.New){
            if(Trigger.isInsert){
               setPayers.add(sh.Payer__c);             
            }
            else if(Trigger.isUpdate && sh.Payer__c!=((Ship_to__c)Trigger.oldMap.get(sh.id)).Payer__c){
                setPayers.add(sh.Payer__c);   
            }
        }            
    }
    if(!setPayers.isEmpty()){
        for(Account payer:[select parentid,id,parent.parentid from Account where id in:setPayers]){
            mapPayerCommercial.put(payer.id,payer.parentid);
            mapPayerGlobal.put(payer.id,payer.parent.parentid);
        }
    }
    if(!mapPayerCommercial.isempty()){
        for(Ship_To__c sh:(list<ship_to__c>)Trigger.New){
            if(mapPayerCommercial.containsKey(sh.Payer__c)){
                sh.Commercial_Account__c= mapPayerCommercial.get(sh.Payer__c);
                sh.global_Account__c = mapPayerGlobal.get(sh.Payer__c);
            }
        }
    }
}

}