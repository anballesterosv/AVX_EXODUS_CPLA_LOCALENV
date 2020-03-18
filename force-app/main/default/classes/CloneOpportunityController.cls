/**
   @Author - Aditi.O.Sharma
   @name -  cloneOpportunityController 
   @CreateDate - 
   @Description - Clones the Opportunity
   @Revision- 1.0
*/
public class CloneOpportunityController {
    public id opportunityId;
    Private final string EMPTYSPACESTRING = ' ';
    Private final string EMPTYSTRING = '';
    Private final string SLASHSTRING = '/';
    Private final string STAGESTRING = 'Explore';
    Private final string FISCALSTRING = '06/01/';
    Private final string OPPLINEITEMSTRING = 'OpportunityLineItem';
    Private final string TOTALPRICESTRING = ',TotalPrice';
    Private final string PROJECTPRODUCTIDSTRING = ',Project_Product_Id__c';
    //Private final string OPPORTUNITYSTRING = 'Opportunity';
    //Private final string NEWOPPORTUNITY = 'New Opportunity';
    Private final string SELECTQUERY1STRING = 'SELECT id,Project_Product_Id__c,';
    Private final String FROMQUERYSTRING = ' FROM OpportunityLineItem  where opportunityid =:opportunityid and ActiveProduct2__c=true and product2.IsActive=true Limit 1000';
    Private final string SELECTIDSTRING = 'SELECT id,';
    Private final string FROMSTRING = ' FROM ProjectOpportunity__c where Opportunity__c =:opportunityid and Project__r.MeasureDate__c!=null and Project__r.MeasureDate__c>=:fiscalDate Limit 1000';
       /*
    @methodname-cloneOpportunityController
    @aurguments-controller
    @description-standard controller
    */
    public cloneOpportunityController(ApexPages.StandardController controller) {
        opportunityId = ApexPages.currentPage().getParameters().get('id');
    }
     /*
    @methodname-save
    @aurguments-null
    @return - PageReference
    */
     public PageReference save() {
        //Proxy Code
         if(!Test.isRunningTest() ){
        opportunityId = ApexPages.currentPage().getParameters().get('id');
        }
        string fieldFromUtils = utils.getCreatableFieldsSOQL(OPPLINEITEMSTRING);
        fieldFromUtils = fieldFromUtils .replaceall(TOTALPRICESTRING ,EMPTYSTRING);
        fieldFromUtils = fieldFromUtils .replaceall(PROJECTPRODUCTIDSTRING ,EMPTYSTRING);
        string fieldFromUtilsforProjectOpportunity = utils.getCreatableFieldsSOQL('ProjectOpportunity__c');
        id userid = UserInfo.getUserId();     
        list<opportunity> lstOfOpportunityUpdate = new list<opportunity>();
        list<opportunity> lstofoppinsert = new list<opportunity>();
        
        //This code is to clone the opportunities with Renewal date equals to Today 
        opportunity oldopp = new opportunity();
        oldopp = [select id,name,Budget_Confirmed__c,Accountid,Account.name,Amount,External_ID__c,Business__c,BusinessAlias__c,CloseDate,CloseReason__c,CustomerMeetingReport__c, Discovery_Completed__c ,EstimatedCloseDate__c, EstimatedShipDate__c,LeadSource__c,RelatedToRFP__c,RenewalDate__c,SourceOpportunity__c,OriginalName__c,OwnerId,Description,ExpectedRevenue,ForecastCategoryName,LeadSource,NextStep,RecordTypeid,Pricebook2id,Campaignid,IsPrivate,Probability,TotalOpportunityQuantity,StageName,SyncedQuoteid,Type from opportunity where id =:opportunityId LIMIT 1];
        opportunity newOpp = oldopp.clone(false, true, false,false); //do a deep clone         
        newOpp.IsApexCloned__c = true;
        newOpp.SourceOpportunity__c = oldopp.id;
        newOpp.Name = oldopp.BusinessAlias__c+EMPTYSPACESTRING+Label.NewOppName+EMPTYSPACESTRING+oldopp.Account.name+EMPTYSPACESTRING+Label.NewOppName+EMPTYSPACESTRING+ 
        STRING.VALUEOF(system.today().addMonths(1))+EMPTYSPACESTRING+Label.NewOppName+EMPTYSPACESTRING+oldopp.OriginalName__c;
        if(newOpp.name.length()>=150 ){
        newOpp.name = newOpp.name.substring(0,79);
        }  
        newOpp.Probability = null;
        newOpp.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'New Opportunity' LIMIT 1].Id;
        newOpp.CloseReason__c = null;
        newOpp.StageName = STAGESTRING;
        newOpp.StageName = Label.OpportunityStage;
        newOpp.external_id__c = EMPTYSTRING;          
        oldopp.External_ID__c = Label.Is_Cloned;
        lstofoppinsert.add(newOpp);
        lstOfOpportunityUpdate.add(oldopp);  
        Database.insert(newOpp,false); 
        Database.update(oldopp,false) ;
        
        list<OpportunityLineItem> lstOfOpporLineinsert = new list<OpportunityLineItem>();
        list<ProjectOpportunity__c> lstOfOpportunityProductInsert = new list<ProjectOpportunity__c>();
        
        //Logic for checking measure date
        integer month = system.today().month();
        integer year = system.today().year();
        string fiscalDatestring;
        if(month>=6){
        fiscalDatestring = FISCALSTRING +year;
        }
        else{
        year = year-1;
        fiscalDatestring = FISCALSTRING +year;
        }
        date currentfiscalyear = date.parse(fiscalDatestring);
        date fiscaldate = currentfiscalyear.addyears(-3);     
        string query = SELECTQUERY1STRING  + fieldFromUtils+ FROMQUERYSTRING ;
        
        string queryForProjectOpp = SELECTIDSTRING + fieldFromUtilsforProjectOpportunity+ FROMSTRING;
        
        
        list<OpportunityLineItem> lstOfOpporLine =database.query(query);
        list<ProjectOpportunity__c> lstOfOpportunityProduct = [select project__c,opportunity__c from ProjectOpportunity__c where Opportunity__c =:opportunityid and Project__r.MeasureDate__c!=null and Project__r.MeasureDate__c>=:fiscalDate Limit 1000];
        
        //This code is to Clone the opportunity product and map it to the corresponding new opportunity
        if(lstOfOpporLine!= Null && !lstOfOpporLine.isempty()){  
        for(OpportunityLineItem objOppLine:lstOfOpporLine){
            OpportunityLineItem newobjopportunityline = new OpportunityLineItem();
            newobjopportunityline = objOppLine.clone(false, true);
            newobjopportunityline.opportunityid = newOpp.id;
            lstOfOpporLineinsert.add(newobjopportunityline); 
        }
        }
        if(lstOfOpportunityProduct!= Null && !lstOfOpportunityProduct.isempty()){
            for(ProjectOpportunity__c objProjOpp:lstOfOpportunityProduct){
                ProjectOpportunity__c newobjProjOpp = new ProjectOpportunity__c ();
                newobjProjOpp = objProjOpp.clone(false, true);
                newobjProjOpp.opportunity__c = newOpp.id;
                lstOfOpportunityProductInsert.add(newobjProjOpp); 
            }
        }
        //Database.insert(lstOfOpporLineinsert,false);
        insert lstOfOpporLineinsert;
        Database.insert(lstOfOpportunityProductInsert,false);
        PageReference orderPage = new PageReference(SLASHSTRING + newopp.id);
        orderPage.setRedirect(true);
        return orderPage; 
        
        
    }
}