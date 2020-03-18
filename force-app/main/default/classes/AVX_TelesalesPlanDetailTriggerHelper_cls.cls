/**************************************************************************************************************
* @company          Avanxo Brasil
* @author           Igor Novaes href=<igor.novaes@globant.com>
* @project          EXODUS - CPLA Cargill
* @name             AVX_CreditLimit_tgr
* @description      Helper for the trigger AVX_TelesalesPlanDetail_tgr
* @dependencies     none
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2020-02-21   Igor Novaes.                  Initial version.
**************************************************************************************************************/

public class AVX_TelesalesPlanDetailTriggerHelper_cls {
    public AVX_TelesalesPlanDetailTriggerHelper_cls() {
        System.debug('Enter to empty constructor');
    }

    public static void createTelesalesPlanDetailTask(List<TelesalesPlanDetail__c> records) {
        Id workPlanRecTypeId = Schema.SObjectType.TelesalesPlan__c.getRecordTypeInfosByDeveloperName().get('WorkPlan').getRecordTypeId();
        System.debug('createTelesalesPlanDetailTask');
        Date today = Date.today();
        DateTime dt = DateTime.now();
        String dayOfWeekNow = dt.format('u');
        
        Set<Id> tspIdSet = new Set<Id>();
        Set<Id> setShipToId = new Set<Id>();

        for(TelesalesPlanDetail__c objTspDetail : records){            
            tspIdSet.add(objTspDetail.TelesalesPlan__c);
            setShipToId.add(objTspDetail.Ship_To__c);
        }
        List<TelesalesPlan__c> lstTsp = [SELECT Id, Telemarketer__c, RecordType.Name, RecordType.DeveloperName FROM TelesalesPlan__c WHERE Id IN: tspIdSet AND RecordTypeId = :workPlanRecTypeId];
        System.debug('lstTsp(35)');
        if(lstTsp.isEmpty()) return;

        Map<Id, TelesalesPlan__c> mapIdTelemarketer = new Map<Id, TelesalesPlan__c>();
        for (TelesalesPlan__c objTSP : lstTsp) {
            mapIdTelemarketer.put(objTSP.Id, objTSP);
        }
        

        //Getting Ship To information
        Map<Id,Ship_To__c> mapIdShipTo = new  Map<Id,Ship_To__c>();

        List<Ship_To__c> lstShipTo = [SELECT Id, Commercial_Account__c, CreditLimit__c, ExtraInformation__c, Name, PrimaryContact__c FROM Ship_To__c WHERE Id IN: setShipToId];
        if(!lstShipTo.isEmpty()){
            for(Ship_To__c objShipTo : lstShipTo){
                mapIdShipTo.put(objShipTo.Id, objShipTo);
            }
        }

        //Getting Commercial Account information
        Set<Id> setCommercialAccId = new Set<Id>();
        for(Ship_To__c objShipTo : mapIdShipTo.values()){
            setCommercialAccId.add(objShipTo.Commercial_Account__c);
        }

        Map<Id,Account> mapIdAccount = new Map<Id,Account>();

        List<Account> lstCommercialAccount = [SELECT Id, Name, CurrencyIsoCode FROM Account WHERE Id IN :setCommercialAccId];
        if(!lstCommercialAccount.isEmpty()){
            for(Account objAccount : lstCommercialAccount){
                mapIdAccount.put(objAccount.Id, objAccount);
            }
        }

        //Getting TelesalesPlan record type name
        Map<Id,String> mapTspIdRecTypeName = new Map<Id,String>();

        for(TelesalesPlan__c objTsp : lstTsp){
            mapTspIdRecTypeName.put(objTsp.Id, objTsp.RecordType.DeveloperName);
        }
        
        String callTo = System.Label.AVX_CallTo;
        Set<Id> setOWnerId = new Set<Id>();
        List<Task> lstTasks = new List<Task>(); 

        for (TelesalesPlanDetail__c tspDetails : records) { 
            String a = mapIdShipTo.get(tspDetails.Ship_To__c).Commercial_Account__c;
            Account b = mapIdAccount.get(mapIdShipTo.get(tspDetails.Ship_To__c).Commercial_Account__c);
            System.debug('valor de a: ' + a);
            System.debug('valor de b: ' + b);
            if(tspDetails.DayOfTheWeek__c == dayOfWeekNow){
                TelesalesPlan__c tspObj = new TelesalesPlan__c();
                tspObj = mapIdTelemarketer.get(tspDetails.TelesalesPlan__c);
                Task objTask = new Task(
                    WhatId = tspDetails.Ship_To__c,
                    WhoId = mapIdShipTo.get(tspDetails.Ship_To__c).PrimaryContact__c,
                    OwnerId = mapTspIdRecTypeName.get(tspDetails.TelesalesPlan__c) == 'WorkPlan' ? tspObj.Telemarketer__c : tspDetails.Telemarketer__c,
                    TimeToCall__c = tspDetails.Hours__c,
                    Status = 'Open',
                    TelesalesPlan__c = tspDetails.TelesalesPlan__c,
                    Priority = tspDetails.Priority__c,
                    TypeTask__c = mapTspIdRecTypeName.get(tspDetails.TelesalesPlan__c),
                    ActivityDate = Date.today(),
                    ShipTo__c = tspDetails.Ship_To__c,
                    CreditLimit__c = mapIdShipTo.get(tspDetails.Ship_To__c).CreditLimit__c,
                    ExtraInformation__c = mapIdShipTo.get(tspDetails.Ship_To__c).ExtraInformation__c,
                    CurrencyIsoCode = mapIdAccount.get(mapIdShipTo.get(tspDetails.Ship_To__c).Commercial_Account__c).CurrencyIsoCode,
                    Subject = callTo + ' ' + mapIdShipTo.get(tspDetails.Ship_To__c).Name,
                    TelesalesPlanDetail__c = tspDetails.Id
                );
            setOWnerId.add(tspObj.Telemarketer__c);
            lstTasks.add(objTask);
            }
        }           
        
        Map<String,Task> mapUniqueTask = new Map<String,Task>();

        List<Task> lstTask = [SELECT Id, OwnerId, Status, WhatId, ActivityDate, TimeToCall__c FROM Task WHERE ActivityDate = :today AND Status = 'Open' AND OwnerId IN: setOwnerId];

        for(Task objTask : lstTask){
            String keyMap = objTask.OwnerId + '|' + objTask.WhatId + '|' + objTask.ActivityDate + '|' + objTask.TimeToCall__c;
            mapUniqueTask.put(keyMap, objTask);
        }
        
        List<Task> lstNewTasksToInsertFinal = new List<Task>();
        
        for (Task tskInsert: lstTasks) {
            
            if(mapUniqueTask.get(tskInsert.OwnerId + '|' + tskInsert.WhatId + '|' + tskInsert.ActivityDate + '|' +tskInsert.TimeToCall__c) == null){
                lstNewTasksToInsertFinal.add(tskInsert);
            }
        }
        if(!lstNewTasksToInsertFinal.isEmpty() && lstNewTasksToInsertFinal != null){
        	insert lstNewTasksToInsertFinal;
        }
    }


