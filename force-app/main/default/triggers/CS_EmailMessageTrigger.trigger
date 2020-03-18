/**
* @author       Ratnesh Kumar, (RATNESH_KUMAR@CRGL-THIRDPARTY.COM)
* @version      1.0
* @createddate  1/29/2019
* @name         CS_EmailMessageTrigger
* @description  Trigger for  EmaillMessage Object
* @modifiedby   
* @modifieddate 
*/
trigger CS_EmailMessageTrigger on EmailMessage (before insert,after insert, before update){
    //check if execution is disabled for this trigger
        system.debug('*********CS_EmailMessageHandler.bDisableEmailTriggerExecution : '+CS_EmailMessageHandler.bDisableEmailTriggerExecution);

    if( !CS_EmailMessageHandler.bDisableEmailTriggerExecution ){        
        if( trigger.isBefore && trigger.isInsert){
             CS_EmailMessageHandler.updateEmailMessageBeforeInsert(trigger.new); 
            if(Label.CS_Is_Execute_Trigger == 'true'){
             CS_EmailMessageHandlerUtility.processEmailMessageHeader(trigger.new);
            }
        }
        else if( trigger.isAfter & trigger.isInsert ){
            system.debug('*********trigger called after insert');
            CS_EmailMessageHandler.afterInsertEmailMessage( trigger.new );
            /* POC - Handling AutoResponse Emails with Attachments 
            CS_EmailMessageHandler.updatedescriprionfortesting( trigger.new);
            */
            system.debug('trigger called after insert');
        }
        
        if( trigger.isBefore && trigger.isUpdate){
            CS_EmailMessageHandler.updateEmailMessageBeforeInsert(trigger.new);
        }
        
    }
}