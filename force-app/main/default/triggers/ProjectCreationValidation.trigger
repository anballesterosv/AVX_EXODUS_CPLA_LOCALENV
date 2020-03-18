/**
@Author - Aditi Sharma
@name - ProjectCreationValidation
@CreateDate - 01-18-2017
@Description - This is an Apex Triiger to Validate the Project Creation.
@Revision-
*/ 
trigger ProjectCreationValidation on project__c(before Insert) {

/*************Before Insert**********************************/
    If(Trigger.isBefore && Trigger.isInsert){
        system.debug('my trigger is @@@@@');
        beforeInsertorUpdate();
    }
   
     
/**************methods for calling helper class***************/
    Public Void beforeInsertorUpdate(){
        ProjectCreationValidation callMethod = new ProjectCreationValidation();
        ProjectCreationValidation.projectValidation(Trigger.New);
        
    }
    
}