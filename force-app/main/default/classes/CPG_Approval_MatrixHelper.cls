/**
Class Name: CPG_Approval_MatrixHelper
Created Date: Oct-06-2017
Created By: Cognizant
This class is  helper class for setting up approvers for different Protein Quote approval flows.
**/
public class CPG_Approval_MatrixHelper{

public static void setQuoteApprovers(list<CameleonCPQ__Quote__c> lstQuotes){
    //Map to store Approval Matrix
    map<string, approval_matrix__c> mapApproval = new map<string, approval_matrix__c>();
    for(approval_matrix__c am: [select BM_Approver_1__c, BM_Approver_2__c, BM_Approver_3__c, BM_Approver_4__c, BM_Approver_5__c,BM_Approver_6__c, SP_Approver_1__c, SP_Approver_2__c, SP_Approver_3__c, SP_Approver_4__c, SP_Approver_5__c,SP_Approver_6__c, ST_Approver_1__c, ST_Approver_2__c, ST_Approver_3__c, ST_Approver_4__c, ST_Approver_5__c, criterion__c from approval_matrix__c LIMIT 10000]){
        mapApproval.put(am.criterion__c, am);        
    }
    if(!lstQuotes.isEmpty()){
        for(CameleonCPQ__Quote__c quote: lstQuotes){
            string channel='';
            if(quote.opportunity_channel__c!=null){
                channel = quote.opportunity_channel__c;
            }
            string mId = 'Quote-'+channel+'-'+quote.Approval_Zone__c+'-'+quote.DealSize__c+ '-'+quote.opportunity_type__c;
            string mIdPriceType = 'Quote-'+channel+'-'+quote.Approval_Zone__c+'-'+quote.DealSize__c+ '-'+quote.opportunity_type__c + '-' + quote.Pricing_Type__c;
            system.debug('mId :'+mId +'***mIdPriceType :'+mIdPriceType );
            if(!mapApproval.isEmpty() && mapApproval.get(mId)!=null){
                quote.BM_Approver_1__c = mapApproval.get(mId).BM_Approver_1__c;  
                quote.BM_Approver_2__c = (mapApproval.get(mId).BM_Approver_2__c!=null)?mapApproval.get(mId).BM_Approver_2__c:mapApproval.get(mId).BM_Approver_1__c;  
                quote.BM_Approver_3__c = (mapApproval.get(mId).BM_Approver_3__c!=null)?mapApproval.get(mId).BM_Approver_3__c:mapApproval.get(mId).BM_Approver_1__c;   
                quote.BM_Approver_4__c = (mapApproval.get(mId).BM_Approver_4__c!=null)?mapApproval.get(mId).BM_Approver_4__c:mapApproval.get(mId).BM_Approver_1__c;  
                quote.BM_Approver_5__c = (mapApproval.get(mId).BM_Approver_5__c!=null)?mapApproval.get(mId).BM_Approver_5__c:mapApproval.get(mId).BM_Approver_1__c; 
                quote.BM_Approver_6__c = (mapApproval.get(mId).BM_Approver_6__c!=null)?mapApproval.get(mId).BM_Approver_6__c:mapApproval.get(mId).BM_Approver_1__c;                 
                quote.SP_Approver_1__c = mapApproval.get(mId).SP_Approver_1__c; 
                quote.SP_Approver_2__c = (mapApproval.get(mId).SP_Approver_2__c!=null)?mapApproval.get(mId).SP_Approver_2__c:mapApproval.get(mId).SP_Approver_1__c;    
                quote.SP_Approver_3__c = (mapApproval.get(mId).SP_Approver_3__c!=null)?mapApproval.get(mId).SP_Approver_3__c:mapApproval.get(mId).SP_Approver_1__c;   
                quote.SP_Approver_4__c = (mapApproval.get(mId).SP_Approver_4__c!=null)?mapApproval.get(mId).SP_Approver_4__c:mapApproval.get(mId).SP_Approver_1__c;   
                quote.SP_Approver_5__c = (mapApproval.get(mId).SP_Approver_5__c!=null)?mapApproval.get(mId).SP_Approver_5__c:mapApproval.get(mId).SP_Approver_1__c;   
                quote.SP_Approver_6__c = (mapApproval.get(mId).SP_Approver_6__c!=null)?mapApproval.get(mId).SP_Approver_6__c:mapApproval.get(mId).SP_Approver_1__c;   
                quote.ST_Approver_1__c = mapApproval.get(mId).ST_Approver_1__c;   
                quote.ST_Approver_2__c = (mapApproval.get(mId).ST_Approver_2__c!=null)?mapApproval.get(mId).ST_Approver_2__c:mapApproval.get(mId).ST_Approver_1__c;   
                quote.ST_Approver_3__c = (mapApproval.get(mId).ST_Approver_3__c!=null)?mapApproval.get(mId).ST_Approver_3__c:mapApproval.get(mId).ST_Approver_1__c;  
                quote.ST_Approver_4__c = (mapApproval.get(mId).ST_Approver_4__c!=null)?mapApproval.get(mId).ST_Approver_4__c:mapApproval.get(mId).ST_Approver_1__c; 
                quote.ST_Approver_5__c = (mapApproval.get(mId).ST_Approver_5__c!=null)?mapApproval.get(mId).ST_Approver_5__c:mapApproval.get(mId).ST_Approver_1__c;            
            }  
            //Match Pricing Type for specified Opp type approver set up
            if(!mapApproval.isEmpty() && mapApproval.get(mIdPriceType)!=null){
                quote.BM_Approver_1__c = mapApproval.get(mIdPriceType).BM_Approver_1__c;  
                quote.BM_Approver_2__c = (mapApproval.get(mIdPriceType).BM_Approver_2__c!=null)?mapApproval.get(mIdPriceType).BM_Approver_2__c:mapApproval.get(mIdPriceType).BM_Approver_1__c;  
                quote.BM_Approver_3__c = (mapApproval.get(mIdPriceType).BM_Approver_3__c!=null)?mapApproval.get(mIdPriceType).BM_Approver_3__c:mapApproval.get(mIdPriceType).BM_Approver_1__c;   
                quote.BM_Approver_4__c = (mapApproval.get(mIdPriceType).BM_Approver_4__c!=null)?mapApproval.get(mIdPriceType).BM_Approver_4__c:mapApproval.get(mIdPriceType).BM_Approver_1__c;  
                quote.BM_Approver_5__c = (mapApproval.get(mIdPriceType).BM_Approver_5__c!=null)?mapApproval.get(mIdPriceType).BM_Approver_5__c:mapApproval.get(mIdPriceType).BM_Approver_1__c;    
                quote.BM_Approver_6__c = (mapApproval.get(mIdPriceType).BM_Approver_6__c!=null)?mapApproval.get(mIdPriceType).BM_Approver_6__c:mapApproval.get(mIdPriceType).BM_Approver_1__c;  
                quote.SP_Approver_1__c = mapApproval.get(mIdPriceType).SP_Approver_1__c; 
                quote.SP_Approver_2__c = (mapApproval.get(mIdPriceType).SP_Approver_2__c!=null)?mapApproval.get(mIdPriceType).SP_Approver_2__c:mapApproval.get(mIdPriceType).SP_Approver_1__c;    
                quote.SP_Approver_3__c = (mapApproval.get(mIdPriceType).SP_Approver_3__c!=null)?mapApproval.get(mIdPriceType).SP_Approver_3__c:mapApproval.get(mIdPriceType).SP_Approver_1__c;   
                quote.SP_Approver_4__c = (mapApproval.get(mIdPriceType).SP_Approver_4__c!=null)?mapApproval.get(mIdPriceType).SP_Approver_4__c:mapApproval.get(mIdPriceType).SP_Approver_1__c;   
                quote.SP_Approver_5__c = (mapApproval.get(mIdPriceType).SP_Approver_5__c!=null)?mapApproval.get(mIdPriceType).SP_Approver_5__c:mapApproval.get(mIdPriceType).SP_Approver_1__c;   
                quote.SP_Approver_6__c = (mapApproval.get(mIdPriceType).SP_Approver_6__c!=null)?mapApproval.get(mIdPriceType).SP_Approver_6__c:mapApproval.get(mIdPriceType).SP_Approver_1__c;   
                quote.ST_Approver_1__c = mapApproval.get(mIdPriceType).ST_Approver_1__c;   
                quote.ST_Approver_2__c = (mapApproval.get(mIdPriceType).ST_Approver_2__c!=null)?mapApproval.get(mIdPriceType).ST_Approver_2__c:mapApproval.get(mIdPriceType).ST_Approver_1__c;   
                quote.ST_Approver_3__c = (mapApproval.get(mIdPriceType).ST_Approver_3__c!=null)?mapApproval.get(mIdPriceType).ST_Approver_3__c:mapApproval.get(mIdPriceType).ST_Approver_1__c;  
                quote.ST_Approver_4__c = (mapApproval.get(mIdPriceType).ST_Approver_4__c!=null)?mapApproval.get(mIdPriceType).ST_Approver_4__c:mapApproval.get(mIdPriceType).ST_Approver_1__c; 
                quote.ST_Approver_5__c = (mapApproval.get(mIdPriceType).ST_Approver_5__c!=null)?mapApproval.get(mIdPriceType).ST_Approver_5__c:mapApproval.get(mIdPriceType).ST_Approver_1__c;         
            }  
        }
    }
}

}