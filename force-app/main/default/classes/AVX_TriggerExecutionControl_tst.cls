/**
**************************************************************************************************************
* @company          Avanxo Brasil
* @author           Andrés Ballesteros href=<aballesteros@avanxo.com>
* @project          EXODUS - CPLA Cargill
* @name             AVX_TriggerExecutionControl_tst
* @description      Test class that covers the following classes/triggers: CRM_TriggerExecutionControl_cls
* @dependencies     Class CRM_TriggerExecutionControl_cls
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2020-02-03   Andrés Ballesteros            Initial version.
**************************************************************************************************************
**/

@isTest
private class AVX_TriggerExecutionControl_tst {
	/**
    * @method      test
    */
    @isTest 
    public static void test() {
    	// SCENARY 1: resets the value of the flag to false to allow new executions in the same thread
        AVX_TriggerExecutionControl_cls.resetTriggerExecutionStatus('MyTestingTrigger'); 
		system.debug('Is Trigger already executed? (1): '+AVX_TriggerExecutionControl_cls.hasAlreadyDone('MyTestingTrigger')); // trigger hasn't been fire yet
        system.assertEquals(false, AVX_TriggerExecutionControl_cls.hasAlreadyDone('MyTestingTrigger')); // Ask if trigger has been fired
        system.assertEquals(false, AVX_TriggerExecutionControl_cls.hasAlreadyDone('MyTestingTrigger', AVX_TriggerExecutionControl_cls.TriggerContext.BEFORE));

        // SCENARY 2: indicates that trigger has been executed
        AVX_TriggerExecutionControl_cls.setAlreadyDone('MyTestingTrigger'); 
        system.debug('Is Trigger already executed? (2): '+AVX_TriggerExecutionControl_cls.hasAlreadyDone('MyTestingTrigger')); // trigger has already been fire once
        system.assertEquals(true, AVX_TriggerExecutionControl_cls.hasAlreadyDone('MyTestingTrigger', AVX_TriggerExecutionControl_cls.TriggerContext.BEFORE));
        system.assertEquals(true, AVX_TriggerExecutionControl_cls.hasAlreadyDone('MyTestingTrigger'));
	
        // SCENARY 3: Resets the value of the flag again to allow new executions in the same thread	
        AVX_TriggerExecutionControl_cls.resetExecutionStatus('MyTestingTrigger', AVX_TriggerExecutionControl_cls.TriggerContext.AFTER);
        AVX_TriggerExecutionControl_cls.resetTriggerExecutionStatus('MyTestingTrigger'); 
        
        // SCENARY 4: BYPASS
        AVX_TriggerExecutionControl_cls.bypass('MyTestingTrigger');
        AVX_TriggerExecutionControl_cls.clearBypass('MyTestingTrigger');
    }
}