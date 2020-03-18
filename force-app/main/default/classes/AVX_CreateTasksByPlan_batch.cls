/**************************************************************************************************************
* Avanxo Brasil
* @author           Ismael Sanchez (isanchez@avanxo.com)
* Project:          CPLA - EXODUS Project
* Description:      Batch process that creates the tasks of programmed telemarketers in an active telesales plan
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                      Description     
*           -----   ----------      --------------------        ---------------   
* @version   1.0    2020-03-05      Ismael Sanchez              class created 
*************************************************************************************************************/
global  class AVX_CreateTasksByPlan_batch implements Database.Batchable<sObject> {

    public Date today;

    public AVX_CreateTasksByPlan_batch(Date todayParam) {
        today = todayParam;
    }
    public AVX_CreateTasksByPlan_batch() {
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String todayStr = String.valueOf(today);
        System.debug('todayStr-->');
        System.debug(todayStr);
        String query = 'Select id, name, startDate__c, enddate__c from telesalesplan__c where StartDate__c<=' 
                    + todayStr + ' and EndDate__c>='+ todayStr;


        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('Enter to execute');
        System.debug('scope-->');
        System.debug(scope);
        String callTo = System.Label.AVX_CallTo;
        Map<String, String> dayMap = new Map<String, String>();
        dayMap.put('Monday', '1');
        dayMap.put('Tuesday', '2');
        dayMap.put('Wednesday', '3');
        dayMap.put('Thursday', '4');
        dayMap.put('Friday', '5');
        dayMap.put('Saturday', '6');
        dayMap.put('Sunday', '7');
        String todayStr = String.valueOf(today);
        Datetime dt = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');
        String dayFilter = dayMap.get(dayOfWeek);

        System.debug('dayFilter-->' + dayFilter);
        List<Task> tasks = Database.query(' SELECT ShipTo__c,TelesalesPlan__c,TimeToCall__c,TypeTask__c,CreatedDate,ActivityDate,OWNERID ' 
                    + ' FROM Task where ActivityDate = ' + todayStr );
        Map<String, Task> taskMap = new Map<String, task>();
        Map<String, TelesalesPlanDetail__c> detailsMap = new Map<String, TelesalesPlanDetail__c>();
        Set<Id> setIds = new Set<Id>();
        System.debug('taskToExclude-->');
        System.debug(tasks);
        //task to map
      
        if(!tasks.isEmpty()) {
            for(Task t : tasks) {
                String key = t.OwnerId +'_'+ t.ShipTo__c +'_'+  t.TimeToCall__c +'_'+ t.TypeTask__c;
                taskMap.put(key,t);
            }
        }
     
        //today plans
        List<Telesalesplan__c> lstPlans = (List<Telesalesplan__c>)scope;
        if(!lstPlans.isEmpty()){
            for(TelesalesPlan__c t: lstPlans){
                setIds.add(t.Id);
            }
        }
        System.debug( 'lstPlans-->');
        System.debug(lstPlans);
        //plan details
        List<TelesalesPlanDetail__c> lstDetails = [SELECT TelesalesPlan__r.RecordType.developername, Ship_To__r.Commercial_Account__r.Name,Ship_To__r.Commercial_Account__r.CurrencyIsoCode,Ship_To__r.ExtraInformation__c, Ship_To__r.CreditLimit__c, 
                                                    Ship_To__r.PrimaryContact__c,TelesalesPlan__r.Telemarketer__c, TelesalesPlan__r.RecordType.name,DayOfTheWeek__c,
                                                    Hours__c,Id,Name,Priority__c,Ship_To__c,Telemarketer__c,TelesalesPlan__c 
                                                    FROM TelesalesPlanDetail__c where DayOfTheWeek__c=:dayFilter AND TelesalesPlan__c in:setIds ];
        if(!lstDetails.isEmpty()){
            for(TelesalesPlanDetail__c t:lstDetails ){
                Id ownerId = t.TelesalesPlan__r.RecordType.developername =='WorkPlan' ? t.TelesalesPlan__r.Telemarketer__c:t.Telemarketer__c;
                String key =ownerId +'_'+ t.Ship_To__c + '_'+ t.Hours__c +'_'+ t.TelesalesPlan__r.RecordType.developername;
                detailsMap.put(key,t);
            }
        }

        System.debug('lstDetails-->');
        System.debug(lstDetails);

        List<Task> lstNewTasks = new List<Task>();
        for (String key : detailsMap.keySet()){
            System.debug('key-->' + key);
            if(!taskMap.containsKey(key)){
                //Create task 
                TelesalesPlanDetail__c objTspDetail = detailsMap.get(key);
                Id ownerId = objTspDetail.TelesalesPlan__r.RecordType.developername =='WorkPlan' ? objTspDetail.TelesalesPlan__r.Telemarketer__c:objTspDetail.Telemarketer__c;
                Task objTask = new Task(
                    WhatId = objTspDetail.Ship_To__c,
                    WhoId = objTspDetail.Ship_To__r.PrimaryContact__c,
                    OwnerId = ownerId,
                    TelesalesPlan__c = objTspDetail.TelesalesPlan__c,
                    Status = 'Open',
                    Priority = objTspDetail.Priority__c,
                    ActivityDate = today,
                    TimeToCall__c = objTspDetail.Hours__c,
                    TypeTask__c = objTspDetail.TelesalesPlan__r.RecordType.developername,
                    ShipTo__c = objTspDetail.Ship_To__c,
                    CreditLimit__c =  objTspDetail.Ship_To__r.CreditLimit__c,
                    ExtraInformation__c = objTspDetail.Ship_To__r.ExtraInformation__c,
                    CurrencyIsoCode = objTspDetail.Ship_To__r.Commercial_Account__r.CurrencyIsoCode,
                    Subject = callTo + ' ' + objTspDetail.Ship_To__r.Commercial_Account__r.Name
                );
                lstNewTasks.add(objTask);
            }
        }
        System.debug( 'lstNewTasks-->');
        System.debug(lstNewTasks);
        if(!lstNewTasks.isEmpty()){
            insert lstNewTasks;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('Creating task finished succesfully');
    }
}