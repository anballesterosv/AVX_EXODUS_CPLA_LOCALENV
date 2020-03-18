/**
@Author - Aditi Sharma
@name - OpportunityClone
@CreateDate - 12-29-2016
@Description - This is a Batch class to clone all the Renewed Opportunities and its opportunities products.
@Revision-
*/ 
global class OpportunityClone implements Database.Batchable<sObject>{
    
       global String Query;
    
 /*@Description - Batch Start Method to get the List of Opportunities in a string .
@Author - Aditi Sharma
@date - 12-29-2016
@param - Database.BatchableContext BC
@Return - Database.QueryLocator */ 
    global Database.QueryLocator start(Database.BatchableContext BC){
        string blank = '';
        string isCloned = Label.Is_Cloned;
        Query = Label.Query;
        return Database.getQueryLocator(Query);
        
    }
 /*@Description - Batch execute Method to clone the list of opportunities and their opportunity products
@Author - Aditi Sharma
@date - 12-29-2016
@param - List<opportunity> lstOfOpportunity
@Return - Database.QueryLocator */     
    global void execute(Database.BatchableContext BC, List<opportunity> lstOfOpportunity){
        map<id,id>mapOfOppIds = new map<id,id>();
        string fieldFromUtils = utils.getCreatableFieldsSOQL('OpportunityLineItem');     
        fieldFromUtils = fieldFromUtils .replaceall(',UnitPrice','');        
        string fieldFromUtilsforProjectOpportunity = utils.getCreatableFieldsSOQL('ProjectOpportunity__c');       
        id userid = UserInfo.getUserId();     
        map<id,opportunity>mapOfOldOpportunities = new map<id,opportunity>([select id,
                                                                            old_opportunity__r.ownerid from opportunity Limit 1000]); 
        list<opportunity> lstOfOpportunityUpdate = new list<opportunity>();
        list<opportunity> lstofoppinsert = new list<opportunity>();
        //record type Map by Name
        Map<String,Schema.RecordTypeInfo> oppRecordTypeMap = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        //This code is to clone the opportunities with Renewal date equals to Today 
        for(Opportunity opp : lstOfOpportunity){ 
            opportunity newOpp = opp.clone(false, true, false,false); //do a deep clone  
          
            newOpp.IsApexCloned__c = true;
            newOpp.SourceOpportunity__c = opp.id;
          
            newOpp.Name = opp.BusinessAlias__c+' '+Label.NewOppName+' '+opp.Account.name+' '+Label.NewOppName+' '+ 
                            STRING.VALUEOF(system.today().addMonths(1))+' '+Label.NewOppName+' '+opp.OriginalName__c;         
            if(newOpp.name.length()>=150 ){
               newOpp.name = newOpp.name.substring(0,79);
            }  
            newOpp.CloseDate = system.today().addMonths(1);
            newOpp.RenewalDate__c =null;
             newOpp.Probability = null;
             //newOpp.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name ='New Opportunity'].Id;
             newOpp.RecordTypeId = oppRecordTypeMap.get('New Opportunity').getRecordTypeId();
             newOpp.CloseReason__c = null;
             newOpp.StageName = null;
            newOpp.StageName = Label.OpportunityStage;
            newOpp.Type = Label.OpportunityTypeRenewal;            
            opp.External_ID__c = Label.Is_Cloned;
            lstofoppinsert.add(newOpp);
            lstOfOpportunityUpdate .add(opp);  
        }
        Database.insert(lstofoppinsert,false);         
        Database.update(lstOfOpportunityUpdate,false) ;
        
        //Getting the Map of old opportunity and new opportunity
         lstofoppinsert = [select id,SourceOpportunity__c,external_id__c,old_opportunity__r.ownerid,
                           old_opportunity__r.OriginalName__c from opportunity where id in:lstofoppinsert Limit 1000];
         for(opportunity objopp:lstofoppinsert){
           
            objopp.ownerid = objopp.old_opportunity__r.ownerid;
            mapOfOldOpportunities.put(objopp.SourceOpportunity__c,objopp);
            objopp.OriginalName__c = objopp.old_opportunity__r.OriginalName__c;
        }
     
        list<OpportunityLineItem> lstOfOpporLineinsert = new list<OpportunityLineItem>();
        
      integer month = system.today().month();
        integer year = system.today().year();
        string fiscalDatestring;
        if(month>=6){
         fiscalDatestring = '06/01/'+year;
        }
        else{
          year = year-1;
          fiscalDatestring = '06/01/'+year;
        }
        date currentfiscalyear = date.parse(fiscalDatestring);        
        date fiscaldate = currentfiscalyear.addyears(-3);     
     
        string query = 'SELECT id,' + fieldFromUtils+ ' FROM OpportunityLineItem  where opportunityid in:lstOfOpportunity and ActiveProduct2__c=true and product2.IsActive=true Limit 1000';
         string queryForProjectOpp = 'SELECT id,' + fieldFromUtilsforProjectOpportunity+ ' FROM ProjectOpportunity__c where Opportunity__c in:lstOfOpportunity and Project__r.MeasureDate__c!=null and Project__r.MeasureDate__c>=:fiscalDate Limit 1000';
       
        list<OpportunityLineItem> lstOfOpporLine =database.query(query);
        list<ProjectOpportunity__c> lstOfOpportunityproject = database.query(queryForProjectOpp);
     
        list<ProjectOpportunity__c> lstOfOpportunityProjectInsert = new list<ProjectOpportunity__c>();
        //This code is to Clone the opportunity product and map it to the corresponding new opportunity
    
        if(lstOfOpporLine!= Null && !lstOfOpporLine.isempty()){
        
            for(OpportunityLineItem objOppLine:lstOfOpporLine){
           
            
                if(mapOfOldOpportunities.containsKey(objOppLine.opportunityid)){
               
                    OpportunityLineItem newobjopportunityline = new OpportunityLineItem();
                    newobjopportunityline = objOppLine.clone(false, true);
                    newobjopportunityline.opportunityid = mapOfOldOpportunities .get(objOppLine.opportunityid).id;
                    lstOfOpporLineinsert.add(newobjopportunityline); 
                    
                }
            }
        }
        if(lstOfOpportunityProject!= Null && !lstOfOpportunityProject.isempty()){
        
            for(ProjectOpportunity__c objProjectOpportunity:lstOfOpportunityProject){
           
            
                if(mapOfOldOpportunities.containsKey(objProjectOpportunity.opportunity__c)){
               
                    ProjectOpportunity__c newobjProjectOpp = new ProjectOpportunity__c ();
                    newobjProjectOpp  = objProjectOpportunity.clone(false, true);
                    newobjProjectOpp.opportunity__c = mapOfOldOpportunities .get(objProjectOpportunity.opportunity__c).id;
                    lstOfOpportunityProjectInsert.add(newobjProjectOpp); 
                    
                }
            }
        }
       Database.insert(lstOfOpporLineinsert,false);
       Database.insert(lstOfOpportunityProjectInsert,false);
        
    }
/*@Description - Batch finish Method.
@Author - Aditi Sharma
@date - 12-29-2016
@param - 
@Return - */ 
    global void finish(Database.BatchableContext BC){
    }
}