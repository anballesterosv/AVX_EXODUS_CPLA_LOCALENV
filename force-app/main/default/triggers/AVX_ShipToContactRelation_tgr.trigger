/**
**************************************************************************************************************
* @company          Avanxo Brasil
* @author           Igor Novaes href=<igor.novaes@globant.com>
* @project          EXODUS - CPLA Cargill
* @name             AVX_CreditLimit_tgr
* @description      Trigger for the CS_Ship_To_Contact_Relation__c Object.
* @dependencies     AVX_ShipToContactRelation_cls
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2020-02-04   Igor Novaes.                  Initial version.
**************************************************************************************************************
**/

trigger AVX_ShipToContactRelation_tgr on CS_Ship_To_Contact_Relation__c (/*before insert, before update, before delete, */after insert, after update /*after delete, after undelete*/) {
    /*if(trigger.isBefore) {     
        if(!AVX_TriggerExecutionControl_cls.hasAlreadyDone('AVX_CreditLimit_tgr ', AVX_TriggerExecutionControl_cls.TriggerContext.BEFORE)) {
            
            AVX_TriggerExecutionControl_cls.setAlreadyDone('AVX_CreditLimit_tgr ', AVX_TriggerExecutionControl_cls.TriggerContext.BEFORE);
            
            if(trigger.isInsert) {
                System.debug('\n\n-=#=-\n>>>>>>>>>>   ' + 'AVX_CreditLimit_tgr  - Before Insert execution block' + '   <<<<<<<<<<\n-=#=-\n');

            } else if(trigger.isUpdate) {
                System.debug('\n\n-=#=-\n>>>>>>>>>>   ' + 'AVX_CreditLimit_tgr  - Before Update execution block' + '   <<<<<<<<<<\n-=#=-\n');

            } else if(trigger.isDelete) {
                System.debug('\n\n-=#=-\n>>>>>>>>>>   ' + 'AVX_CreditLimit_tgr  - Before Delete execution block' + '   <<<<<<<<<<\n-=#=-\n');
            }
            
        } else {
            System.debug('\n\n-=#=-\n>>>>>>>>>>   ' + 'Trigger "AVX_CreditLimit_tgr " has already done all BEFORE methods' + '   <<<<<<<<<<\n-=#=-\n');
        }
    } else */if (trigger.isAfter) {
        if(!AVX_TriggerExecutionControl_cls.hasAlreadyDone('AVX_CreditLimit_tgr ', AVX_TriggerExecutionControl_cls.TriggerContext.AFTER)) {
            
            AVX_TriggerExecutionControl_cls.setAlreadyDone('AVX_CreditLimit_tgr ', AVX_TriggerExecutionControl_cls.TriggerContext.AFTER);
            
            if(trigger.isInsert) {
                AVX_ShipToContactRelationTgrHelper_cls.relateContactPrimaryContact(Trigger.new);
                System.debug('\n\n-=#=-\n>>>>>>>>>>   ' + 'AVX_CreditLimit_tgr  - After Insert execution block' + '   <<<<<<<<<<\n-=#=-\n');
            } else if(trigger.isUpdate) {
                AVX_ShipToContactRelationTgrHelper_cls.relateContactPrimaryContact(Trigger.new);
                System.debug('\n\n-=#=-\n>>>>>>>>>>   ' + 'AVX_CreditLimit_tgr  - After Update execution block' + '   <<<<<<<<<<\n-=#=-\n');
            }/* else if(trigger.isDelete) {
                System.debug('\n\n-=#=-\n>>>>>>>>>>   ' + 'AVX_CreditLimit_tgr  - After Delete execution block' + '   <<<<<<<<<<\n-=#=-\n');
            } else if (trigger.isUndelete) {
                System.debug('\n\n-=#=-\n>>>>>>>>>>   ' + 'AVX_CreditLimit_tgr  - After Undelete execution block' + '   <<<<<<<<<<\n-=#=-\n');
            }*/
        } else {
            System.debug('\n\n-=#=-\n>>>>>>>>>>   ' + 'Trigger "AVX_CreditLimit_tgr " has already done all AFTER methods' + '   <<<<<<<<<<\n-=#=-\n');
        }
    }
}