    public static void transferTasksContingencyPlan(Map<Id,TelesalesPlanDetail__c> aNewMap){
        Id contingencyPlanRecTypeId = Schema.SObjectType.TelesalesPlan__c.getRecordTypeInfosByDeveloperName().get('ContingencyPlan').getRecordTypeId();
        Date today = Date.today();
        Time currentTime = Datetime.now().time();
        
        Set<Id> setParentTspIds = new Set<Id>();
        for(TelesalesPlanDetail__c objTspDetail : aNewMap.values()){
            if(objTspDetail.Hours__c > currentTime){
                setParentTspIds.add(objTspDetail.TelesalesPlan__c);
            }
        }

        List<TelesalesPlan__c> lstTsp = [SELECT Id FROM TelesalesPlan__c WHERE RecordTypeId = :contingencyPlanRecTypeId AND Id IN :setParentTspIds];
        if(lstTsp.isEmpty()) return;

        List<TelesalesPlanDetail__c> lstTspDetail = [SELECT Id, Ship_To__c, Hours__c, Priority__c, Telemarketer__c FROM TelesalesPlanDetail__c WHERE Id IN :aNewMap.keySet() AND TelesalesPlan__c IN :lstTsp];
        if(lstTspDetail.isEmpty()) return;

        /*

        Set<Id> setIdTspRoot = new Set<Id>();
        for(TelesalesPlan__c tsp : [SELECT TelesalesWorkPlan__c FROM TelesalesPlan__c WHERE RecordTypeId = :contingencyPlanRecTypeId AND Id IN :setParentTspIds]){
            setIdTspRoot.add(tsp.TelesalesWorkPlan__c);
        }

        Set<id> lstDetailRootId = new Set<Id>();
        List<TelesalesPlanDetail__c> lstDetailRoot = [SELECT Id, Ship_To__c, Hours__c, Priority__c, Telemarketer__c FROM TelesalesPlanDetail__c WHERE TelesalesPlan__c IN :setIdTspRoot];
        for(TelesalesPlanDetail__c detailRoot : lstDetailRoot){
            lstDetailRootId.add(detailRoot.Id);
        }
        System.debug('lstTspDetail size:  ' + lstTspDetail.size());
        System.debug('lstDetailRoot Size:  ' + lstDetailRoot.size());
        System.debug('lstDetailRoot: ' + lstDetailRoot);
        System.debug('lstTspDetail: ' + lstTspDetail);

        */

        Map<String,Id> mapKeyTelemarketer = new Map<String,Id>();
        for(TelesalesPlanDetail__c objTspDetail : lstTspDetail){
            System.debug('Telemarker: ' + objTspDetail.Telemarketer__c);
            System.debug('');
            mapKeyTelemarketer.put(objTspDetail.Ship_To__c + '|' + objTspDetail.Hours__c + '|' + objTspDetail.Priority__c, objTspDetail.Telemarketer__c);
        }

        List<Task> lstTask = [SELECT Id, OwnerId, ShipTo__c, TimeToCall__c, Priority FROM Task WHERE Status = 'Open' AND TimeToCall__c > :currentTime ];
        if(lstTask.isEmpty()) return;

        List<Task> lstTaskToUpdt = new List<Task>();
        for(Task objTask : lstTask){
            if(mapKeyTelemarketer.get(objTask.ShipTo__c + '|' + objTask.TimeToCall__c + '|' + objTask.Priority) != null){
                System.debug('Owner Id: ' + mapKeyTelemarketer.get(objTask.ShipTo__c + '|' + objTask.TimeToCall__c + '|' + objTask.Priority));
                objTask.OwnerId = mapKeyTelemarketer.get(objTask.ShipTo__c + '|' + objTask.TimeToCall__c + '|' + objTask.Priority);
                lstTaskToUpdt.add(objTask); 
            }
        }
        update lstTaskToUpdt;
    }

