/**
@Author Vaishali
@name CPG_OpportunityProductTriggerHelper
@CreateDate Sept 1, 2017
@Description Helper class for Opportunity Product trigger
@Version <1.0>
@reference OpportunityProductTrigger
@Modifiedby : Vaishali, 
@ModifiedDate: Set 4, 2017
*/ 
/************************************************************************************/
public class CPG_OpportunityProductTriggerHelper {
/**
@Methodname beforeInsertOpportunityProduct
@CreateDate Sept 1, 2017
@Description This method will delete all associated product group records for opportunity when opportunity
            line item added to opportunity record
@Version <1.0>
*/ 
    public static void beforeInsertOpportunityProduct(List<OpportunityLineItem> lstOppLine){
        Set<ID> OppId=new Set<ID>();
        for(OpportunityLineItem oppL :lstOppLine){
            OppId.add(oppL.OpportunityId );
        }
        List<Product_Group__c> lstNewPG=[SELECT Opportunity__c FROM Product_Group__c where Opportunity__c In:OppId];
        /*for(Product_Group__c pg:[SELECT Opportunity__c FROM Product_Group__c where Opportunity__c In:OppId]){
            lstNewPG.add(pg);
        } */
       database.Delete(lstNewPG,false);
    } 


   
    
/**
@Methodname rollupTrigger
@CreateDate Sept 1, 2017
@Description This method will calculate sum of volume/quantity for all line items, cannot use roll up field as its conditional update
@Version <1.0>
Commented- As Volume Logic changed for Opportunity line item-only when result NOT LOST
*/     
   /*public static void rollupTrigger(list<OpportunityLineItem> records){
        Set<ID> OpportunityIds =new Set<ID>();
        for(OpportunityLineItem item:records){
            OpportunityIds.add(item.opportunityId);
        } */
        
        /*map<id,Double> OpportunityMap = new map<id,Double>();
        for(AggregateResult ar : [select opportunityId ,sum(Quantity) from OpportunityLineItem where OpportunityId IN :OpportunityIds group by OpportunityId]){
                OpportunityMap.put((Id)ar.get('OpportunityId'),(Double)ar.get('expr0'));
        }
        List<opportunity> OpportunitiesToUpdate = new List<opportunity>();
        for(Opportunity op : [Select Id, Volume__c ,HasOpportunityLineItem from Opportunity where Id IN :OpportunityIds ]){
                Double VouleSum = 0;
                if(OpportunityMap.containsKey(op.Id)){
                    VouleSum = OpportunityMap.get(op.Id);
                }
                op.Volume__c = VouleSum;
                OpportunitiesToUpdate.add(op);
        
        }*/
        
        /*List<opportunity> OpportunitiesToUpdate = new List<opportunity>();
         for(Opportunity op : [Select Id, Volume__c ,oppWonItemVolume__c, HasOpportunityLineItem from Opportunity where Id IN :OpportunityIds]){
             op.Volume__c=op.oppWonItemVolume__c;
         }
         if(OpportunitiesToUpdate.size()>0){
             database.update(OpportunitiesToUpdate,false);
         }
        
    }*/
    //Method to calculate Opportunity product Volume for Case based Products
    public static void updateVolumeforCases(list<OpportunityLineItem> oppProds){
        map<id,decimal> mapProductCaseWt = new map<id, decimal>();
        for(OpportunityLineItem oli:OppProds){
            if(oli.number_of_cases__c!=null && !oli.has_linked_quote__c){
                mapProductCaseWt.put(oli.product2Id, 0);
            }
        }
        for(product2 prod:[select id,NET_CASE_WT_LBS__c from product2 where id in:mapProductCaseWt.keySet()]){
            mapProductCaseWt.put(prod.id, prod.NET_CASE_WT_LBS__c);
        }
        for(OpportunityLineItem oli:oppProds){
            if(!mapProductCaseWt.isEmpty() || mapProductCaseWt.containsKey(oli.product2Id)){
                oli.quantity = oli.number_of_cases__c*mapProductCaseWt.get(oli.product2Id);
            }
        }
    }
   
}