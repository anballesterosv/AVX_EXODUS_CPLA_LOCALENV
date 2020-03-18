/**
* @author       Ratnesh Kumar
* @version      1.0
* @createddate  Mar 19, 2019
* @name         CS_CaseHelper
* @description  Helper class for Protein Case Trigger and Handler. Contains common Protein business specific utility/helper methods.
                This class also helps to reduce the cyclomatic complexity to caller class. 
* @referencedby CS_CaseHandler
* @modifiedby   
* @modifieddate 
*/ 
public with sharing class CS_CaseHelper {

    /*
     * @description This method add ShipTo ID of supplied Case to the supplied Set, if ShipTo is entered for Case in below flow
                    1. Case created manually by CSR.
                    2. ShipTo is changed manually by CSR for Case Update.
     * @param Case tempCase Case reference.
     * @param Set<Id> shipToIdsForAccount Set reference into which ShipTo ID will be added.
    */
    public static void getShipToIdsForAccount(Case tempCase, Set<Id> shipToIdsForAccount) {
        System.debug('Inside getShipToIdsForAccount.');
        if(String.isNotBlank(tempCase.CS_Ship_To__c)) { //For manual/phone/fax/email case get the Ship To Id entered to populate account
            shipToIdsForAccount.add(tempCase.CS_Ship_To__c);
        }
    }
    
    /*
     * @description This method add ContactID of supplied Case to the supplied Set, if only Contact and No Ship To is assigned to Case in below flow
                    1. Case created through Email-to-Case flow.
                    2. Case created manually by CSR.
     * @param Case tempCase Case reference.
     * @param Set<Id> contactIdsForSingleShipTo Set reference into which ContactID will be added.
    */
    public static void getContactIdsForSingleShipTo(Case tempCase, Set<Id> contactIdsForSingleShipTo) {
        System.debug('Inside getContactIdsForSingleShipTo.');
        //If only Contact and No Ship To is assigned to Case, get contact to populate Ship To and Account
        if(String.isNotBlank(tempCase.ContactId) && String.isBlank(tempCase.CS_Ship_To__c)) {
            contactIdsForSingleShipTo.add(tempCase.ContactId);
        }
    }

    /* Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
     *
     * @description This method add ShipToID of supplied Case to the supplied Set, if only ShipTo and No Contact is assigned to Case in below flow
                    1. Case created through Email-to-Case flow.
                    2. Case created manually by CSR.
     * @param Case tempCase Case reference.
     * @param Set<Id> contactIdsForSingleShipTo Set reference into which ContactID will be added.
    */
    public static void getShipToIdsForSingleContact(Case tempCase, Set<Id> shipToIdsForSingleShipTo) {
        System.debug('Inside getShipToIdsForSingleContact.');
        //If only Ship To and No Contact is assigned to Case, get shipTo to populate Contact and Account
        if(String.isBlank(tempCase.ContactId) && String.isNotBlank(tempCase.CS_Ship_To__c)) {
            shipToIdsForSingleShipTo.add(tempCase.CS_Ship_To__c);
        }
    }
    
    /*
     * @description This method does Case field updates in 2 scenarios
                    1. Single Active ShipTo Related to Contact Scenario - Update ShipTo and Account Fields.
                    2. ShipTo is entered or updated on Case Scenarios - Update the Account field with ShipTo's Commercial Account.
     * @param Case tempCase Case reference to update.
     * @param CS_Ship_To_Contact_Relation__c contactShipToRelationRec ShipTo Contact Relation record to get Ship To related to Contact & Commercial Account
     * @param Ship_To__c shipToRec ShipTo record to get Commercial Account
    */
    public static void populateSingleShipToAndAccount(Case tempCase, CS_Ship_To_Contact_Relation__c contactShipToRelationRec, Ship_To__c shipToRec) {
        System.debug('Inside populateSingleShipToAndAccount.');
        if(contactShipToRelationRec != null) { //for email-to-case and manual case with no Ship To entered scenario
            tempCase.AccountId = contactShipToRelationRec.CS_Ship_To__r.Commercial_Account__c;
            tempCase.CS_Ship_To__c = contactShipToRelationRec.CS_Ship_To__c;
        } else if(shipToRec != null) { //for manual case if ship to entered then populate account with Ship To's Commercial account
            tempCase.AccountId = shipToRec.Commercial_Account__c;
        }
        
        //start Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
        system.debug('******contactShipToRelationRec : '+contactShipToRelationRec);

        if(tempCase.ContactId == null && contactShipToRelationRec != null){
            tempCase.ContactId = contactShipToRelationRec.CS_Contact__c;
        }
        system.debug('******CS_CaseHelper 63 tempCase : '+tempCase);
        //end Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
    }

    /*
     * @description This method does prepares below data to validate ShipTo Contact Relation for a case
                    1. Set of ShipTo associated with case
                    2. Set of Contact associated with case.
                    3. List of cases to be validated for ShipTo Contact Relation.
     * @param Case tempCase Case reference to update.
     * @param Map<String, Set<Id>> mapContactAndShiptoIdsToValidate - Map of set of ShipTo and Contact to be validated for relation.
     * @param List<Case> caseListToValidate - List of cases to be validated
    */
    public static void prepareToValidateShipToContactRelation(Case tempCase, Map<String, Set<Id>> mapContactAndShiptoIdsToValidate, List<Case> caseListToValidate) {
        System.debug('Inside prepareToValidateShipToContactRelation.');
        //get list of contacts, shipTos and cases when both Contact and shipTo are populated
        if(String.isNotBlank(tempCase.ContactId) && String.isNotBlank(tempCase.CS_Ship_To__c)) {
            mapContactAndShiptoIdsToValidate.get('Contact').add(tempCase.ContactId);
            mapContactAndShiptoIdsToValidate.get('ShipTo').add(tempCase.CS_Ship_To__c);
            caseListToValidate.add(tempCase);
        }
    }
    
    /*
     * @description This method does the below operation for facilitating the validation of ShipTo and Contact Relation for a case
                    1. Prepares the map of Contact and its related ShipTo fetched from CS_Ship_To_Contact_Relation__c for involded contact and shipto
                    2. Call the method that actually validate the relation based on the list of cases and map of Contact and its related ShipTo fetched.
     * @param List<Case> caseListToValidate - List of cases to be validated
     * @param Map<String, Set<Id>> mapContactAndShiptoIdsToValidate - Map of set of ShipTo and Contact to be validated for relation.
    */
    public static void validateShipToContactRelation(List<Case> caseListToValidate, Map<String, Set<Id>> mapContactAndShiptoIdsToValidate) {
        System.debug('Inside validateShipToContactRelation.');
        if(!caseListToValidate.isEmpty()) {
            Map<Id,List<Id>> mapContactShipTo = new Map<Id,List<Id>>();
            //get ship tos related to Contact
            mapContactShipTo = getContactShipToRelation(mapContactAndShiptoIdsToValidate.get('Contact'), mapContactAndShiptoIdsToValidate.get('ShipTo'));
            validateRelation(mapContactShipTo, caseListToValidate); //pass the data to validation routine
        }
    }

    /*
     * @description This method validates the combination of Contact and ShipTo on case for their relation. 
                    If they are nor related it adds error to the case.
     * @param Map<Id,List<Id>> mapContactShipTo Map of Contact and its related ShipTo.
     * @param List<Case> caseListToValidate - List of cases to be validated
    */
    public static void validateRelation(Map<Id,List<Id>> mapContactShipTo, List<Case> caseListToValidate) {
        System.debug('Inside validateRelation.');
        //check if the Case ShipTo and its contact are related
        for(Case temp :caseListToValidate) {
            if(mapContactShipTo.get(temp.ContactId) == null || 
               (!mapContactShipTo.get(temp.ContactId).contains(temp.CS_Ship_To__c))) {
                temp.addError(Label.CS_Ship_To_Contact_Relation_Error_Message);    
            }
        }
    }

    /*
     * @description This method will get map of contact & Ship To Contact Relation only if there is 1:1 relation between contact and active Ship To.
     * @param Set<Id> contactIds Set of Contact Ids for which Ship To Contact Relation needed
     * @return Map<Id,CS_Ship_To_Contact_Relation__c> Map of contactid & its Ship To Contact Relation record if 1 active shipto found.
    */
    public static Map<Id,CS_Ship_To_Contact_Relation__c> getContactWithSingleShipToRelation(Set<Id> contactIds) {
        Map<Id,CS_Ship_To_Contact_Relation__c> contactShipToRelationMap = new Map<Id,CS_Ship_To_Contact_Relation__c>();
        for(Contact temp: [SELECT Id,(SELECT CS_Ship_To__c, CS_Ship_To__r.Commercial_Account__c
                                      FROM Ship_To_Contact_Relation__r
                                      WHERE CS_Ship_To_Status__c = 'Active' limit 2)
                           FROM Contact 
                           WHERE Id IN :contactIds]) {
           if(temp.Ship_To_Contact_Relation__r.size() == 1) {
                contactShipToRelationMap.put(temp.Id, temp.Ship_To_Contact_Relation__r.get(0));
           }           
        }
        return contactShipToRelationMap;
    }
    
    /* Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
     *
     * @description This method will get map of contact & Ship To Contact Relation only if there is 1:1 relation between shipTo and active Contact.
     * @param Set<Id> shipToIds : Set of ShipTo Ids for which Ship To Contact Relation needed
     * @return Map<Id,CS_Ship_To_Contact_Relation__c> Map of ShipToId & its Ship To Contact Relation record if 1 active Contact found.
    */
    public static Map<Id,CS_Ship_To_Contact_Relation__c> getContactWithSingleShipToRelationFromShipTo(Set<Id> shipToIds) {
        Map<Id,CS_Ship_To_Contact_Relation__c> shipToContactRelationMap = new Map<Id,CS_Ship_To_Contact_Relation__c>();
        for(Ship_To__c temp: [SELECT Id,(SELECT CS_Ship_To__c, CS_Contact__c, CS_Ship_To__r.Commercial_Account__c
                                      FROM Ship_To_Contact_Relation__r
                                      WHERE CS_Contact_Status__c = 'Active' limit 2)
                           FROM Ship_To__c 
                           WHERE Id IN :shipToIds]) {
           if(temp.Ship_To_Contact_Relation__r.size() == 1) {
                shipToContactRelationMap.put(temp.Id, temp.Ship_To_Contact_Relation__r.get(0));
           }           
        }
        system.debug('shipToContactRelationMap : '+shipToContactRelationMap);
        return shipToContactRelationMap;
    }
    
    
    
    /*
     * @description This method will get the contact and its related shipTos in a map.
     * @param Set<Id> contactIds Contact Ids to be look for.
     * @param set<Id> shipToIds ShipTo Ids to be look for.
     * @return Map<Id,List<Id>> Map of the contact and its related shipTos
    */
    public static Map<Id,List<Id>> getContactShipToRelation(Set<Id> contactIds, Set<Id> shipToIds) {
        Map<Id,List<Id>> mapContactShipTos = new Map<Id,List<Id>>();
        if(!contactIds.isEmpty() && !shipToIds.isEmpty()) {
            for(CS_Ship_To_Contact_Relation__c temp: [SELECT CS_Contact__c,CS_Ship_To__c  
                                                      FROM CS_Ship_To_Contact_Relation__c 
                                                      WHERE CS_Contact__c IN :contactIds
                                                      AND  CS_Ship_To__c IN: shipToIds]) {
                                                        
                    if(mapContactShipTos.get(temp.CS_Contact__c) != null) {
                        mapContactShipTos.get(temp.CS_Contact__c).add(temp.CS_Ship_To__c);
                    } else {
                        mapContactShipTos.put(temp.CS_Contact__c, new List<Id>{temp.CS_Ship_To__c});
                    }
             }
        }
        return mapContactShipTos;
    }
    
    /*
     * @description This method will get the commercial account associated with ship to in map.
     * @param Set<Id> shipToIds Set of Ship To Ids for which commercial needed.
     * @return Map<Id,Ship_To__c> Map of Ship To record having commercial account.
    */
    public static Map<Id,Ship_To__c> getShipToCommercialAccountMap(Set<Id> shipToIds) {
        Map<Id,Ship_To__c> mapShipToCommercialAccount; 
        if(!shipToIds.isEmpty()) {
            mapShipToCommercialAccount = new Map<ID, Ship_To__c>([SELECT Id, Commercial_Account__c FROM Ship_To__c WHERE Commercial_Account__c != null AND ID IN :shipToIds]);
        }
        return (mapShipToCommercialAccount != null ? mapShipToCommercialAccount : new Map<Id, Ship_To__c>());
    }
    /*
Description : Invocable Method to Clone Email message records from child records to parent case
Input: List<Case>- duplicate case list,       
Output :   None
*/
    @InvocableMethod(label='Create Child Record' description='Create Child Records related to case')
    public static void createChildRecords( List<case> caseList )
    {
        system.debug('caseList **********'+caseList );
        
        
          for(case c : caseList){
          
          system.debug('Case status:::'+ c.status);
        
        }
        
         
        //call method to initiate child record creation
        reparentChildRecords( caseList, new Set<Id>(),false );
              
    }
    /*
Description : Method to Clone Email message records from child records to parent case
Input: List<Case>- duplicate case list,
Set<Id< emailMessageIds - if present then need to process only Records with these Ids
Output :   None
*/
    public static void reparentChildRecords( List<case> caseList, Set<Id> emailMessageIds,boolean fromEmailTrigger )
    {
        
       
        try{
            if( caseList != null && !caseList.isEmpty() )
            {
                Set<Id> emailIdsSet = new Set<Id>();
                if( emailMessageIds!= null )
                {
                    emailIdsSet = emailMessageIds;
                }
                Map<Id,Id> caseIdMap = new Map<Id,Id>();   //map of case id and parent case id
                for( Case caseRec: caseList )
                {
                    
                    if( String.isNotBlank( caseRec.ParentId ) )
                    {
                        caseIdMap.put( caseRec.Id,caseRec.ParentId );
                    }
                    
                }
                system.debug('caseIdMap***'+caseIdMap);
                if( !caseIdMap.isEmpty() )
                {
                    //query on EmailMessage record
                    List<EmailMessage> emailList = new List<EmailMessage>([ SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, 
                                                                           LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, FromName, 
                                                                           FromAddress, ValidatedFromAddress, ToAddress, CcAddress, BccAddress, Incoming, 
                                                                           HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsExternallyVisible, 
                                                                           MessageIdentifier, ThreadIdentifier, IsClientManaged , RelatedToId FROM EmailMessage 
                                                                           where ParentId IN: caseIdMap.keySet()
                                                                          ]);
                    system.debug('emailList****'+emailList);
                    List<EmailMessage> oldEmailList = new List<EmailMessage>();
                    List<EmailMessage> insertEmailList = new List<EmailMessage>();
                    //iterate to create new email message records
                    for( EmailMessage eRec: emailList )
                    {
                        //check added to exclude Auto response rule records
                        //If mehtod is getting called from email message trigger, then only records in set will be cloned.
                        if( caseIdMap.containsKey( eRec.ParentId ) && 
                           ( String.isBlank( eRec.Headers ) || ( String.isNotBlank( eRec.Headers ) && !eRec.Headers.contains( CS_SystemConstants.AUTO_RESPONE_HEADER ) ) ) &&
                           ( emailIdsSet.isEmpty() || ( !emailIdsSet.isEmpty() && emailIdsSet.contains( eRec.Id ) ) ) 
                          )
                        {
                            oldEmailList.add( eRec );
                            //create new email message records under parent case
                            EmailMessage eMsg = new EmailMessage();
                            eMsg.ParentId = caseIdMap.get( eRec.ParentId );
                            eMsg.TextBody = eRec.TextBody;
                            eMsg.HtmlBody = eRec.HtmlBody;
                            eMsg.Headers = eRec.Headers;
                            eMsg.Subject = eRec.Subject;
                            eMsg.FromName = eRec.FromName;
                            eMsg.FromAddress = eRec.FromAddress;
                            //eMsg.ValidatedFromAddress = eRec.ValidatedFromAddress; //commented to avoid bad picklist issue
                            eMsg.ToAddress = eRec.ToAddress;
                            eMsg.BccAddress = eRec.BccAddress;
                            eMsg.CcAddress = eRec.CcAddress;
                            eMsg.Incoming = eRec.Incoming;
                            //eMsg.HasAttachment = eRec.HasAttachment;  //not writeable
                            eMsg.Status = eRec.Status;
                            eMsg.MessageDate = eRec.MessageDate;
                            //eMsg.ReplyToEmailMessageId = eRec.ReplyToEmailMessageId;  //to be updated later
                            //eMsg.ActivityId = eRec.ActivityId;    //will be updated automatically
                            //eMsg.IsExternallyVisible = eRec.IsExternallyVisible;  //not writeable
                            eMsg.MessageIdentifier = eRec.MessageIdentifier;
                            eMsg.ThreadIdentifier = eRec.ThreadIdentifier;
                            eMsg.IsClientManaged = eRec.IsClientManaged;
                            eMsg.CS_Created_From_Duplicate_Case__c= true;
                            
                            insertEmailList.add( eMsg );
                        }
                    }
                    
                    system.debug('insertEmailList**********'+insertEmailList);
                    system.debug('oldEmailList*********'+oldEmailList);
                    if( !insertEmailList.isEmpty() )
                    {
                        
                        try
                        {
                            //disable trigegr execution for Email Message 
                            CS_EmailMessageHandler.bDisableEmailTriggerExecution = true;
                            //insert Email Message Records
                            insert insertEmailList;
                            
                            //Enable trigegr execution for Email Message 
                            CS_EmailMessageHandler.bDisableEmailTriggerExecution = false;
                            
                            //system.debug('old size>>'+emailList.size()+'new size>>'+insertEmailList.size());
                            
                            //create map of old email message id and new email message id
                            Map<String,String> oldNewEmailMap = new Map<String,String>();
                            for( Integer i = 0; i < oldEmailList.size(); i++ )
                            {
                                oldNewEmailMap.put( oldEmailList[i].id, insertEmailList[i].id );
                            }
                            //query on Attachment records related to Email Messages
                            List<Attachment> attachList = new List<Attachment>();
                            system.debug('oldNewEmailMap:::::::::::'+oldNewEmailMap.keySet());
                             
                            if(fromEmailTrigger){
                            
                            insertAttachments(oldNewEmailMap.keySet(),oldNewEmailMap);
                            }
                            else{                      
                            for( Attachment aRec: [ SELECT Id, ParentId, Name, IsPrivate, ContentType, BodyLength, Body, 
                                                   OwnerId, Description, IsPartnerShared, ConnectionReceivedId, ConnectionSentId 
                                                   FROM Attachment where ParentId IN:oldNewEmailMap.keySet()
                                                  ])
                            {
                                system.debug('aRec.ParentId:::::::::::'+aRec.ParentId);
                                 system.debug('aRec*******'+aRec);
                                if( oldNewEmailMap.containsKey( aRec.ParentId ) )
                                {
                                    Attachment newAttRec = new Attachment();
                                    newAttRec.ParentId = oldNewEmailMap.get( aRec.ParentId );
                                    newAttRec.Name =  aRec.Name;
                                    newAttRec.IsPrivate =  aRec.IsPrivate;
                                    newAttRec.ContentType =  aRec.ContentType;
                                    newAttRec.Body =  aRec.Body;
                                    attachList.add( newAttRec );
                                    system.debug('attachList:::::::'+attachList.size());
                                }
                                
                            }
                             //query on Content Document Link records to create New  link
                              List<ContentDocumentLink> insertDocLinkList = new List<ContentDocumentLink>();
                        Set<String> parentIdSet = oldNewEmailMap.keySet();
                        system.debug('parentIdSet************'+parentIdSet);
                        for( ContentDocumentLink cLink : [ select LinkedEntityId, ContentDocumentId,ShareType,Visibility FROM 
                                                          ContentDocumentLink where LinkedEntityId IN:parentIdSet
                                                         ] )
                        {
                        system.debug('cLink ************'+cLink );
                            ContentDocumentLink cNewLink = new ContentDocumentLink();
                            cNewLink.ContentDocumentId = cLink.ContentDocumentId;
                            cNewLink.LinkedEntityId = oldNewEmailMap.get( cLink.LinkedEntityId );
                            cNewLink.ShareType = cLink.ShareType;
                            cNewLink.Visibility = cLink.Visibility;
                            
                            insertDocLinkList.add( cNewLink );
                        }
                        
                         
                            //insert attachment records
                            if( !attachList.isEmpty() )
                            {
                               CS_SystemConstants.insertAttchment( attachList );
                            }
                                 //insert content document link
                        if( !insertDocLinkList.isEmpty() )
                        {
                            insert insertDocLinkList;
                        }
                         }      
                        }
                        catch( Exception e )
                        {
                            system.debug('/n/n/n Exception Cause      : '+e.getCause()+'/n/n/n');
                            system.debug('/n/n/n Exception LineNumber : '+e.getLineNumber()+'/n/n/n');
                            system.debug('/n/n/n Exception Message    : '+e.getMessage()+'/n/n/n');
                            system.debug('/n/n/n Exception StackTrace : '+e.getStackTraceString()+'/n/n/n');
                        }
                    }
                    
                    //if method is called from Email Message trigger then exclude Case Comment Cloning.
                    if( emailIdsSet.isEmpty() )
                    {
                        //logic to move case comment from duplicate case to its parent case
                        //query on case comment records
                        List<CaseComment> insertCaseCommentList = new List<CaseComment>();
                        for( CaseComment cRec: [ SELECT Id, ParentId, IsPublished, CommentBody, 
                                                ConnectionReceivedId, ConnectionSentId FROM CaseComment 
                                                where ParentId IN: caseIdMap.keySet() 
                                               ] )
                        {
                            //create new case comment records
                            CaseComment cNewRec = new CaseComment();
                            cNewRec.ParentId = caseIdMap.get( cRec.ParentId );
                            cNewRec.IsPublished = cRec.IsPublished;
                            cNewRec.CommentBody = cRec.CommentBody;
                            insertCaseCommentList.add( cNewRec );
                        }
                        
                        if( !insertCaseCommentList.isEmpty() )
                        {
                            try
                            {
                                insert insertCaseCommentList;
                            }
                            catch( Exception e )
                            {
                                
                            }
                            
                        } 
                    }
                    
                }
            }
            
        }catch(Exception e){
            system.debug('/n/n/n Exception Cause      : '+e.getCause()+'/n/n/n');
            system.debug('/n/n/n Exception LineNumber : '+e.getLineNumber()+'/n/n/n');
            system.debug('/n/n/n Exception Message    : '+e.getMessage()+'/n/n/n');
            system.debug('/n/n/n Exception StackTrace : '+e.getStackTraceString()+'/n/n/n');
        }
    }
    
    @future
    public static void insertAttachments( set<String> parentIdSet,Map<String,String> oldNewEmailMap){
    
    
     List<Attachment> attachList = new List<Attachment>();
      for( Attachment aRec: [ SELECT Id, ParentId, Name, IsPrivate, ContentType, BodyLength, Body, 
                                                   OwnerId, Description, IsPartnerShared, ConnectionReceivedId, ConnectionSentId 
                                                   FROM Attachment where ParentId IN:oldNewEmailMap.keySet()
                                                  ])
                              {
                                if( oldNewEmailMap.containsKey( aRec.ParentId ) )
                                {
                                    Attachment newAttRec = new Attachment();
                                    newAttRec.ParentId = oldNewEmailMap.get( aRec.ParentId );
                                    newAttRec.Name =  aRec.Name;
                                    newAttRec.IsPrivate =  aRec.IsPrivate;
                                    newAttRec.ContentType =  aRec.ContentType;
                                    newAttRec.Body =  aRec.Body;
                                    attachList.add( newAttRec );
                                    system.debug('attachList:::::::'+attachList.size());
                                }
                                
                            }
                            //insert attachment records
                            if( !attachList.isEmpty() )
                            {
                               CS_SystemConstants.insertAttchment( attachList );
                            }
        }
    
}