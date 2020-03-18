public without sharing class AccountPlanCloneButtonClass {
    
    private final static String SLASH = '/';
    public boolean ren{get;set;}
    public id recordId{get;set;}
    public AccountPlanCloneButtonClass (ApexPages.StandardController controller) {
        system.debug('inside class');
    }
    public flow.interview.AccountPlanRecordClone myFlow{get;set;}
    public pageReference getNewAbsenceId() {
    	pageReference pgRef=null;
        if(myFlow == null){
            System.debug('Flownull'+myFlow);
            
        }
        else{
            ren=true;
            //System.debug('else part'+myFlow.AccountPlanObj.Id);
            recordId = myFlow.AccountPlanObj.Id;
            pgRef= new pageReference (SLASH +myFlow.AccountPlanObj.Id);
        }
        return pgRef;
    }
    
    public pageReference getUrl(){
        return new PageReference(SLASH +myFlow.AccountPlanId);
    }
}