    public static void changeTaskHourPriority(List<TelesalesPlanDetail__c> aNewList, Map<Id,TelesalesPlanDetail__c> aOldMap){
        System.debug('changeTaskHour-->(163)');
        Date today = Date.today();

        Set<Id> setTspId = new Set<Id>();
        for(TelesalesPlanDetail__c objTspDetail : aNewList){
            if(objTspDetail.Hours__c != aOldMap.get(objTspDetail.Id).Hours__c || objTspDetail.Priority__c != aOldMap.get(objTspDetail.Id).Priority__c){
                setTspId.add(objTspDetail.TelesalesPlan__c);
            }
        }
        if(setTspId.IsEmpty()) return;

        List<TelesalesPlan__c> lstTsp = [SELECT Id, Telemarketer__c FROM TelesalesPlan__c WHERE Id IN :setTspId];

        Map<Id, Id> mapTspIdTelemarketer = new Map<Id,Id>();
        for(TelesalesPlan__c objTsp : lstTsp){
            mapTspIdTelemarketer.put(objTsp.Id, objTsp.Telemarketer__c);
        }

        Map<String,Time> mapKeyHour = new Map<String,Time>();
        Map<String,String> mapKeyPriority = new Map<String,String>();

        for(TelesalesPlanDetail__c objTspDetail : aNewList){
            if(setTspId.contains(objTspDetail.TelesalesPlan__c)){

                mapKeyHour.put(objTspDetail.Ship_To__c + '|' + aOldMap.get(objTspDetail.Id).Hours__c + '|' + aOldMap.get(objTspDetail.Id).Priority__c + '|' + mapTspIdTelemarketer.get(objTspDetail.TelesalesPlan__c), objTspDetail.Hours__c);
                mapKeyPriority.put(objTspDetail.Ship_To__c + '|' + aOldMap.get(objTspDetail.Id).Hours__c + '|' + aOldMap.get(objTspDetail.Id).Priority__c + '|' + mapTspIdTelemarketer.get(objTspDetail.TelesalesPlan__c), objTspDetail.Priority__c);
            }
        }

        List<Task> lstTask = [SELECT Id, WhatId, WhoId, OwnerId, TimeToCall__c, Status, TelesalesPlan__c, 
                            Priority, TypeTask__c, ActivityDate, ShipTo__c, CreditLimit__c, ExtraInformation__c, 
                            TelesalesPlandetail__r.Hours__c,
                            CurrencyIsoCode, Subject, TelesalesPlanDetail__c FROM Task WHERE ActivityDate = :today AND TelesalesPlanDetail__c IN :aNewList];
        if(lstTask.isEmpty()) return;

        List<Task> lstTaskToUpdt = new List<Task>();
        List<Task> lstTasksToClone = new List<Task>();
        
        for(Task objTask : lstTask){
            String key =  objTask.ShipTo__c + '|' + objTask.TelesalesPlandetail__r.Hours__c + '|' + objTask.Priority + '|' + mapTspIdTelemarketer.get(objTask.TelesalesPlan__c);
            String priority = mapKeyPriority.get(key);
            Time timeToCall = mapKeyHour.get(key);
            
            if(objTask.Status == 'Open' && key != null){
                objTask.TimeToCall__c = timeToCall;
                objTask.Priority = priority;
                lstTaskToUpdt.add(objTask);
            }else if(objTask.Status != 'Open' && key != null ){
                lstTasksToClone.add(objTask);
            }
        }   
        if(!lstTaskToUpdt.isEmpty() && lstTaskToUpdt != null){
            update lstTaskToUpdt;
        }
        
        List<Task> lstTaskToInsert = new List<Task>();
        System.debug('MapTime: ' + mapKeyHour.keySet());
        if(!lstTasksToClone.isEmpty()){
            for(Task objTask : lstTasksToClone){   
                Time timeToCall = mapKeyHour.get(objTask.ShipTo__c + '|' + objTask.TelesalesPlandetail__r.Hours__c + '|' + objTask.Priority + '|' + mapTspIdTelemarketer.get(objTask.TelesalesPlan__c));
                String priority = mapKeyPriority.get(objTask.ShipTo__c + '|' + objTask.TelesalesPlandetail__r.Hours__c + '|' + objTask.Priority + '|' + mapTspIdTelemarketer.get(objTask.TelesalesPlan__c));   
                Task newTask = new Task(
                    WhatId = objTask.WhatId, 
                    WhoId = objTask.WhoId,
                    OwnerId = objTask.OwnerId,
                    Status = 'Open',
                    TelesalesPlan__c = objTask.TelesalesPlan__c,
                    Priority = priority,
                    TypeTask__c = objTask.TypeTask__c,
                    ActivityDate = today,
                    ShipTo__c = objTask.ShipTo__c,
                    CreditLimit__c = objTask.CreditLimit__c,
                    ExtraInformation__c = objTask.ExtraInformation__c,
                    CurrencyIsoCode = objTask.CurrencyIsoCode,
                    Subject = objTask.Subject,
                    TimeToCall__c = timeToCall,
                    TelesalesPlanDetail__c = objTask.TelesalesPlanDetail__c
                );
                lstTaskToInsert.add(newTask);
            }
        }
        
        if(!lstTaskToInsert.isEmpty() && lstTaskToInsert != null){
            insert lstTaskToInsert;
        }
    }

