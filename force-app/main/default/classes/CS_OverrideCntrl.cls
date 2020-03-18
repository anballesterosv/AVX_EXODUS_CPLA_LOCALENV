/*
*Author: Vasanthi Narayan
*Project: Protein Service Cloud Implementation
*This Class have the methods called from the components : CS_Knowledge_banner, CS_ServiceComplaint_New_Override, CS_KnowledgePublish_Override
*/

public class CS_OverrideCntrl {
    /*
     *Author: Vasanthi Narayan
     *Description: Method to get the Case Reason from the Case Id passed
     *
     */
    @auraEnabled
    public static String getcaseReason(String caseId){
        String csReason;
        case cs ;
        if(caseId != null){
            
            cs =[Select id, Reason from case where id =: caseId];
        }
        csReason= cs.Reason;
       return csReason;
        
    }
    
     /*
     *Author: Vasanthi Narayan
     *Description: Method to get the knowledge Record and locked status from the Knowledge Id passed
     *
     */
    @auraEnabled
    public static Map<Boolean,Knowledge__kav> getknowledgeRec(String knowledgeId){
        Map<Boolean,Knowledge__kav> returnValue = new Map<Boolean,Knowledge__kav>();
        Knowledge__kav  knldge;
         Boolean isLockedRecord = false;
        if(knowledgeId != null){
            
            knldge = [select id,KnowledgeArticleId,  CS_Category__c, PublishStatus, CS_Market_Channel__c from Knowledge__kav where id =: knowledgeId];
             isLockedRecord = Approval.isLocked(knldge.id);
            returnValue.put(isLockedRecord,knldge);
        }
      
        return returnValue;
        
    }
    
     /*
     *Author: Vasanthi Narayan
     *Description: Method to get the knowledge Record from the Knowledge Id passed
     *
     */
    @auraEnabled
    public static Knowledge__kav getknowledgeRecs(String knowledgeId){
       
        Knowledge__kav  knldge;
        
        if(knowledgeId != null){
            
            knldge = [select id,KnowledgeArticleId,  CS_Category__c, PublishStatus, CS_Market_Channel__c from Knowledge__kav where id =: knowledgeId];
        
        }
       
        return knldge;
        
    }
    
    /*
     *Author: Vasanthi Narayan
     *Description: Method to publish the knowledge Record as New
     *
     */
    @auraEnabled
    public static boolean publishArticle(String knowledgeId){
        
        KbManagement.PublishingService.publishArticle(knowledgeId, true);
        return true;
    }
    
}