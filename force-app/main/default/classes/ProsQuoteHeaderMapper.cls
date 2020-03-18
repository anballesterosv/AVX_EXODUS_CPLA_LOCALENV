public class ProsQuoteHeaderMapper implements ProsIBatchableProcess
{
    private ProsDmlExecutor dmlExecutor;
    private ProsLogger prosLogger;
    private String jobIdExecuted;
    private String inputDocumentName;
    private String outputDocumentName;
    /* Switching to use Legacy_Record_ID__c instead of External ID
    private final String EXTERNAL_ID_API_NAME = 'CameleonCPQ__ExternalId__c'; */
    private final String EXTERNAL_ID_API_NAME = 'Legacy_Record_ID__c';
    private final String EXTERNAL_ID_KEY = 'Quote ID';
    
    public ProsQuoteHeaderMapper(String inputDocumentName)
    {
        this.inputDocumentName = inputDocumentName;
        this.outputDocumentName = inputDocumentName + '-out';
        prosLogger = new prosLogger();
        dmlExecutor = new ProsDmlExecutor(prosLogger);
    }
    
    public List<CameleonCPQ__Quote__c> MapCsvContentToSObjects(String documentName)
    {
        List<List<String>> rows = ProsDocumentHandler.ParseCSVByDocumentName(documentName, false);
        List<CameleonCPQ__Quote__c> quotesToInsert = new List<CameleonCPQ__Quote__c>();
        if (rows.size() > 0)
        {            
            List<String> header = rows.remove(0);
            ProsUtils.SwapValuesOnList(EXTERNAL_ID_KEY, EXTERNAL_ID_API_NAME, header);
            Integer externalIdIndex = ProsUtils.GetIndexFromStringList(header, EXTERNAL_ID_API_NAME);
            Set<String> ids = GetExternalIdsFromQuotes(rows, externalIdIndex, EXTERNAL_ID_API_NAME);
            
            String externalIdKey;
            Boolean wasAlreadySaved; 
            String message = 'The record was already mapped. Same external ID.';
            for(List<String> row : rows)
            {
                externalIdKey = row.get(externalIdIndex);
                wasAlreadySaved = ids.contains(externalIdKey);
                if(!wasAlreadySaved)
                {
                    Integer index = 0;
                    CameleonCPQ__Quote__c cpqQuote = new CameleonCPQ__Quote__c();
                    for(String value : row)
                    {
                        if(!String.isEmpty(value))
                        {
                            object valueObj = ProsUtils.ConvertToTheRightValue(value);
                            cpqQuote.put(header.get(index), valueObj);                            
                        }
                        index++;
                    }                
                    quotesToInsert.add(cpqQuote);                    
                }
                else
                {
                    prosLogger.Log(GetJobId(), ProsUtils.LogStatus.SUCCESS, ProsUtils.LogType.INFORMATION, message, System.now(), System.now(), null, externalIdKey);                    
                }
            }
            prosLogger.Save();            
        }
        return quotesToInsert;
    }
    
    public Set<String> GetExternalIdsFromQuotes(List<List<String>> rows, Integer externalIdIndex, String externalIdApiName)
    {
        List<String> externalIds = ProsUtils.GetValuesByIndex(rows, externalIdIndex);            
        List<CameleonCPQ__Quote__c> quotesAlreadyImported = QueryQuotesAlreadyImported(externalIds);
        Set<String> ids = ProsUtils.GetValuesAsSet(quotesAlreadyImported, externalIdApiName);
        return ids;
    }
    
    public List<CameleonCPQ__Quote__c> QueryQuotesAlreadyImported(List<String> externalIds)
    {
        /* Switching to use Legacy_Record_ID__c instead of External ID
        return [SELECT CameleonCPQ__ExternalId__c, Id
                FROM CameleonCPQ__Quote__c 
                WHERE CameleonCPQ__ExternalId__c IN : externalIds]; */
                
         return [SELECT Legacy_Record_ID__c , Id
                FROM CameleonCPQ__Quote__c 
                WHERE Legacy_Record_ID__c IN : externalIds];        
    }
    
    public void SaveScopeAsOutputDocument(List<sObject> scope)
    {
        List<String> rows = new List<String>();
        String externalId;
        String internalId;
        for(sObject scopeObj : scope)
        {
            externalId = (String) scopeObj.get(EXTERNAL_ID_API_NAME);
            internalId = (String)scopeObj.get('Id');            
            if(externalId != null && internalId != null)
            {
                rows.add(externalId + ',' + internalId);
            }
        }
        if (rows.size() > 0)
        {
            String content = String.join(rows, '\n');
            Document document = ProsDocumentHandler.createDocumentIfNotExist(this.outputDocumentName, null, 'text/csv', 'csv');
            String currentContent = document.body.toString();
            if(!String.isEmpty(currentContent))
            {
                content = currentContent + '\n' + content;
            }
            document.Body = Blob.valueOf(content);
            update document;
        }
    }
    
    /**To retrieve a string query*/
    public String GetQuery()
    {
        return '';
    }
    
    /**Start all process*/
    public void InitProcess()
    {
        Document document = ProsDocumentHandler.createDocumentIfNotExist(this.outputDocumentName, null, 'text/csv', 'csv');
        String content = document.Body != null ? document.Body.toString() : null;
        if(!String.isEmpty(content))
        {
            document.Body = Blob.valueOf('');
            update document;
        }
    }
    
    /**To execute a process*/
    public Boolean DoWork(List<SObject> scope)
    {
        System.debug('DoWork: ' + scope.size() + ' records to save');
        dmlExecutor.DmlInsert(scope, GetJobId());
        SaveScopeAsOutputDocument(scope);
        return true;
    }
    
    /**To do sometime when end a process*/
    public Boolean Complete()
    {        
        Document document = ProsDocumentHandler.GetDocumentByName(this.outputDocumentName);
        String content = document.Body.toString();
        if(!String.isEmpty(content))
        {
            document.Body = Blob.valueOf('LegacyQuoteId,SFDCQuoteId\n' + content);
            update document;
        }
        return true;
    }
    
    /**Validate something*/
    public Boolean ValidateData()
    {
        return true;
    }
    
    /**Get the batch size*/
    public Integer GetBatchSize()
    {
        return 3;
    }
    
    /**Extra method that will return a list of objects built to avoid query locator*/
    public List<sObject> GetIterable()
    {
        return MapCsvContentToSObjects(this.inputDocumentName);
    }
    
    /**Get the job id*/
    public String GetJobId()
    {
        return this.jobIdExecuted;
    }

    /**Setting the job id to a variable*/
    public void SetJobId(String jobId)
    {
        this.jobIdExecuted = jobId;    
    }
}