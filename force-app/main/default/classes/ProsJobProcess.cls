global class ProsJobProcess implements Database.Batchable<sObject>
{
	/** Stores the job executor instance*/
    private ProsIBatchableProcess jExecutor;
    
    private ProsLogger prosLogger;
    
    /**
     * Custom constructor
     *
     * @param ibp The bachable process instance class
     */
    public ProsJobProcess(ProsIBatchableProcess ibp)
    {
        System.debug('ProsJobProcess');
        jExecutor = ibp;
        prosLogger = new ProsLogger();
    }
    
    /**
     * Returne the batch size
     *
     * @return scope A Integer value
     */
    global Integer GetScope()
    {
        return jExecutor.GetBatchSize();
    }
    
    /**
     * Standard interface methods for Database.Batchable
     *
     * @param ctx The batchable contex
     * @param A data base query locator
     */
    global Iterable<sObject> Start(Database.BatchableContext ctx)
    {
        String jobId = ctx.getJobId();
        String message = 'Batch job has started';
        prosLogger.Log(jobId, ProsUtils.LogStatus.SUCCESS, ProsUtils.LogType.INFORMATION, message).Save();        
        jExecutor.SetJobId(jobId);
        jExecutor.InitProcess();
        return jExecutor.GetIterable();
    }
    
    /**
     * Standard interface methods for Database.Batchable
     *
     * @param ctx The batchable contex
     * @param scope The scope objects list
     */
    global void Execute(Database.BatchableContext ctx, List<sObject> scope)
    {
        String jobId = ctx.getJobId();
        jExecutor.SetJobId(jobId);
        jExecutor.DoWork(scope);
    }
    
    /**
     * Standard interface methods for Database.Batchable
     *
     * @param ctx The batchable contex
     */
    global void Finish(Database.BatchableContext ctx)
    {
        String jobId = ctx.getJobId();
        jExecutor.SetJobId(jobId);
        if (jExecutor.Complete())
        {
            String message = 'Batch job has completed';
        	prosLogger.Log(jobId, ProsUtils.LogStatus.SUCCESS, ProsUtils.LogType.INFORMATION, message).Save();
        }
    }
}