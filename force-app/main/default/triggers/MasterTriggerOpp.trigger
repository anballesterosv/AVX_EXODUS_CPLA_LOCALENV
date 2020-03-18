/*************************************************************************************************************************************************************
 *@ Version:        1.1
@ Author:     Sanhit.Hegde/Romain Derval
@ Req No:     task 39     
@ Refer Classes:  
@ Purpose:        
**************************************************************************************************************************************/
trigger MasterTriggerOpp on Opportunity (before Insert,before update, after insert,after update, before delete) {
    SmartCPQOpportunityTriggerHandler cpqHandler = new SmartCPQOpportunityTriggerHandler();
    
/*************Before Insert**********************************/
    If(Trigger.isBefore && Trigger.isInsert){
        beforeInsertorUpdate();
        
        //cpqHandler.handleBeforeInsert(Trigger.new);
        //Nullify Quote related fields for Cloned Quotes
        for(Opportunity opp:Trigger.New){
            opp.Primary_Quote__c = null;
            opp.Primary_Quote_Status__c = null;
            opp.Quote_Pricing_start_Date__c = null;
            opp.Quote_Pricing_End_Date__c =null;   
        }
        
        //Validate Key Contact
        set<id> setConId = new set<id>();
        map<id,id> mapConAcc = new map<id,id>();
        map<id,set<id>> mapConRelAcc = new map<id,set<id>>();
        for(Opportunity Opp:Trigger.New){
            if(opp.Key_Customer_Contact_Identified__c!=null ){
               setConId.add(opp.Key_Customer_Contact_Identified__c); 
            }
            for(contact con:[select id,accountid from contact where id in:setConId]){
                mapConAcc.put(con.id,con.accountid);
            }
            for(AccountContactRelation rel:[select contactid,accountid from AccountContactRelation where contactid in:setConId]){
                if(!mapConRelAcc.isempty() && mapConRelAcc.containsKey(rel.contactid)){
                    mapConRelAcc.get(rel.contactid).add(rel.accountid);
                }    
                else{
                    mapConRelAcc.put(rel.contactid, new set<id>{rel.accountid});
                }
            }
        }  
        if(!setConId.isEmpty()){
            for(Opportunity Opp:Trigger.New){
                if(opp.Key_Customer_Contact_Identified__c!=null && mapConAcc.get(opp.Key_Customer_Contact_Identified__c)!=opp.accountid  && (mapConRelAcc.isEmpty() || (!mapConRelAcc.get(opp.Key_Customer_Contact_Identified__c).contains(opp.accountid)))){
                    opp.addError('Please add a related Contact as Customer Key Contact!');    
                }        
            }  
        }   
    }
    else if (Trigger.isAfter && Trigger.isInsert){
        cpqHandler.handleAfterInsert(Trigger.new);
        //Check User Access on Account for new Opportunities
        string uRole;
        if(UserInfo.getUserRoleId()!=null){
            list<userRole> roles = [select name from userRole where id=:UserInfo.getUserRoleId()];
            uRole = roles[0].Name;
        }
        
        //if(uRole==null || (label.Trade_Sales_Roles!=null && label.Trade_Sales_Roles.indexOf(uRole)==-1)) //
         if(uRole==null || (label.Trade_Sales_Roles!=null && label.Trade_Sales_Roles.indexOf(uRole)==-1)&&(label.Trade_Sales_Roles2!=null && label.Trade_Sales_Roles2.indexOf(uRole)==-1)){
            list<id> lstAccId = new list<id>();
            for(Opportunity opp:Trigger.new){
                lstAccId.add(opp.Accountid);    
            }
            try{
                CPG_validateAccountAccess.checkUserAccess(lstAccId);
            }catch(exception e){
                if(e.getMessage().indexOf('INSUFFICIENT_ACCESS_OR_READONLY')!=-1){
                    Trigger.new[0].addError('You do not have sufficient access rights to create Opportunity!');        
                }
            }
        }
        //Call Cloned Opp Count Roll up function for eligible Opportunities
        set<id> OppIds = new set<id>();
        for(Opportunity  opp:Trigger.New){
            if(opp.SourceOpportunity__C!=null){
                oppIds.add(opp.SourceOpportunity__C);
            }           
        }
        if(!oppIds.isEmpty()){
            CPG_OpportunityUtil.rollUpClonedOppCount(OppIds);
        }
    }else if (Trigger.isAfter && Trigger.isUpdate){
        cpqHandler.handleAfterUpdate(Trigger.new,Trigger.old);
        
    }
    //Cognizant-:Pricing Date Validation on Opportunity
     else if(Trigger.isBefore && Trigger.isupdate){
        
        OpportunityTriggerHelper callMethod = new OpportunityTriggerHelper(Trigger.New,trigger.newmap);
        callMethod.IsPrimaryQuoteExists();
        //Cognizant-:opp Line Item WON volume update
        callMethod.UpdateWonItemVolume(); 
        //default SIMPLE Opportunity Stage to CREATE
        
        for(Opportunity opp:Trigger.New){
            //Vaishali 
            if(opp.StageName!= 'Present' && opp.StageName!='Closed Won' && opp.StageName!='Closed Lost' ){
                if(opp.opportunity_type__c=='SIMPLE' && Trigger.oldmap.get(opp.id).opportunity_type__c!='SIMPLE'){
                    opp.StageName='CREATE';
                }
            }
        }
        //Validate Key Contact
        set<id> setConId = new set<id>();
        map<id,id> mapConAcc = new map<id,id>();
        map<id,set<id>> mapConRelAcc = new map<id,set<id>>();
        for(Opportunity Opp:Trigger.New){
             if(opp.Key_Customer_Contact_Identified__c!=null && opp.Key_Customer_Contact_Identified__c!= trigger.oldMap.get(opp.id).Key_Customer_Contact_Identified__c){
                 setConId.add(opp.Key_Customer_Contact_Identified__c); 
             }
        }
        List<AccountContactRelation> lstAccCons = [select contactid,accountid from AccountContactRelation where contactid in:setConId];
        for(Opportunity Opp:Trigger.New){
            for(contact con:[select id,accountid from contact where id in:setConId]){
                mapConAcc.put(con.id,con.accountid);
            }
            for(AccountContactRelation rel:lstAccCons){
                if(!mapConRelAcc.isempty() && mapConRelAcc.containsKey(rel.contactid)){
                    mapConRelAcc.get(rel.contactid).add(rel.accountid);
                }    
                else{
                    mapConRelAcc.put(rel.contactid, new set<id>{rel.accountid});
                }
            }
        }  
        if(!setConId.isEmpty()){
            for(Opportunity Opp:Trigger.New){
                if(setConId.contains(opp.Key_Customer_Contact_Identified__c) && mapConAcc.get(opp.Key_Customer_Contact_Identified__c)!=opp.accountid  && (mapConRelAcc.isEmpty() || (!mapConRelAcc.get(opp.Key_Customer_Contact_Identified__c).contains(opp.accountid)))){
                    opp.addError('Please add a related Contact as Customer Key Contact!');    
                }        
            }  
        }    
        
    }
  /*  If(Trigger.isBefore && Trigger.isupdate){
        stageValidation();
    }*/
   
     
/**************methods for calling helper class***************/
    Public Void beforeInsertorUpdate(){
        OpportunityTriggerHelper callMethod = new OpportunityTriggerHelper(Trigger.New,trigger.newmap);
        callMethod.populateBisiness();
        callMethod.populateoriginalName();
//Cognizant-:Pricing Date Validation on Opportunity
        callMethod.IsPrimaryQuoteExists();
//Cognizant-:opp Line Item WON volume update
        callMethod.UpdateWonItemVolume();
    }
   /* public void stageValidation(){
    OpportunityTriggerHelper callMethod = new OpportunityTriggerHelper(trigger.new,trigger.newmap);
     callMethod.preventClosedWonOpportunityAll();
      
    }*/
    
    //The below code is added by Sri Harshitha Bandi as per the user story with VSTS ID #42722.
    If(Trigger.isBefore && Trigger.isDelete){
        OpportunityTriggerHelper oppTriggHelper = new OpportunityTriggerHelper(Trigger.Old, Trigger.OldMap);
        oppTriggHelper.blockOppDeletionWithCMRs(Trigger.Old, Trigger.OldMap);
    }
}