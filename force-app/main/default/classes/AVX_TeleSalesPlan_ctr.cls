/**************************************************************************************************************
* Avanxo Brasil
* @author           Ismael Sanchez (isanchez@avanxo.com)
* Project:          CPLA - EXODUS Project
* Description:      Class used to assign clients to a telesales plan or  contingency plan
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                      Description     
*           -----   ----------      --------------------        ---------------   
* @version   1.0    2020-03-05      Ismael Sanchez              class created 
*************************************************************************************************************/
public with sharing class AVX_TeleSalesPlan_ctr {
    public AVX_TeleSalesPlan_ctr() {
        System.debug(LoggingLevel.DEBUG, 'Enter to empty constructor');
    }
        

    public static String parseSecondsToHours(Long longtime){
        String timeParsed = '';
        if(longtime!=null){
            DateTime dt = DateTime.newInstance(longtime);
            String myDtString = dt.format().substring(11);
        }
        return timeParsed;
    } 


@AuraEnabled
public static RecordType getRecordTypeById(String id){
    RecordType rt;
    List<RecordType> lstRecordTypes = [SELECT Id,  Name, DeveloperName, Description FROM RecordType WHERE id=:id ];
    if(!lstRecordTypes.isEmpty()){
        rt = lstRecordTypes[0];
    }
    return rt;
}


@AuraEnabled
public static List<User> getTelemarketerByFilters(String textFilter, String plansToExlud, String idContingencyPlan) {
    String key =  '%' + String.escapeSingleQuotes(textFilter)   + '%'; 
    List<String> lstAlpha = plansToExlud.split(',');
    Set<Id> idUsers = new Set<Id>();
    List<User> lstUsers = new List<User>();
    List<TelesalesPlan__c> lstTelemarketerToExclude = [SELECT TelesalesWorkPlan__r.Telemarketer__c FROM TelesalesPlan__c WHERE Id =:idContingencyPlan limit 1];
    for(TelesalesPlan__c t: [SELECT Telemarketer__r.Name, Name, Id FROM TelesalesPlan__c WHERE Telemarketer__r.Name like :key
                            AND Id not in :lstAlpha ]){
        if(!lstTelemarketerToExclude.isEmpty()){
            if(t.Telemarketer__r.Id!=lstTelemarketerToExclude[0].TelesalesWorkPlan__r.Telemarketer__c){
                idUsers.add(t.Telemarketer__r.Id);
            }

        }
    }
    if(!idUsers.isEmpty()){
        lstUsers =  [SELECT Name, Id FROM User WHERE Id in:idUsers ];
    }
    return lstUsers;
}


@AuraEnabled
public static List<WrapperClientList> reloadContingencyClients( String textFilter, String day, String idContingencyPlan ){
    return executeQueryContingencyClients(textFilter, day, idContingencyPlan);
}

@AuraEnabled(cacheable=true)
public static List<WrapperClientList> getContingencyClients( String textFilter, String day, String idContingencyPlan ){
    return executeQueryContingencyClients(textFilter, day, idContingencyPlan);
}

public static List<WrapperClientList> executeQueryContingencyClients(String textFilter, String day, String idContingencyPlan){
    String key = '%' + String.escapeSingleQuotes(textFilter) + '%';
    Set<String> orExpressions = getOrExpression(textFilter);
    Map<String,TelesalesPlanDetail__c> contingencyDetailsMap = new Map<String,TelesalesPlanDetail__c>();
    List<WrapperClientList> wrapperList = new List<WrapperClientList>();
    List<TelesalesPlanDetail__c> lstDetails = new List<TelesalesPlanDetail__c>();
    List<TelesalesPlan__c > lstPlanes = [Select TelesalesWorkPlan__c from TelesalesPlan__c where id=:idContingencyPlan ];
    List<TelesalesPlanDetail__c> lstContingencyDetails = [SELECT Ship_To__c,Hours__c,DayOfTheWeek__c  FROM TelesalesPlanDetail__c where  TelesalesPlan__c= :idContingencyPlan];
    if(!lstContingencyDetails.isEmpty()){
        for(TelesalesPlanDetail__c t: lstContingencyDetails){
            String keyMap = t.Ship_To__c + '_' + t.DayOfTheWeek__c + '_' + t.Hours__c;
            contingencyDetailsMap.put(keyMap, t);
        }
    }
    String idTelesalesPlan = '';
    if(!lstPlanes.isEmpty()){ 
        idTelesalesPlan = lstPlanes[0].TelesalesWorkPlan__c;
    }
    String orExpressionValidated = orExpressions.size() > 0? ' ( Ship_To__r.Name like :orExpressions OR Ship_To__r.ERP_Number__c like :orExpressions )' : ' ( Ship_To__r.Name like :key OR Ship_To__r.ERP_Number__c like :key) ';
    if(day.equalsIgnoreCase('GENERAL')){
        lstDetails =  Database.query(String.escapeSingleQuotes('SELECT Ship_To__r.Name, Ship_To__r.Commercial_Account__c, Ship_To__r.ERP_Number__c, TelesalesPlan__c, DayOfTheWeek__c,Hours__c, Priority__c  ' 
                                    + '  FROM TelesalesPlanDetail__c  where ' + orExpressionValidated + ' AND TelesalesPlan__c =:idTelesalesPlan  limit 300 '));
    } else {
        lstDetails =  Database.query(String.escapeSingleQuotes('SELECT Ship_To__r.Name, Ship_To__r.Commercial_Account__c, Ship_To__r.ERP_Number__c, TelesalesPlan__c, DayOfTheWeek__c,Hours__c, Priority__c  ' 
                                    + '  FROM TelesalesPlanDetail__c  where ' + orExpressionValidated + '  AND TelesalesPlan__c =:idTelesalesPlan  AND DayOfTheWeek__c=:day limit 300 '));
    }

    if(!lstDetails.isEmpty()){
        for(TelesalesPlanDetail__c t: lstDetails){
            String keyFor = t.Ship_To__c + '_' + t.DayOfTheWeek__c + '_' + t.Hours__c;
            if(!contingencyDetailsMap.containsKey(keyFor)){
                WrapperClientList w = new WrapperClientList();
                w.telesalesPlanDetail = t;
                wrapperList.add(w);
            }
        }
    }
    return wrapperList;
}


@AuraEnabled
public static List<WrapperClientList> getClientsByFiltersReload (String idPlan,String textfilter,String itemsToShow, Boolean isWorkPlan){
    return executeQueryClientsByFilter(idPlan,textfilter,itemsToShow, isWorkPlan);


}

public static Set<String> getOrExpression(String textfilter) {
    Set<String> likes =  new Set<String>();
    if(textfilter.length()>0 && textfilter.contains(',')){
        String [] arrStrings = textfilter.split(',');
        for(String s: arrStrings) {
            if(s.length()!=0){
                String likeExp = '%' +    String.escapeSingleQuotes(s.trim())   + '%'; 
                likes.add(likeExp);
            }
        }
    }
    System.debug(likes);
  return likes;  
}

public static List<WrapperClientList> executeQueryClientsByFilter (String idPlan,String textfilter,String itemsToShow, Boolean isWorkPlan){
        String key = '%' + textfilter + '%';
        Set<String> orExpressions = getOrExpression(textfilter); 
        List<WrapperClientList> finalList = new List<WrapperClientList>();
        List<WrapperClientList> lstAdded = new List<WrapperClientList>();
        List<WrapperClientList> lstNotAdded = new List<WrapperClientList>();
        List<WrapperClientList> lstOther = new List<WrapperClientList>();
        Map<Id,Id> relacionMap = new Map<Id,Id>();
        Map<Id,TelesalesPlan__c> telesalesPlanMap = new Map<Id,TelesalesPlan__c>();
        Set<Id> idTelesalesPlan = new Set<Id>();
        Set<Id> idInitial = new Set<Id>();
        Set<Id> idOther = new Set<Id>();
        String rtContingency = 'Contingency Plan';
        String orExpressionValidated = !orExpressions.isEmpty()? '(Name like :orExpressions OR ERP_Number__c like :orExpressions)' : ' (Name like :key OR ERP_Number__c like :key) ';
        List<TelesalesPlanDetail__c> lstInitialAdded = Database.query(string.escapeSingleQuotes('SELECT TelesalesPlan__r.RecordType.Name,Ship_To__c,TelesalesPlan__c  FROM TelesalesPlanDetail__c where  TelesalesPlan__c =:idPlan' +
         (isWorkPlan?'':' AND TelesalesPlan__r.RecordType.Name !=:rtContingency ') + ' limit 300'));
        List<TelesalesPlanDetail__c> lstInitialOther = Database.query(string.escapeSingleQuotes('SELECT TelesalesPlan__r.RecordType.Name,Ship_To__c,TelesalesPlan__c  FROM TelesalesPlanDetail__c where TelesalesPlan__c !=:idPlan ' +
         (isWorkPlan?'':' AND TelesalesPlan__r.RecordType.Name !=:rtContingency ') + 'limit 300'));
        for(TelesalesPlanDetail__c t:lstInitialAdded){
            idInitial.add(t.Ship_To__c);
        }
        for(TelesalesPlanDetail__c t:lstInitialOther) {
            idOther.add(t.Ship_To__c);
            idTelesalesPlan.add(t.TelesalesPlan__c);
            relacionMap.put(t.Ship_To__c, t.TelesalesPlan__c);
        }
        List<TelesalesPlan__c> lstTelesalesPlan = Database.query(String.escapeSingleQuotes('SELECT Telemarketer__r.Name, Name, Id FROM TelesalesPlan__c WHERE id IN :idTelesalesPlan'));
        for(TelesalesPlan__c p: lstTelesalesPlan){
            telesalesPlanMap.put(p.Id,p);
        }
        if(!idInitial.isEmpty()){
            List<Ship_To__c> lstAddedResult = Database.query(String.escapeSingleQuotes('  SELECT id,Name,Street__c,Phone__c,ERP_Number__c,Commercial_Account__c FROM  Ship_To__c where ' 
            +  orExpressionValidated + 'AND  id in:idInitial limit 300 '));
            for(Ship_To__c t:lstAddedResult) {
                WrapperClientList w = new WrapperClientList();
                w.added = true;
                w.client = t;
                lstAdded.add(w);
            }
        }
        
        
        List<Ship_To__c> lstOtherResult = Database.query(string.escapeSingleQuotes('  SELECT id,Name,Street__c,Phone__c,ERP_Number__c,Commercial_Account__c FROM Ship_To__c WHERE  ' 
        + orExpressionValidated + ' AND id in:idOther limit 300'));
        for(Ship_To__c t:lstOtherResult) {
            WrapperClientList w = new WrapperClientList();
            w.inOther = true;
            w.client = t;
            if(relacionMap.containsKey(t.Id) && telesalesPlanMap.containsKey(relacionMap.get(t.Id)) ){
                w.telesalesPlan = telesalesPlanMap.get(relacionMap.get(t.Id));
            }
            lstAdded.add(w); 
        }
        Set<Id> finalIdsAded = new Set<Id>();
        finalIdsAded.addAll(idInitial);
        finalIdsAded.addAll(idOther);

        List<Ship_To__c> listNonAdded = Database.query(string.escapeSingleQuotes(' SELECT id,Name,Street__c,Phone__c,ERP_Number__c,Commercial_Account__c FROM Ship_To__c WHERE  ' 
        + orExpressionValidated +  '  AND Id not in:finalIdsAded '));
        for(Ship_To__c s: listNonAdded) {
            WrapperClientList w = new WrapperClientList();
            w.nonAdded = true;
            w.client = s;
            lstNotAdded.add(w);
        }

        if(itemsToShow.equals('ADDED')) {
            finalList.addAll(lstAdded);
        } else if (itemsToShow.equals('NONADDED')){
            finalList.addAll(lstNotAdded);
        } else {//All
            finalList.addAll(lstAdded);
            finalList.addAll(lstNotAdded);
        }
        System.debug(finalList);
        return finalList;
    }


    @AuraEnabled(cacheable=true)
    public static List<WrapperClientList> getClientsByFilters(String idPlan,String textfilter,String itemsToShow, Boolean isWorkPlan ) {
        return executeQueryClientsByFilter(idPlan,textfilter,itemsToShow, isWorkPlan);
    }

    
    @AuraEnabled
    public static List<WrapperClientList> getPlanDetailsByPlanReload (String idPlan, String dayFilter, String orderBy){
        return executeQueryPlanDetailsByPlan(idPlan, dayFilter, orderBy);

    }

    public static   List<WrapperClientList> executeQueryPlanDetailsByPlan (String idPlan, String dayFilter, String orderBy){
        List<WrapperClientList> wrapper = new List<WrapperClientList>();
        List<TelesalesPlanDetail__c> lstPlanDetails = new List<TelesalesPlanDetail__c>();
        if (Schema.sObjectType.TelesalesPlanDetail__c.fields.Name.isAccessible()) {
            String order;
            if(dayFilter=='GENERAL'){
                if (orderBy.contains('HOUR')) {
                    order=orderBy.replace('HOUR','');
                    lstPlanDetails = database.query(String.escapeSingleQuotes('SELECT Telemarketer__c,Telemarketer__r.Name, TelesalesPlan__r.TelesalesWorkPlan__c,TelesalesPlan__r.Telemarketer__r.Name, id, name,DayOfTheWeek__c,Hours__c,Priority__c, Ship_To__r.Name, Ship_To__r.ERP_Number__c,Ship_To__r.Status__c,Ship_To__r.IdentificationNumber__c '
                                                     +' FROM  TelesalesPlanDetail__c WHERE  TelesalesPlan__c=:idPlan ORDER BY Hours__c '+ order));
                }
            } else {
                if (orderBy.contains('HOUR')) {
                    order=orderBy.replace('HOUR','');
                    lstPlanDetails = database.query(String.escapeSingleQuotes('SELECT Telemarketer__c,Telemarketer__r.Name, TelesalesPlan__r.TelesalesWorkPlan__c,TelesalesPlan__r.Telemarketer__r.Name, id, name, DayOfTheWeek__c,Hours__c, Priority__c,Ship_To__r.Name, Ship_To__r.ERP_Number__c,Ship_To__r.Status__c,Ship_To__r.IdentificationNumber__c '
                                                    + ' FROM  TelesalesPlanDetail__c WHERE  TelesalesPlan__c=:idPlan AND DayOfTheWeek__c =:dayFilter  ORDER BY Hours__c ' +order));
                } 
            }
            if(!lstPlanDetails.isEmpty()){
                for(TelesalesPlanDetail__c t: lstPlanDetails){
                    WrapperClientList w = new WrapperClientList();
                    w.telesalesPlanDetail = t;
                    wrapper.add(w);
                }
            }
        }
        return wrapper;
    }


    @AuraEnabled(cacheable=true)
    public static List<WrapperClientList> getPlanDetailsByPlan (String idPlan, String dayFilter, String orderBy){
        return executeQueryPlanDetailsByPlan(idPlan, dayFilter, orderBy);
    }


    @AuraEnabled
    public static void saveOrUpdateTelesalesPlanDetails(List<TelesalesPlanDetail__c> lstToSaveOrUpdate){
        try{
            if(!lstToSaveOrUpdate.isEmpty()) {
                if (Schema.sObjectType.TelesalesPlanDetail__c.isUpdateable()) {
                    upsert lstToSaveOrUpdate;
                }
            }
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteListTelesalesPlanDetails(List<Id> lstTelesalesPlanDetailsToDelete){
        try{
            if(!lstTelesalesPlanDetailsToDelete.isEmpty()) {
                if (Schema.sObjectType.TelesalesPlanDetail__c.isDeletable()) {
                    delete [Select id From TelesalesPlanDetail__c where id in :lstTelesalesPlanDetailsToDelete];
                }
            }
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<WrapperOptionCombo> getPickistValuesByField(String fieldName) {
        List<WrapperOptionCombo> picklistValues = new List<WrapperOptionCombo>();
        if(fieldName == 'DAYS') {
	        Schema.DescribeFieldResult fieldResult = TelesalesPlandetail__c.DayOfTheWeek__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        for(Schema.PicklistEntry pickListVal : ple) {
                WrapperOptionCombo w = new WrapperOptionCombo();
                w.value = pickListVal.getValue();
                w.label = pickListVal.getLabel();
	            picklistValues.add(w);
	        }
        } else if (fieldName == 'PRIORITY') {
            Schema.DescribeFieldResult fieldResult = TelesalesPlandetail__c.Priority__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        for(Schema.PicklistEntry pickListVal : ple) {
                WrapperOptionCombo w = new WrapperOptionCombo();
                w.value = pickListVal.getValue();
                w.label = pickListVal.getLabel();
	            picklistValues.add(w);
	        } 
        } 
    	return picklistValues;
    }

    
    @AuraEnabled(cacheable=true)
    public static Boolean canEdit(String fieldName) {
        Boolean canEdit = true;
        Id profileId = userinfo.getProfileId();
        List<Profile> lstProfiles= Database.query(String.escapeSingleQuotes('select Name from profile where id=:profileId '));
        if(!lstProfiles.isEmpty()){
            Profile p = lstProfiles[0];
            if(p.Name.equalsIgnoreCase('Telemarketer')){
                canEdit = false;
            }
        }
        return canEdit;
    }

    @AuraEnabled
    public static WrapperTelesalesPlan getPlanDetailsByShipToReload(String idShipTo) {
        return executeQueryPlanDetailByShipTo(idShipTo);
    }
    
    public static WrapperTelesalesPlan executeQueryPlanDetailByShipTo(String idShipTo){
        WrapperTelesalesPlan wrapper = new WrapperTelesalesPlan();
        List<Ship_To__c> shipTo = Database.query(String.escapeSingleQuotes('SELECT id,Name,Street__c,Phone__c,ERP_Number__c,Commercial_Account__c FROM Ship_To__c WHERE id=:idShipTo'));
        if(!shipTo.isEmpty()){
            wrapper.shipTo = shipTo[0];
            String rtContingency = 'Contingency Plan';
            wrapper.lstTelesalesPlanDetails = Database.query(string.escapeSingleQuotes('SELECT id,  name,DayOfTheWeek__c, Hours__c, Priority__c,TelesalesPlan__c, Ship_To__r.Commercial_Account__c,Ship_To__r.Name, Ship_To__r.ERP_Number__c,Ship_To__r.Status__c,Ship_To__r.IdentificationNumber__c ' 
            +'FROM  TelesalesPlanDetail__c WHERE  Ship_To__c=:idShipTo AND TelesalesPlan__r.RecordType.Name !=:rtContingency '));
        }
        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static WrapperTelesalesPlan getPlanDetailsByShipTo(String idShipTo) {
        return executeQueryPlanDetailByShipTo(idShipTo);
    }

    public class WrapperOptionCombo{
        @AuraEnabled public String value{set;get;}
        @AuraEnabled public String label{set;get;}
        public WrapperOptionCombo() { 
            this.label = '';
            this.value = '';
        }
    } 


    public class WrapperClientList {
        @AuraEnabled public Boolean added{set;get;}
        @AuraEnabled public Boolean nonAdded{set;get;}
        @AuraEnabled public Boolean inOther{set;get;}
        @AuraEnabled public Boolean checked{set;get;}
        @AuraEnabled public Ship_To__c client{set;get;}
        @AuraEnabled public String hourFormated {set;get;}
        @AuraEnabled public TelesalesPlan__c telesalesPlan {set;get;}
        @AuraEnabled public TelesalesPlanDetail__c  telesalesPlanDetail {set;get;}
        @AuraEnabled public User telemarketer {set;get;}
        public WrapperClientList() {
            this.added = false;
            this.nonAdded = false;
            this.inOther = false;
            this.client = null;
            this.telesalesPlan = null;
            this.checked = false;
            this.telesalesPlanDetail = null;
            this.telemarketer = null;
            this.hourFormated = null;
        }
    }

    public class WrapperTelesalesPlan {
        @AuraEnabled public Ship_To__c shipTo{set;get;}
        @AuraEnabled public List<TelesalesPlanDetail__c> lstTelesalesPlanDetails{set;get;}
       

        public WrapperTelesalesPlan() {
            this.shipTo = null;
            this.lstTelesalesPlanDetails = null;
        }
    }
}