public with sharing class AVX_TelesalesTriggerHelper_cls {
    
    public AVX_TelesalesTriggerHelper_cls() {
        System.debug('Enter to empty constructor');
        
    }

    public static void validateTelesalesPlanUpdate(List<TelesalesPlan__c> records, Map<Id,TelesalesPlan__c> oldMap){
        String errorMessage = System.Label.AVX_Telesales_there_is_a_plan_active;
        Set<Id> idTelemerketers = new Set<Id>();
        Set<Id> recordTypes = new Set<Id>();
        for(TelesalesPlan__c t : records) {
            idTelemerketers.add(t.Telemarketer__c);
            recordTypes.add(t.RecordTypeId);
        }
        List<TelesalesPlan__c> lstPlans = Database.query(String.escapeSingleQuotes('SELECT Telemarketer__c,RecordTypeId,StartDate__c, Enddate__c FROM TelesalesPlan__c WHERE Telemarketer__c in:idTelemerketers AND RecordTypeId in :recordTypes order by StartDate__c asc') );
        if( (!lstPlans.isEmpty() && lstPlans.size()==1)){ //The plan is unique(!)
            Boolean error = false;
            Boolean revalidateStartDate = false;
            Boolean revalidateEndDate = false;
            TelesalesPlan__c oldObj;
            for(TelesalesPlan__c newPlan: records) {
                oldObj = oldMap.get(newPlan.Id);
                Boolean startDateChange = false;
                Boolean endDateChange = false;
                //what change
                if(newPlan.StartDate__c != oldObj.StartDate__c){
                    startDateChange = true; 
                } 
                if(newPlan.Enddate__c != oldObj.Enddate__c){
                    endDateChange = true;
                }
                if(startDateChange && !(newPlan.StartDate__c>=oldObj.StartDate__c &&  newPlan.StartDate__c<=oldObj.Enddate__c)){
                    revalidateStartDate = true;
                }
                if(endDateChange && !(newPlan.Enddate__c>=oldObj.StartDate__c &&  newPlan.Enddate__c<=oldObj.Enddate__c)){
                    revalidateEndDate = true;
                }
            }

            Boolean breakFor = false;
            if(revalidateStartDate){
                for(TelesalesPlan__c newPlan: records) {
                    for(TelesalesPlan__c planBD: lstPlans) {
                        if(newPlan.StartDate__c >= planBD.StartDate__c && newPlan.StartDate__c <= planBD.Enddate__c){
                            newPlan.addError(errorMessage);
                            breakFor= true;
                            break;
                        }
                    }
                    if(breakFor){
                        break;
                    }
                }
            }
            if(revalidateEndDate){
                for(TelesalesPlan__c newPlan: records) {
                    for(TelesalesPlan__c planBD: lstPlans) {
                        if(newPlan.Enddate__c >= planBD.StartDate__c && newPlan.Enddate__c <= planBD.Enddate__c){
                            newPlan.addError(errorMessage);
                            breakFor= true;
                            break;
                        }
                    }
                    if(breakFor){
                        break;
                    }
                }
            }
 
        }
        
    }

    public static void validateTelesalesPlanActiveInsert(List<TelesalesPlan__c> records) {
        String errorMessage = System.Label.AVX_Telesales_there_is_a_plan_active;
        Set<Id> idTelemerketers = new Set<Id>();
        Set<Id> recordTypes = new Set<Id>();
        Set<Id> idLstWorkPlans = new Set<Id>();
        List<TelesalesPlan__c> lstPlans = new List<TelesalesPlan__c>();
        String whereCondition;
        Boolean isContingency= false;
        for(TelesalesPlan__c t : records) {
            if(t.Telemarketer__c!=null){
                idTelemerketers.add(t.Telemarketer__c);
            }
            recordTypes.add(t.RecordTypeId);
            if(t.TelesalesWorkPlan__c!=null){
                idLstWorkPlans.add(t.TelesalesWorkPlan__c);
            }
        }
        List<RecordType> lstRecordTypes = Database.query(String.escapeSingleQuotes('SELECT DeveloperName FROM RecordType where id in :recordTypes'));
        if(!lstRecordTypes.isEmpty()){
            String strContingency = lstRecordTypes[0].DeveloperName;
            if(strContingency=='ContingencyPlan'){
                isContingency = true;
                List<TelesalesPlan__c> lstWorkPlans = Database.query(String.escapeSingleQuotes('SELECT id,Telemarketer__c FROM TelesalesPlan__c where id in :idLstWorkPlans'));
                for(TelesalesPlan__c t:lstWorkPlans){
                    idTelemerketers.add(t.Telemarketer__c);
                }
            }
        }
        whereCondition = isContingency? ' TelesalesWorkPlan__r.Telemarketer__c ': 'Telemarketer__c';
        
        if(!idTelemerketers.isEmpty()){
            lstPlans = Database.query(String.escapeSingleQuotes('SELECT Telemarketer__c,RecordTypeId,StartDate__c, Enddate__c FROM TelesalesPlan__c WHERE ' + whereCondition +' in:idTelemerketers AND RecordTypeId in :recordTypes order by StartDate__c asc') );
        }
        Boolean sameDates = false;
        Boolean existStartDate = false;
        Boolean existEndDate = false;
        for(TelesalesPlan__c newPlan: records) {
            for(TelesalesPlan__c planBD: lstPlans) {
                if(newPlan.StartDate__c == planBD.StartDate__c && newPlan.Enddate__c == planBD.Enddate__c){
                    newPlan.addError(errorMessage);
                    sameDates= true;
                    break;
                }
            }
            if(sameDates){
                break;
            }
        }
        if(!sameDates){
            for(TelesalesPlan__c newPlan: records) {
                for(TelesalesPlan__c planBD: lstPlans) {
                    if(newPlan.StartDate__c >= planBD.StartDate__c && newPlan.StartDate__c <= planBD.Enddate__c){
                        newPlan.addError(errorMessage);
                        existStartDate= true;
                        break;
                    }
                }
                if(existStartDate){
                    break;
                }
            }
    
            for(TelesalesPlan__c newPlan: records) {
                for(TelesalesPlan__c planBD: lstPlans) {
                    if(newPlan.Enddate__c >= planBD.StartDate__c && newPlan.Enddate__c <= planBD.Enddate__c){
                        newPlan.addError(errorMessage);
                        existEndDate= true;
                        break;
                    }
                }
                if(existEndDate){
                    break;
                }
            }
        }    
    }   

    public static void createTelesalesTasks(Map<Id,TelesalesPlan__c> aOldMap, Map<Id,TelesalesPlan__c> aNewMap){
        Id workPlanRecType = Schema.SObjectType.TelesalesPlan__c.getRecordTypeInfosByDeveloperName().get('WorkPlan').getRecordTypeId();
        Date today = Date.today();

        Set<Id> setTspId = new Set<Id>();
        for(TelesalesPlan__c objTelesalesPlan : aNewMap.values()){
            Boolean startDateChange = aOldMap.get(objTelesalesPlan.Id).StartDate__c != objTelesalesPlan.StartDate__c;
            Boolean endDateChange = aOldMap.get(objTelesalesPlan.Id).EndDate__c != objTelesalesPlan.EndDate__c;
            Boolean validDateNow = objTelesalesPlan.StartDate__c <= today && objTelesalesPlan.EndDate__c >= today;
            Boolean validDateOld = aOldMap.get(objTelesalesPlan.Id).StartDate__c <= today && aOldMap.get(objTelesalesPlan.Id).EndDate__c >= today;
            Boolean workPlanReType = objTelesalesPlan.RecordTypeId == workPlanRecType;
            if((startDateChange || endDateChange) && validDateNow && !validDateOld && workPlanReType){
                setTspId.add(objTelesalesPlan.Id);
            }
        }
        if(setTspId.isEmpty()) return;

        List<TelesalesPlanDetail__c> lstTpsDetail = [SELECT Id, TelesalesPlan__c, Ship_To__c, Priority__c, Hours__c FROM TelesalesPlanDetail__c WHERE TelesalesPlan__c IN :setTspId];
        if(lstTpsDetail.isEmpty()) return;

        //Getting Ship To Information
        Set<Id> setShipToId = new Set<Id>();
        for(TelesalesPlanDetail__c objTspDetail : lstTpsDetail){
            setShipToId.add(objTspDetail.Ship_To__c);
        }

        Map<Id,Ship_To__c> mapTspDetailIdShipTo = new Map<Id,Ship_To__c>();

        List<Ship_To__c> lstShipTo = [SELECT Id, Commercial_Account__c, CreditLimit__c, ExtraInformation__c, PrimaryContact__c, Name FROM Ship_To__c WHERE Id IN :setShipToId];
        if(!lstShipTo.isEmpty()){
            for(Ship_To__c objShipTo : lstShipTo){
                mapTspDetailIdShipTo.put(objShipTo.Id, objShipTo);
            }
        }

        //Getting Account information
        Set<Id> setCommercialAccId = new Set<Id>();
        for(Ship_To__c objShipTo : lstShipTo){
            setCommercialAccId.add(objShipTo.Commercial_Account__c);
        }

        List<Account> lstAccount = [SELECT Id, CurrencyIsoCode, Name FROM Account WHERE Id IN :setCommercialAccId];

        Map<Id, Account> mapShipToIdAccount = new Map<Id, Account>();
        if(!lstAccount.isEmpty()){
            for(Account objCommercialAcc : lstAccount){
                mapShipToIdAccount.put(objCommercialAcc.Id, objCommercialAcc);
            }
        }

        //Getting TelesalesPlan record type name
        Map<Id,String> mapTspIdRecTypeName = new Map<Id,String>();

        List<TelesalesPlan__c> lstTsp = [SELECT Id, RecordType.DeveloperName FROM TelesalesPlan__c WHERE Id IN :aNewMap.keySet()];
        for(TelesalesPlan__c objTsp : lstTsp){
            mapTspIdRecTypeName.put(objTsp.Id, objTsp.RecordType.DeveloperName);
        }

        Map<Id,List<TelesalesPlanDetail__c>> tspAndTspDetailMap = new Map<Id,List<TelesalesPlanDetail__c>>();
        for(TelesalesPlanDetail__c objTspDetail : lstTpsDetail){
            if(tspAndTspDetailMap.containsKey(objTspDetail.TelesalesPlan__c)){
                List<TelesalesPlanDetail__c> lstTspDetailChildren = tspAndTspDetailMap.get(objTspDetail.TelesalesPlan__c);
                lstTspDetailChildren.add(objTspDetail);
            }else{
                List<TelesalesPlanDetail__c> lstTspDetailChildren = new List<TelesalesPlanDetail__c>();
                lstTspDetailChildren.add(objTspDetail);
                tspAndTspDetailMap.put(objTspDetail.TelesalesPlan__c, lstTspDetailChildren);
            }
        }

        List<Task> lstNewTasksToInsert = new List<Task>();
        String callTo = System.Label.AVX_CallTo;

        Set<Id> setOwnerId = new Set<Id> ();
        for(Id objTelesalesId : tspAndTspDetailMap.keySet()){
            for(TelesalesPlanDetail__c objTspDetail : tspAndTspDetailMap.get(objTelesalesId)){
                System.debug('tipu-> ' + mapTspIdRecTypeName.get(objTspDetail.TelesalesPlan__c));
                Task objTask = new Task(
                    WhatId = objTspDetail.Ship_To__c,
                    WhoId = mapTspDetailIdShipTo.get(objTspDetail.Ship_To__c).PrimaryContact__c,
                    OwnerId = aNewMap.get(objTspDetail.TelesalesPlan__c).Telemarketer__c,
                    TelesalesPlan__c = objTspDetail.TelesalesPlan__c,
                    Status = 'Open',
                    Priority = objTspDetail.Priority__c,
                    ActivityDate = Date.today(),
                    TimeToCall__c = objTspDetail.Hours__c,
                    TypeTask__c = mapTspIdRecTypeName.get(objTspDetail.TelesalesPlan__c),
                    ShipTo__c = objTspDetail.Ship_To__c,
                    CreditLimit__c = mapTspDetailIdShipTo.get(objTspDetail.Ship_To__c).CreditLimit__c,
                    ExtraInformation__c = mapTspDetailIdShipTo.get(objTspDetail.Ship_To__c).ExtraInformation__c,
                    CurrencyIsoCode = mapShipToIdAccount.get(mapTspDetailIdShipTo.get(objTspDetail.Ship_To__c).Commercial_Account__c).CurrencyIsoCode,
                    Subject = callTo + ' ' + mapTspDetailIdShipTo.get(objTspDetail.Ship_To__c).Name,
                    TelesalesPlanDetail__c = objTspDetail.Id
                );
                setOwnerId.add(aNewMap.get(objTspDetail.TelesalesPlan__c).Telemarketer__c);
                lstNewTasksToInsert.add(objTask);
            }
        } 
        Map<String,Task> mapUniqueTask = new Map<String,Task>();

        List<Task> lstTask = [SELECT Id, OwnerId, Status, WhatId, ActivityDate FROM Task WHERE ActivityDate = :today AND Status = 'Open' AND OwnerId IN: setOwnerId];

        for(Task objTask : lstTask){
            mapUniqueTask.put(objTask.OwnerId + '|' + objTask.WhatId + '|' + objTask.ActivityDate, objTask);
        }
        
        List<Task> lstNewTasksToInsertFinal = new List<Task>();
        for (Task tskInsert: lstNewTasksToInsert) {
            if(mapUniqueTask.get(tskInsert.OwnerId + '|' + tskInsert.WhatId + '|' + tskInsert.ActivityDate) == null){
                lstNewTasksToInsertFinal.add(tskInsert);
            }
        }
        System.debug('lstNewTasksToInsertFinal-->');
        System.debug(lstNewTasksToInsertFinal);
        insert lstNewTasksToInsertFinal;
    }


    public static void reassignTasks(Map<Id,TelesalesPlan__c> aOldMap, Map<Id,TelesalesPlan__c> aNewMap){
        Id contingencyPlanRecTypeId = Schema.SObjectType.TelesalesPlan__c.getRecordTypeInfosByDeveloperName().get('ContingencyPlan').getRecordTypeId();
        Date today = Date.today();
        Time currentTime = Datetime.now().time();

        Set<Id> setTspIds = new Set<Id>();

        for(TelesalesPlan__c objTelesalesPlan : aNewMap.values()){
            Boolean startDateChange = aOldMap.get(objTelesalesPlan.Id).StartDate__c != objTelesalesPlan.StartDate__c;
            Boolean endDateChange = aOldMap.get(objTelesalesPlan.Id).EndDate__c != objTelesalesPlan.EndDate__c;
            Boolean validDateNow = objTelesalesPlan.StartDate__c <= today && objTelesalesPlan.EndDate__c >= today;
            Boolean validDateOld = aOldMap.get(objTelesalesPlan.Id).StartDate__c <= today && aOldMap.get(objTelesalesPlan.Id).EndDate__c >= today;
            Boolean contingencyRecType = aNewMap.get(objTelesalesPlan.Id).RecordTypeId == contingencyPlanRecTypeId;

            if((startDateChange || endDateChange) && validDateNow && !validDateOld && contingencyRecType){
                setTspIds.add(objTelesalesPlan.Id);
            }
        }

        List<TelesalesPlanDetail__c> lstTspDetail = [SELECT Id, TelesalesPlan__c, Telemarketer__c, Ship_To__c, Hours__c, DayOfTheWeek__c, Priority__c FROM TelesalesPlanDetail__c WHERE TelesalesPlan__c IN :setTspIds AND Hours__c > :currentTime];
        if(lstTspDetail.isEmpty()) return;

        Map<String,Id> mapContingencyDetail = new Map<String,Id>();
        for(TelesalesPlanDetail__c objTspDetail : lstTspDetail){
            mapContingencyDetail.put(objTspDetail.Ship_To__c + '|' + objTspDetail.Priority__c, objTspDetail.Telemarketer__c);
        }
        
        List<Task> lstTask = [SELECT Id, TelesalesPlan__c, OwnerId, ShipTo__c, ActivityDate, Priority FROM Task WHERE ActivityDate = :today];
        if(lstTask.isEmpty()) return;

        List<Task> lstTaskToUpdt = new List<Task>();
        for(Task objTask : lstTask){
            objTask.OwnerId = mapContingencyDetail.get(objTask.ShipTo__c + '|' + objTask.Priority);
            lstTaskToUpdt.add(objTask);
        }

        if(lstTaskToUpdt != null && !lstTaskToUpdt.isEmpty()){
            update lstTaskToUpdt;
        }
    }

    public static void deleteRelatedDetails(Map<Id,TelesalesPlan__c> aOldMap){
        
        List<TelesalesPlanDetail__c> lstTspDetailToDelete = new List<TelesalesPlanDetail__c>();

        for(TelesalesPlanDetail__c objTspDetail : [SELECT Id FROM TelesalesPlanDetail__c WHERE TelesalesPlan__c IN :aOldMap.keySet()]){
            lstTspDetailToDelete.add(objTspDetail);
        }

        if(!lstTspDetailToDelete.isEmpty() && lstTspDetailToDelete != null){
            delete lstTspDetailToDelete;
        }
    }
}