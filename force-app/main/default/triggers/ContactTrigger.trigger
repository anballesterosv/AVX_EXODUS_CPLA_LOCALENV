trigger ContactTrigger on Contact (After insert, After Update, After Delete ,Before Delete) {
set<id> setparentAccIds = new set<id>();
set<id> setparentAccIdsnoCon = new set<id>();
set<id> setCrisisAccIds = new set<id>();
set<id> setImpactedAccIds = new set<id>();
set<id> sethasCrisisContacts = new set<id>();
list<Account> lstAccounts = new list<Account>();
// Get all Account Ids for newly inserted Contacts
if(Trigger.isAfter && Trigger.isInsert){
    for(Contact con:Trigger.New){
        setparentAccIds.add(con.Accountid);
        if(con.Crisis_Management_Contact__c){
            setCrisisAccIds.add(con.Accountid);
        }
    }
}
for(id accId :setparentAccIds){
    if(!setCrisisAccIds.isEmpty() && setCrisisAccIds.contains(accId)){
        lstAccounts.add(new account(id=accId, has_contact__c=true, has_crisis_contact__c= true));    
    }
    else{
        lstAccounts.add(new Account(id=accId, has_contact__c=true));
    }
}

//Get all Account ids for updated Crisis Management Contacts
if(Trigger.isAfter && Trigger.isUpdate){
    for(contact con:Trigger.New){
        if(con.Crisis_Management_Contact__c!=Trigger.oldMap.get(con.id).Crisis_Management_Contact__c){
            setImpactedAccIds.add(con.Accountid);
        }
    }
}
// Get all Account Ids for deleted
if(Trigger.isAfter && Trigger.isDelete){
    for(Contact con:Trigger.old){
        setImpactedAccIds.add(con.Accountid);
    }        
}
if(!setImpactedAccIds.isEmpty()){
    for(account acc:[select id, (select Crisis_Management_Contact__c from Contacts) from Account where id in:setImpactedAccIds]){
        if(acc.contacts.size()==0){
            setparentAccIdsnoCon.add(acc.id);    
        }
        else{
            for(Contact con:acc.Contacts){
                if(con.Crisis_Management_Contact__c){
                    sethasCrisisContacts.add(acc.id);
                }
            }
        }
    }
    //Update impacted Accounts
    for(id accId :setImpactedAccIds){
        if(!setparentAccIdsnoCon.isEmpty() && setparentAccIdsnoCon.contains(accId)){
            lstAccounts.add(new Account(id=accId, has_contact__c=false));
        }
        else if(sethasCrisisContacts.isEmpty() || !sethasCrisisContacts.contains(accId)){
            lstAccounts.add(new Account(id=accId, has_crisis_contact__c=false));
        }
        else if(!sethasCrisisContacts.isEmpty() && sethasCrisisContacts.contains(accId)){
            lstAccounts.add(new Account(id=accId, has_contact__c=true, has_crisis_contact__c=true));    
        }
    }
}
//Update impacted Contacts
if(!lstAccounts.isEmpty()){
    update lstAccounts;
}
    
// Added by Mahesh
    if(Trigger.isDelete && Trigger.isBefore){
        ContactDeletion.deleteprevention(trigger.old);
    }

}