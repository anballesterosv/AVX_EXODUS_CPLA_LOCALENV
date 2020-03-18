/**
**************************************************************************************************************
* @company          Avanxo Brasil
* @author           Andrés Ballesteros href=<andres.ballestero@globant.com>
* @project          EXODUS - CPLA Cargill
* @name             AVX_TriggerExecutionControl_cls
* @description      Controls double execution of triggers to avoid unnecessary loops and Apex limits over process.
* @dependencies     None
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2020-02-03   Andrés Ballesteros            Initial version.
**************************************************************************************************************
**/

global class AVX_TriggerExecutionControl_cls {
    
    // Variable to avoid the trigger execution loop
    private static set<string> ExecutedTriggers_set = new set<string>();

    public Enum TriggerContext { BEFORE, AFTER }
    private static Map<String, Set<TriggerContext>> mapExecutedTriggers = new Map<String, Set<TriggerContext>>();
    private static Set<String> setTriggersToBypass = new Set<String>();
     
    // Indicates if trigger has been fired once in the same thread
    public static boolean hasAlreadyDone(string strAPINameOfTrigger) { 
        if(!ExecutedTriggers_set.isEmpty()){
            return ExecutedTriggers_set.contains(strAPINameOfTrigger);
        }else{
            return false;
        }
    }   

    // Sets that trigger has been fired
    public static void setAlreadyDone(string strAPINameOfTrigger) { 
        ExecutedTriggers_set.add(strAPINameOfTrigger);
        setAlreadyDone(strAPINameOfTrigger, TriggerContext.BEFORE);
        setAlreadyDone(strAPINameOfTrigger, TriggerContext.AFTER);
    }

    // Indicates that trigger has not ran yet (optional)
    public static void resetTriggerExecutionStatus(string strAPINameOfTrigger) { 
        ExecutedTriggers_set.remove(strAPINameOfTrigger);
        resetExecutionStatus(strAPINameOfTrigger);
    }

    /**
    * @method       hasAlreadyDone
    * @description  Method to check if a trigger has been executed in the specified context.
    */
    public static boolean hasAlreadyDone(string strAPINameOfTrigger, TriggerContext enmTriggerContext) {
        if(setTriggersToBypass.contains(strAPINameOfTrigger)) return true;
        if(mapExecutedTriggers.containsKey(strAPINameOfTrigger)) {
            return mapExecutedTriggers.get(strAPINameOfTrigger).contains(enmTriggerContext);
        } else {
            return false;
        }
    }   

    /**
    * @method       setAlreadyDone
    * @description  Method to set that a trigger has been executed in the specified context
    */
    public static void setAlreadyDone(String strAPINameOfTrigger, TriggerContext enmTriggerContext) {
        if(mapExecutedTriggers.containsKey(strAPINameOfTrigger)) {
            mapExecutedTriggers.get(strAPINameOfTrigger).add(enmTriggerContext);
        } else {
            Set<TriggerContext> setTriggerContext = new Set<TriggerContext>();  //To preserve backward compatibility.
            setTriggerContext.add(enmTriggerContext);                           //To preserve backward compatibility.
            mapExecutedTriggers.put(strAPINameOfTrigger, setTriggerContext);
        }
    }

    /**
    * @method       resetExecutionStatus
    * @description  Method to mark a trigger as not executed.
    */
    public static void resetExecutionStatus(String strAPINameOfTrigger) {
        if(mapExecutedTriggers.containsKey(strAPINameOfTrigger)) {
            mapExecutedTriggers.remove(strAPINameOfTrigger);
        }
    }

    /**
    * @method       resetExecutionStatus
    * @description  Method to mark a trigger as not executed in the specified context.
    */
    public static void resetExecutionStatus(String strAPINameOfTrigger, TriggerContext enmTriggerContext) {
        if(mapExecutedTriggers.containsKey(strAPINameOfTrigger)) {
            if(mapExecutedTriggers.get(strAPINameOfTrigger).contains(enmTriggerContext)) {
                mapExecutedTriggers.get(strAPINameOfTrigger).remove(enmTriggerContext);
            }
        }
    }

    /**
    * @method       bypass
    * @description  Method to bypass the execution of a trigger.
    */
    public static void bypass(String strAPINameOfTrigger) {
        setTriggersToBypass.add(strAPINameOfTrigger);
    }

    /**
    * @method       clearBypass
    * @description  Method to clear a trigger bypass.
    */
    public static void clearBypass(String strAPINameOfTrigger) {
        if(setTriggersToBypass.contains(strAPINameOfTrigger)) {
            setTriggersToBypass.remove(strAPINameOfTrigger);
        }
    }
}