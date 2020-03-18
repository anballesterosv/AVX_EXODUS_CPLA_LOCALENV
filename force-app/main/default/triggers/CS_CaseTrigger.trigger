/**
* @author       Ratnesh Kumar, (RATNESH_KUMAR@CRGL-THIRDPARTY.COM)
* @version      1.0
* @createddate  3/19/2019
* @name         CS_CaseTrigger
* @description  Trigger for  Case Object
* @modifiedby   
* @modifieddate 
*/
trigger CS_CaseTrigger on Case (before insert, before update) {

    CS_CaseHandler handler = new CS_CaseHandler();

    if( trigger.isBefore && trigger.isInsert) {
        //call handler method to handle before insert case flow
        handler.beforeInsertCase(trigger.new);
    }  

    if( trigger.isBefore && trigger.isUpdate ) {
       //call handler method to handle before update case flow
       handler.beforeUpdateCase( trigger.newMap, trigger.oldMap );
    }  
}