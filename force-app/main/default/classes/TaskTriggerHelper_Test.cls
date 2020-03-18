@isTest
public class TaskTriggerHelper_Test {
    static testMethod void validateHelper(){
        Business__c b = new Business__c();
        b.BusinessUnitAlias__c = 'Foods Brazil';
        b.Name = 'Cargill Foods Brazil';
        b.CargillEnterprise__c = 'FoodIngredientsBioIndustrialFIBI';
        b.CargillGroup__c = 'GoToMarket (GTM)';
        Insert b;
        
        
        Task insertNew = new Task();
        insertNew.Subject ='Test';
        insertNew.OwnerId = CPG_TestFactory_Util.createTestUser('System Administrator').id;
        insertNew.Priority = 'Normal';
        insertNew.Status ='Open';
        Insert insertNew;
    }
    static testMethod void validateCMRtaskRollup(){
        //create account       
        list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(2);
        acclist[0].Parentid=acclist[1].id;
        update acclist[0];
        
        //Create Contact
        list<contact> lstCon = new list<contact>();
        lstCon = CPG_TestFactory_Util.createTestContacts(2,acclist);
        
        //Create Cargill Attendee
        user attendee = CPG_TestFactory_Util.createTestUser('System Administrator');
        user attendee2 = CPG_TestFactory_Util.createTestUser('System Administrator');
           
        //Create Customer Meeting report   
        list<CustomerMeetingReport__c> lstCMR = CPG_TestFactory_Util.createTestCustomerMeetingReport(1,acclist);
        
        //Add Attendees to CMR
        list<Customer_Meeting_Attendee__c> lstAtt = new list<Customer_Meeting_Attendee__c>();
        lstAtt.add(new Customer_Meeting_Attendee__c(Cargill_Attendee__c=attendee.id, customer_meeting_report__c = lstCMR[0].id));
        lstAtt.add(new Customer_Meeting_Attendee__c(Cargill_Attendee__c=attendee2.id, customer_meeting_report__c = lstCMR[0].id));
        insert lstAtt;
        
        //Add Customer Attendees to CMR
        list<Customer_Meeting_Contact__c> lstConAtt = new list<Customer_Meeting_Contact__c>();
        lstConAtt.add(new Customer_Meeting_Contact__c(contact__c=lstCon[0].id, customer_meeting_report__c = lstCMR[0].id));
        lstConAtt.add(new Customer_Meeting_Contact__c(contact__c=lstCon [1].id, customer_meeting_report__c = lstCMR[0].id));
        insert lstConAtt;
        
        //Create Tasks against CMR
        list<task> lstTask = new list<task>();
        Task insertNew1 = new Task();
        insertNew1.Subject ='Test';
        insertNew1.OwnerId = attendee.id;
        insertNew1.Priority = 'Normal';
        insertNew1.Status ='Open';
        insertNew1.whatid = lstCMR[0].id;
        lstTask.add(insertNew1);
        
        Task insertNew2 = new Task();
        insertNew2.Subject ='Test';
        insertNew2.OwnerId = attendee.id;
        insertNew2.Priority = 'Normal';
        insertNew2.Status ='Open';
        insertNew2.whatid = lstCMR[0].id;
        lstTask.add(insertNew2);
        Insert lstTask;
        delete lstTask[0];
        
    }
}