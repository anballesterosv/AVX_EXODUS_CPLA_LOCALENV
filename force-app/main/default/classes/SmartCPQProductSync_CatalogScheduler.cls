/**
@Author - PROS (RDE)
@Name - SmartCPQProductSync_CatalogScheduler
@CreateDate -12-06-2017
@Description - A small Schedulable class that provides the entry point from the Apex scheduler. Handles the initial schedule call as well as the subsequent scheduled calls in the chain.
@Version - 1.0 
**/
global class SmartCPQProductSync_CatalogScheduler implements schedulable, Database.AllowsCallouts{ 
    String jsonObject = null;
     /**
    @Author - PROS
    @method name - SmartCPQProductSync_CatalogScheduler
    @CreateDate - 29-06-2017
    @Description -  Constructor from CPQJobSpec with the next job to run
    @Param - jsonObject
    @Version - 1.0
   
    */
    public SmartCPQProductSync_CatalogScheduler(String jsonObject){
        // We are called from SmartCPQProductSync_JobSpec with the next job to run
        this.jsonObject = jsonObject;
        System.debug('-----jsonObject----inside scheduler----'+jsonObject);
    }
    
    /**
    @Author - PROS
    @method name - SmartCPQProductSync_CatalogScheduler
    @CreateDate - 29-06-2017
    @Description -  Constructor from SmartCPQProductSync_JobSpec  to run the first job
    @Param - null
    @Version - 1.0
    */
   public SmartCPQProductSync_CatalogScheduler(){
        // We are called from the scheduler to run the first job
        this.jsonObject = null;
        System.debug('-----Scheduler called for 1st time-----');
    }
    /**
    @Author - PROS
    @method name - execute 
    @CreateDate - 29-06-2017
    @Description - Execute method runs the Job
    @Param - cat
    @Version - 1.0
    */
    global void execute(SchedulableContext cat){
        System.debug('----execute job-----');
        SmartCPQProductSync_JobSpec.run(this.jsonObject);  
    } 
}