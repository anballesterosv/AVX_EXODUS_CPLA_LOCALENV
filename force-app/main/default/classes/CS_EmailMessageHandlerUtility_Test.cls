@isTest
public class CS_EmailMessageHandlerUtility_Test {

               /*
        * @Description :
        *  The below test method will cover the 'assignExternalUserAndNoContactRouting' ,
        * @author : Ramesh Yenugula
        //Sprint O :  related method :appendCaseSubtoEmailSubject
        */

    public static testmethod void testassignExternalUserAndNoContactRoutingWOExtUsr(){
        
        List<EmailMessage> es = CS_TestDataHelper.getEmailMessageRecords('null',false,null,'mani@gmail.com');
        List<Id> caseIds = new List<Id>();
         // caseIdset set is used for maintin the set of email message Parent Id and passed getMapOfCaseAndChannelQueue() ,appendCaseSubtoEmailSubject ,getMapOfCaseAndChannelQueue method.       
        Set<Id> caseIdset = new Set<Id>();
        Map<Id, String> mapCaseIdChannelQueue = new Map<Id, String> ();
        for(EmailMessage e : es){
            caseIds.add(e.parentId);
            caseIdset.add(e.parentId);
        }
      
        for(Case temp : [Select Id, Contact.CS_Routing_Channel__c, Contact.CS_Sub_Channel__c From Case Where Id IN :caseIdset AND ContactID != null]){            
            mapCaseIdChannelQueue.put(temp.Id, temp.Contact.CS_Routing_Channel__c);
        }
           
        List<Case> caseList = [SELECT id,SuppliedEmail FROM Case WHERE id IN:caseIds];
        CS_EmailMessageHandlerUtility.assignExternalUserAndNoContactRouting(caseList);
        CS_EmailMessageHandlerUtility.getMapOfCaseAndChannelQueue(mapCaseIdChannelQueue,caseIdset);
    }
    
    
    

}