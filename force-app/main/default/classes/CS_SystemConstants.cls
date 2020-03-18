/*
* @author      Ramesh Yenugula  (RAMESH_YENUGULA@CRGL-THIRDPARTY.COM)
* @version      1.0
* @createddate  Feb 2, 2019
* @name     CS_SystemConstants
* @description This class contains the static variables and these are referenced across the protein related classes for Protein Service Cloud implementation project.
* @referencedby CS_EmailMessageHandler,CS_CaseHandler
* @modifiedby   
* @modifieddate 
*/  

public class CS_SystemConstants {
    
    public static final String PROTEIN_SERVICE_RECORD_TYPE = 'CS_Protein_Case';
    public static final String PROTEIN_PROFILE_NAME = 'Customer Service Agent';
    //email message constants
    public static final String AUTO_RESPONE_HEADER = 'X-SFDC-AutoResponse';
    //org wide address
    public static final String ORG_WIDE_PROTEIN_SERVICE_EMAIL = 'Protein Customer Service';//'customerservice_proteintest@cargill.com';  //
    //Group/Queue names
    public static final String NO_CONTACT_SERVICE_QUEUE = 'CS_No_Contact_Service_Queue';
    public static final String ACTIVE_STATUS = 'Active';
    public static final String PROTEIN_SERVICE_PHONE_ENTITLEMENT = 'Protein Service Phone Entitlement';
    public static final String PROTEIN_SERVICE_PHONE_ENTITLEMENT_TYPE = 'Phone Support';
    public static final String PROTEIN_SERVICE_EMAIL_ENTITLEMENT = 'Protein Service Email Entitlement';
    public static final String PROTEIN_SERVICE_EMAIL_ENTITLEMENT_TYPE = 'Email Support';
    //case status values
    public static final string CASE_STATUS_CLOSED = 'Closed';
    public static final string CASE_STATUS_REOPEN = 'Re-Open';
    //case reason values
    public static final string CASE_REASON_DUPLICATE = 'Duplicate Case';
    
    public static final String PROTEIN_ENTITLEMENT_PROCESS_RECORD_TYPE = 'Protein_Customer_Service';
    public static final String PROTEIN_SERVICE_QUEUE = 'Protein Customer Service Queue';
    public static final Map<String, String> CASE_ORIGIN_SUPPORT_MAP = new Map<String, String>{'Email'=>PROTEIN_SERVICE_EMAIL_ENTITLEMENT_TYPE, 
                                                                                            'Phone'=>PROTEIN_SERVICE_PHONE_ENTITLEMENT_TYPE,
                                                                                            'Manual'=>PROTEIN_SERVICE_PHONE_ENTITLEMENT_TYPE,
                                                                                            'Fax'=>PROTEIN_SERVICE_PHONE_ENTITLEMENT_TYPE};
    //Protein Service Account - Dummy Account Name
    public static final string DUMMY_ACCOUNT_NAME = 'Protein Service Account';
    
   /*
     Description : Method to return recordType Id based on recordType name and object name
     Input: String - recordType name, SObjectType  
     Output : String ( recordType Id )  
    */
    public static String getRecordTypeId( String recordTypeName, SObjectType objectName )
    {
        String recordTypeId;
        if( recordTypeName != null && recordTypeName != '' )
        {
            //get map specific to object
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = new Map<String,Schema.RecordTypeInfo>();
            recordTypeInfo = objectName.getDescribe().getRecordTypeInfosByDeveloperName();
            
            if( recordTypeInfo.containsKey( recordTypeName ) )
            {
                recordTypeId = recordTypeInfo.get( recordTypeName ).getRecordTypeId();
            }
        }
        return recordTypeId;
    }
    
    /*
     Description : Method to return org wide address  
     Input: String - DisplayName  
     Output : String
    */
    public static String getOrgWideEmailForDisplayName( String displayName )
    {
        String emailAddress = '';
        List<OrgWideEmailAddress> orgEmailList = new List<OrgWideEmailAddress>( [ select Address from OrgWideEmailAddress where DisplayName =: displayName LIMIT 1] );
        if( !orgEmailList.isEmpty() && orgEmailList[0].Address != null )
        {
            emailAddress = orgEmailList[0].Address;
        }
        return emailAddress;
    }
    
