/**
 * @author       Manikandan Radhakrishnapillai
 * @version      1.0
 * @createddate  Jan 31, 2020
 * @name         CS_EmailMessageHandlerUtilityHelper_Test
 * @description  Test class for CS_EmailMessageHandlerUtilityHelper class
 * @modifiedby
 * @modifieddate
 */

@IsTest
public with sharing class CS_EmailMessageHandlerUtilityHelper_Test {
    
    
    /**
     * @Description : This method will test the method getCasesToBeClosed, it will also cover the methods like 
     *                stampEmailMessageID,getEmailMessageReferenceListMap of CS_EmailMessageHandlerUtilityHelper
     */
    public static testmethod void testgetCasesToBeClosed(){
        
        List<EmailMessage> emList = CS_TestDataHelper.getEmailMessageRecords('New',false,null,'mani@gmail.com');
        List<Id> emailIds = new List<Id>();
        
        for(EmailMessage em :emList){
            emailIds.add(em.id);
        }

        List<EmailMessage> emailMessagesToBeChecked = [SELECT id,parentId,parent.CS_Market_Channel__c,parent.status,
                                                              CS_EmailMessage_ID__c, parent.ownerId
                                                       FROM EmailMessage
                                                       WHERE id IN:emailIds];

        Map<String,EmailMessage> messageIdEmailMessageMap = new Map<String,EmailMessage>();
        Map<String, List<String>> emailMessgaeReferenceListMap = new Map<String, List<String>>();
        for(EmailMessage em : emailMessagesToBeChecked){
            messageIdEmailMessageMap.put('HK2PR0201MB20985818F3CF2C20DA8B8655B4220@HK2PR0201MB2098.apcprd02.prod.outlook.com',em);
            emailMessgaeReferenceListMap.put('HK2PR0201MB20985818F3CF2C20DA8B8655B4220@HK2PR0201MB2098.apcprd02.prod.outlook.com',
                                            new List<String>{'BN7PR04MB3825BAB516EBABD16BE41D83DF220@BN7PR04MB3825.namprd04.prod.outlook.com',
                                                             'HK2PR0201MB20985818F3CF2C20DA8B8655B4220@HK2PR0201MB2098.apcprd02.prod.outlook.com'});
        }
        
            Map<Id,EmailMessage> casesToBeClosed = CS_EmailMessageHandlerUtilityHelper.getCasesToBeClosed(
                                                                       messageIdEmailMessageMap,
                                                                       emailMessgaeReferenceListMap, 
                                                                       emailMessagesToBeChecked);
            System.assertEquals(casesToBeClosed.size(),1);
    }

    /**
     * @Description : This method will test the method closeCase, it will also cover the methodpopulateCasesToBeClosed
     *                of CS_EmailMessageHandlerUtilityHelper
     */
    public static testMethod void testcloseCase(){
          
            List<EmailMessage> emList = CS_TestDataHelper.getEmailMessageRecords('New',true,null,'mani@gmail.com');

            system.debug('emList : '+emList);
            List<Id> emailIds = new List<Id>();
            Map<Id,EmailMessage> caseIdsToBeClosedWithParentMap = new Map<Id,EmailMessage>();
            for(EmailMessage em :emList){
                emailIds.add(em.id);
            }

            List<EmailMessage> emailMessagesToBeChecked = [SELECT id,parentId,parent.CS_Market_Channel__c,parent.status,
                                                                CS_EmailMessage_ID__c, parent.ownerId
                                                        FROM EmailMessage
                                                        WHERE id IN:emailIds];

            system.debug('emailMessagesToBeChecked : '+emailMessagesToBeChecked);
            for(EmailMessage em : emailMessagesToBeChecked){
                caseIdsToBeClosedWithParentMap.put(em.parentId,em);
            }

            System.assertEquals(caseIdsToBeClosedWithParentMap.size(),1);
            CS_EmailMessageHandlerUtilityHelper.closeCase(caseIdsToBeClosedWithParentMap);

    }

}