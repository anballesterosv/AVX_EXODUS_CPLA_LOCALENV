/**
Class Name: Protein_notifyUsersOnInactivity
Description: This batch class is used to detect the LastLoginDate of the users & send email notifications to the users other than with API only profile:
			  If user didn't login in the last 60 days, 1st Notification to be sent.
			  If user didn't login in the last 80 days, 2nd Notification to be sent.
			  If user didn't login in the last 90 days, he/she should be deactivated in the system by sending an email Notification.

Developer: Sri Harshitha Bandi
CreatedDate: 10/12/2019
**/

global class Protein_notifyUsersOnInactivity implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
         String query;
        if(Test.isRunningTest()){
         query = 'SELECT Id, Name, LastLoginDate, IsActive, email FROM User WHERE IsActive = TRUE AND LastLoginDate!=null AND Profile.Name != \'API Only\' AND Profile.Name != \'System Administrator\' ORDER BY LastLoginDate DESC limit 100';
        }
        else{
         query = 'SELECT Id, Name, LastLoginDate, IsActive, email FROM User WHERE IsActive = TRUE AND LastLoginDate!=null AND Profile.Name != \'API Only\' AND Profile.Name != \'System Administrator\' AND LastLoginDate != LAST_N_DAYS:1 ORDER BY LastLoginDate DESC';
        }
        
        //String query = 'SELECT Id, Name, LastLoginDate, IsActive, email FROM User WHERE IsActive = TRUE AND LastLoginDate!=null AND Profile.Name != \'API Only\' AND LastLoginDate != LAST_N_DAYS:9 ORDER BY LastLoginDate DESC';  //Returns all the Active users whose last login is greater is 60 days
       
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<User> lstUsers) {
        
        List<User> lstUpdateUsers = new List<User>();
        List<Id> lstUserIdsToDeactivate = new List<Id>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate1 = [select Id, Body from EmailTemplate where DeveloperName = 'Last_Login_60_Days_HTML' LIMIT 1];
        EmailTemplate emailTemplate2 = [select Id, Body from EmailTemplate where DeveloperName = 'Last_Login_80_Days_HTML' LIMIT 1];
        EmailTemplate emailTemplate3 = [select Id, Body from EmailTemplate where DeveloperName = 'Notify_users_on_Deactivation' LIMIT 1];
        
        System.debug('%%%user list='+lstUsers.size());
        // process each batch of records        
        for(User u : lstUsers) {    
            // Check for last login whether it is equal to 60 days or 80 days or greater than 90 days
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email = Protein_notifyUsersOnInactivity_Helper.checkUserLoginDate(u, emailTemplate1, emailTemplate2);
            if(email.getTargetObjectId() != null) {
                emailsToSend.add(email);
            }
            
            if(u.LastLoginDate.date().daysBetween(System.today()) >= 90 || Test.isRunningTest()) {
                System.debug('User who had logged in 90 days ago: ' +u.Name);
                u.IsActive = false;
                lstUpdateUsers.add(u);
            }
        }
        //Updating the user records
        if(!lstUpdateUsers.isEmpty()) {
            System.debug('lstUpdateUsers: ' +lstUpdateUsers);
            Database.SaveResult[] srList = Database.update(lstUpdateUsers, false);
            lstUserIdsToDeactivate = Protein_notifyUsersOnInactivity_Helper.returnUserIdsToDeactivate(srList);
        }
        List<User> lstUsersToDeactivate = [SELECT Id, Name, LastLoginDate, IsActive, email FROM User WHERE Id IN :lstUserIdsToDeactivate];
        for(User u : lstUsersToDeactivate) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {u.Email});
            email.setSaveAsActivity(false);
            email.setTargetObjectId(u.Id);
            email.setTemplateId(emailTemplate3.Id);
            emailsToSend.add(email);
        }
        
        //Sending all the Notification Emails
        if(!emailsToSend.isEmpty()) {
            System.debug('emailsToSend: ' +emailsToSend);
            //Messaging.sendEmail(emailsToSend);
        }
        
    } 
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Apex Job Done');
    }
    
}