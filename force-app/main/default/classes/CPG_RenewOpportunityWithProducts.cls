/**
@Author Vaishali
@name CPG_RenewOpportunityWithProducts 
@CreateDate Sept 4, 2017
@Description Helper class for Opportunity renewal -process builder
@Version <1.0>
@reference Process Builder - Opportunity Renewal
@Modifiedby : Sri harshitha Bandi, 
@ModifiedDate: Oct 11, 2019
*/
Public with sharing class CPG_RenewOpportunityWithProducts {

      @InvocableMethod(label='Renew Opportunity' description='Create New Opportunity with opportunity Line Items')
      public static List<ID> getRenewedOpp(List<ID> oldIds) {  
          List<ID> lstNew=new List<ID>(); 
          ID oldId =oldIds[0];
          system.debug('*****oldId ' + oldId);
          // Initialize setup variables
            String objectName = 'Opportunity';  // modify as needed
            String query = 'SELECT';
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            
            // Grab the fields from the describe method and append them to the queryString one by one.
            for(String s : objectFields.keySet()) {
               query += ' ' + s + ', ';
            }
            
            // Manually add related object's fields that are needed.
            query += 'Account.Name '; // modify as needed    'Account.Name';
            system.debug('*****query ' + query);
            // Strip off the last comma if it exists.
            if (query.subString(query.Length()-1,query.Length()) == ','){
                query = query.subString(0,query.Length()-1);
            }
            
            // Add FROM statement
            query += ' FROM ' + objectName;
            
            // Add on a WHERE/ORDER/LIMIT statement as needed
            query += ' WHERE Id =  \''+ oldId +'\'  LIMIT 1'; // modify as needed   WHERE Id = \'test\' AND HasOpportunityLineItem = true LIMIT 1'; 
            system.debug(query);
            Opportunity opp = database.query(query);
            system.debug(opp);
            Opportunity newOpp = opp.clone(false, false, false, false);
           // newOpp.Name=opp.Account.Name + ' | ' +opp.OriginalName__c + ' | ' + string.valueof(system.Today()+30) ;
            String oppName=opp.OriginalName__c;
            If(oppName.indexOfAny('|')<0){
                newOpp.Name=opp.OriginalName__c;
            }
            else{
                
                List<String> lstVal = oppName.split('|');
                newOpp.Name=lstVal[1];
                system.debug('@@oppName Origin-->'+lstVal);
                system.debug('@@oppName Origin-->'+ newOpp.Name);
                
            }
            newOpp.stagename='Explore';
            newOpp.SourceOpportunity__c = opp.id;  ///added by Latha
            newOpp.Type='Existing Business';
            newOpp.Volume__c=0;
            newOpp.Amount=0;
            newOpp.RenewalDate__c= null;
            newOpp.Result__c = null;
            newOpp.CloseDate =system.Today()+30;
            newOpp.Count_of_CMROs__c =0; /// added by Latha 
            newOpp.HasOpportunityProductRequest__c = false; ///added by latha
            newOpp.HasOpportunityProductGroup__c = false;
            newOpp.Number_of_Cloned_Opp__c = 0;// added by Mani @24/10/2019 for Sprint M 
            newOpp.OwnerId =[select Id,OwnerId from Account where Id=:opp.AccountId LIMIT 1][0].OwnerId ;
            newOpp.Renewed_Opportunity__c = TRUE; // Added by Sri Harshitha on 30/10/2019 to update the Renew Opportunity flag for Renewed Opps as per US #46510 in Sprint-N (Protein Sales).
            system.debug('*****newOpp info' + newOpp); 
            try{
                if(Schema.sObjectType.Opportunity.isCreateable()){            
                    insert newOpp;
                    system.debug('*****newOpp insert' + newOpp); 
                }
            }catch(exception e){
                system.debug('*****exception insert' + e); 
            }
            system.debug('*****newOpp' + newOpp); 
            if (opp.HasOpportunityLineItem == true && Schema.sObjectType.OpportunityLineItem.isAccessible()) {
                List<OpportunityLineItem> products = [SELECT Id, 
                                                      Name, 
                                                      Quantity, 
                                                      TotalPrice, PricebookEntryId FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];  
                system.debug('product List = ' +products);
                system.debug('newOpp Id = ' + newOpp.Id);
                List<OpportunityLineItem> newProdList = executeForEveryOLI(products, newOpp);
                if(Schema.sObjectType.OpportunityLineItem.isCreateable()){
                    system.debug('****newProdList before insert' + newProdList);
                    insert(newProdList);
                    system.debug('***newProdList ' + newProdList);
                }
            } // end if 
            lstNew.add(newOpp.id);
            //return newOpp.id;
            return lstNew; 
          
      }

    private static List<OpportunityLineItem> executeForEveryOLI(List<OpportunityLineItem> products, Opportunity newOpp){
        List<OpportunityLineItem> newProdList = new List<OpportunityLineItem>();
        for (OpportunityLineItem prod:products) {
            OpportunityLineItem newProd = prod.clone(false, false, false, false);
            newProd.OpportunityId = newOpp.id;
            system.debug('***newProdList 11' + newProd.OpportunityId);
            newProd.TotalPrice =0.00;
            newProdList.add(newProd);
            system.debug('***newProdList222 ' + newProdList);
        }
        return newProdList;
    }
}