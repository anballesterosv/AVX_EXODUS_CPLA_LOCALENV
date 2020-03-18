/**
@Author - PROS
@Name - SmartCPQProductSync_VersionDelete
@CreateDate - 29-06-2017
@Description - This Apex class will delete any versions older than the last three versions in CPQ system.
@Version - 1.0
@reference - N/A 
**/
public class SmartCPQProductSync_VersionDelete{
private static final String CPQ_VERSION_DELETE ='CPQVersionDelete';
private static final String HTTPR_REQUESTB_RUNWAIT ='HttpR:RequestB:runWait';
private static final String HTTPR_REQUESTE_RUNWAIT ='HttpR:RequestE:runWait';
private static final String HTTPR_REQUESTF_RUNWAIT_FAILURE ='HttpR:RequestF:runWait:Failure:';
private static final String NB_VERSIONS_TOKEEP ='3';
private static final String PROCESS_BEG ='Process:Beg';
private static final String PROCESS_End ='Process:End';
private static final String HTTPR_REQUESTB ='HttpR:RequestB';
private static final String HTTPR_REQUESTE ='HttpR:RequestE';
private static final String HTTPR_REQUESTF_FAILURE ='HttpR:RequestF:Failure:';  
private static final String FIRST_END_POINT_URL = 'eximpWS/rest-services/deleteVersionWorkflow?nbVersion=' + NB_VERSIONS_TOKEEP;
private static final String SECOND_END_POINT_URL = 'eximpWS/rest-services/deleteVersionWorkflow/progress';
private static final String HTTP_POST = 'POST';
private static final String HTTP_GET = 'GET';
private static final String CONTENT_TYPE = 'Content-Type';
private static final String APP_JSON = 'application/json';
private static final String AUTH_STRING = 'Authorization';
private static final String COLON=':';

private static final String STEP0_TRIGGERVERSION_DELETION='Step0:TriggerVersion Deletion';       
    private static Long iStepCurr;
    private static String sVersionLabelDyn;
  /**
    @Author - PROS
    @method name - continuationCalloutReset
    @CreateDate - 29-06-2017
    @Description - This method resets the variable iStepCurr to 0
    @Param - null
    @Version - 1.0
    @reference - NR
    */
    private static void continuationCalloutReset() 
    {
        iStepCurr = 0;
    }     
    
    static {
        continuationCalloutReset();
    }
    /**
    @Author - PROS
    @method name - continuationCallout
    @CreateDate - 29-06-2017
    @Description - This method will send the http callouts to CPQ system from SFDC to delete versions.
    @Param - HttpResoonse res
    @Version - 1.0
    @reference - NR
    */
    @testVisible
    private static HttpRequest continuationCallout(HttpResponse res) 
    {     
        
        HttpRequest req = null;
        
        while(true) {
            if(iStepCurr == 0) {
                SmartCPQProductSync_Globals.info(CPQ_VERSION_DELETE , STEP0_TRIGGERVERSION_DELETION); 
                iStepCurr = 1;
                req = new HttpRequest();          
                req.setEndpoint(SmartCPQProductSync_Globals.url +FIRST_END_POINT_URL);
                req.setMethod(HTTP_POST);
                req.setHeader(CONTENT_TYPE, APP_JSON);
                req.setHeader(AUTH_STRING, SmartCPQProductSync_Globals.authToken);
            } else if(iStepCurr == 1) {
                
                req = new HttpRequest();
                req.setEndpoint(SmartCPQProductSync_Globals.url + SECOND_END_POINT_URL);                     
                req.setHeader(AUTH_STRING, SmartCPQProductSync_Globals.authToken);
                req.setMethod(HTTP_GET);   
                
            }
            break;          
        }
        
        return req;
    }
    /**
    @Author - PROS
    @method name - runWait
    @CreateDate - 29-06-2017
    @Description - This method is furure method which will control the call outs from SFDC to CPQ.
    @Param - jobSpecContext
    @Version - 1.0
    @reference - NR
    */ 
    @future (callout=true)
    public static void runWait(String jobSpecContext) {
        runWaitp(jobSpecContext);
    }
    /**
    @Author - PROS
    @method name - runWaitp
    @CreateDate - 29-06-2017
    @Description - This method is used to call the ContinuationCallout method which deletes the version and this is been called in runwait method.
    @Param - jobSpecContext
    @Version - 1.0
    @reference - runWait
    */     
    public static void runWaitp(String jobSpecContext) 
    {
        iStepCurr = 1;    
        Http http = new Http();
        HttpRequest req = continuationCallout(null);
        HttpResponse res = null; 
           
        try {
            SmartCPQProductSync_Globals.info(CPQ_VERSION_DELETE, HTTPR_REQUESTB_RUNWAIT ); 
            req.setCompressed(true);
            res = http.send(req);
            System.debug('-----res----'+res);
            System.debug('-----res body----'+res.getBody());
            SmartCPQProductSync_Globals.info(CPQ_VERSION_DELETE, HTTPR_REQUESTE_RUNWAIT ); 
        } catch(System.CalloutException e) {
            SmartCPQProductSync_Globals.error(CPQ_VERSION_DELETE, HTTPR_REQUESTF_RUNWAIT_FAILURE + e + COLON + res.toString()); 
        }        
        SmartCPQProductSync_JobSpec.signalFinished(jobSpecContext, res);
    }  
    
    /**
    @Author - PROS
    @method name - deleteVersion
    @CreateDate - 29-06-2017
    @Description - 
    @Param - null
    @Version - 1.0
    @reference - NR
    */
    @future (callout=true)
    public static void deleteVersion(String jobSpecContext) {
        deleteVersionp(jobSpecContext);
    }
    /**
    @Author - PROS
    @method name - deleteVersionp
    @CreateDate - 29-06-2017
    @Description - This method will delete versions in CPQ system.
    @Param -String jobSpecContext
    @Version - 1.0
    @reference - NR
    */
    public static void deleteVersionp(String jobSpecContext)   
    {
        
        sVersionLabelDyn = SmartCPQProductSync_JobSpec.getVersionLabelDyn(jobSpecContext);    
        SmartCPQProductSync_Globals.info(CPQ_VERSION_DELETE, PROCESS_BEG);      
        Http http = new Http();
        HttpRequest req = null;
        HttpResponse res = null;   
        
        iStepCurr = 0;  
        while((req = continuationCallout(res)) != null) {
            try {
                SmartCPQProductSync_Globals.info(CPQ_VERSION_DELETE, HTTPR_REQUESTB); 
                req.setCompressed(true);
                res = http.send(req);
                System.debug('-----res----'+res);
                System.debug('---res body----'+res.getBody());
                SmartCPQProductSync_Globals.info(CPQ_VERSION_DELETE, HTTPR_REQUESTE); 
            } catch(System.CalloutException e) {
                SmartCPQProductSync_Globals.error(CPQ_VERSION_DELETE, HTTPR_REQUESTF_FAILURE  + e + COLON + res.toString()); 
                break;
            }     
            break;      
        }
        SmartCPQProductSync_Globals.info(CPQ_VERSION_DELETE, PROCESS_End); 
        continuationCalloutReset();
        
        SmartCPQProductSync_JobSpec.signalFinished(jobSpecContext);
        
        //return 0;    
    }
}