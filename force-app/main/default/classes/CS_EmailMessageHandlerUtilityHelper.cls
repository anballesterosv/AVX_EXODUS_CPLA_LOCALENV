/**
 * @author       Manikandan Radhakrishnapillai
 * @version      1.0
 * @createddate  Jan 20, 2020
 * @name         CS_EmailMessageHandlerUtilityHelper
 * @description  Utility class for CS_EmailMessageHandlerUtility class
 * @referencedby CS_EmailMessageHandlerUtility
 * @modifiedby
 * @modifieddate
 */

public with sharing class CS_EmailMessageHandlerUtilityHelper {

    /**
     * @description : Get the list of duplicate case which got created as part of the reply 
     *                of any of the mail(which dosent have a thread ID) that already created a Case 
     * @param       : messageIdEmailMessageMap map of Email Unique Id and its corresponding EmailMessages
     * @param       : emailMessgaeReferenceListMap map of Email Unique Id and its corresponding List of Reference IDs
     * @param       : emailMessagesToBeChecked list of emailMessages to be checked for closure
     * @return      : caseIdsToBeClosedWithParentMap map of caseIds to be closed with case information
     */
    public static Map<Id,EmailMessage> getCasesToBeClosed(Map<String,EmailMessage> messageIdEmailMessageMap,
                                                           Map<String, List<String>> emailMessgaeReferenceListMap,
                                                           List<EmailMessage> emailMessagesToBeChecked){
        
        Map<String, EmailMessage> emailMessagesToBeCheckedUniqueIdMap = new Map<String,EmailMessage>();
        Map<Id,EmailMessage> caseIdsToBeClosedWithParentMap = new Map<Id,EmailMessage>();
        

        System.debug('emailMessagesToBeChecked : '+emailMessagesToBeChecked);

        if(!emailMessagesToBeChecked.isEmpty()){
            for(EmailMessage em : emailMessagesToBeChecked){
                emailMessagesToBeCheckedUniqueIdMap.put(em.CS_EmailMessage_ID__c,em);
            }
        }

        if(!emailMessgaeReferenceListMap.isEmpty()){
            for(String emailMsgId : emailMessgaeReferenceListMap.KeySet()){
                for(String emailMsgRefId : emailMessgaeReferenceListMap.get(emailMsgId)){
                    if(emailMessagesToBeCheckedUniqueIdMap.get(emailMsgRefId) != null &&
                    emailMessagesToBeCheckedUniqueIdMap.get(emailMsgRefId).parent.status != NULL &&
                    emailMessagesToBeCheckedUniqueIdMap.get(emailMsgRefId).parent.status != 'Closed'){
                        caseIdsToBeClosedWithParentMap.put(messageIdEmailMessageMap.get(emailMsgId).parentId,
                                                           emailMessagesToBeCheckedUniqueIdMap.get(emailMsgRefId));
                    }
                }
            }
        }

        return caseIdsToBeClosedWithParentMap;
    }

    /**
     * @description : This method will stamp the CS_EmailMessage_ID__c with unique Message Id from the 
     *                Email Message header via regular expression
     * @param       : emailMessage emailMessage record for which the unique id should get stamped
     * @param       : messageIdEmailMessageMap preparing a map with the above uniqie id and the emailMessage record
     */
    public static void stampEmailMessageID(EmailMessage emailMessage, 
                                            Map<String,EmailMessage> messageIdEmailMessageMap) {

        String regex = 'Message-ID: \\<(.*?)\\>';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(emailMessage.headers);

        if(regexMatcher.find()) {
            system.debug('Message-ID extracted : ' + regexMatcher.group(1));
            emailMessage.CS_EmailMessage_ID__c = regexMatcher.group(1);
            messageIdEmailMessageMap.put(emailMessage.CS_EmailMessage_ID__c,emailMessage);
        }

    }

    /**
     * @description : This method will get all the Reference Message id list from the 
     *                Email Message header via regular expression
     * @param       : em emailMessage record from which we have to fetch the refernce List
     * @param       : emailMessageReferenceListMap map of Email Unique Id and its corresponding List of Reference IDs
     * @param       : refList list of message Id references
     */
    public static void getEmailMessageReferenceListMap(EmailMessage em, 
                                                        Map<String, List<String>> emailMessageReferenceListMap,
                                                        List<String> refList) {

        List<String> messageIds = new List<String>();

        String regex = 'References: \\<(.*?)\\>((,| )\\<(.*?)\\>)*';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(em.headers);

        if(regexMatcher.find()) {
            //System.debug('matcher : '+regexMatcher);
            //System.debug('matcher : '+ s.substring(regexMatcher.start(),regexMatcher.end()));
            String match = em.headers.substring(regexMatcher.start(), regexMatcher.end());
            for(String msgId : match.split('( |,)?<|>')){
                if(!msgId.contains('References:') && msgId.length()>1){
                    messageIds.add(msgId);
                }
            }
            System.debug('messageId Ref List : '+messageIds);
            emailMessageReferenceListMap.put(em.CS_EmailMessage_ID__c,messageIds);
            refList.addAll(messageIds);
        }
        
    }


    /**
     * @description : This method will assign the duplicate case to the orginal case , also 
     *                it will close the duplicate case
     * @param       : caseIdsToBeClosedWithParentMap map of case id and case record which should get closed
     */
    public static void closeCase(Map<Id,EmailMessage> caseIdsToBeClosedWithParentMap){
        
        List<Case> casesToBeClosed;
        if(!caseIdsToBeClosedWithParentMap.isEmpty() &&
            Schema.sObjectType.Case.fields.CS_Market_Channel__c.isAccessible() &&
            Schema.sObjectType.Case.fields.CS_Case_Reassignment_Reason__c.isAccessible()){
            casesToBeClosed = [SELECT id,CS_Market_Channel__c,Reason,CS_Case_Sub_Reason__c,
                                      CS_Case_Reassignment_Reason__c,status,OwnerId,CS_Is_Duplicate__c
                                FROM Case 
                                WHERE id IN:caseIdsToBeClosedWithParentMap.KeySet()];
        }

        populateCasesToBeClosed(casesToBeClosed , caseIdsToBeClosedWithParentMap);

        try{
            if(!casesToBeClosed.isEmpty() && 
               Schema.sObjectType.Case.fields.parentId.isUpdateable() &&
               Schema.sObjectType.Case.fields.CS_Market_Channel__c.isUpdateable()){
                update casesToBeClosed;
            }
        }catch(Exception ex){
            CS_SystemConstants.printExceptions(ex);
        }
    }


    private static void populateCasesToBeClosed(List<Case> casesToBeClosed,
                                         Map<Id,EmailMessage> caseIdsToBeClosedWithParentMap){

        if(!casesToBeClosed.isEmpty()){
            for(Case newCase: casesToBeClosed){
                newCase.parentId = caseIdsToBeClosedWithParentMap.get(newCase.id).parentId;
                newCase.CS_Market_Channel__c = caseIdsToBeClosedWithParentMap.get(newCase.id).parent.CS_Market_Channel__c;
                newCase.OwnerId = caseIdsToBeClosedWithParentMap.get(newCase.id).parent.OwnerId;
                newCase.CS_Is_Duplicate__c = true;
            }
        }

    }
}