/**
   @Author - Harshavi Tanguturi
   @name - AccountActivityListCompController
   @CreateDate - 12-29-2016
   @Description - This is Controller class for retrieving task records of related object records to particular account
   @Revision-
*/
public class AccountActivityListCompController{
    private Static final String EMPTYSTRING= '';
    private Static final String SPACESTRING = ' ';
    private Static final String STRING_SELECT = 'select id,'+'(select id,Subject,Status,ActivityDate,OwnerId,WhatId,What.Name,Owner.Name,What.Type,Who.Type,WhoId,Who.Name'+' from Tasks '+'WHERE Status IN : statusList ORDER BY CreatedDate DESC) from ';
    private Static final String STRING_SELECT_FOR_CONTACT = 'select id,'+'(select id,Subject,Status,ActivityDate,OwnerId,WhatId,What.Name,Owner.Name,What.Type,Who.Type,WhoId,Who.Name'+' from Tasks '+'WHERE Status IN : statusList AND WhatId =:EMPTYSTRING  ORDER BY CreatedDate DESC) from ';
    private Static final String COMMADELIMETER = ',';
    private Static final String ESCAPEQUOTES= '\'';
    private Static final String WHERECLAUSE='where '+'Account__c'+'= \'';
    private Static final String WHERECLAUSESTANDRAD='where '+'AccountId'+'= \'';
    private Static final String WHERECLAUSEACCOUNT='where '+'Id'+'= \'';
    private Static final String LIMIT_VAL = ' LIMIT ';
    private Static final String TASKOBJECT = 'Tasks';
    private Static final String UNDER_SCORE_NOTATION = '__c';
    private Static final String ACCOUNT_OBJECT= 'Account';
    private Static final String CONTACT_OBJECT = 'Contact';
     
    private AccountActivityListCompController(){}
    /*@Description -Aura enabled Method used to retrive objects related to specific user loggedin
    @Author - Harshavi Tanguturi
    @date - 12-29-2016
    @param - 
    @Return - ProfileSettingForActivity(wrapperclass)*/
    @AuraEnabled
    public static ProfileSettingForActivity retrieveActivityObjectList() {
        Id profileId=userinfo.getProfileId();
        map<string,string> objectmap = new map<string,string>();
        List<String> objectstosend = new List<string>();
        List<String> objectsList = new List<String>();
        ProfileSettingForActivity profileSetting = new ProfileSettingForActivity(EMPTYSTRING,EMPTYSTRING,null,null,EMPTYSTRING);
        profileSetting.defaultDisplayValue = String.valueof(Cargill_Leap_App_Config__c.getInstance(profileId).AccountActivityDefaultDisplayNummber__c);
        profileSetting.activityObjectList  = Cargill_Leap_App_Config__c.getInstance(profileId).AccountActivityObjectList__c;              // to get the profile specific object List
        profileSetting.objectlistSeperated = profileSetting.activityObjectList.split(COMMADELIMETER);
        profileSetting.statusFilterList = Cargill_Leap_App_Config__c.getInstance(profileId).Status_Filter_List__c;
        for(String objects:profileSetting.objectlistSeperated){        // split custom setting value to list of objects
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objects);
        Schema.DescribeSObjectResult dsr = convertType.getDescribe();
        String objectLabel = dsr.getLabel(); 
        objectsList.add(objectLabel);
        objectmap.put(objectLabel,objects);
        objectstosend.add(objectLabel);
        }
        
