/***************************************************
@Author - PROS (RDE)
@Name - SmartCPQProductSync_JobSpec 
@CreateDate - 27-06-2017 
@Description - This class is used to call the CatalogIntegration, CatalogVersion, CatalogDelete, CatalogCaching classes to send request to CPQ as per the requirements.
@Version - 1.0
@reference - SmartCPQProductSync_CatalogScheduler
****************************************************/
global class SmartCPQProductSync_JobSpec     {
    
    static final Integer EJSNOTSTARTED= 0;
    static final Integer EJSLOADING= 1;
    static final Integer EJSLOADWAITING= 2;
    static final Integer EJSVERSIONING= 3;
    static final Integer EJSVERSIONWAITING= 4;
    static final Integer EJSCACHING= 5;
    static final Integer EJSCOMPLETE= 6;
    static final Integer EJSDELETE= 7;
    static final Integer EJSDELETEWAITING= 8;
    
    //Used to keep track off the already processed products and their Active statuses, used to take care of duplicates
    String sLastProcessedProduct = null;
    String sProductCode_Beg = null;
    String sProductCode_End = null;
    String sVersionLabelDyn = null;
    Integer current = EJSNOTSTARTED;  
    Integer offsetCount;
    static integer staticOffsetCount = -1;
    
    static Map<String,String[]> mapNextLoad = new Map<String,String[]>();
    
    static final String sBeg_ProductCode_Beg;
    static final String sBeg_ProductCode_End;
    private static final String DEFAULT_STRING = 'Default';
    private static final String NULL_STRING = 'null';
    private static final String SUCCESS='SUCCESS';
    private static final String CPQCATALOGJOBSPEC='CPQCatalogJobSpec';
    private static final String STEP5_FAILURE1='Step5:Failure1:';
    private static final String STEP4_FAILURE1='Step4:Failure1:';
    private static final String STEP5_FAILURE2='Step5:Failure2:';
    private static final String STEP5_FAILED='Step5:Import Failed:';
    private static final String CPQVERSIONDELETE='CPQVersionDelete';
    private static final String STEP1_FAILURE1='Step1:Failure1:';
    private static final String STEP2_FAILURE2='Step2:Failure2:';
    private static final String STEP3_CONTINUE='Step3:Continue:';
    private static final String STEP4_COMPLETE='Step4:Complete:';
    private static final String STEP4_FAILURE2='Step4:Failure2:';
    private static final String STEP5_IMPORT_CANCELLED='Step5:Import Cancelled:';
    private static final String STEP5_IMPORT_SUCCEEDED='Step5:Import Succeeded:';
    private static final String STEP4_VERSIONCREATION_FAILED='Step4:Version Creation Failed:';
    private static final String STEP4_VERSIONCREATION_SUCCEDDED='Step4:Version Creation Succedded:';
    private static final String VERSIONING='Versioning';
    private static final String ERROR='ERROR';
    private static final String IMPORTING='Importing';
    private static final String CPQVERSION='CPQVersion';
    
    private static final String STATUS_OK = 'OK';
    private static final String BODY_SUCCEEDED = 'SUCCEEDED';
    private static final String BODY_FAILED = 'FAILED';
    private static final String BODY_CANCELED = 'CANCELED';
    private static final String BODY_DATABASE = 'DATABASE';
    private static final String BODY_WARNING ='WARNING';
    private static final string COLON=':';
    private static final string SPACESTRING=' '; 
    private static final string EMPTYTRING=''; 
    private static final string QUESTIONMARK=' ? ';
    private static final string CPQ_CATALOG_SCHEDULAR='CPQ Catalog Scheduler ';
    private static final string START_BRACKET='[';
    private static final string CLOSE_BEGINNING='] Beg';
    private static final string CLOSE_CNT='] Cnt';
    private static final string VERSION='Version ';
    private static final string SEMICOLON=';';
    private static final string BEGINNING=' Beg';
    private static final string CNT=' Cnt';
    private static final string PRODUCT_CODE_BEG='';
    private static final string PRODUCT_CODE_END= '';
    private static final string PRODUCTCODE_111001='111001';
    private static final string PRODUCTCODE_115000='115000';
    private static final string PRODUCTCODE_115001='115001';
    private static final string PRODUCTCODE_120000='120000';
    private static final string PRODUCTCODE_120001='120001';
    private static final string PRODUCTCODE_999999='999999';
    private static final string S0000='S0000';
    private static final string S9999='S9999';
    private static final string CACHE_BEG='Cache Beg';
    private static final string DELETE_VERSION='Delete Version';
    private static final string DELETE_VERSION_SUCCESSFULLY='Deleted Version- Successfully';
    private static final string SALESFORCE_CPQ_INTEGRATION_JOB_STATUS='Salesforce - CPQ Integration Job Status';
    private static final string SALESFORCE_TO_CPQ='Salesforce to CPQ Integration job completed successfully';
    private static final string COMPLETED_UNSUCCESFULLY='Salesforce to CPQ Integration job completed unsuccessfully. Occured error during ';
    static {
        sBeg_ProductCode_Beg = PRODUCT_CODE_BEG;
        sBeg_ProductCode_End = PRODUCT_CODE_END;
    }
     /********************************
    @Author - PROS
    @method name - thiss
    @CreateDate - 12-06-2017
    @Description - 
    @Version - 1.0
    **********************************/
    @testVisible
    private static SmartCPQProductSync_JobSpec thiss(String jsonObject) {
        return (SmartCPQProductSync_JobSpec) JSON.deserialize(jsonObject, SmartCPQProductSync_JobSpec.class);
    }
     /********************************
    @Author - PROS
    @method name - getProductCodeBeg
    @CreateDate - 12-06-2017
    @Description - 
    @Version - 1.0
    **********************************/
    public static String getProductCodeBeg(String jsonObject)
    {
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        return thi_s.sProductCode_Beg;
    }
    
    /********************************
    @Author - PROS
    @method name - getProcessedProducts
    @CreateDate - 03-13-2018
    @Description - 
    @Version - 1.0
    **********************************/
    public static String getLastProcessedProduct(String jsonObject)
    {
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        return thi_s.sLastProcessedProduct;
    }    
    
     /********************************
    @Author - PROS
    @method name - setProductCodeBeg
    @CreateDate - 12-06-2017
    @Description - 
    @Version - 1.0
    **********************************/
    public static void setProductCodeBeg(String jsonObject, String productCodeBeg)
    {
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        thi_s.sProductCode_Beg = productCodeBeg;
    }
   
    /********************************
    @Author - PROS
    @method name - setProductCodeEnd
    @CreateDate - 12-06-2017
    @Description - 
    @Version - 1.0
    **********************************/
    public static void setProductCodeEnd(String jsonObject, String productCodeEnd)
    {
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        thi_s.sProductCode_End = productCodeEnd;
    }   
      /********************************
    @Author - PROS
    @method name - getProductCodeEnd
    @CreateDate - 12-06-2017
    @Description - 
    @Version - 1.0
    **********************************/
    public static String getProductCodeEnd(String jsonObject)
    {
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        return thi_s.sProductCode_End;
    }
     /********************************
    @Author - 12
    @method name - getVersionLabelDyn
    @CreateDate - 12-06-2017
    @Description - 
    @Version - 1.0
    **********************************/
    public static String getVersionLabelDyn(String jsonObject)
    {
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        if (thi_s.sVersionLabelDyn!=null) {
            return thi_s.sVersionLabelDyn.replace(' ', '');
        } else {
        	return thi_s.sVersionLabelDyn;
        }
    }
    /**
    @Author - PROS
    @method name - getOffsetCount
    @CreateDate - 12-06-2017
    @Description - This method is used to send records in differenct set of xml's.
    @Param -String jobSpecContext
    @Version - 1.0
    @reference - NR
    */
    public static Integer getOffsetCount(String jsonObject){
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        thi_s.offsetCount = staticOffsetCount +1;
        staticOffsetCount = thi_s.offsetCount;
        
        return thi_s.offsetCount;
    }
    /**
    @Author - PROS
    @method name - run
    @CreateDate - 12-06-2017
    @Description - This method will call the below classes
    @               1. CPQ002_CatalogIntegration
    @               2. CPQ003_VersionGenerator
    @               3. CPQ004_CacheGeneration
    @               4. CPQ005_VersionDelete
    @Param - String jsonObject
    @Version - 1.0
    @reference -SmartCPQProductSync_CatalogScheduler
    */ 
    public static void run(String jsonObject )
    {       
        // Called from SmartCPQProductSync_CatalogScheduler
        if(jsonObject == null) {
            System.debug('----First Call----'+jsonObject);
            // First call
            SmartCPQProductSync_JobSpec thi_s = new SmartCPQProductSync_JobSpec();
            thi_s.sVersionLabelDyn = VERSION + 
            System.currentTimeMillis();
            thi_s.current = EJSLOADING;
            thi_s.sProductCode_Beg = sBeg_ProductCode_Beg;
            thi_s.sProductCode_End = sBeg_ProductCode_End;
           	thi_s.sLastProcessedProduct = '';
            SmartCPQProductSync_CatalogIntegration.restUploadCatalog(JSON.serialize(thi_s));
        } else {
            // Subsequent call
            
            SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
            System.debug('----jsonObject--run----'+jsonObject);
            System.debug('------thi_s.current-run----'+thi_s.current);
            if(thi_s.current <= EJSNOTSTARTED) {
                
            }else if(thi_s.current == EJSLOADING) {
                SmartCPQProductSync_CatalogIntegration.restUploadCatalog(JSON.serialize(thi_s));
            }else if(thi_s.current == EJSLOADWAITING) {
                System.debug('---runwait---'+JSON.serialize(thi_s));
               SmartCPQProductSync_CatalogIntegration.runWait(JSON.serialize(thi_s));
            } else if(thi_s.current == EJSVERSIONING) {
                 SmartCPQProductSync_VersionGenerator.generateVersion(JSON.serialize(thi_s));
            } else if(thi_s.current == EJSVERSIONWAITING) {
                System.debug('-----1111-----'+thi_s);
                System.debug('-----2222---JSON----'+JSON.serialize(thi_s));
                SmartCPQProductSync_VersionGenerator.runWait(JSON.serialize(thi_s));
            } else if(thi_s.current == EJSCACHING) {
               SmartCPQProductSync_CacheGeneration.generateCache(JSON.serialize(thi_s));
            }else if(thi_s.current == EJSDELETE){
                System.debug('----3333 JSON D----'+JSON.serialize(thi_s));
               SmartCPQProductSync_VersionDelete.deleteVersion(JSON.serialize(thi_s));
            }else if(thi_s.current == EJSDELETEWAITING){
                System.debug('----4444 JSON V----'+JSON.serialize(thi_s));
               SmartCPQProductSync_VersionDelete.runWait(JSON.serialize(thi_s));
            }
        }
    }
    
    /**
    @Author - IDC Accenture
    @method name - signalFinished
    @CreateDate - 29-06-2017
    @Description - 
    @Version - 1.0
    */
    public static void signalFinished(String jsonObject, HttpResponse resWait) 
    {
        // Called from runWait in CPQCatalogIntegration or CPQVersionGenerator
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        thi_s.next(resWait);
    }
    /**
    @Author - IDC Accenture
    @method name - signalFinished
    @CreateDate - 29-06-2017
    @Description - 
    @Version - 1.0
    */
    public static void signalFinished(String jsonObject) 
    {
        // Called from work routine in CPQCatalogIntegration, CPQVersionGenerator or CPQCacheGeneration
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        thi_s.next(null);
    }  
    
     /**
    @Author - IDC Accenture
    @method name - signalFinished
    @CreateDate - 29-06-2017
    @Description - 
    @Version - 1.0
    */
    public static void signalFinished(String jsonObject, String offsetProduct, String processedProducts) 
    {
        // Called from work routine in CPQCatalogIntegration, CPQVersionGenerator or CPQCacheGeneration
        SmartCPQProductSync_JobSpec thi_s = thiss(jsonObject);
        if(offsetProduct != null){
			thi_s.sProductCode_Beg = thi_s.sProductCode_End;
            thi_s.sProductCode_End = offsetProduct;
            thi_s.sLastProcessedProduct = processedProducts;
        }
        
        thi_s.next(null); 
    }     
    
    
    /****************************************************************************
    @Author - PROS
    @method name - getChronString
    @CreateDate - 29-06-2017
    @Description - This method is used to sent time to hit the server(chronstring).
    @Param -waitSeconds
    @Version - 1.0
    @reference - NR
    *****************************************************************************/
    @testVisible 
    private static String getChronString(Integer waitSeconds)
    {
        DateTime now  = DateTime.now();    
        DateTime nextRunTime = now.addSeconds(waitSeconds);
        return EMPTYTRING + nextRunTime.second() + SPACESTRING + nextRunTime.minute() + 
        SPACESTRING + nextRunTime.hour() + SPACESTRING + nextRunTime.day() + SPACESTRING + nextRunTime.month() + QUESTIONMARK + nextRunTime.year(); 
    }
   
    /****************************************************************
    @Author - IDC Accenture
    @method name - schedule
    @CreateDate - 29-06-2017
    @Description - This method will schedule the classes in below order to execute.
    @               1. SmartCPQProductSync_CatalogIntegration
    @               2. SmartCPQProductSync_VersionGenerator
    @               3. SmartCPQProductSync_CacheGeneration
    @               4. SmartCPQProductSync_VersionDelete
    @Param - NA
    @Version - 1.0
    @reference -NA
    *****************************************************************/
    @testVisible 
    private void schedule()
    {
        String sScheduleTitle = CPQ_CATALOG_SCHEDULAR + DateTime.now().format() + SPACESTRING;    
        if(this.current <= EJSNOTSTARTED) {
            return;
        } else if(this.current == EJSLOADING) {
            sScheduleTitle += START_BRACKET + this.sProductCode_Beg + SEMICOLON + this.sProductCode_End + CLOSE_BEGINNING;
        } else if(this.current == EJSLOADWAITING) {
            sScheduleTitle += START_BRACKET + this.sProductCode_Beg + SEMICOLON + this.sProductCode_End + CLOSE_CNT;
        } else if(this.current == EJSVERSIONING) {
            sScheduleTitle += VERSION  + this.sVersionLabelDyn + BEGINNING;
        } else if(this.current == EJSVERSIONWAITING) {
            sScheduleTitle += VERSION  + this.sVersionLabelDyn + CNT;
        } else if(this.current == EJSCACHING) {
            sScheduleTitle += CACHE_BEG;
        }else if(this.current == EJSDELETE){
            sScheduleTitle += DELETE_VERSION;
        }else if(this.current == EJSDELETEWAITING){
            sScheduleTitle += DELETE_VERSION_SUCCESSFULLY;
        }
        else { 
            return;
        }   
        System.schedule(sScheduleTitle  + SPACESTRING +
         System.currentTimeMillis(), 
        getChronString(10), new SmartCPQProductSync_CatalogScheduler(JSON.serialize(this))); 
    } 
     
    /**********************************************
    @Author - IDC Accenture
    @method name - Next
    @CreateDate - 29-06-2017
    @Description - This method will check if each class has executed successfully or not, if not then it will stop execution.
    @               1. SmartCPQProductSync_CatalogIntegration
    @               2. SmartCPQProductSync_VersionGenerator
    @               3. SmartCPQProductSync_CacheGeneration
    @               4. SmartCPQProductSync_VersionDelete
    @Param - HttpResponse resWait
    @Version - 1.0
    @reference -NA  
    ***********************************************/
    @testVisible 
    private void next(HttpResponse resWait) 
    {System.debug('-------this.current------'+this.current);
      if(this.current <= EJSNOTSTARTED) {
            return;
        } else if(this.current == EJSLOADING) {
            this.current = EJSLOADWAITING;
            //Wait 30s before querying CPQ again
            //SmartCPQProductSync_JobSpec.sleep(30);
        } else if(this.current == EJSLOADWAITING) {
            
            if(resWait == null) {
                SmartCPQProductSync_Globals.error(CPQCATALOGJOBSPEC, STEP5_FAILURE1+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
                resetCPQResetSetting();        //resetting when we get response as null from CPQ while sending file
                sendEmail(ERROR,IMPORTING);
            } else if(!resWait.getStatus().equals(STATUS_OK)) {
                SmartCPQProductSync_Globals.error(CPQCATALOGJOBSPEC, STEP5_FAILURE2+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
                resetCPQResetSetting();
                sendEmail(ERROR,IMPORTING);
            } else if(resWait.getBody().indexOf(BODY_FAILED) > 0) {
                SmartCPQProductSync_Globals.error(CPQCATALOGJOBSPEC,STEP5_FAILED+ resWait.getStatus() + COLON + resWait.getBody());
          
                this.current = EJSCOMPLETE;
                resetCPQResetSetting();        //resetting even when Import is failed
                sendEmail(ERROR,IMPORTING);
            }else if(resWait.getBody().indexOf(BODY_CANCELED) > 0) {
                SmartCPQProductSync_Globals.error(CPQCATALOGJOBSPEC, STEP5_IMPORT_CANCELLED+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
                resetCPQResetSetting();       //resetting ebven when job is cancelled
                sendEmail(ERROR,IMPORTING);
            }
            else if(resWait.getBody().indexOf(BODY_SUCCEEDED) > 0 || resWait.getBody().indexOf(BODY_WARNING) >0 ){
                
                SmartCPQProductSync_Globals.error(CPQCATALOGJOBSPEC, STEP5_IMPORT_SUCCEEDED+ resWait.getStatus() + COLON + resWait.getBody());
                if(Boolean.Valueof(CPQResetSetting__c.getInstance(DEFAULT_STRING).hasNextRecords__c) == true){
                    this.current = EJSLOADING;
                    CPQResetSetting__c t = CPQResetSetting__c.getInstance(DEFAULT_STRING);
                    t.Count__c = Integer.Valueof(CPQResetSetting__c.getInstance(DEFAULT_STRING).Count__c) + 1;
                    update t;
                }
                else if(Boolean.Valueof(CPQResetSetting__c.getInstance(DEFAULT_STRING).hasNextRecords__c) == false){
 					resetCPQResetSetting();
                    this.current = EJSVERSIONING;    
                }
            }/*else{
                SmartCPQProductSync_Globals.error(CPQCATALOGJOBSPEC, STEP5_FAILED+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
                resetCPQResetSetting();       
                sendEmail(ERROR,IMPORTING);
            }*/
        } else if(this.current == EJSVERSIONING) {
            this.current = EJSVERSIONWAITING;
            resetCPQResetSetting();
            //sendEmail();
        } else if(this.current == EJSVERSIONWAITING) {
            if(resWait == null) {
                SmartCPQProductSync_Globals.error(CPQVERSION, STEP4_FAILURE1+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
                sendEmail(ERROR,VERSIONING); 
            } else if(!resWait.getStatus().equals(STATUS_OK)) {
                SmartCPQProductSync_Globals.error(CPQVERSION, STEP4_FAILURE2+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
            } else if(resWait.getBody().indexOf(BODY_SUCCEEDED) < 0){
                SmartCPQProductSync_Globals.error(CPQVERSION, STEP4_VERSIONCREATION_FAILED+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
                sendEmail(ERROR,VERSIONING);
            } else {
                SmartCPQProductSync_Globals.error(CPQVERSION, STEP4_VERSIONCREATION_SUCCEDDED + resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCACHING;
                
            }      
        } else if(this.current == EJSCACHING) {
            this.current = EJSDELETE;
            resetCPQResetSetting();

        }else if(this.current == EJSDELETE){
            
            this.current = EJSDELETEWAITING;
        }else if(this.current == EJSDELETEWAITING) {
            if(resWait == null) {
            
                SmartCPQProductSync_Globals.error(CPQVERSIONDELETE, STEP1_FAILURE1+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
            } else if(!resWait.getStatus().equals(STATUS_OK)) {
            
                SmartCPQProductSync_Globals.error(CPQVERSIONDELETE, STEP2_FAILURE2+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
            } else if(resWait.getBody().indexOf(BODY_DATABASE) < 0) {
            
                SmartCPQProductSync_Globals.error(CPQVERSIONDELETE, STEP3_CONTINUE+ resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
                sendEmail(SUCCESS,NULL_STRING );
                updateLastUpdateCPQResetSetting();
            } else {
                SmartCPQProductSync_Globals.error(CPQVERSIONDELETE, STEP4_COMPLETE + resWait.getStatus() + COLON + resWait.getBody());
                this.current = EJSCOMPLETE;
                sendEmail(SUCCESS,NULL_STRING );
				updateLastUpdateCPQResetSetting();                
            }  
                  
        }
        
        else { 
            return;  
        }     
        this.schedule();    
    }
    /**
    @Author - PROS
    @method name - sendEmail
    @CreateDate - 29-06-2017
    @Description - 
    @Version - 1.0
    */
    public void sendEmail(String Status , String locn){
        
        /*List<RecipientEmailAddressForCPQ__c> recpEmail = null;
        for(RecipientEmailAddressForCPQ__c mail : recpEmail){
            String mail1 = mail.Email__c;
            if(mail1 != Null){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String[] toAddress = new String[]{mail1};
                email.setSubject(SALESFORCE_CPQ_INTEGRATION_JOB_STATUS);
                if(Status == SUCCESS)
                    email.setPlainTextBody(SALESFORCE_TO_CPQ);
                else
                    email.setPlainTextBody(COMPLETED_UNSUCCESFULLY+locn);
   
                    email.setToAddresses(toAddress);
                    Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
            }
        }*/
    }
    
/**************************************************************************************
   @Author      - PROS
   @name        - resetCPQResetSetting
   @CreateDate  - 29-06-2017
   @Description - 
   @Revision    - 1.0
*****************************************************************************************/ 
     @testVisible 
     private void resetCPQResetSetting(){
        CPQResetSetting__c t;
         if(CPQResetSetting__c.getInstance(DEFAULT_STRING)!=null){
             t = CPQResetSetting__c.getInstance(DEFAULT_STRING);
             t.Count__c = 0;
             t.hasNextRecords__c = NULL_STRING;
             update t;  
         } 
     }    
    


/**************************************************************************************
   @Author      - PROS
   @name        - updateLastUpdateCPQResetSetting
   @CreateDate  - 1-06-2017
   @Description - 
   @Revision    - 1.0
*****************************************************************************************/ 
     @testVisible 
     private void updateLastUpdateCPQResetSetting(){
        CPQResetSetting__c t;
         if(CPQResetSetting__c.getInstance(DEFAULT_STRING)!=null){
             t = CPQResetSetting__c.getInstance(DEFAULT_STRING);
             t.Last_Update__c = Date.today();
             update t;  
         } 
     }      
    


/**************************************************************************************
   @Author      - PROS
   @name        - updateLastUpdateCPQResetSetting
   @CreateDate  - 1-06-2017
   @Description - 
   @Revision    - 1.0
**************************************************************************************** 
public static void sleep(Integer sleepSeconds) {
    Long startTS = System.currentTimeMillis();
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://1.cuzillion.com/bin/resource.cgi?sleep=' + sleepSeconds);
    req.setMethod('GET');
    Http http = new Http();
    HTTPResponse res = http.send(req);
    Long duration = System.currentTimeMillis() - startTS;
    System.debug('Duration: ' + duration + 'ms');
}*/
    
    }