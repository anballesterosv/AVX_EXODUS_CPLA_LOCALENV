public class ProsLogger 
{
	private List<sObject> prosLogList;
    
    public ProsLogger()
    {
        prosLogList = new List<sObject>();
    }
    
    public virtual ProsLogger Log(
        String batchId, 
        ProsUtils.LogStatus status, 
        ProsUtils.LogType type, 
        String message, 
        DateTime startDate, 
        DateTime endDate, 
        String quoteId, 
        String externalId)
    {  
        PROS_Log__c prosLog = new PROS_Log__c();
        prosLog.put('BatchID__c', batchId);
        prosLog.put('Status__c', status.Name());
        prosLog.put('Type__c', type.Name());
        prosLog.put('Message__c', message);
        prosLog.put('StartDate__c', startDate);
        prosLog.put('EndDate__c', endDate);   
        prosLog.put('PROS_Quote__c', quoteId);
        prosLog.put('External_Id__c', externalId);
        prosLogList.add(prosLog);
        return this;
    }
    
    public virtual ProsLogger Log(
        String batchId, 
        ProsUtils.LogStatus status, 
        ProsUtils.LogType type, 
        String message, 
        DateTime startDate, 
        DateTime endDate)
    {  
        
        return Log(batchId, status, type, message, startDate, endDate, null, null);
    }
    
    public virtual ProsLogger Log(
        String batchId, 
        ProsUtils.LogStatus status, 
        ProsUtils.LogType type, 
        String message)
    {  
        Datetime now = System.now();
        return Log(batchId, status, type, message, now, now);
    }
    
    public virtual ProsLogger Log(
        ProsUtils.LogStatus status, 
        ProsUtils.LogType type, 
        String message, 
        DateTime startDate, 
        DateTime endDate)
    {          
        return Log(null, status, type, message, startDate, endDate);
    }
    
    public virtual ProsLogger Log(
        ProsUtils.LogStatus status,
        ProsUtils.LogType type, 
        String message)
    {  
        Datetime now = System.now();
        return Log(status, type, message, now, now);
    }
    
    public ProsLogger Error(String message)
    {
        return Log(ProsUtils.LogStatus.FAILURE, ProsUtils.LogType.ERROR, message);
    }
    
    public ProsLogger Info(String message)
    {
        return Log(ProsUtils.LogStatus.SUCCESS, ProsUtils.LogType.INFORMATION, message);
    }
    
    public void Save()
    {        
        try
        {
            if (prosLogList.size() > 0)
            {
                insert prosLogList;
        		prosLogList.clear();
            }
        }
        catch (Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }
}