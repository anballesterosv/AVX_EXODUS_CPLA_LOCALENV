/**
* @author       Ratnesh Kumar (ratnesh_kumar@crgl-thirdparty.com)
* @version      1.0
* @createddate  Feb 2, 2019
* @name         CS_TestDataHelper
* @description  Helper Test class for creating test data for other test classes
* @modifiedby   
* @modifieddate 
*/
@isTest
public class CS_TestDataHelper {
    
    public static final String GLOBALACCOUNT_RECORD_TYPE = 'GlobalAccount';
    public static final String PAYERCCOUNT_RECORD_TYPE = 'Payer';
    public static final String COMMERCIALACCOUNT_RECORD_TYPE = 'CommercialAccount';
    public static final String INTERNAL_MARKETCHANNEL = 'Internal'; 
    public static final String FOODSERVICE_MARKETCHANNEL = 'Food Service';
    public static final String PI_MARKETCHANNEL = 'Protein Ingredients';
    public static final String FS_CUSTOMERSERVICEAGENT_ROLE = 'Food Service Customer Service Agent';
    
    /**
* @Description :
*  This function will insert Integration_profile__c custom setting with SkipValidationProfiles__c= true
* 
* @author : Manikandan Radhakrishnapillai
*/
    
    public static void insertCustomIntegrationProfileDetail(){
        try{
            List<Integration_profile__c> ip = [SELECT id FROM Integration_profile__c WHERE SetupOwnerId =: UserInfo.getOrganizationId()];
            if(  ip.size() == 0)
                insert new Integration_profile__c(SetupOwnerId=UserInfo.getOrganizationId(), SkipValidationProfiles__c=true);
            else{
                ip[0].SkipValidationProfiles__c=true;
                update ip[0];
            }
        }catch(Exception ex){
            System.debug('******Exception occured in insertCustomIntegrationProfileDetail*******');
            System.debug('Exception Message :'+ex.getMessage());
            System.debug('Exception Cause :'+ex.getCause());
            System.debug('Exception StackTrace :'+ex.getStackTraceString());
        }
    }
    
    
    /**
* @Description :
*  This function will create the 'Bill_To__c' record for a payerAccount and return the same
* 
* @author : Manikandan Radhakrishnapillai
* @param payerAccountId : AccountId  of type 'Payer'    
* @return  Bill_To__c record
*/
    public static Bill_To__c createBillTo( Id payerAccountId) {
        Bill_To__c billTo = new Bill_To__c(Name='Test Bill To', Payer__c= payerAccountId);
        try{
            insert billTo;
        }catch(Exception ex){
            
        }
        return billTo;
    }
    
    
    /**
* @Description :
*  This function will create the 'Ship_To__c' record with billToId, payerAccountId,commercialAccountid and return the same
* 
* @author : Manikandan Radhakrishnapillai
* @param billToId, payerAccountId,commercialAccountid    
* @return Ship_To__c record 
*/
    public static Ship_To__c createShipTo( Id billToId, Id payerAccountId, Id commercialAccountid) {
        Ship_To__c shipTo = new Ship_To__c(Name='Test Ship To', 
                                           Sold_To__c= billToId, 
                                           Payer__c= payerAccountId, 
                                           Commercial_Account__c= commercialAccountid, 
                                           Status__c = 'Active');
        try{
            insert shipTo;
        }catch(Exception ex){
            
        }
        return shipTo;
    }
    
    /**
* @Description :
*  This function will create the 'CS_Ship_To_Contact_Relation__c' record with contactId,shipToId and return the same
* 
* @author : Manikandan Radhakrishnapillai
* @param contactId,shipToId    
* @return CS_Ship_To_Contact_Relation__c record 
*/   
    public static CS_Ship_To_Contact_Relation__c createShipToContactRelation( Id contactId, Id shipToId) {
        CS_Ship_To_Contact_Relation__c ShipToRelation = new CS_Ship_To_Contact_Relation__c(CS_Contact__c= contactId, CS_Ship_To__c= shipToId);
        System.debug(ShipToRelation);
        try{
            insert ShipToRelation;
        }catch(Exception ex){
            
        }
        return ShipToRelation;
    }
    
    /**
* @Description :
*  This function will create Account Record with given accName, recordTypeName & marketChannel and return the same
* 
* @author : Manikandan Radhakrishnapillai
* @param : accName - name of the Account, 
recordTypeName - Account recordtype,
marketChannel  - any of the market Channel 
* @return Account record 
*/
    public static Account createAccountRecord( String accName, String recordTypeName, String marketChannel )
    {
        Id recTypeId = [SELECT Id, Name FROM RecordType WHERE developerName =: recordTypeName].Id;
        Account acc = new Account(Name=accName, 
                                  Market_Channel__c=marketChannel, 
                                  Segment__c='Core',
                                  recordTypeId = CS_SystemConstants.getRecordTypeId( recordtypename, Account.SObjectType ));
        try{
            insert acc;
        }catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return acc;
        
    }
    
