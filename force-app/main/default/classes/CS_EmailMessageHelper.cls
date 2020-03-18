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
public with sharing class CS_EmailMessageHelper {

    //get the routing channel queue map
    private final static Map<String, Id> QUEUEMAP = CS_SystemConstants.getProteinServiceQueueMap();

    /*
    * @description This helper method will update the from address of email messages to provided defaultFromAddress. This method was written to 
    *              reduce the cyclomatic complexity of the class.
    * @param List of Email Message records (Trigger.New)
    * @param String defaultFromAddress - From Address to Set
    * @param Set of Case Ids for outgoing emails
    */
    public static void updateValidateFromAddress(List<EmailMessage> emailList,String defaultFromAddress, Set<Id> caseIds) {
        for(EmailMessage eRec: emailList) {
            if(!eRec.Incoming && eRec.CS_ProteinServiceEmail__c) {
                eRec.ValidatedFromAddress = defaultFromAddress;
                CaseIds.add(eRec.ParentId);
            }
        }
    }

    /**
    * getUserPDLMap : Populate PDL and its associated emaillist from CS_ProteinPDL__mdt map
    * @return       : Map<String,String> userPDLMap
    */
    
    public static Map<String,String>  getUserPDLMap(){

        CS_ProteinPDL__mdt[] internalUserQueuemdt = [SELECT PDLname__c, PDL__c
                                                    FROM CS_ProteinPDL__mdt];
        Map<String,String> userPDLMap = new Map<String,String>();

        for(CS_ProteinPDL__mdt pdl : internalUserQueuemdt){
            //String userPDLMapkey = pdl.Username__c + ':' + pdl.PDLname__c;
            String userPDLMapkey = pdl.PDLname__c;
            userPDLMapkey = userPDLMapkey.toUpperCase();
            userPDLMap.put(userPDLMapkey,pdl.PDL__c);
        } 
        return userPDLMap;
    }
    

    /**
    * setToAddress          : This utility method will set Toaddresses by replacing the PDL given by user
    * @param  em            : EmailMessage record upon which operation is doing
    * @param  toAddressList : Actual list of ToAddresses given by user , which may contain the PDL as well
    * @param  userPDLMap    : the configured Metadata Info of PDLs  
    */
    
    public static void setToAddress(EmailMessage em, 
                                    List<String> toAddressList, 
                                    Map<String,String> userPDLMap){

    //String loggedInUser = System.UserInfo.getUserName();
    String toAddress = em.ToAddress;
    for(String email : toAddressList){
            //String userPDLMapkey = loggedInUser + ':' + email;
            String userPDLMapkey = '';
            userPDLMapkey = email.toUpperCase();
            system.debug('\n\n******** userPDLMapkey : '+userPDLMapkey+'\n\n');
            if(userPDLMap.containsKey(userPDLMapkey)){
                system.debug('\n\n****Replace To address****\n\n');
                if(toAddress.contains(','+email)){
                    toAddress = toAddress.replace(','+email,','+userPDLMap.get(userPDLMapkey));
                }
                if(toAddress.contains(email)){
                    toAddress = toAddress.replace(email,userPDLMap.get(userPDLMapkey));
                }
                em.ToAddress = toAddress;
                system.debug('\n\n****em.ToAddress : '+em.ToAddress+'\n\n');
            }
        }

    }
    
    
    /*
    * @description This helper method will append the Case Number to email subject of outgoing email.
    * @param List of Email Message records (Trigger.New)
    * @param Set of Case Ids for outgoing emails
    */
    public static void appendCaseNumberToSubject(List<EmailMessage> emailList, Set<Id> caseIds) {
        Map<Id, Case> mapOfCase = new Map<Id, Case>([Select Id, CaseNumber,Subject From Case Where ID IN :CaseIds]);
        Map<Id, Case> mapOfCaseSubject = new Map<Id, Case>([Select Id, subject From Case Where ID IN :CaseIds]);
            for(EmailMessage eRec: emailList) {
                if(!eRec.Incoming && eRec.CS_ProteinServiceEmail__c && mapOfCase.get(eRec.ParentId) != null 
                        && ( !eRec.Subject.contains(mapOfCase.get(eRec.ParentId).CaseNumber))) {
                                
                                 eRec.Subject += ' - ' + mapOfCase.get(eRec.ParentId).CaseNumber;                               
                                
                                system.debug('eRec.Subject******'+eRec.Subject);
            }
           
        }
    }

    /*
    * @description : This is a utility method for getting all the ToAddress's individually in a Set 
    * @param List<EmailMessage> emailList : list of EmailMessage record which started the process
    * @param Set<String> : set of email To Addresses 
    */

    public static Set<String> getEmailSet(List<EmailMessage> emailList,
                                        Map<Id,String> mapCaseIdToAddress){

        Set<String> emailSet = new Set<String>();
        //loop through email message
        for(EmailMessage tempEmail: emailList) {
            //mapCaseIdToAddress.put(tempEmail.ParentId,tempEmail.ToAddress);
            mapCaseIdToAddress.put(tempEmail.ParentId,tempEmail.Headers); //get headers to know the actual sequence of email addresses
            if(tempEmail.ToAddress != null) {
                emailSet.addAll(tempEmail.ToAddress.deleteWhitespace().split(';'));
            }
        }
        return emailSet;

    }

    /**
    * getInternalUserQueueMap :
    * It returns the InternalUser and his associated email id in a Map configured in the 'CS_InternalUser_QueueMap__mdt'
    * @return   :  Map<String,String> internalUserQueueMap
    */
    public static Map<String,String> getInternalUserQueueMap(){

            CS_InternalUser_QueueMap__mdt[] internalUserQueuemdt;

            if(CS_InternalUser_QueueMap__mdt.sObjectType.getDescribe().isAccessible()){
                internalUserQueuemdt = [SELECT InternalUserEmail__c, QueueName__c
                                        FROM CS_InternalUser_QueueMap__mdt];
            }

            Map<String,String> internalUserQueueMap = new Map<String,String>();
            for (CS_InternalUser_QueueMap__mdt i : internalUserQueuemdt) {
                internalUserQueueMap.put(i.InternalUserEmail__c.toUpperCase(),i.QueueName__c);
            }

            System.debug('\n\n\n*******internalUserQueueMap'+internalUserQueueMap+'\n\n\n');
            return internalUserQueueMap;
    }


    

    /**
    * saveResultErrors :
    * The method will print if any errors are associated with any saveResults 
    * @param  srList : saveResult records as part of an insert or update
    */
    public static void getSaveResultErrors(Database.SaveResult[] srList){
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    /**
    * populateEmailMessageAndCaseIds 
    * The utility method will return the CasIds and EmailMessageIds
    * @param  caseIds         : caseIds which will be returned via reference
    * @param  emailMessageIds : emailMessageIds which will be returned via reference
    * @param  emailList       : the list of emailmessage records which triggered the event
    */
    public static void populateEmailMessageAndCaseIds(Set<Id> caseIds , 
                                                    Set<Id> emailMessageIds , 
                                                    List<EmailMessage> emailList){
        
        for( EmailMessage eRec: emailList ){
                //add all case ids in common set
                if( !eRec.CS_Created_From_Duplicate_Case__c && eRec.CS_ProteinServiceEmail__c ){
                    caseIds.add( eRec.ParentId );
                    emailMessageIds.add( eRec.Id );
                    
                }

                system.debug('caseIds******'+caseIds); 
                system.debug('emailMessageIds******'+emailMessageIds);
            }
    }

    /**
    * populateDuplicateCaseAndReOpenCaselist 
    * if case status is closed  and Reason is Duplicate and Parent Id is not blank, Parent case is not closed
    * then New incoming email message will be cloned on parent case.
    * else if case status is closed  and Reason is Duplicate and Parent Id is not blank, Parent case is closed
    * then Parent Case will updated with Re-open status.
    * @param  duplicateCaseList : the duplicate Case List which will be returned via reference
    * @param  reopenCaseList    : reopenCaseList description
    * @param  cRec              cRec description
    */
    public static void populateDuplicateCaseAndReOpenCaselist(List<case> duplicateCaseList , 
                                                            List<case> reopenCaseList , 
                                                            Case cRec){
        
            if( cRec.Status.equalsIgnoreCase( CS_SystemConstants.CASE_STATUS_CLOSED ) &&
                        cRec.Reason == CS_SystemConstants.CASE_REASON_DUPLICATE &&
                        String.isNotBlank( cRec.ParentId ) && !cRec.Parent.IsClosed){
                duplicateCaseList.add(cRec);
                //system.debug('duplicateCaseList If******'+duplicateCaseList);
                
            }else if( ( cRec.Status.equalsIgnoreCase( CS_SystemConstants.CASE_STATUS_CLOSED ) &&
                        cRec.Reason == CS_SystemConstants.CASE_REASON_DUPLICATE &&
                        String.isNotBlank( cRec.ParentId ) && cRec.Parent.IsClosed) ){
                //update case status to Re-Open
                    duplicateCaseList.add( cRec );
                    cRec.Parent.Status = CS_SystemConstants.CASE_STATUS_REOPEN;
                    reopenCaseList.add( cRec.Parent );
            }   

    }

}