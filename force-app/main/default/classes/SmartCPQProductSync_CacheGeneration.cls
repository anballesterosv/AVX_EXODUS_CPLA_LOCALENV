/**
@Author - PROS
@Name - SmartCPQProductSync_CacheGeneration
@CreateDate -12-14-2017
@Description - This Apex class will generate the Cache files in CPQ whenever version is created in CPQ system.
@Version - 1.0
@reference - N/A
**/
public class SmartCPQProductSync_CacheGeneration {

    private static Long iStepCurr;
    private static String sVersionLabelDyn;
    private static final String COLON=':';
    private static final String CPQCACHE='CPQCache';
    private static final String HTTPR_REQUESTB='HttpR:RequestB';
    private static final String HTTPR_REQUESTE='HttpR:RequestE';
    private static final String HTTPR_REQUESTF_FAILURE='HttpR:RequestF:Failure:';
    private static final String PROCESS_END='Process:End';
    private static final String PROCESS_BEG='Process:Beg';
    private static final String FIRST_END_POINT_URL = 'eximpWS/rest-services/serialization/versions/';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String APP_JSON = 'application/json';
    private static final String AUTH_STRING = 'Authorization';
    private static final String HTTP_PUT = 'PUT';
    private static final String STEP0_TRIGGER_CACHE_GENERATION='Step0:TriggerCacheGeneration';
 /**
@Author - PROS
@Name - continuationCalloutReset
@CreateDate - 12-14-2017
@Description - 
@Version - 1.0
@reference - N/A
**/   
  private static void continuationCalloutReset(){
        iStepCurr = 0;
    }     
    static{
        continuationCalloutReset();
    }
    
    /**
    @Author - PROS
    @method name - continuationCallout
    @CreateDate - 12-14-2017
    @Description - This method will send the http callouts to CPQ system from SFDC.
    @Param - HttpResoonse res
    @Version - 1.0
    @reference - NR
    **/ 
    @testVisible
    private static HttpRequest continuationCallout(HttpResponse res){
        HttpRequest req = null;
        String requestBody = null;  
        while(true) {
            if(iStepCurr == 0) {
                SmartCPQProductSync_Globals.info(CPQCACHE, STEP0_TRIGGER_CACHE_GENERATION); 
                iStepCurr = 1;
                req = new HttpRequest();          
                req.setEndpoint(SmartCPQProductSync_Globals.url + FIRST_END_POINT_URL + sVersionLabelDyn);
                req.setMethod(HTTP_PUT);
                req.setHeader(CONTENT_TYPE, APP_JSON);
                req.setHeader(AUTH_STRING, SmartCPQProductSync_Globals.authToken);
            }
            break;            
        }
        return req;
    }
    
    /**
    @Author - PROS
    @method name - generateCache
    @CreateDate - 12-14-2017
    @Description - This method is furure method which will control the callouts from SFDC to CPQ and generate Cache in CPQ system.
    @Param -String jobSpecContext
    @Version - 1.0
    @reference - NR 
    */
     @future (callout=true)
    public static void generateCache(String jobSpecContext) 
    {   
        sVersionLabelDyn = SmartCPQProductSync_JobSpec.getVersionLabelDyn(jobSpecContext); 
        SmartCPQProductSync_Globals.info(CPQCACHE, PROCESS_BEG);      
        Http http = new Http();
        HttpRequest req = null;
        HttpResponse res = null;   
        iStepCurr = 0;  
        while((req = continuationCallout(res)) != null) {
            try {
                SmartCPQProductSync_Globals.info(CPQCACHE, HTTPR_REQUESTB); 
                req.setCompressed(true);
                res = http.send(req);
                System.debug('-----res----'+res);
                System.debug('-----res body----'+res.getBody());
                SmartCPQProductSync_Globals.info(CPQCACHE, HTTPR_REQUESTE); 
            } catch(System.CalloutException e) {
                SmartCPQProductSync_Globals.error(CPQCACHE, HTTPR_REQUESTF_FAILURE + e + COLON + res.toString()); 
                break;
            }        
        }
        SmartCPQProductSync_Globals.info(CPQCACHE, PROCESS_END); 
        continuationCalloutReset();
        SmartCPQProductSync_JobSpec.signalFinished(jobSpecContext);
        //return 0;    
    }
}