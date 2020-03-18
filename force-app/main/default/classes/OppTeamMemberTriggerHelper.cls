/*****************************************************************************************************************************
Author:sanhita.hegde
Description: Helps MasterOpp trigger
name :OppTeamMemberTriggerHelper 
****************************************************************************************************************************/
public without sharing class OppTeamMemberTriggerHelper {
    Private List<OpportunityTeamMember> newOppList = new List<OpportunityTeamMember>();
    Private List<OpportunityTeamMember> oldTeamList = new List<OpportunityTeamMember>();
    private final static String TECH_RESOURSE = 'TechResource';
    private static List<Project__c> allPro = new List<Project__c>();
    private static Map<Id,Id> proMem = new Map<Id,Id>();
    private static List<ProjectTeamMembers__c> insertMem = new List<ProjectTeamMembers__c>();
    private static List<Project__Share> jobShares = new List<Project__Share>(); 
    /*****************************************************************************************************************************
Author:sanhita.hegde
Description: Helps MasterOpp trigger
name :OppTeamMemberTriggerHelper 
****************************************************************************************************************************/
    public OppTeamMemberTriggerHelper ( List<OpportunityTeamMember> newTriggerList,List<OpportunityTeamMember> oldTriggerList){
        newOppList = newTriggerList ;
        oldTeamList = oldTriggerList;
    }

 /*****************************************************************************************************************************
Author:sanhita.hegde
Description: It will add the members to the realted project team when opportunity member gets added.
name :addProjectTeam 
****************************************************************************************************************************/
public void addProjectTeam(){
    try{
     set<Id> oppId = New set<Id>();
            Map<Id,Set<Id>> allTeam = new Map<Id,Set<Id>>();
          
            //get the newly inserted records
            for(OpportunityTeamMember oTe:newOppList){
                
                if(!allTeam.containsKey(oTe.OpportunityId)){
                    allTeam.put(oTe.OpportunityId, new Set<Id>());
                }
                allTeam.get(oTe.OpportunityId).add(oTe.UserId);
            }
         
            //get the already existong memebers in project team
            allPro = [select Id,opportunity__c from Project__c where opportunity__c IN: allTeam.keySet() LIMIT 10000];
           
            for(ProjectTeamMembers__c p:[select Id,Member__c,Project__c from ProjectTeamMembers__c 
                                                        where Project__c In: allPro LIMIT 10000]){
                proMem.put(p.Project__c,p.Member__c);
            }
            
            //loop through all the projects associated with that opportunity
            for(Project__c pT:[select Id,opportunity__c from Project__c where opportunity__c IN: allTeam.keySet() LIMIT 10000]){
               if(allTeam.get(pT.Opportunity__c).contains(proMem.get(pT.Id))){
                   
                }
                else{
                    //loop through all the members that are added 
                   for(Id o:allTeam.get(pT.Opportunity__c)){
                        ProjectTeamMembers__c newMem = new ProjectTeamMembers__c();
                       
                        newMem.Member__c = o;
                        newMem.Project__c = pT.Id;
                        newMem.Role__c = TECH_RESOURSE;
                        insertMem.add(newMem);
                        
                        //give sharing access
                        
                        Project__Share recShare = new Project__Share();
                        recShare.ParentId = newMem.Project__c;
                        recShare.UserOrGroupId =newMem.Member__c ;
                        recShare.AccessLevel = Label.SyncProjectMem1;
                        recShare.RowCause = Schema.Project__Share.RowCause.Opportunity_Team_Member__c;
                        jobShares.add(recShare);
                        
                    }
                    
                }
                
            }
            //insert both project member and sharing record
            Database.insert(insertMem);
            Database.insert(jobShares);
    }
    catch(Exception e){
        Throw e;
    }
}
/*****************************************************************************************************************************
Author:sanhita.hegde
Description:It will remove the related project team members when the opportunity member gets removed.
name :deleteMemandSharing 
****************************************************************************************************************************/
    public void deleteMemandSharing(){
        try{
        List<String> oppId = new List<String>();
            List<String> userId = new List<String>();
            //get the member who is getting deleted
            for(OpportunityTeamMember oOld:oldTeamList){
                oppId.add(oOld.opportunityId);
                userId.add(oOld.UserId);
                
            }
            //get the sharing record for that user and delete that record.
            List<Project__c> projectsRelated= new List<Project__c>([select Id from Project__c where Opportunity__c IN: oppId LIMIT 10000]);
            List<ProjectTeamMembers__c> deleteProTeam = new List<ProjectTeamMembers__c>([select Id,member__c,Project__c from ProjectTeamMembers__c where 
                                                            project__c IN:projectsRelated AND Member__c In:userId LIMIT 10000]);
            List<Project__Share> delShare = new List<Project__Share>([select Id,ParentId,UserOrGroupId from Project__share where 
                                                ParentId In:projectsRelated AND UserOrGroupId IN:userId AND 
                                                (RowCause =: Label.SyncProjectMem2 OR RowCause =: Label.SyncProjectMem3) LIMIT 10000]);
            if(!deleteProTeam.isEmpty())
            {
            	Database.delete(deleteProTeam);
            }
            if(!delShare.isEmpty())
            {
            	Database.delete(delShare);
            }
    }
    
    catch(Exception e){
        throw e;
    }
    }
}