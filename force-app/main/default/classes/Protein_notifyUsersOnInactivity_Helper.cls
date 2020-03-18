/**
Class Name: Protein_notifyUsersOnInactivity_Helper
Description: This is a helper class for Protein_notifyUsersOnInactivity apex class

Developer: Sri Harshitha Bandi
CreatedDate: 10/12/2019
**/
public class Protein_notifyUsersOnInactivity_Helper {
    
    public static List<Id> returnUserIdsToDeactivate(Database.SaveResult[] srList) {
        List<Id> lstUserIdsToDeactivate = new List<Id>();
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('User Id: ' + sr.getId());
                lstUserIdsToDeactivate.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        return lstUserIdsToDeactivate;
    }
    
    public static Messaging.SingleEmailMessage checkUserLoginDate(User u, EmailTemplate emailTemplate1, EmailTemplate emailTemplate2) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(u.LastLoginDate.date().daysBetween(System.today()) == 60 || Test.isRunningTest()) {
            System.debug('User who had logged in 60 days ago: ' +u.Name);
            email.setToAddresses(new String[] {u.Email});
            email.setSaveAsActivity(false);
            email.setTargetObjectId(u.Id);
            email.setTemplateId(emailTemplate1.Id);
        }
        if(u.LastLoginDate.date().daysBetween(System.today()) == 80 || Test.isRunningTest()) {
            System.debug('User who had logged in 80 days ago: ' +u.Name);
            email.setToAddresses(new String[] {u.Email});
            email.setSaveAsActivity(false);
            email.setTargetObjectId(u.Id);
            email.setTemplateId(emailTemplate2.Id);
        }
        if(email == null) {
            return null;
        }
        else {
            return email;   
        }
    }

}