    /**
* @Description :
*  Create Contact record for a given Account and return the same
* 
* @author : Manikandan Radhakrishnapillai
* @param accId : the account record Id    
* @return Object of type DataTableResponse is returned 
*/
    public static Contact createContactRecord( String accId)
    {
        Contact cRec = new Contact();
        cRec.LastName = 'Test Contact Name';
        cRec.AccountId = accId;
        cRec.Email='abc@cargill.com';
        cRec.CS_Sub_Channel__c = 'K-12';
        try
        {
            insert cRec;    
        }
        catch( Exception e )
        {
            
        }
        
        return cRec;
    }
    
    
    /**
* @Description :
*  This function will create Entitlement Records and return the same
* 
* @author : Manikandan Radhakrishnapillai
* @param : accId - Account recordId 
* @return : List<Entitlement>  
*/
    public static List<Entitlement> createEntitlementRecords( String accId )
    {
        List<Entitlement> entlList = new List<Entitlement>();
        
        Entitlement entl = new Entitlement();
        entl.Name = CS_SystemConstants.PROTEIN_SERVICE_EMAIL_ENTITLEMENT;
        entl.Type = CS_SystemConstants.PROTEIN_SERVICE_EMAIL_ENTITLEMENT_TYPE;
        entl.RecordTypeId = CS_SystemConstants.getRecordTypeId(CS_SystemConstants.PROTEIN_ENTITLEMENT_PROCESS_RECORD_TYPE, Entitlement.SObjectType);       
        //entl.SlaProcessId = sProcess.Id;
        entl.StartDate = System.today() - 1;
        entl.EndDate = null;
        entl.AccountId = accId;
        
        
        Entitlement entl1 = new Entitlement();
        entl1.Name = CS_SystemConstants.PROTEIN_SERVICE_PHONE_ENTITLEMENT;
        entl1.Type = CS_SystemConstants.PROTEIN_SERVICE_PHONE_ENTITLEMENT_TYPE;
        entl1.RecordTypeId = CS_SystemConstants.getRecordTypeId(CS_SystemConstants.PROTEIN_ENTITLEMENT_PROCESS_RECORD_TYPE, Entitlement.SObjectType);       
        entl1.StartDate = System.today() - 1;
        entl1.EndDate = null;
        entl1.AccountId = accId;
        
        entlList.add(entl);
        entlList.add(entl1);
        
        try
        {
            insert entlList;
            
        }
        catch( Exception e)
        {
            
        }
        return entlList;
    }
    
    /**
* @Description :
*  The function will create Case records with given 'count', contactId, queueName, sgipToId
* 
* @author : Manikandan Radhakrishnapillai
* @param : count - no of Case record needs to be created,
contactId - contact for which the Case needs to be created
queueName - if we need to make a queue as an owner
shipToId - if any shipTo needs to be associated with the Case    
* @return : List<Case> - created Case records. 
*/
    public static List<Case> createCaseRecordList( Integer count, String contactId, String queueName, Id shipToId )
    {
        List<case> caseList = new List<Case>();
        Id recordTypeId = CS_SystemConstants.getRecordTypeId( CS_SystemConstants.PROTEIN_SERVICE_RECORD_TYPE, Case.SObjectType );    
        system.debug('Case recordtype :'+[SELECT id,name FROM RecordType where id =: recordTypeId].name);

        String queueId = CS_SystemConstants.getQueueId( queueName );
        
        if( queueName!=null && queueName.contains('Queue')){
            queueId = CS_SystemConstants.getQueueId( queueName );
        }
        
        for( Integer i=0; i<count; i ++ )
        {
            Case caseRec = new Case();
            caseRec.RecordTypeId = recordTypeId;
            caseRec.Subject = 'Test Case Subject'+i;
            caseRec.Priority = 'High';
            caseRec.Status='New';
            caseRec.Reason = 'CTL';
            caseRec.CS_Number_of_Orders__c = 22.23;
            if(queueId != null){
                caseRec.OwnerId = queueId;
            }
            caseRec.ContactId = contactId;
            caseRec.Origin = 'Email';
            if(shipToId != null){
                caseRec.CS_Ship_To__c= shipToId;
            }
            
            caseList.add( caseRec );
        }
        
        system.debug('\n\ncaseList: '+caseList+'\n\n');
        return caseList;
    } 
    
