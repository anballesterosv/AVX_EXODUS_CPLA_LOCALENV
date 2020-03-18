public class ProsDmlExecutor 
{
	private ProsLogger prosLogger;
    
	public ProsDmlExecutor(ProsLogger prosLogger)
    {
        this.prosLogger = prosLogger;
    }
    
    public Database.SaveResult[] DmlInsert(List<sObject> dataToInsert, String batchId)
    {
        Database.SaveResult[] results = Database.insert(dataToInsert, false);
        CheckInsertResult(results, batchId, dataToInsert); 
        return results;
    }
    
    private void CheckInsertResult(Database.SaveResult[] results, String batchId, List<sObject> dataToInsert)
    {
        Datetime now = System.now();        
        // Check results. 
        for (Integer i = 0; i < results.size(); i++) 
        {
            String message;
            String externalId = (String) dataToInsert.get(i).get('CameleonCPQ__ExternalId__c');
            if (results[i].isSuccess()) 
            {
                String quoteId = results[i].getId();
                dataToInsert.get(i).put('Id', quoteId);
                message = 'Successfully created ID: ' + quoteId;
                prosLogger.Log(batchId, ProsUtils.LogStatus.SUCCESS, ProsUtils.LogType.INFORMATION, message, now, now, quoteId, externalId);
                //String activeRelease = '1';
                //ProsCPQSyncer.AsyncCreateCart(externalId, activeRelease);
                //ProsCPQSyncerSchedulable sc = new ProsCPQSyncerSchedulable();
                //sc.execute(null);
            } 
            else 
            {
            	message = 'Error: could not create sobject. The error reported was: '+ results[i].getErrors()[0].getMessage() + '\n';
                System.debug(message);
                prosLogger.Log(batchId, ProsUtils.LogStatus.FAILURE, ProsUtils.LogType.ERROR, message, now, now, null, externalId);
            }
        }
        prosLogger.Save();
    }
}