         profileSetting.objectlistSeperated = objectstosend;
         profileSetting.objectmap = objectmap;
         system.debug('>>map>>'+objectmap);
        return profileSetting; 
    }
    /*@Argument - recordId
    @Description -Aura enabled Method used to retrive Task list of all the related objects
    @ReturnType - List<Task>*/
    @AuraEnabled
    public static List<taskWrapperWithMap> createActivityObjectList(String recordId){
        ProfileSettingForActivity profilesetting = AccountActivityListCompController.retrieveActivityObjectList();
        //List<String> objlist = profilesetting.objectlistSeperated;
        map<String,list<Task>> taskmap = new map<String,list<Task>>();
         String statusAppend = profilesetting.statusFilterList;
        list<String> statusList = new list<String>();
        statusList = statusAppend.split(COMMADELIMETER);
        list<Task> tasklist = new list<task>();
        //list<Sobject> objectList = new list<Sobject>();
        List<Task> tasklist1 =new list<task>();
        list<Task> taskfinal = new list<task>();
        List<Task> finalList = new List<Task>();
        Integer n=Integer.valueof(profilesetting.defaultDisplayValue);
        String limitValue = String.valueof(n);
        Map<string,String> objectmap = new map<String,String>();
        objectmap = profilesetting.objectMap;
        List<String> objectListAPI = new List<String>();
        for(String obj:objectMap.values()){
            String querySelect = STRING_SELECT + obj + SPACESTRING ;
            String querySelectContact = STRING_SELECT_FOR_CONTACT + obj + SPACESTRING ;
            String limitClause = LIMIT_VAL +limitValue;
            if(obj.contains(UNDER_SCORE_NOTATION)){
            string queryString = querySelect + WHERECLAUSE + recordId + ESCAPEQUOTES +limitClause;
            list<Sobject> customObjectsList=database.query(queryString);
            system.debug(customObjectsList);
                for(integer i=0;i<customObjectsList.size();i++){
                taskmap.put(customObjectsList[i].id,customObjectsList.get(i).getSobjects(TASKOBJECT));
                tasklist = (List<Task>)taskmap.get(customObjectsList[i].id) ;
                if(!tasklist.isEmpty()){
                    taskfinal.addall(tasklist);
                }
            }
       
          }
          else{
          String queryStandard;
          if(obj == ACCOUNT_OBJECT){
            queryStandard = querySelect+WHERECLAUSEACCOUNT+recordId+ESCAPEQUOTES +limitClause;
            }
            else if(obj == CONTACT_OBJECT ){
            queryStandard = querySelectContact + WHERECLAUSESTANDRAD+ recordId+ ESCAPEQUOTES +limitClause;
            system.debug('quer contact ---'+queryStandard );
            }
            else {
            queryStandard = querySelect+ WHERECLAUSESTANDRAD+ recordId+ ESCAPEQUOTES +limitClause;
            }
            list<Sobject> standardObjectList=database.query(queryStandard);
            system.debug(standardObjectList);
            for(integer i=0;i<StandardObjectList.size();i++){
                taskmap.put(StandardObjectList[i].id,StandardObjectList.get(i).getSobjects(TASKOBJECT));
                tasklist1 = (List<Task>)taskmap.get(StandardObjectList[i].id) ;
                if(!tasklist1.isEmpty()){
                    taskfinal.addall(tasklist1);
                }
            } 
        } 
    }
    finalList = [select id,Subject,Status,ActivityDate,OwnerId,WhatId,What.Name,Owner.Name,What.Type,Who.Type from Task WHERE ID IN:taskfinal  ORDER BY CreatedDate DESC  LIMIT 1000];
    system.debug('>>>>taskfinal>>>'+finalList);
    
    Map<String, String> objectLabelMap = new Map<String, String>();
    for(String key: objectMap.keySet()){
        objectLabelMap.put(objectMap.get(key), key);
    }
    List<taskWrapperWithMap> taskWrapperList = new List<taskWrapperWithMap>();
               taskWrapperWithMap tskwrp = new taskWrapperWithMap(null,EMPTYSTRING);
               for(Task tsk: finalList ){
                   //taskWrapperWithMap tskwrp = new taskWrapperWithMap(null,EMPTYSTRING);
                   tskwrp.taskList = tsk;
                   if(tsk.whoId!=null && tsk.WhatId==null){
                    tskwrp.objectLabel = objectLabelMap.get(tsk.Who.Type);
                   }
                   else{
                       tskwrp.objectLabel = objectLabelMap.get(tsk.What.Type);
                       taskWrapperList .add(tskwrp );
                   }
               }

    return taskWrapperList ;
}

public class taskWrapperWithMap{
    @AuraEnabled
    public Task taskList;
    @AuraEnabled
    public String objectLabel;
    
