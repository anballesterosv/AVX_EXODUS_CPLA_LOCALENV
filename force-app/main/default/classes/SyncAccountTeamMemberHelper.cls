/*****************************************************************************************************************************
    Author:sanhita.hegde
    Description: Helps MasterOpp trigger
    name :
    ****************************************************************************************************************************/
    public without sharing class SyncAccountTeamMemberHelper{
        Private List<AccountView__c > newTeamList = new List<AccountView__c >();
        Private List<AccountView__c > oldTeamList = new List<AccountView__c >();
        Private List<AccountView__c > delList = new List<AccountView__c >();
        public SyncAccountTeamMemberHelper( List<AccountView__c > newTriggerList,List<AccountView__c > oldTriggerList,List<AccountView__c > deleteList){
            newTeamList = newTriggerList ;
            oldTeamList = oldTriggerList;
            delList = deleteList;
        }
        public void syncAccTeaminsert(){
           
           Map<Id,Id> userAccountId = new Map<Id,Id>();
           Map<Id,AccountView__c> mapObj =new  Map <Id,AccountView__c>();
           
           For(AccountView__c accVi:newTeamList){
               userAccountId.put(accVi.User__c,accVi.Account__c);
               mapObj.put(accVi.User__c,accVi);
               System.debug('*****User'+mapObj);
           }
           
           List<AccountTeamMember>  accTeamInsert = new List<AccountTeamMember>();
           List<AccountTeamMember> existMem = new List<AccountTeamMember>([select Id,UserId,AccountId from AccountTeamMember where UserId IN:userAccountId.keySet() AND AccountId IN:userAccountId.values()]);
           if( existMem != null && !existMem.isEmpty() ){
               for(AccountTeamMember accTe:existMem){
                   accTe.AccountAccessLevel = mapObj.get(accTe.UserId).Account_Access_Custom__c;
                    accTe.CaseAccessLevel= mapObj.get(accTe.UserId).Case_Access_Custom__c;
                    accTe.OpportunityAccessLevel =mapObj.get(accTe.UserId).Opportunity_Access_Custom__c;
                    accTe.TeamMemberRole = mapObj.get(accTe.UserId).Account_Team_Role__c;
                    
                   
               }
               
               Database.update(existMem);
               
           }
           else{
               AccountTeammember accNew = new AccountTeammember ();
               for(AccountView__c accTem:newTeamList){
                    accNew.AccountAccessLevel =accTem.Account_Access_Custom__c;
                    accNew.CaseAccessLevel= accTem.Case_Access_Custom__c;
                    accNew.OpportunityAccessLevel =accTem.Opportunity_Access_Custom__c;
                    accNew.UserId = accTem.User__c;
                    accNew.AccountId = accTem.Account__c;
                    accNew.TeamMemberRole = accTem.Account_Team_Role__c;
               }
                    accTeamInsert.add(accNew);
                    Database.insert(accTeamInsert);
           }
            
            
            
            //update the existing account view records.
            List<AccountView__c> existAccTeamView = new List<AccountView__c>();
            System.debug('existing account team view'+existAccTeamView );
            for(AccountView__c accV:[select id,User__c,Account__c,Account_Access_Custom__c,Case_Access_Custom__c,
            						Opportunity_Access_Custom__c,Account_Team_Role__c,Account_Access__c,Case_Access__c, 
            						Opportunity_Access__c from AccountView__c where User__c IN:mapObj.keySet()]){
                accV.Account_Access__c = mapObj.get(accV.User__c).Account_Access__c;
                accV.Case_Access__c =  mapObj.get(accV.User__c).Case_Access__c;
                accV.Opportunity_Access__c = mapObj.get(accV.User__c).Opportunity_Access__c;
                //accV.Account_Team_Role__c = mapObj.get(accV.User__c).Account_Team_Role__c;
                
                existAccTeamView.add(accV);
            }
            if(!existAccTeamView.isEmpty())
            {
            	database.Update(existAccTeamView);
            }
            
            
        }
        public void syncAccTeamupdate(){
            
            Map<Id,Id> userAccount = new Map<Id,Id>();
            Map<Id, AccountView__c> mapObj = new  Map<Id, AccountView__c>();
            List<Id> recId = new List<Id>();
            for(AccountView__c accTe:oldTeamList){
                userAccount.put(accTe.User__c,accTe.Account__c);
                mapObj.put(accTe.User__c,accTe);
                recId.add(accTe.Id);
                
            }
            List<AccountTeamMember> listTeam = new List<AccountTeamMember>([SELECT AccountAccessLevel,AccountId,CaseAccessLevel,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,OpportunityAccessLevel,PhotoUrl,SystemModstamp,TeamMemberRole,Title,UserId FROM AccountTeamMember
                                                where AccountId In:userAccount.values() AND UserId IN:userAccount.keySet()]);
            System.debug('exist satd team'+listTeam);
            //if the account team member already exists in the standard team
            if( listTeam != null && !listTeam.isEmpty() ){
                System.debug('accountteammember exist stad');
            for(AccountTeamMember accUp:listTeam){
                accUp.AccountAccessLevel = mapObj.get(accUp.UserId).Account_Access_Custom__c;
                accUp.CaseAccessLevel= mapObj.get(accUp.UserId).Case_Access_Custom__c;
                accUp.OpportunityAccessLevel = mapObj.get(accUp.UserId).Opportunity_Access_Custom__c;
                accUp.TeamMemberRole = mapObj.get(accUp.UserId).Account_Team_Role__c;
               
            }
            Database.Update(listTeam);
            }
            
            //if the member does not exist in the standard account team member team
            else{
                AccountTeamMember accNewCr = new AccountTeamMember();
                List<AccountTeamMember> accTeamNewInsert = new List<AccountTeamMember>();
                for(AccountView__c accTeNew:oldTeamList){
                accNewCr.UserId = accTeNew.User__c;
                accNewCr.AccountId = accTeNew.Account__c;
                accNewCr.AccountAccessLevel = accTeNew.Account_Access_Custom__c;
                accNewCr.CaseAccessLevel= accTeNew.Case_Access_Custom__c;
                accNewCr.OpportunityAccessLevel = accTeNew.Opportunity_Access_Custom__c;
                accNewCr.TeamMemberRole = accTeNew.Account_Team_Role__c;
                accTeamNewInsert.add(accNewCr);
                
                }
                Database.insert(accTeamNewInsert);
            }
            
            //update the already existing account team view records 
            List<AccountView__c> existCusto = new List<AccountView__c>();
            System.debug('Id of this one'+existCusto);
            for(AccountView__C acV:[select Id,User__c,Account__c,Account_Access__c,Case_Access__c,Opportunity_Access__c from AccountView__c 
            						where User__C IN:userAccount.keySet() AND Account__c IN:userAccount.values() AND Id NOT IN:recId]){
                acV.Account_Access__c = mapObj.get(acV.User__c).Account_Access__c;
                acV.Case_Access__c = mapObj.get(acV.User__c).Case_Access__c;
                acV.Opportunity_Access__c = mapObj.get(acV.User__c).Opportunity_Access__c;
                //acV.Account_Team_Role__c = mapObj.get(acV.User__c).Account_Team_Role__c;
                existCusto.add(acV);
            }
            if(!existCusto.isEmpty())
            {
            	Database.update(existCusto);
            }
            
            
        }

                
        public void deleteAccRec(){
            
            Map<Id,Id> userAccountP = new Map<Id,Id>();
            List<Id>  recId = new List<Id>();
            for(AccountView__c delAcc :delList){
                userAccountP.put(delAcc.User__c,delAcc.Account__c);
                recId.add(delAcc.Id);
            }
            
            List<AccountTeamMember> delAccountTeamMem = new List<AccountTeamMember>([select Id,AccountId,UserId from AccountTeamMember where UserId IN:userAccountP.keySet() AND AccountId IN: userAccountP.values()]);
            system.debug('deleletion lits'+delAccountTeamMem);
            //check if other records exists with the same pair in account team view
            List<AccountView__c> existAccTeam = [select Id,User__c,Account__c from AccountView__c where User__c IN:userAccountP.keySet()  AND Account__c IN:userAccountP.values() AND Id NOT IN:recId];
            List<AccountView__c> lasteditedRec = [select Id,User__c,Account__c,Account_Team_Role__c from AccountView__C where User__c IN:userAccountP.keySet()  AND Account__c IN:userAccountP.values() AND Id NOT IN:recId order by LastModifiedDate desc limit 1];
            
             if( existAccTeam != null && !existAccTeam.isEmpty() ){
                 for(AccountTeamMember del:delAccountTeamMem)
                 {
                     del.TeamMemberRole = lasteditedRec[0].Account_Team_Role__c;
                 }
                 Database.update(delAccountTeamMem);
                 
             }
             else{
            Database.delete(delAccountTeamMem);
             }
            
            
        }
        
    }