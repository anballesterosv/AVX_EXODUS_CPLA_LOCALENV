/**
@Author - PROS
@Name - SmartCPQProductSync_Globals 
@CreateDate - 29-06-2017
@Description - This is Globals class which is used to declare the variables in it.
@Version - 1.0
@reference - N/A 
*/
global class SmartCPQProductSync_Globals{
    public static final String sWorkspace = 'wksCargill';
    public static final String versionLabelWorking = 'Working version'; 
    public static final String sDateFormat = 'yyyyMMddhhmmss';     
   
    public static final String url = 'https://pr006901.proscloud.com/';
    //public static final String user = 'catalogLoader';
    public static final String user = UserInfo.getOrganizationId().substring(0,15);
    //public static final String password = 'cl123';
    public static final String password = CameleonCPQ__CAMCPQSettings__c.getInstance().CameleonCPQ__CPQSession_AuthPwd__c;
    public static final String authToken = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(user + ':'+ password)); 
    public static final String defaultString = 'Default';

    public static final String PUTMethod = 'PUT';
    public static final String GETMethod = 'GET';
    public static final String POSTMethod = 'POST';
    public static final String OKStatus = 'OK';
    public static final String READYStatus = 'READY';
  
    /**
    @Author - PROS
    @Name - info
    @CreateDate - 29-06-2017
    @Description - 
    @Version - 1.0
    @reference - N/A 
    */
    public static void info(String sClass, String s) { System.debug(sClass + ':INF:' + System.Now().format(sDateFormat) + ':' + s); }
       
    /**
    @Author - PROS
    @Name - warn
    @CreateDate - 29-06-2017
    @Description - 
    @Version - 1.0
    @reference - N/A 
    */
    public static void warn(String sClass, String s) { System.debug(sClass + ':WRN:' + System.Now().format(sDateFormat) + ':' + s); }
      
    /**
    @Author - PROS
    @Name - error
    @CreateDate - 29-06-2017
    @Description - 
    @Version - 1.0
    @reference - N/A 
    */
     public static void error(String sClass, String s) { System.debug(sClass + ':ERR:' + System.Now().format(sDateFormat) + ':' + s); }
    /**
    @Author - PROS
    @Name - errorLogs
    @CreateDate - 29-06-2017
    @Description - 
    @Version - 1.0
    @reference - N/A 
    */ 
    public static void errorLogs(String sClass,String methodName, Exception errMsg) {  
        System.debug('CLASS NAME : '+sClass + ' : METHOD NAME : ' + methodName +':ERR:' + System.Now().format(sDateFormat) + ':' + errMsg);  
    } 
    
    
    public static Boolean isNumeric(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }

}