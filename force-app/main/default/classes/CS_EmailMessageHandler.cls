/**
* @author       Ramesh Yenugula
* @version      2.0
* @createddate  Feb 2, 2019
* @name         CS_EmailMessageHandler
* @description  Helper class for Email Message trigger code and object specific business logic code
* @referencedby CS_EmailMessageTrigger
* @modifiedby   Manikandan Radhakrishnapillai
* @modifieddate 9/3/2019
*/
public with sharing class CS_EmailMessageHandler {

//flag marked true will not execute trigger for Email Message
public static Boolean bDisableEmailTriggerExecution = false;

//get the routing channel queue map
private final static Map<String, Id> QUEUEMAP = CS_SystemConstants.getProteinServiceQueueMap();

private final static String NOCONTACTQUEUEID = CS_SystemConstants.getQueueId(CS_SystemConstants.NO_CONTACT_SERVICE_QUEUE);

/*
* @description This method will set the from address of all Protein outgoing case emails(reply, replyAll, forward) to Protein Customer Service email address.
* @param List of Email Message records (Trigger.New)
*/
public static void updateEmailMessageBeforeInsert(List<EmailMessage> emailList) {
    if(!emailList.isEmpty()) {
        Set<Id> caseIds = new Set<Id>(); //Case Id associated with outgoing email message
        String defaultFromAddress = CS_SystemConstants.getOrgWideEmailForDisplayName(CS_SystemConstants.ORG_WIDE_PROTEIN_SERVICE_EMAIL);
    if(String.isNotBlank(defaultFromAddress)) {
        CS_EmailMessageHelper.updateValidateFromAddress(emailList, defaultFromAddress, caseIds);
    if(!caseIds.isEmpty()) {
        CS_EmailMessageHelper.appendCaseNumberToSubject(emailList, caseIds);
    }
}

    /*Phase 2 POC 
    * PDL implementation
    */
    
    Map<String,String> userPDLMap = new Map<String,String>();
    //get the PDLs associated with each users from the Ciustom Metadata 
    userPDLMap = CS_EmailMessageHelper.getUserPDLMap();

    system.debug('\n\n\n******** userPDLMap : '+userPDLMap);
    for(EmailMessage em : emailList){
        if(!em.incoming && em.ToAddress != null){
            List<String> toAddressList = em.ToAddress.deleteWhitespace().split(',');
            
            //calling setToAddress to change the PDL to corresponding ToAddresses
            CS_EmailMessageHelper.setToAddress(em , toAddressList , userPDLMap);
        }
    }
    
        system.debug('\n\n\n*******emailList : '+emailList);
    }
}


/*
* @description This method will assign internal protein cases to the first CSR found in the To Address of email message.
* @param List of Email Message records (Trigger.New)
*/
@InvocableMethod(label='Assign Case To CSR' description='Assign case to first CSR found in the email message')
public static void assignInternalCaseOwner(List<EmailMessage> emailList) {
    if(!emailList.isEmpty()) {
        
        //Set of email address to query user record
        Set<String> emailSet = new Set<String>();
        //Store Map of Case with ToAddress
        Map<Id,String> mapCaseIdToAddress = new Map<Id,String>();
        //List of case to update with owner id
        Map<Id,Case> casesToUpdate = new Map<Id, Case>();
        //POC for Internal users
        Map<Id,Case> caseMap = new Map<Id,Case>();
     
        //Calling getEmailList method to get all To addresses in a Set
        emailSet = CS_EmailMessageHelper.getEmailSet(emailList , mapCaseIdToAddress);

        for(Case c : [SELECT id,suppliedEmail,contactid FROM Case WHERE id IN: mapCaseIdToAddress.keyset()]){
            caseMap.put(c.id,c);
        }

        System.debug('********EmailSet: ' + emailSet);
        //System.debug('/n/n*****mapCaseIdToAddress: ' + mapCaseIdToAddress+'/n/n');

        //get the all user ID's based on email and active status and from Customer Service Agent  Profile
        Map<String, Id> emailUserIdMap = new Map<String, Id>(); //Contains email as key and user objectid as value
        for(User tempUser: [Select Id, email from User Where IsActive=True AND profile.name =:CS_SystemConstants.PROTEIN_PROFILE_NAME AND email IN :emailSet]) {
            emailUserIdMap.put(tempUser.email.toLowerCase(), tempUser.Id);
        }           
        System.debug('********emailUserIdMap: ' + emailUserIdMap);

        //For Contacts Using Cargill Emails - get their routing channel to route the case to correct sub-channel queue - Starts
        Map<Id, String> mapCaseIdChannelQueue = new Map<Id, String>(); //Map of Case Id and Its Contact's Routing Channel Name Mapping
        CS_EmailMessageHandlerUtility.getMapOfCaseAndChannelQueue(mapCaseIdChannelQueue, mapCaseIdToAddress.keySet());
        //For Contacts Using Cargill Emails - get their routing channel to route the case to correct sub-channel queue - Ends

        /*Phase 2 req - Redifined Internal User Workflow
        * 1. When the Internal User is set up as a Contact then associate it to the right Queue based on the RoutingChannel(channel + SubChannel)
        * else
        * 2. When the Internal User is found in the CustomMetadata settings 'CS_InternalUser_QueueMap__mdt' then assign the owner based on the same.
        * else
        * 3. When there is atleast one CSR found in the 'ToAddress' of the incoming mail assign the same CSR as the Case Owner
        * else
        * 4. If nothing is found as per the above associate the Case to 'NoContactQueue'
        */ 
        
        //loop through the cases to find the CSR for the case
        for(Id tempId: mapCaseIdToAddress.keySet()) {
        
                casesToUpdate = genericCaseAssignementBasedOnContact(mapCaseIdChannelQueue.get(tempId) , tempId , caseMap.get(tempId).ContactId);

            //Map Internal Users as per the custom settings CS_InternalUser_QueueMap__mdt to the associated Queue 
            if(casesToUpdate.get(tempId) == null){
                casesToUpdate = internalCaseAssignmentViaCustomMetaData(tempId , caseMap.get(tempId).SuppliedEmail);
            }
            //Set any CSRs in ToAddress as Case Owner 
            if(casesToUpdate.get(tempId) == null){    
                casesToUpdate = internalCaseAssignmentViaCSRToAddress(mapCaseIdToAddress , emailUserIdMap , tempId);                                
            }                        

            if(casesToUpdate.get(tempId) == null) { //assign to no contact queue for cases 
                casesToUpdate.put(tempId, new Case(Id=tempId, OwnerId=noContactQueueId, CS_Is_Internal__c=(String.isNotBlank(mapCaseIdChannelQueue.get(tempId)) ? false : true)));
            }                   
        }
        //update the case
        Database.SaveResult[] srList = Database.update(casesToUpdate.values(), false);
        // Calling getSaveResultErrors to check if any issue has happened while updating 
        CS_EmailMessageHelper.getSaveResultErrors(srList);

    }
}

    /**
    * genericCaseAssignementBasedOnContact :
    * When the Internal User is set up as a Contact then associate it to the right Queue,
    * based on the RoutingChannel(channel + SubChannel)
    * @param  caseRoutingChannel : routing channel for case(channel + SubChannel)
    * @param  tempId             : caseid
    * @param  caseContactId      : contactId associated with the case
    */

    private static Map<Id,Case> genericCaseAssignementBasedOnContact(String caseRoutingChannel, 
                                                                    Id tempId, 
                                                                    Id caseContactId){
        Map<Id,Case> casesToUpdate = new Map<Id, Case>();
        Id queueId;
        //get Queue Id of NO Contact Service Queue 
        String noContactQueueId = CS_SystemConstants.getQueueId(CS_SystemConstants.NO_CONTACT_SERVICE_QUEUE);
        if(caseRoutingChannel != null){
            queueId = queueMap.get(caseRoutingChannel);
        }

        if(queueId != null) { //If sub-channel queue found then assign to sub-channel queue
            casesToUpdate.put(tempId, new Case(Id=tempId, OwnerId=queueId, CS_Is_Internal__c=false));
        }else if(queueId == null && caseContactId != null){
            casesToUpdate.put(tempId, new Case(Id=tempId, OwnerId=noContactQueueId, CS_Is_Internal__c=(String.isNotBlank(caseRoutingChannel) ? false : true)));
        }

        return casesToUpdate;
    }

    /**
    * internalCaseAssignmentViaCustomMetaData :
    * When the Internal User is found in the CustomMetadata settings 'CS_InternalUser_QueueMap__mdt',
    * then assign the owner based on the same.         
    * @param  tempId        :  caseid
    * @param  suppliedEmail :  email associated with the internal user configured in the custom metadata
    */

    private static Map<Id,Case> internalCaseAssignmentViaCustomMetaData(Id tempId, 
                                                                        String suppliedEmail){
        
            Map<Id,Case> casesToUpdate = new Map<Id, Case>();
            Map<String,String> internalUserQueueMap = CS_EmailMessageHelper.getInternalUserQueueMap();
            String formattedSuppliedEmail = '';
            formattedSuppliedEmail =suppliedEmail.toUpperCase();
            System.debug('\n\n\n*******suppliedEmail : '+formattedSuppliedEmail+'\n\n\n');
                    
            if(internalUserQueueMap.containsKey(formattedSuppliedEmail)){
                casesToUpdate.put(tempId, new Case(Id=tempId, OwnerId=queueMap.get(internalUserQueueMap.get(formattedSuppliedEmail)), 
                            CS_Is_Internal__c=true));

            }

            System.debug('\n\n\n*******casesToUpdate'+casesToUpdate+'\n\n\n');
            return casesToUpdate;
    }

    /**
    * internalCaseAssignmentViaCSRToAddress :
    * When there is atleast one CSR found in the 'ToAddress' of the incoming mail assign the same CSR as the Case Owner
    * @param  mapCaseIdToAddress : caseid and its corresponding mail addresses associated
    * @param  emailUserIdMap     : email and its associated User Map
    * @param  tempId             : caseId
    */
    private static Map<Id,Case> internalCaseAssignmentViaCSRToAddress(Map<Id,String> mapCaseIdToAddress, 
                                                                    Map<String, Id> emailUserIdMap, 
                                                                    Id tempId){
        
        Map<Id,Case> casesToUpdate = new Map<Id, Case>();

        if(String.isNotBlank(mapCaseIdToAddress.get(tempId))) {
            String toAddress  = '';
            toAddress = mapCaseIdToAddress.get(tempId).toLowerCase();
            for(String tempStr: toAddress.substringBetween('\nto:','\n').deleteWhitespace().split(',')) { //Check each email address in ToAddress
                //System.debug('Inner Loop: ' + tempId);
                if(tempStr.contains('<') && tempStr.contains('>')){
                    tempStr = tempStr.substringBetween('<','>') ;
                }
                //system.debug('tempStr:: ' + tempStr);
                if(emailUserIdMap.get(tempStr) != null) { //assign to CSR if found
                    casesToUpdate.put(tempId, new Case(Id=tempId, OwnerId=emailUserIdMap.get(tempStr), CS_Is_Internal__c=true));
                    //System.debug('Inner Loop Break: ' + emailUserIdMap.get(tempStr) + ' : ' + tempStr);
                    break;
                }
            }
        }    
        return casesToUpdate;
    } 

/**
 * afterInsertEmailMessage 
 * 
 * @param  emailList emailList description
 */
public static void afterInsertEmailMessage( List<EmailMessage> emailList )
{
    system.debug('emailList******'+emailList );
    if( !emailList.isEmpty() )
    {

        Set<Id> caseIds = new Set<Id>();           
        Set<Id> emailMessageIds = new Set<Id>();
        Database.SaveResult[] srList;

        CS_EmailMessageHelper.populateEmailMessageAndCaseIds(caseIds , emailMessageIds , emailList);

        if( !caseIds.isEmpty() ){
            //get Protein service case record type id
            Id recordTypeId = CS_SystemConstants.getRecordTypeId( CS_SystemConstants.PROTEIN_SERVICE_RECORD_TYPE , Case.SObjectType );
            List<case> duplicateCaseList = new List<Case>();
            List<case> reopenCaseList = new List<case>();             
            //query on case records to get Protein Service Case List
            for( case cRec: [ select id,RecordTypeId,OwnerId,Priority,Status,Reason,ParentId,Parent.IsClosed, 
                                CreatedDate from Case where RecordTypeId =: recordTypeId and Id IN:caseIds ] )
            {

                CS_EmailMessageHelper.populateDuplicateCaseAndReOpenCaselist(duplicateCaseList , reopenCaseList , cRec);

                system.debug('duplicateCaseList******'+duplicateCaseList);
                system.debug('reopenCaseList*********'+reopenCaseList);
                if( !duplicateCaseList.isEmpty() && !emailMessageIds.isEmpty() ){
                    system.debug('duplicateCaseList inside ******'+duplicateCaseList);
                    //call case helper method to clone email message from duplicate case to parent case
                    CS_CaseHelper.reparentChildRecords( duplicateCaseList, emailMessageIds,true );
                    
                }

                //update cases which are marked as Re-Open
                if( !reopenCaseList.isEmpty() ){
                    try{
                        srList = Database.update(reopenCaseList, false);
                    }
                    catch( Exception e ){
                        System.debug('Error occured : '+e);
                    }
                    CS_EmailMessageHelper.getSaveResultErrors(srList);
                }
            }
        }
    }
}


}