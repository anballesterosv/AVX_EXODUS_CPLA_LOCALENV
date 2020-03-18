/**
@Author - PROS Accenture
@Name -SmartCPQProductSync_VersionGenerator  
@CreateDate - 12-14-2017
@Description - This Apex class will generate version and creates it in CPQ system.
@Version - 1.0
@reference - N/A
**/
public with sharing class SmartCPQProductSync_VersionGenerator {
    
    private static Long iStepCurr;
    private static String sVersionLabelDyn;
    private static final String CPQVERSION='CPQVersion';
    private static final String COLON=':';
    private static final String FIRST_END_POINT_URL = 'eximpWS/rest-services/versioning/';
    private static final String SECOND_END_POINT_URL = 'eximpWS/rest-services/versioning/progress';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String APP_JSON = 'application/json';
    private static final String AUTH_STRING = 'Authorization';
    private static final String HTTP_PUT = 'PUT';
    private static final String HTTP_GET = 'GET';
    private static final String DESCRIPTION_VERSION1=', "description": "version 1 description" }';
    private static final string STEP0_TRIGGER_VERSION_GENERATION= 'Step0:TriggerVersionGeneration';
    private static final String HTTPR_REQUESTB_RUNWAIT='HttpR:RequestB:runWait';
    private static final String HTTPR_REQUESTE_RUNWAIT='HttpR:RequestE:runWait';
    private static final String HTTPR_REQUESTF_RUNWAIT_FAILURE='HttpR:RequestF:runWait:Failure:';
   
    private static final String HTTPR_REQUESTB='HttpR:RequestB';
    private static final String HTTPR_REQUESTE='HttpR:RequestE';
    private static final String HTTPR_REQUESTF_FAILURE='HttpR:RequestF:Failure:';
    private static final String PROCESS_BEG= 'Process:Beg';
    private static final String PROCESS_END='Process:End'; 
    private static final String OPENBRACKET = '{';
    private static final String SPACESTRING = '';
    private static final String DOUBLEQUOTESTRING = '"';
    private static final String DATESTRING = 'date';

   
    /******************************
    @Author - PROS
    @Name - continuationCalloutReset
    @CreateDate - 12-14-2017
    @Description - 
    @Version - 1.0
    ******************************/ 
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
    @CreateDate - 12-14-2017
    @Description - This method will send the http callouts to CPQ system from SFDC to generate versions.
    @Param - HttpResoonse res
    @Version - 1.0
    @reference - NR
    */ 
    @testVisible
    private static HttpRequest continuationCallout(HttpResponse res) 
    {     

        
        HttpRequest req = null;
        String requestBody = null;
        
        while(true) {
            if(iStepCurr == 0) {
                SmartCPQProductSync_Globals.info(CPQVERSION, STEP0_TRIGGER_VERSION_GENERATION); 
                iStepCurr = 1;
                req = new HttpRequest();          
                req.setEndpoint(SmartCPQProductSync_Globals.url + FIRST_END_POINT_URL + sVersionLabelDyn);
                req.setMethod(HTTP_PUT);
                req.setHeader(CONTENT_TYPE, APP_JSON);
                req.setHeader(AUTH_STRING, SmartCPQProductSync_Globals.authToken);
                requestBody = OPENBRACKET+SPACESTRING+DOUBLEQUOTESTRING+DATESTRING+DOUBLEQUOTESTRING+SPACESTRING+COLON + System.currentTimeMillis() + DESCRIPTION_VERSION1;
                req.setBody(requestBody);
                
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
    @Author - IDC Accenture
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
    @Author - IDC Accenture
    @method name - runWaitp
    @CreateDate - 29-06-2017
    @Description - This method is used to call the ContinuationCallout method which sends requst to CPQ system and this is been called in runwait method.
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
            SmartCPQProductSync_Globals.info(CPQVERSION, HTTPR_REQUESTB_RUNWAIT); 
            req.setCompressed(true);
            res = http.send(req);
            System.debug('----res----'+res);
            System.debug('----res Body-----'+res.getBody());
            SmartCPQProductSync_Globals.info(CPQVERSION, HTTPR_REQUESTE_RUNWAIT); 
        } catch(System.CalloutException e) {
            SmartCPQProductSync_Globals.error(CPQVERSION, HTTPR_REQUESTF_RUNWAIT_FAILURE + e + COLON + res.toString()); 
        } 
        SmartCPQProductSync_JobSpec.signalFinished(jobSpecContext, res);
    }  
    
    /**
    @Author - IDC Accenture
    @method name - generateVersion
    @CreateDate - 29-06-2017
    @Description - This method is furure method which will control the callouts from SFDC to CPQ and generate version.
    @Param -String jobSpecContext
    @Version - 1.0
    @reference - NR
    */
    @future (callout=true)
    public static void generateVersion(String jobSpecContext) {
        generateVersionp(jobSpecContext);
    }
    /**
    @Author - IDC Accenture
    @method name - generateVersionp
    @CreateDate - 29-06-2017
    @Description - This method will generate versions and creates in CPQ system.
    @Param -String jobSpecContext
    @Version - 1.0
    @reference - NR 
    */
    public static void generateVersionp(String jobSpecContext){
        sVersionLabelDyn = SmartCPQProductSync_JobSpec.getVersionLabelDyn(jobSpecContext);    
        SmartCPQProductSync_Globals.info(CPQVERSION, PROCESS_BEG);      
        Http http = new Http();
        HttpRequest req = null;
        HttpResponse res = null;   
        iStepCurr = 0;  
        while((req = continuationCallout(res)) != null) {
            try {
                SmartCPQProductSync_Globals.info(CPQVERSION, HTTPR_REQUESTB); 
                req.setCompressed(true);
                res = http.send(req);
                System.debug('-----res----'+res);
                System.debug('-----res body----'+res.getBody());
                SmartCPQProductSync_Globals.info(CPQVERSION, HTTPR_REQUESTE); 
            } catch(System.CalloutException e) {
                SmartCPQProductSync_Globals.error(CPQVERSION, HTTPR_REQUESTF_FAILURE + e + COLON + res.toString()); 
                break;
            }     
            break;      
        }
        SmartCPQProductSync_Globals.info(CPQVERSION, PROCESS_END); 
        continuationCalloutReset();
        SmartCPQProductSync_JobSpec.signalFinished(jobSpecContext);
    }
}