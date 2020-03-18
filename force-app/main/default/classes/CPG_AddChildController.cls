public class CPG_AddChildController {
  @AuraEnabled
  public static List<contact> getContacts(String parentAccount) {
      List<contact> lstCons = new List<contact>();
      set<id>setuConIds = new set<id>();
      for(user_contact__c cnt : [SELECT contact__c from user_contact__c where contact__r.accountid=:parentAccount and user__c=:UserInfo.getUserid() limit 10]){
          setuConIds.add(cnt.contact__c);
        } 
      for(contact cnt : [SELECT id,name,Email from contact where accountid=:parentAccount]){
        if(setuConIds.isEmpty() || !setuConIds.contains(cnt.id)){
            lstCons.add(cnt);
        }
      }   
      return lstCons;
  }
  @AuraEnabled
  public static List<user_contact__c > getuContacts(String parentAccount) {
      List<user_contact__c> lstCons = new List<user_contact__c>();
        for(user_contact__c cnt : [SELECT Name,contact__c,contact__r.Name,id,contact__r.Email,contact__r.Title from user_contact__c where contact__r.accountid=:parentAccount  and user__c=:UserInfo.getUserid() limit 10]){
          lstCons.add(cnt);
        }   
      return lstCons;
  }
  
  @AuraEnabled
  public static void removeuContact(String conId) {
      list<user_contact__c> cnt = [SELECT id from user_contact__c where contact__c=:conId  and user__c=:UserInfo.getUserid() ];
      delete cnt;
  }
    
  @AuraEnabled
  public static void addCons(List<string> lstOfContactIds){
    list<User_Contact__c> lstContacts = new list<User_Contact__c>();
    for(id sContactId : lstOfContactIds){
        User_Contact__c uContact = new User_Contact__c();
        uContact.Contact__c = sContactId;
        uContact.user__c = UserInfo.getUserid();
        lstContacts.add(uContact);
   }
   insert lstContacts;
 }
}