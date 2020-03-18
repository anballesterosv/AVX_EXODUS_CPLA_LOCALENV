/*
Author: Mahesh C
Description : This method is written to send Email To Pricer based on Opportunity Type
Method Name : updateEmailMessageBeforeInsert      

*/

public with sharing class Protein_SendToPricerController {
    
    @AuraEnabled
    public static String sendEmail(Id prodColId){
        string validateMsg='';
        Boolean isSentToPricer=false;
        Boolean isFieldCheck=false;
        set<Id> oppId=new set<Id>();
        List<Id> pROwner=new List<Id>();
        
        List<Product_Request__c> prodReq=[select id,Name,CreatedById ,Related_Opportunity__c,Sent_to_Pricer__c,Status__c,Pricing_Due_Date__c,Pricing_Timeframe__c,Pricing_Notification_Date__c from Product_Request__c where Id=:prodColId];
        system.debug('ProdReq++++'+prodReq);
        
        for(Product_Request__c pr:ProdReq){
            oppId.add(prodReq[0].Related_Opportunity__c);
            pROwner.add(pr.CreatedById);
            system.debug('oppId Value+++'+oppId);
            //validate the mandatory fields
            isSentToPricer = Protein_SendToPricerHelper.validateSendToPricer(pr,isSentToPricer);
            system.debug('isSentToPricer++'+isSentToPricer);
            isFieldCheck = Protein_SendToPricerHelper.validateFieldCheckOne(pr,isFieldCheck);
            system.debug('isFieldCheck++'+isFieldCheck);
                       
        }
        
        List<Opportunity> oppList=new List<Opportunity>();
        if(oppId!=Null){
            oppList= [select id,Name,RecordType.Name from Opportunity where id IN: oppId];
            System.debug('oppList++'+oppList);
        }
        
        List<Product_Collection__mdt> prodColectionMappingList=[select id,Opportunity_Type__c,Pricer__c From Product_Collection__mdt];
        system.debug('ProdColectionMapping++++'+prodColectionMappingList);
 //      EmailTemplate et = [Select Id from EmailTemplate where Name = 'Email to Pricing Team'];
        List<string> mdtString=new List<string>();               
        boolean flag;
        Map<String,String> oppmdtRecType = new Map<String,String>();
        
        for(Opportunity opp:oppList){    
        
            oppmdtRecType.clear();
            flag = false;
            for(Product_Collection__mdt mdt:ProdColectionMappingList){
                
                if(isSentToPricer == true){
                   validateMsg = 'Checkbox Checked';  
                   system.debug('%%%checkbox check='+validateMsg);                  
                }
                else if(Opp.RecordType.Name == mdt.Opportunity_Type__c){
                    mdtString.add(mdt.Pricer__c);                
                    flag = true;  
                    oppmdtRecType.put(Opp.RecordType.Name, mdt.Opportunity_Type__c);         
                }               
            }
             validateMsg = validateOppRecType(flag,oppmdtRecType,validateMsg,isFieldCheck,isSentToPricer,mdtString,pROwner,opp,prodReq);
             system.debug('%%%checkbox cjeck222='+validateMsg); 
        } 
            
        return validateMsg;
    } 
    private static string validateOppRecType(Boolean flag,Map<String,String> oppmdtRecType,string validateMsg,Boolean isFieldCheck,Boolean isSentToPricer,List<string> mdtString,List<Id> pROwner,Opportunity opp,List<Product_Request__c> prodReq)
    {
        EmailTemplate et = [Select Id from EmailTemplate where Name = 'Email to Pricer' limit 1];
        if(!flag && oppmdtRecType.get(Opp.RecordType.Name) == null && ValidateMsg != 'Checkbox Checked'){                    
            ValidateMsg='Record Type not matched';                    
        }
        else if(isFieldCheck == true && flag == true){
                    
                    validateMsg='Pricing date blank';                   
        }
        else if(isvalidCheck(isFieldCheck,isSentToPricer,validateMsg))
        {
                List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(MdtString);
            mail.setWhatId(prodReq[0].id);
                mail.setTargetObjectId(pROwner[0]);
                mail.setSaveAsActivity(false);
                mail.setBccSender(false);
              //  mail.setHtmlBody('Hi  <br/><br/>New Product Collection Record is created<br/><br/> Thanks <br/>');
                mail.setTemplateId(et.id);
                mails.add(mail);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                system.debug('results++'+results);
                
                if(results[0].success){
                    updateProdReqData(ProdReq);
                    system.debug('ProdReq Update Check'+ProdReq);
                    validateMsg= 'Success Email';
                }
                else{
                    validateMsg= 'Email failed';
                }
         system.debug('%%%checkbox cjeck33='+validateMsg);                       
        }
        system.debug('%%%checkbox cjeck44='+validateMsg); 
        return validateMsg;
    } 

    private static boolean isvalidCheck(boolean isFieldCheck, boolean isSentToPricer, string validateMsg){
    
        return (isFieldCheck == false && isSentToPricer == false && validateMsg != 'Checkbox Checked');
    
    }

    public static void updateProdReqData(List<Product_Request__c> prodReq){
        List<Product_Request__c> updatePRList = new List<Product_Request__c>();
        
        for(Product_Request__c pr : prodReq)
        {
            pr.Sent_to_Pricer__c=True;
            pr.Pricing_Notification_Date__c=system.today();   
            updatePRList.add(pr);
        }
        try{
            if(!updatePRList.isEmpty())
            {
                update updatePRList;
            }
        }catch(exception e){
            system.debug('exception::'+e);    
        }
    }
}