    //Constructor
    taskWrapperWithMap(Task taskList, String objectLabelMap){
        this.taskList = taskList;
        this.objectLabel= objectLabel;
    }
}
    /*@Description -Aura enabled Method used to retrive the list of tasks based on the object selected
    @Author - Harshavi Tanguturi
    @date - 12-29-2016
    @param - recordId,selectedObject
    @Return - List<Task>*/
    @AuraEnabled
    public static List<taskWrapperWithMap> getObjectSpecificTaskList(String recordId,String selectedObject){
        
        map<string,string> objectmap  = new  map<string,string>();
        String objectValue;
        ProfileSettingForActivity profilesetting = AccountActivityListCompController.retrieveActivityObjectList();
        String statusAppend = profilesetting.statusFilterList;
        list<String> statusList = new list<String>();
        statusList = statusAppend.split(COMMADELIMETER);
        Integer n=Integer.valueof(profilesetting.defaultDisplayValue);
        String limitValue = String.valueof(n);
        String limitClause = LIMIT_val + limitValue;
        objectmap = profilesetting.objectMap;
        objectValue = objectmap.get(selectedObject);
        map<String,list<Task>> taskmap = new map<String,list<Task>>();
        List<Task> taskfinal = new List<Task>();
        List<Task> taskSpecific = new List<Task>();
        List<Task> finalListspecific = new List<Task>();
        String querySelect = STRING_SELECT + objectValue + SPACESTRING  ;
        String querySelectContact = STRING_SELECT_FOR_CONTACT + objectValue + SPACESTRING  ;
        String queryStringStandard;
        //Code for getting Tasks from Custom Objects
        if(objectValue.contains(UNDER_SCORE_NOTATION)){     
        string queryString=querySelect +WHERECLAUSE+recordId+ ESCAPEQUOTES +limitClause;
        List<Sobject> customObjectsList = database.query(queryString);       //To query the Tasks of the selected object dynamically 
            for(integer i=0;i<customObjectsList.size();i++){
            taskmap.put(customObjectsList[i].id,customObjectsList.get(i).getSobjects(TASKOBJECT));
            taskSpecific = (List<Task>)taskmap.get(customObjectsList[i].id) ;
            if(!taskSpecific.isEmpty()){
                taskfinal.addall(taskSpecific);
            }
            }
           }
           
        //Code for getting Tasks from Standard Objects
        else{
        if(objectValue == ACCOUNT_OBJECT){
            //List<Sobject> StandardObjectList = new List<Sobject>();
            queryStringStandard=querySelect+WHERECLAUSEACCOUNT+recordId+ESCAPEQUOTES +limitClause;
            system.debug('queryStringStandard--------'+queryStringStandard);
            }  
         else if(objectValue == CONTACT_OBJECT ){
             queryStringStandard = querySelectContact+whereclauseStandrad+recordId+ ESCAPEQUOTES +limitClause; 
         }
         else{
            //List<Sobject> StandardObjectList = new List<Sobject>();
            queryStringStandard=querySelect +whereclauseStandrad+recordId+ ESCAPEQUOTES +limitClause; 
         } 
         List<SObject> standardObjectList = database.query(queryStringStandard); 
         for(integer i=0;i<StandardObjectList.size();i++){
             taskmap.put(StandardObjectList[i].id,StandardObjectList.get(i).getSobjects(TASKOBJECT));
             taskSpecific = (List<Task>)taskmap.get(StandardObjectList[i].id) ;
             if(!taskSpecific.isEmpty()){
                 taskfinal.addall(taskSpecific);
             }
         }
         }         
        finalListspecific  = [select id,Subject,Status,ActivityDate,OwnerId,WhatId,What.Name,Owner.Name,What.Type,WhoId,Who.Type,Who.Name from Task WHERE ID IN:taskfinal  ORDER BY CreatedDate DESC  LIMIT 1000];        
        List<taskWrapperWithMap> taskWrapperList = new List<taskWrapperWithMap>();
               taskWrapperWithMap tskwrp = new taskWrapperWithMap(null,EMPTYSTRING);
               for(Task tsk: finalListspecific ){
                   //taskWrapperWithMap tskwrp = new taskWrapperWithMap(null,EMPTYSTRING);
                   tskwrp.taskList = tsk;
                   if(tsk.whoId!=null && tsk.whatId==null){
                        tskwrp.objectLabel = tsk.Who.Type;
                   }
                   else{
                       tskwrp.objectLabel = tsk.What.Type;
                       taskWrapperList .add(tskwrp );
                   }
               }
        system.debug('final list'+finalListspecific );

    return taskWrapperList ;
    }
    
    /* Inner class to wrap up the values of Custom setting details */
    public class ProfileSettingForActivity{
        @AuraEnabled
        public string defaultDisplayValue;
        @AuraEnabled
        public string activityObjectList;
        @AuraEnabled
        public string statusFilterList;
        @AuraEnabled
        Public List<String> objectlistSeperated;
        @AuraEnabled
        Public map<String,String> objectMap;
        public ProfileSettingForActivity(String defaultDisplayValue,String activityObjectList,List<String> objectlistSeperated,map<String,String> objectMap,String statusFilterList){

        this.defaultDisplayValue = defaultDisplayValue;
        this.activityObjectList = activityObjectList;
        this.objectlistSeperated = objectlistSeperated;
        this.statusFilterList = statusFilterList;
        this.objectMap= objectMap;


        }
    } 

}