    /**
* @Description :
*  create single Case record for a given contact, account, shipTo
* 
* @author : Manikandan Radhakrishnapillai
* @param caseId : the record Id of the Case    
* @return Object of type DataTableResponse is returned 
*/
    public static Case createCaseRecord( String contactId, String accountId, Id shiptoid , 
                                        String status, String parentCaseId, String caseReason, String suppliedEmail)
    {
        Case caseRec = new Case();
        caseRec.RecordTypeId = CS_SystemConstants.getRecordTypeId( CS_SystemConstants.PROTEIN_SERVICE_RECORD_TYPE, Case.SObjectType );    
        system.debug('Case recordtype :'+[SELECT id,developerName FROM RecordType where id =: caseRec.RecordTypeId].developerName);
        caseRec.Subject = 'Test Case Subject';
        caseRec.Priority = 'High';
        if(caseReason != null){
            caseRec.Reason = caseReason;
        }else{
            caseRec.Reason = 'CSR';
        }
        
        caseRec.CS_Market_Channel__c = FOODSERVICE_MARKETCHANNEL;
        caseRec.Origin = 'Email';
        caseRec.CS_Case_Reassignment_Reason__c = 'PTO';
        caseRec.CS_Number_of_Orders__c = 23.22;
        if(suppliedEmail != null){
            caseRec.SuppliedEmail = suppliedEmail;
        }
        if(parentCaseId != null){
            caseRec.parentId = parentCaseId;
        }
        if(status == null){
            caseRec.status = CS_SystemConstants.CASE_STATUS_CLOSED;
        }else{
            caseRec.status = status;
        }

        if(shiptoid != null){
            caseRec.CS_Ship_To__c = shiptoid;
        }
        if( String.isNotBlank( contactId ) )
        {
            caseRec.ContactId = contactId;
        }else{
            caseRec.CS_Market_Channel__c = FOODSERVICE_MARKETCHANNEL;
        }
        if( String.isNotBlank( accountId ) )
        {
            caseRec.AccountId = accountId;
        }

        system.debug('case getting created : '+caseRec);
        try
        {

            insert caseRec;    
        }
        catch( Exception e )
        {
            CS_SystemConstants.printExceptions(e);
        }
        
        return caseRec;
    }
    
