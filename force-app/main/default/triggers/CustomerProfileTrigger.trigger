trigger CustomerProfileTrigger on CustomerProfile__c (before Insert, after delete, before update) {
    
    if(trigger.isInsert && trigger.isBefore){
        for(CustomerProfile__c cp:Trigger.New){
            //Default Owner to be set as current user if not specified
            if(cp.owner__c==null){
                cp.owner__c=userInfo.getuserid();
            }
            //set Status upon Customer Profile creation
            if(cp.Express_Value__c!=null || cp.Strategic_Initiative__c!=null || cp.of_Strategic_Objectives__c>0){
                 cp.Status__c='In Progress';
            }
            else{
                 cp.Status__c='Not Started';
            }
        }
    }
    
    //Status update on Customer Profile changes
    if(trigger.isUpdate && trigger.isBefore){
        for(CustomerProfile__c cp:Trigger.New){
            if(cp.Express_Value__c!=null && cp.Strategic_Initiative__c!=null && cp.of_Strategic_Objectives__c>0){
                cp.Status__c='Complete';
            }
            else if(cp.Express_Value__c!=null || cp.Strategic_Initiative__c!=null || cp.of_Strategic_Objectives__c>0){
                 cp.Status__c='In Progress';
            }
            else{
                 cp.Status__c='Not Started';
            }
        }
    }
    
    
    if(trigger.isDelete && trigger.isAfter){
        set<id> setAccIds = new set<id>();
        set<id> setCPAccIds = new set<id>();
        set<id> setAccIdsParent = new set<id>();
        set<id> setCPAccIdsParent = new set<id>();
        
        list<Account> lstAccount = new list<account>();
        list<Account> lstAccountParent = new list<account>();
        
        for(CustomerProfile__c cp:Trigger.old){
            setAccIds.add(cp.account__c);
            if(cp.Global_Account_id__c!=null){
                setAccIdsParent.add(cp.Global_Account_id__c);
            }
        }    
        if(!setAccIds.isEmpty()){
            for(CustomerProfile__c cp:[select account__c,account__r.parentid from CustomerProfile__c  where account__c in:setAccIds]){
                setCPAccIds.add(cp.account__c);
                if(cp.account__r.parentid!=null){
                    setCPAccIdsParent.add(cp.account__r.parentid);
                }
            }
            for(id accId :setAccIds){
                if(setCPAccIds.isEmpty() || (!setCPAccIds.isEmpty() && !setCPAccIds.contains(accId))){
                    lstAccount.add(new Account(id=accid, Has_Customer_Profile__c=false));
                }
            }    
            if(!lstAccount.isEmpty()){
                update lstAccount;
            }
            //Update Parent Account
            for(id accId :setAccIdsParent){
                if(setCPAccIdsParent.isEmpty() || (!setCPAccIdsParent.isEmpty() && !setCPAccIdsParent.contains(accId))){
                    lstAccountParent.add(new Account(id=accid, Has_Customer_Profile_at_Commercial_Level__c=false));
                }
            }    
            if(!lstAccountParent.isEmpty()){
                update lstAccountParent;
            }
        }
        
    }
}