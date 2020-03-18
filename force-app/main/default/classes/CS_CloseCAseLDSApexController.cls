/**
* @author       Manikandan Radhakrishnapillai 
* @version      1.0
* @createddate  June 20, 2019
* @name         CS_CloseCAseLDSApexController
* @description  Apex controller for the Lightning Component CS_CloseCAseLDS
* @modifiedby   
* @modifieddate 
*/ 
public with sharing class CS_CloseCAseLDSApexController {

/**
* @Description : The method will update the CS_Is_New_Email__c to false as soon as the Case Owner opens the Case page.
* @author : Manikandan Radhakrishnapillai
*/
    @AuraEnabled
    public static void getCaseContainsOpenEmailMessages(String caseId){ 
        try{
            Case opencase = [SELECT id,Ownerid,CS_Is_New_Email__c FROM Case WHERE id =: caseId];
            if(System.UserInfo.getUserId() == opencase.ownerid && opencase.CS_Is_New_Email__c) {
                opencase.CS_Is_New_Email__c = false;
                update opencase;
            }
        }catch(Exception ex){
            system.debug('\n\n\n Exception Occured in Updating Is_New_Email__c flag...\n\n\n');
            system.debug('Cause ex :'+ex.getCause());
            system.debug('line Number ex :'+ex.getLineNumber());
            system.debug('Message ex :'+ex.getMessage());
            system.debug('Stacktrace ex :'+ex.getStackTraceString());
        }
    }
    
}