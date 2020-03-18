/**
 * @author       Manikandan Radhakrishnapillai
 * @version      1.0
 * @createddate  Sep 3, 2019
 * @name         CS_EmailMessageHelper
 * @description  Utility class for CS_EmailMessageHandler class
 * @referencedby CS_EmailMessageHandler
 * @modifiedby
 * @modifieddate
 */

public with sharing class CS_EmailMessageHandlerUtility {

	//get the routing channel queue map
	private final static Map<String, Id> QUEUEMAP = CS_SystemConstants.getProteinServiceQueueMap();

	/*
	 * @description This helper method will get routing channel to route the case to correct sub-channel queue. It will get contact on case and then
	 *              get the routing channel associated with that contact to determine case routing channel.
	 * @param Map<Id, String> mapCaseIdChannelQueue Map of Case Id and its related contact's routing channel name
	 * @param Set<Id> caseIds Set of Case Ids to map with routing channel
	 */
	public static void getMapOfCaseAndChannelQueue(Map<Id, String> mapCaseIdChannelQueue, Set<Id> caseIds) {
        // Sprint P Deletion of  PI - Commodity,PI - Pet Treats
        Set<String> specialSubChannelSet = new Set<String>{'Aldi','Frozen Whole Birds','K-12','Kroger','McDonalds','USDA','Walmart'};
        // Sprint P Deletion of  PI - Commodity,PI - Pet Treats

        String tempStr = null;
        for(Case temp: [Select Id, Contact.CS_Routing_Channel__c, Contact.CS_Sub_Channel__c From Case Where Id IN :caseIds AND ContactID != null]) {
            tempStr = String.valueOf(temp.Contact.CS_Sub_Channel__c);
            if(specialSubChannelSet.contains(tempStr)) {
                mapCaseIdChannelQueue.put(temp.Id, tempStr);
            } else {
                mapCaseIdChannelQueue.put(temp.Id, temp.Contact.CS_Routing_Channel__c);
            }
        }
	}

	/**
	 * VSTS ID : 47436
	 * @description This method will assign external user to protein cases.
	 * @param List of Email Message records (Trigger.New)
	 * @referencedby CS_Protein_Email_to_Case_Assignment_Process (Process)
	 */
	@InvocableMethod(label=' External User Assignment & No Contact Queue Routing '
	description=' Assign case to an External User Configured in Custom Metadata ')
	public static void assignExternalUserAndNoContactRouting(List<Case> caseList) {
        System.debug(' ********* External User Assignment & No Contact Queue Routing ********** ');
        if(!caseList.isEmpty()) {

        //List of case to update with owner id
        Map<Id,Case> casesToUpdate = new Map<Id, Case>();
        String noContactQueueId = CS_SystemConstants.getQueueId(CS_SystemConstants.NO_CONTACT_SERVICE_QUEUE);

        for(Case originCAse: caseList) {

            if(!isDomainExist(originCAse.SuppliedEmail)){
            //Map External Users as per the custom settings CS_ExternalUser_Routing__mdt to the associated Queue
            casesToUpdate = externalCaseAssignmentViaCustomMetaData(originCase.id , originCase.SuppliedEmail,queueMap);

                if(casesToUpdate.get(originCase.id) == null) { //assign to no contact queue for cases
                    casesToUpdate.put(originCase.id, new Case(Id=originCase.id, OwnerId=noContactQueueId));
                }
            }
        }
        //update the case
        Database.SaveResult[] srList = Database.update(casesToUpdate.values(), false);
        // Calling getSaveResultErrors to check if any issue has happened while updating
        CS_EmailMessageHelper.getSaveResultErrors(srList);

        }
	}

	/**
	 * VSTS ID : 47436
	 * isDomainExist check whether the suppliedEmail of a case contains the domain values mentioned
	 in the Custom Label CS_ByPass_Domains_For_NoContactQueue
	 * @param  suppliedEmail case.SuppliedEmail
	 * @return boolean
	 */
	private static Boolean isDomainExist(String suppliedEmail){
        List<String> domainBypassVariables = Label.CS_ByPass_Domains_For_NoContactQueue.split(', ',0);
        for(String domain : domainBypassVariables){
            if(suppliedEmail.contains(domain)){
                return true;
            }
        }
        return false;
	}

	/**
	 * VSTS ID : 47436
	 * externalCaseAssignmentViaCustomMetaData :
	 * When the External User is found in the CustomMetadata settings 'CS_ExternalUser_Routing__mdt',
	 * then assign the owner based on the same.
	 * @param  tempId        :  caseid
	 * @param  suppliedEmail :  email associated with the external user configured in the custom metadata
	 */

	private static Map<Id,Case> externalCaseAssignmentViaCustomMetaData(Id tempId,
        String suppliedEmail,
        Map<String, Id> queueMap){

        Map<Id,Case> casesToUpdate = new Map<Id, Case>();
        Map<String,String> externalUserQueueMap = getExternalUserQueueMap();
        String formattedSuppliedEmail = ' ';
        formattedSuppliedEmail = suppliedEmail.toUpperCase();
        System.debug('\n\n\n*******External Users suppliedEmail : ' + formattedSuppliedEmail + '\n\n\n');

        if(externalUserQueueMap.containsKey(formattedSuppliedEmail)) {
            casesToUpdate.put(tempId, new Case(Id = tempId, OwnerId = queueMap.get(externalUserQueueMap.get(formattedSuppliedEmail))));
        }

        System.debug('\n\n\n*******External Routing casesToUpdate' + casesToUpdate + '\n\n\n');
        return casesToUpdate;
    }

    /**
    * VSTS ID : 47436
    * getExternalUserQueueMap :
    * It returns the ExternalUser and his associated email id in a Map configured in the 'CS_ExternalUser_Routing__mdt'
    * @return   :  Map<String,String> externalUserQueueMap
    */
    public static Map<String, String> getExternalUserQueueMap() {

        CS_ExternalUser_Routing__mdt[] externalUserQueuemdt;

        if(CS_ExternalUser_Routing__mdt.sObjectType.getDescribe().isAccessible()) {
            externalUserQueuemdt = [SELECT ExternalUserEmail__c, QueueName__c
                                    FROM CS_ExternalUser_Routing__mdt];
        }

        Map<String, String> externalUserQueueMap = new Map<String, String>();
        for (CS_ExternalUser_Routing__mdt i :externalUserQueuemdt) {
            externalUserQueueMap.put(i.ExternalUserEmail__c.toUpperCase(), i.QueueName__c);
        }

        System.debug('\n\n\n*******External UserQueueMap' + externalUserQueueMap + '\n\n\n');
        return externalUserQueueMap;
    }

    /**
    * VSTS ID      : 48815
    * @Description : This method processes the incoming emailMessages for finding duplicate cases
    *                Scenarios covered :
    *                1. When a user replies to a mail which has already created a Case and it doesent contain 
    *                   a thread ID on it.
    *                2. After more than one to and fro communications a user send a mail for case creation which
    *                   again resulting in scenario 1  
    * @param       : emailMessageList list of emailMessages from Trigger.new
    */
    public static void processEmailMessageHeader(List<EmailMessage> emailMessageList) {

        System.debug('**********Processing Email Messages ***************');

        
        Map<String, List<String>> emailMessgaeReferenceListMap = new Map<String, List<String>>();
        Map<Id,EmailMessage> caseIdsToBeClosedWithParentMap = new Map<Id,EmailMessage>();
        List<String> emailMessageReferenceList = new List<String>();
        Map<String,EmailMessage> messageIdEmailMessageMap = new Map<String,EmailMessage>();
        List<EmailMessage> emailMessagesToBeChecked = new List<EmailMessage>();

        if(!emailMessageList.isEmpty()){
            for(EmailMessage emailMessage :emailMessageList) {
                if(emailMessage.CS_ProteinServiceEmail__c &&
                   emailMessage.Incoming &&
                   emailMessage.headers != null){
                    CS_EmailMessageHandlerUtilityHelper.stampEmailMessageID(emailMessage,messageIdEmailMessageMap);
                    CS_EmailMessageHandlerUtilityHelper.getEmailMessageReferenceListMap(emailMessage,
                                                                                        emailMessgaeReferenceListMap,
                                                                                        emailMessageReferenceList);
                }
            }
        }

        System.debug('emailMessageReferenceList : '+emailMessageReferenceList);
        System.debug('emailMessgaeReferenceListMap : '+emailMessgaeReferenceListMap);

        if(!emailMessageReferenceList.isEmpty()){
            emailMessagesToBeChecked = [SELECT id,parentId,parent.CS_Market_Channel__c,parent.status,
                                               CS_EmailMessage_ID__c, parent.ownerId
                                        FROM EmailMessage
                                        WHERE CS_EmailMessage_ID__c IN: emailMessageReferenceList];
        }

        caseIdsToBeClosedWithParentMap = CS_EmailMessageHandlerUtilityHelper.getCasesToBeClosed(
                                                                                messageIdEmailMessageMap,
                                                                                emailMessgaeReferenceListMap,
                                                                                emailMessagesToBeChecked);

        System.debug('caseIdsToBeClosedWithParentMap : '+caseIdsToBeClosedWithParentMap);

        if(!caseIdsToBeClosedWithParentMap.isEmpty()){
            CS_EmailMessageHandlerUtilityHelper.closeCase(caseIdsToBeClosedWithParentMap);
        }

    }

    
/*VSTS ID : 47437

 * @description This method will append only manual protein cases subject to outboud emailmessage subject .
 * @param List of Email Message records (Trigger.New)
 */
// Sprint O : Only for manual case subject to apend outbound Emailmessage subject.
/*
 public static void appendCaseSubtoEmailSubject(List<EmailMessage> emailList){

 system.debug('elist*********'+emailList);
 // Get the set of emailmessage ParentID
 Set<Id> emailmessageParentId = new Set<Id>();
 for(EmailMessage ems : emailList){
 // system.debug('ems.Parent'+ems.Parent);
 //system.debug('ems.Parent.Origin'+ ems.Parent.Origin );
 if(ems.ParentId != null){
 emailmessageParentId.add(ems.ParentId);
 }
 }
 system.debug('emailmessageParentId*****'+emailmessageParentId);
 //Get the manual case  subjecy based on email message ParentId and Case origin.
 Map<Id, case> caseSub  =new  Map<Id, case>([select id, Subject from case where Id IN : emailmessageParentId AND Origin ='Manual']);

 for(Emailmessage emsub :emailList){
 // system.debug('emsub.Subject.contains'+emsub.Subject.contains(caseSub.get(emsub.ParentId ).Subject));
 // varify the caseSub map size and manual case subject conatins or not
 if(!caseSub.isEmpty() && !(emsub.Subject.contains(caseSub.get(emsub.ParentId ).Subject)) ){
 // update the Email Subject and Manual case subject for newly created eamil message.
 emsub.Subject += ' - '+ caseSub.get(emsub.ParentId ).Subject;
 system.debug('emsub.Subject *****'+emsub.Subject );

 }
 }
 }

 */
}