    /*
     Description : Method to retunr queue Id based on Queue name
     Input: String - Queue name  
     Output : String ( Queue Id )  
    */
    public static String getQueueId( String queueName )
    {
        String queueId;
        if( queueName != null && queueName != '' )
        {
            //query on group to get queue Id
            List<Group> gList = new List<Group>([select id from Group where Type='Queue' and 
                                                 DeveloperName =: queueName LIMIT 1]);
            if( !gList.isEmpty() )
            {
                queueId = gList[0].id;
            }
        }
        return queueId;
    }
    /*
     Description : Method to query on Dummy Account records   
     Input: String accName  
     Output : List<Account>
    */
    public static List<Account> getAccountByName( String accName )
    {
        /*
        List<Account> accList = new List<Account>( [ select id from Account where 
                                                           Name =: accName LIMIT 1] );
        return accList;
        */
        return new List<Account>( [ select id 
                                    from Account 
                                    where Name =: accName LIMIT 1] );
    }
    /*
     * @description This method will return the map of protein service queue api name and Contact Routing Channel Name from Custom Metadatatype.
     * @return Map of queue with key as Queue API Name and value as Contact Routing Channel Name.
    */
    public static Map<String, String> getRoutingChannelQueueMap()
    {
        Map<String, String> queueRoutingChannelMap = new Map<String, String>();
        for(CS_Sub_Channel_Queue_Map__mdt temp: [SELECT DeveloperName, CS_Routing_Channel_Name__c FROM CS_Sub_Channel_Queue_Map__mdt]) {
            queueRoutingChannelMap.put(temp.DeveloperName, temp.CS_Routing_Channel_Name__c);
        }
        return queueRoutingChannelMap;
    }
    /*
     * @description This method will return the map of protein service Contact Routing Channel Name and protein service Queue object id.
     * @return Map of queue with key as Contact Routing Channel Name and value as Queue Object ID.
    */
    public static Map<String, Id> getProteinServiceQueueMap()
    {
        Map<String, String> queueRoutingChannelMap = getRoutingChannelQueueMap();
        Map<String, Id> queueMap = new Map<String, Id>();
        for(Group temp: [SELECT DeveloperName, Id FROM Group Where Type='Queue']) {
            if(queueRoutingChannelMap.get(temp.DeveloperName) != null) {
                queueMap.put(queueRoutingChannelMap.get(temp.DeveloperName), temp.Id);
            }
        }
        return queueMap;
    }
      /*
     Description : Method to insert attachment list  
     Input: List<Attachment>  
     Output : none
    */
    public static void insertAttchment( List<Attachment> attachList )
    {
        try
        {
            insert attachList;
             system.debug('/n/n/n attachList     : '+ attachList +'/n/n/n');
        }
        catch( Exception e)
        {
                            system.debug('/n/n/n Exception Cause      : '+e.getCause()+'/n/n/n');
                            system.debug('/n/n/n Exception LineNumber : '+e.getLineNumber()+'/n/n/n');
                            system.debug('/n/n/n Exception Message    : '+e.getMessage()+'/n/n/n');
                            system.debug('/n/n/n Exception StackTrace : '+e.getStackTraceString()+'/n/n/n');                            
        }
    }

    public static List<CS_high_priority_Variables__mdt> getHighPriorityVariables(){

        List<CS_high_priority_Variables__mdt>hpv = [SELECT MasterLabel FROM CS_high_priority_Variables__mdt WHERE isRequired__c =true];

        if(hpv == null || hpv.isEmpty()){
            return new List<CS_high_priority_Variables__mdt>();
        }else{
            return hpv;
        }
    }

    /**
     * printExceptions : 
     * Utlity method to print the exceptions
     * @param  ex      : captured exception
     */
    public static void printExceptions(Exception ex){
        system.debug('CS_ShipToRelContactOnCase - Exception Cause       : ' + ex.getCause());
        system.debug('CS_ShipToRelContactOnCase - Exception LineNo      : ' + ex.getLineNumber());
        system.debug('CS_ShipToRelContactOnCase - Exception Message     : ' + ex.getMessage());
        system.debug('CS_ShipToRelContactOnCase - Exception StackTrace  : ' + ex.getStackTraceString());
    }
}