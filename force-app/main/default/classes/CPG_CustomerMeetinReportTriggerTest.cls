@isTest

public class CPG_CustomerMeetinReportTriggerTest{
 @isTest static void TestCustomerMeetingReport(){
      
     CustomerMeetingReport__c customerMeetingReport = new CustomerMeetingReport__c ();
      List<Account> records = [select Id from Account order by CreatedDate DESC limit 1];
      if(records.size() > 0){
      for(Account acc : records){
            customerMeetingReport.Account__c = acc.id;
      }

      }
      
      
      customerMeetingReport.Name = 'Test CMR Trigger';

        insert customerMeetingReport;     
      

  
 }


}