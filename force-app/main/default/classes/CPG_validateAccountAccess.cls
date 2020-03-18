public with sharing class CPG_validateAccountAccess{
public static void checkUserAccess(list<id> lstAccId){
    list<account> lstAccount = new list<account>();
    for(id accId: lstAccId){
        account acc = new account();
        acc.id= accid;
        acc.Update_Timestamp__c = datetime.now();
        lstAccount.add(acc);
    }
    update lstAccount ;
}
}