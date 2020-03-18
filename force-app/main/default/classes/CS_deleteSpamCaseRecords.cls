/**
 * @author       Ramesh Yenugula
 * @version      1.0
 * @createddate 26.01.2020
 * @name         CS_deleteSpamCaseRecords
 * @description batch class for delete the spam email related cases 
 * @modifiedby
 * @modifieddate
*/
global class CS_deleteSpamCaseRecords implements Database.batchable<sObject>{
    // this label is used for store the spam email id.
    public String emailList = System.Label.CS_DeletedEmailList;
    // this label is used for store the email id whom we need to send final results.
     String emaillabel = Label.CS_batchClassResultsReceivedEmailID;
     global String [] email = new String[] {emaillabel };
    
    List<string> caseEmailList = new  List<string>();
       //this varible get the case Protein record Type.
      private static final Id PROTEIN_CASE_RECORDTYPEID;
        static { //get the Protein Case Recordtype Id
            PROTEIN_CASE_RECORDTYPEID = CS_SystemConstants.getRecordTypeId( CS_SystemConstants.PROTEIN_SERVICE_RECORD_TYPE , Case.SObjectType );
        }
     // This method is used for get list of spam case records list based on custom label level(CS_DeletedEmailList) waht we provided.   
    global Database.QueryLocator start(Database.BatchableContext bc){ 
       
     if(string.isNotEmpty(emailList)){    
          caseEmailList = emailList.split(';');
          system.debug(caseEmailList.size());
          System.debug('caseEmailList'+caseEmailList);
        }
        return Database.getQueryLocator('select ID  FROM Case  where SuppliedEmail IN : caseEmailList and RecordTypeId =: PROTEIN_CASE_RECORDTYPEID');
    }    
        // This method will delete the sapm cases based start method results.
      global void execute(Database.BatchableContext bc, List<Case> scope)
        {
        system.debug('deletedListofCase******'+scope);
        system.debug('deletedListofCase.size******'+scope.size());
        if(!scope.isEmpty()){
           Database.delete(scope);
       }
    }
    // This method is used for send the conforamtion mail
    global void finish(Database.BatchableContext bc) {
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
       // Below code will fetch the job Id
      AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors,
      a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById,
      a.CompletedDate From AsyncApexJob a WHERE id = :bc.getJobId()];
    
     // get the job Id
      System.debug('$$$ Jobid is'+bc.getJobId());
    // below code will send an email to User about the status
      mail.setToAddresses(email);
      mail.setReplyTo(emaillabel ); // Add here your email address
      mail.setSenderDisplayName('Apex Batch Processing Module');
      mail.setSubject('Batch Processing '+a.Status);
      mail.setPlainTextBody('The Batch Apex job processed'+  a.TotalJobItems  +'batches with '+ a.NumberOfErrors  +'failures'+'Job Item processed are'+a.JobItemsProcessed);
      Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
    }
}