    public static void deleteRelatedTasks(List<TelesalesPlanDetail__c> aOldList){

        Set<Id> setTspId = new Set<Id>();

        for(TelesalesPlanDetail__c objTspDetail : aOldList){
            setTspId.add(objTspDetail.TelesalesPlan__c);
        }   

        Map<Id,Id> mapTspIdTelemarketer = new Map<Id,Id>();

        List<TelesalesPlan__c> lstTsp = [SELECT Id, Telemarketer__c FROM TelesalesPlan__c WHERE Id IN :setTspId];
        for(TelesalesPlan__c objTsp : lstTsp){
            mapTspIdTelemarketer.put(objTsp.Id, objTsp.Telemarketer__c);
        }
        
        Set<String> setShipToKey = new Set<String>();
         
        for(TelesalesPlanDetail__c objTspDetail : aOldList){
            setShipToKey.add(objTspDetail.Ship_To__c + '|' + objTspDetail.Hours__c + '|' + objTspDetail.Priority__c + '|' + mapTspIdTelemarketer.get(objTspDetail.TelesalesPlan__c));
        }

        List<Task> lstTask = [SELECT Id, ShipTo__c, TimeToCall__c, Priority, TelesalesPlan__c FROM Task WHERE TelesalesPlan__c IN :setTspId];

        List<Task> lstTaskToDelete = new List<Task>();
        for(Task objTask : lstTask){
            if(setShipToKey.contains(objTask.ShipTo__c + '|' + objTask.TimeToCall__c + '|' + objTask.Priority + '|' + mapTspIdTelemarketer.get(objTask.TelesalesPlan__c))){
                lstTaskToDelete.add(objTask);   
            }
        }
        delete lstTaskToDelete;
    }
}