    /**
* @Description :
*  This function will create EmailMessage Records and return the same
* 
* @author : Manikandan Radhakrishnapillai
* @return list<EmailMessage> list of emailMessage 
*/
    public static list<EmailMessage> getEmailMessageRecords(String caseStatus,Boolean hasPArent,String caseReason,String emailAddress)
    {
        
        CS_TestDataHelper.insertCustomIntegrationProfileDetail();     
        
        Account proteinServiceAccountForEntitlement = CS_TestDataHelper.createAccountRecord( CS_SystemConstants.DUMMY_ACCOUNT_NAME, 
                                                                                            CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                                            CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
        Account commercialAccount = CS_TestDataHelper.createAccountRecord( 'testAcc1' , 
                                                                          CS_TestDataHelper.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                          CS_TestDataHelper.FOODSERVICE_MARKETCHANNEL); 
        
        System.debug('\n\n proteinServiceAccountForEntitlement : '+proteinServiceAccountForEntitlement+'\n\n');
        //create entitlement records
        CS_TestDataHelper.createEntitlementRecords( proteinServiceAccountForEntitlement.Id );
        Contact cRec = CS_TestDataHelper.createContactRecord( commercialAccount.Id );
        //insert CSR1 case
        Case parentCase = null;
        if(hasParent){
            parentCase = createCaseRecord(cRec.id,null,null,null,null,null,null);
        }
        
        
        Case caseForEmail;
        if(parentCase != null){
            caseForEmail = createCaseRecord(cRec.id,null,null,caseStatus,parentCase.id,caseReason,null);
        }else if(emailAddress != null){
            caseForEmail = createCaseRecord(cRec.id,null,null,caseStatus,null,null,emailAddress);
        }else{
            caseForEmail = createCaseRecord(cRec.id,null,null,caseStatus,null,null,null);
        }
        
        list<EmailMessage> emailMessage  = new list<EmailMessage>();
        EmailMessage outGoingMail= new EmailMessage();   
        if(emailAddress != null) {
            outGoingMail.toAddress = emailAddress;
            outGoingMail.Headers = '\nto: <'+emailAddress+'> \n';
        }else{    
            outGoingMail.toAddress = cRec.Email;
        }
        outGoingMail.subject = 'Opt Out Test Message';
        outGoingMail.TextBody= 'This is the message body BR-Interno.';
        outGoingMail.incoming = true;
        outGoingMail.headers = 'Message-ID: <HK2PR0201MB20985818F3CF2C20DA8B8655B4220@HK2PR0201MB2098.apcprd02.prod.outlook.com> References: <BN7PR04MB3825BAB516EBABD16BE41D83DF220@BN7PR04MB3825.namprd04.prod.outlook.com>,<CAH3ctt7jM2SeSaGozkPQkFWRqaJieCD3bqqgwLpH-x_UDbV7Zg@mail.gmail.com>';
        outGoingMail.parentid=caseForEmail.id;      

        emailMessage.add(outGoingMail);
        try{
            insert emailMessage ;
        }catch(Exception ex){
            system.debug('exception ex'+ex);
        }
        System.debug('****emailMessage : '+emailMessage);
        return emailMessage;
        
    }       
    /*
Method to create case comment records
Input : Case Id
output : EntitlementRecords list
*/
    public static List<CaseComment> createCaseComments( String caseId )
    {
        List<CaseComment> commentList = new List<CaseComment>();
        
        CaseComment cRec = new CaseComment();
        cRec.ParentId = caseId;
        cRec.CommentBody = 'Test comment'+caseId;
        commentList.add( cRec );
        
        try
        {
            insert commentList;
        }
        catch( Exception e)
        {
            
        }
        return commentList;
    }
    /* Method to create Email message record
Input : None
output : EmailMessage
*/
    public static List<EmailMessage> createEmailMessageRecord( String caseId )
    {
        List<EmailMessage> emailList = new List<EmailMessage>();
        //outgoing email
        EmailMessage email = new EmailMessage();
        //email.FromAddress = 'test@abc.org';
        email.Incoming = false;
        email.ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
        email.Subject = 'Test email';
        email.TextBody = '23456 ';
        email.HtmlBody = '';
        email.ParentId = caseId;
        
        EmailMessage email01 = new EmailMessage();
        //email.FromAddress = 'test@abc.org';
        email01.Incoming = false;
        email01.ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
        email01.Subject = 'COA';
        email01.TextBody = '23456 ';
        email01.HtmlBody = '';
        email01.ParentId = caseId;
        
        //incoming email
        EmailMessage email1 = new EmailMessage();
        //email.FromAddress = 'test@abc.org';
        email1.Incoming = true;
        email1.ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
        email1.Subject = 'Test email';
        email1.TextBody = '23456 ';
        email1.HtmlBody = '';
        email1.ParentId = caseId;
        
        emailList.add(email);
        emailList.add(email1);//
        emailList.add(email01);
        return emailList;
    }
    /*
Method to create attachment records related to Email Message
Input : Case Id
output : EntitlementRecords list
*/
    public static List<Attachment> createAttachments( String eId )
    {
        List<Attachment> attList = new List<Attachment>();
        
        Attachment aRec = new Attachment();
        aRec.ParentId = eId;
        aRec.Body = Blob.valueOf( 'test attachment for '+eId );
        aRec.name = 'Test Atatchment'+eId;
        
        attList.add( aRec );
        
        try
        {
            insert attList;
        }
        catch( Exception e)
        {
            
        }
        return attList;
    }
    
    /*
Method to create attachment records related to Email Message
Input : Case Id
output : EntitlementRecords list
*/
    public static void createContentDocument( String eId )
    {
        
        ContentVersion content = new ContentVersion(); 
        content.Title = 'Test Protein Service'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Test Protein service Body'+eId ); 
        content.VersionData = bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = eId;
        contentlink.contentdocumentid = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'V';
        
        insert contentlink;
        
        try
        {
            
        }
        catch( Exception e)
        {
            
        }
        
    }
    
    public static User createUser(String profileName, String rolename, String email){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name =: profileName].Id,
            LastName = 'last',
            Email = email,
            Username = 'puser000@cargill.com' + System.currentTimeMillis(),
            CompanyName = 'TEST_cargill.com',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive = true,
            UserRoleId = [SELECT id FROM UserRole where name =: rolename].id
        );
        
        try{
            insert(u);
            System.debug('User got created!!!!!!!!!!');
        }catch(Exception e){
            System.debug('Exception in User Id creation');
            System.debug('Exception Cause       : ' + e.getCause());
            System.debug('Exception LineNo      : ' + e.getLineNumber());
            System.debug('Exception Message     : ' + e.getMessage());
            System.debug('Exception StackTrace  : ' + e.getStackTraceString());
        }
        return u;
    }
    
     /*
    Method to return the  Set of case ID
    Input :
    output : set of case Id
    */
    
    public static set<ID> getCaseIds()
    {
        set<Id> caseIds = new set<Id>();
       List<Case> caseList= [select Id from Case];
       for(Case cs :caseList){
       caseIds.add(cs.Id);
       
       }
               
      return caseIds;
    }
    
    
}