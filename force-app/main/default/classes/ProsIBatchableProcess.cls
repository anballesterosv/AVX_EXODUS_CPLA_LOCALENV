public interface ProsIBatchableProcess 
{
	/**To retrieve a string query*/
    String GetQuery();
    
    /**Start all process*/
    void InitProcess();
    
    /**To execute a process*/
    Boolean DoWork(List<SObject> scope);
    
    /**To do sometime when end a process*/
    Boolean Complete();
    
    /**Validate something*/
    Boolean ValidateData();
    
    /**Get the batch size*/
    Integer GetBatchSize();
    
    /**Extra method that will return a list of objects built to avoid query locator*/
    List<sObject> GetIterable();
    
    /**Get the job id*/
    String GetJobId();

    /**Setting the job id to a variable*/
    void SetJobId(String jobId);
}