/**
@Author      - PROS
@name        - SmartCPQProductSync_CatalogIntegration
@CreateDate  - 12-11-2017
@Description - This Apex class performs following tasks
@              1.Genarates XML to send data to CPQ.XML includes StandardSalesItem tags, BusinessValue Tags, ProductCollection Tags
@              2.Helps in callouts to CPQ and Versioning
@Revision    - 1.0
*/
public class SmartCPQProductSync_CatalogIntegration {
    private static Product2[] pp;
    private static final String EMPTYSTRING = '';
    private static final String HYPENSTRING = '-';
    private static final String SPACESTRING= ' ';
    private static final String ZEROSTRING= '0';
    private static final String OPENBRACKETSTRING= '[';
    private static final String CLOSEBRACKETSTRING= ']';
    private static final String SPACEBRACKETSTRING= ' ';
    private static final String TRUESTRING= 'true';
    private static final String FALSESTRING= 'false';
    private static final String UNDERSCORESTRING= '_';
    private static final String ALTRNATUOMSTRING = '<value>LB</value>';
    private static final String LBSTRING = 'LB';
    private static final String MTSTRING = 'MT';
    private static final String TIMESTRING = 'T00:00:00Z';
    private static String slotNo;
    private static Long iStepCurr;
    private static String uploadFileName;
    private static Long ppBeg;
    private static Long ppEnd;
    private static Double WaitBegMilliseconds;
    private static Boolean bWaitFirstOtherwiseLast;
    private static Long chunk;
    private static integer offsetIncr = 0;
    private static integer offsetSize;
    private static integer Count = 0;
    
    private static final String BEEFWEBLINK = 'http://domino.meat.cargill.com/prodspec/spechome.nsf';
    
    /*Business Property Sets*/
    private static final String BPS_BB = 'bpsBoxedBeefAttributes';
    private static final String BPS_DELI = 'bpsDeliAttributes';
    private static final String BPS_GB = 'bpsGroundBeefAttributes';
    private static final String BPS_TURKEY = 'bpsTurkeyAttributes';
    private static final String BPS_TRANSLATIONS = 'bpsTranslations';
    
    /*Business Properties*/
    private static final String BP_BB_PRODUCTLINEGROUP = 'bpBBProductLineGroup';
    private static final String BP_BB_MARKETBASECODE = 'bpBBMarketBaseCode';
    private static final String BP_BB_GRADECODE = 'bpBBGradeCode';
    private static final String BP_BB_BRANDNAME = 'bpBBBrandName';
    private static final String BP_BB_PIECEWEIGHT = 'bpBBPieceWeight';
    private static final String BP_BB_CASEWEIGHT = 'bpBBCaseWeight';
    private static final String BP_BB_CATCHWEIGHT = 'bpBBCatchWeight';
    private static final String BP_BB_SPECPAGE = 'bpBBSpecPage';
    private static final String BP_DELI_FRESHFROZEN = 'bpDeliFreshFrozen';
    private static final String BP_DELI_NETCASESIZE = 'bpDeliNetCaseSize';
    private static final String BP_DELI_PUMP = 'bpDeliPump';
    private static final String BP_DELI_BRANDNAME = 'bpDeliBrandName';
    private static final String BP_DELI_SUBGROUP = 'bpDeliSubgroup';
    private static final String BP_DELI_PRODUCTGROUP = 'bpDeliProductGroup';
    private static final String BP_GB_PRODUCTLINEGROUP = 'bpGBProductLineGroup';
    private static final String BP_GB_MARKETBASECODE = 'bpGBMarketBaseCode';
    private static final String BP_GB_GRADECODE = 'bpGBGradeCode';
    private static final String BP_GB_BRANDNAME = 'bpGBBrandName';
    private static final String BP_GB_PIECEWEIGHT = 'bpGBPieceWeight';
    private static final String BP_GB_PACKAGETYPE = 'bpGBPackageType';
    private static final String BP_GB_ATMOSPHERENAME = 'bpGBAtmosphereName';
    private static final String BP_GB_CASEWEIGHT = 'bpGBCaseWeight';
    private static final String BP_GB_CATCHWEIGHT = 'bpGBCatchWeight';
    private static final String BP_GB_SPECPAGE = 'bpGBSpecPage';
    private static final String BP_TURKEY_FRESHFROZEN = 'bpTurkeyFreshFrozen';
    private static final String BP_TURKEY_NETCASESIZE = 'bpTurkeyNetCaseSize';
    private static final String BP_TURKEY_BRANDNAME = 'bpTurkeyBrandName';  
    
    private static final String BP_LEGACYSYSTEM = 'bpLegacySystem';
    
    private static final String BP_FR_PROD_DESCR = 'bpFrenchProductDescription';

    /*LEGACY BUSINESS*/
    private static final String LEGACY_PROTEAN = 'PROTEAN';
    private static final String LEGACY_BB = 'Boxed Beef';
    private static final String LEGACY_GB = 'Ground Beef';
    private static final String LEGACY_LIST_DELI  = 'Deli|Value Added';
    private static final String LEGACY_LIST_TURKEY  = 'Retail FP';
    
    /*Catalog, Collections & CP*/
    private static final String CAT_CARGILL = 'cat_Cargill_Proteins';
    private static final String CAT_UNASSIGNED = 'colUnassigned';
    private static final String  PRODUCTCPNAME = 'cp_Product_Configuration';
    
    /*Eligibility BRC*/
    private static final String BRC_ELIGIBILITY_HIDE_IN_NOF_PPP = 'brcEligibilityHideNOFPPP';
    
    static {
        continuationCalloutReset();
    }
    
    private static final String sHeader_FMT = '<?xml version=\'\'1.0\'\' encoding=\'\'UTF-8\'\'?>\n' + 
        '<!--CAMELEON SOFTWARE - EMODELING EXPORT - Generation Date : 22/05/2017 10:17:37-->\n' + 
        '<export xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">\n' + ' <importExportMetadata workspaceName="' +
        SmartCPQProductSync_Globals.sWorkspace + '">\n' + '     <exportDate>{0}</exportDate>\n' + '     <exportType>FILTER</exportType> \n' + '     <version isWorking="true" versionDate="8099-12-31T23:59:59Z">\n' + '         <fixNumber>0</fixNumber>\n' + '         <versionDescr>' + SmartCPQProductSync_Globals.versionLabelWorking + '</versionDescr> \n' + '         <versionLabel>' + SmartCPQProductSync_Globals.versionLabelWorking + '</versionLabel> \n' + '     </version> \n' + ' </importExportMetadata> \n';
    
    //Start Date,End Date == Null
    private static final String standardSalesItem_Beg_FMT = ' <standardSalesItem workspace="' +
        SmartCPQProductSync_Globals.sWorkspace + '" name="{0}" eligibility="true">\n' + '     <descriptions>\n' +
        '         <description language="en" country="US" variant="">{1}</description>\n' + '     </descriptions>\n' + '     <businessPropertySets> \n' +
        '         <businessPropertySet workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" name="{2}"> \n' + '     <businessProperties> \n';
    
    //Start Date != Null , End Date == Null
    private static final String standardSalesItem_Beg_FMT1 = ' <standardSalesItem workspace="' + 
        SmartCPQProductSync_Globals.sWorkspace + '" name="{0}" eligibility="true" dateBegin="{3}">\n' + '     <descriptions>\n' + 
        '         <description language="en" country="US" variant="">{1}</description>\n' + '     </descriptions>\n' + '     <businessPropertySets> \n' + 
        '         <businessPropertySet workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" name="{2}"> \n' + '     <businessProperties> \n';
    
    //Start Date == Null , End Date != Null
    private static final String standardSalesItem_Beg_FMT2 = ' <standardSalesItem workspace="' + 
        SmartCPQProductSync_Globals.sWorkspace + '" name="{0}" eligibility="true" dateEnd= "{3}">\n' + '     <descriptions>\n' +
        '         <description language="en" country="US" variant="">{1}</description>\n' + '     </descriptions>\n' + '     <businessPropertySets> \n' + 
        '         <businessPropertySet workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" name="{2}"> \n' + '     <businessProperties> \n';
    
    //Start Date, End Date != Null    
    private static final String standardSalesItem_Beg_FMT3 = ' <standardSalesItem workspace="' +
        SmartCPQProductSync_Globals.sWorkspace + '" name="{0}" eligibility="true" dateBegin="{3}" dateEnd="{4}">\n' + 
        '     <descriptions>\n' + '         <description language="en" country="US" variant="">{1}</description>\n' + '     </descriptions>\n' +
        '     <businessPropertySets> \n' + '         <businessPropertySet workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" name="{2}"> \n' + 
        '     <businessProperties> \n';
    
    private static final String standardSalesItem_End_FMT1 = '        </businessProperties>\n' +
        '      </businessPropertySet>\n' + 
        '     <businessPropertySet workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" name="' + BPS_TRANSLATIONS +'"> \n' + 
        '          <businessProperties> \n'+
        '          		<businessProperty name="' + BP_FR_PROD_DESCR + '">\n' + 
        '            		<seqOrder>0</seqOrder>\n' + '            <values>\n' + '              <value>{0}</value>\n' + 
        '            			</values>\n' + '          </businessProperty>\n' +
        '     </businessProperties> \n'+
        '    </businessPropertySet> \n'+        
        '    </businessPropertySets>\n' + '    <links>\n' + '       <link seqOrder="0" quantity ="1" mergeType="UPDATE">\n' +
        '         <child workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" objectType="CP" name="{1}" />\n' +
        '        <parameterIdent parameterType="LinkType" class="ProductLink" workspace="' + SmartCPQProductSync_Globals.sWorkspace + '"  name="computationLink" />\n' +
        '       </link>\n';
    
    private static final String standardSalesItem_End_FMT1a = '        </businessProperties>\n' +
        '      </businessPropertySet>\n' + 
        '     <businessPropertySet workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" name="' + BPS_TRANSLATIONS +'"> \n' + 
        '          <businessProperties> \n'+
        '          		<businessProperty name="' + BP_FR_PROD_DESCR + '">\n' + 
        '            		<seqOrder>0</seqOrder>\n' + '            <values>\n' + '              <value>{0}</value>\n' + 
        '            			</values>\n' + '          </businessProperty>\n' +
        '      </businessProperties> \n'+
        '    </businessPropertySet> \n'+
        ' </businessPropertySets>\n';   
    
    private static final String standardSalesItem_End_FMT1b = '    <links>\n' + '       <link seqOrder="0" quantity ="1" mergeType="UPDATE">\n' +
        '         <child workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" objectType="CP" name="{0}" />\n' +
        '        <parameterIdent parameterType="LinkType" class="ProductLink" workspace="' + SmartCPQProductSync_Globals.sWorkspace + '"  name="computationLink" />\n' +
        '       </link>\n';
    
    private static final String standardSalesItem_End_FMT2 = '    </links>\n' + '    <sparepartsviews />\n' + '    <manufacturingLinks />\n' + '    <routingLinks />\n' +
        '  </standardSalesItem>\n';
    
    private static final String standardSalesItem_noBPS_End_FMT = '        </businessProperties>\n' +
        '      </businessPropertySet>\n' + '    </businessPropertySets>\n' + '    <links>\n' + '       <link seqOrder="0" quantity ="1" mergeType="UPDATE">\n' +
        '         <child workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" objectType="CP" name="{0}" />\n' +
        '        <parameterIdent parameterType="LinkType" class="ProductLink" workspace="' + SmartCPQProductSync_Globals.sWorkspace + '"  name="computationLink" />\n' +
        '       </link>\n' + '    </links>\n' + '    <sparepartsviews />\n' + '    <manufacturingLinks />\n' + '    <routingLinks />\n' +
        '  </standardSalesItem>\n';
    
    private static final String businessPropertySet_FMT = '          <businessProperty name="{0}">\n' + 
        '            <seqOrder>{2}</seqOrder>\n' + '            <values>\n' + '              <value>{1}</value>\n' + 
        '            </values>\n' + '          </businessProperty>\n';
    
    private static final String businessPropertySet_FMT1 = '          <businessProperty name="{0}">\n' +
        '            <seqOrder>{2}</seqOrder>\n' + '            <values>\n{1}' + '            </values>\n' + '          </businessProperty>\n';
    
    private static final String value_FMT = '              <value>{0}</value>\n';
    
    
    private static final String naLinks_Pp_FMT = '    <links>\n' + '       <link seqOrder="0" quanity ="1" mergeType="UPDATE">\n' + 
        '         <child workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" objectType="CP" name="{0}" />\n' +
        '        <parameterIdent parameterType="LinkType" class="ProductLink" workspace="' + SmartCPQProductSync_Globals.sWorkspace + 
        '"  name="configurationLink" />\n' + '       </link>\n' + '    </links>\n';
    
    private static final String naLinks_NA_FMT = '<naLinks />\n';
    
    private static final String plantLink_FMT = '                     <link seqOrder="{0}" quantity ="1" mergeType="UPDATE">\n' +
        '         <child workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" objectType="SI" name="{1}" />\n' +
        '        <parameterIdent parameterType="LinkType" class="ProductLink" workspace="' + SmartCPQProductSync_Globals.sWorkspace + '"  name="plantLink" />\n' +
        '       </link>\n';
    
    private static final String eligibilityBRC_FMT = '         <eligibilityBrc workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" objectType="BRC" name="{0}" />\n';

    private static final String productCollection_FMT = '  <productCollection isRoot="{0}" name="{1}" workspace="' +
        SmartCPQProductSync_Globals.sWorkspace + '" mergeType="UPDATE">\n' + '    <descriptions>\n' + 
        '      <description variant="" language="en" country="US"  mergeType="IGNORE">{2}</description>\n' + 
        '    </descriptions>\n' + '    <businessPropertySets />\n' + '    <links>\n{3}' + '    </links>\n' + 
        '    <collectionLinks>\n{4}' + '    </collectionLinks>\n' + '    <labelLinks />\n' + '    <labels />\n' +
        '{5}' + '    <searchBpss />\n' + '    <teaserLinks />\n' + '  </productCollection>\n';
    
    private static final String collectionLink_FMT = '      <collectionLink seqOrder="{0}"    mergeType="UPDATE" >\n' +
        '        <child workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" objectType="CL" name="{1}" />\n' + '      </collectionLink>\n';
    
    private static final String link_FMT = '      <link xsi:type="productCollectionItem" seqOrder="{0}"   mergeType="UPDATE" >\n' +
        '        <child workspace="' + SmartCPQProductSync_Globals.sWorkspace + '" objectType="SI" name="{1}" />\n' + '        <labels />\n' + '      </link>\n';
    
    private static final String businessValue_FMT = '     <businessValue name="{0}" workspace="' + SmartCPQProductSync_Globals.sWorkspace + '"> \n' +
        '       <descriptions> \n' + '         <description variant="" language="en" country="US">{1}</description> \n' + 
        '       </descriptions> \n' + '     </businessValue> \n';
    
    
    /**
    @Author      - PROS
    @method name - continuationCalloutReset
    @CreateDate  - 12-11-2017
    @Description - Resets the variables after every callout to CPQ
    @Param       - null
    @Version     - 1.0
    @reference   - NR
    */    
    private static void continuationCalloutReset() {
        slotNo = null;
        iStepCurr = 0;
        uploadFileName = null;
        pp = null;
        ppBeg = null;
        ppEnd = null;
        WaitBegMilliseconds = 0;
        bWaitFirstOtherwiseLast = true;
        chunk = 50;
    }
    
    
    
        @future(callout = true)
    public static void restUploadCatalog(String jobSpecContext) {
        String productCodeOffset = null;
        Date lastUpdate = Date.newInstance(2000, 1, 1);        
        String sProductCode_Beg;
        String sProductCode_End;
       	String lastProcessedProducts = SmartCPQProductSync_JobSpec.getLastProcessedProduct(jobSpecContext);
        sProductCode_Beg = SmartCPQProductSync_JobSpec.getProductCodeBeg(jobSpecContext);
        sProductCode_End = SmartCPQProductSync_JobSpec.getProductCodeEnd(jobSpecContext);
        Integer customOffsetLimit = 0;
        if (CPQResetSetting__c.getInstance(SmartCPQProductSync_Globals.defaultString) != null) {
            customOffsetLimit = Integer.valueof(CPQResetSetting__c.getInstance(SmartCPQProductSync_Globals.defaultString).OFFSET_LIMIT__c);
            Count = Integer.valueof(CPQResetSetting__c.getInstance(SmartCPQProductSync_Globals.defaultString).Count__c);
            if (CPQResetSetting__c.getInstance(SmartCPQProductSync_Globals.defaultString).Last_Update__c != null){
                lastUpdate = CPQResetSetting__c.getInstance(SmartCPQProductSync_Globals.defaultString).Last_Update__c;
            }
        }
        offsetSize = Count * customOffsetLimit;
        
        //Get SFDC product check
        //pp = getAllActiveSFDCProducts(customOffsetLimit,offsetSize);
        pp = getAllActiveSFDCProducts(customOffsetLimit,sProductCode_End,lastUpdate);
       	
        //Remove Duplicates
        pp = removeDuplicates(pp,lastProcessedProducts);
        System.debug('Size of Product List : ' + pp.size());
        
        chunk = pp.size();
        SmartCPQProductSync_Globals.info('CPQCatalog', 'Query:End:' + pp.size());
        
        if (pp.size() > 0) {
            //Update Current offset productcode for current chunk
           	productCodeOffset = pp[pp.size()-1].Name;
            
            Http http = new Http();
            HttpRequest req = null;
            HttpResponse res = null;
            ppBeg = 0;
            bWaitFirstOtherwiseLast = true;
            if (bWaitFirstOtherwiseLast) {
                iStepCurr = 3;
                ppEnd = -1;
            } else {
                iStepCurr = 0;
                ppEnd = Math.min(pp.size() - 1, ppBeg + chunk - 1);
            }
            Integer iCallOuts = 0;
            while ((req = continuationCallout(res)) != null) {
                try {
                System.debug('----iCallOuts-----'+iCallOuts );
                    SmartCPQProductSync_Globals.info('CPQCatalog', 'HttpR:RequestB');
         //           if(Test.isRunningTest()==false){
                        req.setCompressed(true);                    
                        res = http.send(req);
                        System.debug('-----res@-----'+res);
                        System.debug('-----res Body----'+res.getBody());
         //           }    
                    //SmartCPQProductSync_Globals.info('CPQCatalog', 'HttpR:RequestE');
                } catch (System.CalloutException e) {
                    SmartCPQProductSync_Globals.error('CPQCatalog', 'HttpR:RequestF:Failure:' + e + ':' + res.toString());
                    break;
                }
                iCallOuts++;
            }
            if (Boolean.Valueof(CPQResetSetting__c.getInstance(SmartCPQProductSync_Globals.defaultString).hasNextRecords__c) != true) {
                CPQResetSetting__c hasNext1 = CPQResetSetting__c.getInstance(SmartCPQProductSync_Globals.defaultString);
                hasNext1.hasNextRecords__c = TRUESTRING;
                update hasNext1;
            }
        } else {
            //custom setting to store values
            if(Test.isRunningTest()==false){
                CPQResetSetting__c hasNext = CPQResetSetting__c.getInstance(SmartCPQProductSync_Globals.defaultString);
                if (hasNext != null && FALSESTRING!= null) {
                    hasNext.hasNextRecords__c = FALSESTRING;
                }
                if (hasNext != null) {
                    update hasNext;
                }
            }
        }
        SmartCPQProductSync_Globals.info('CPQCatalog', 'Process:End');
        continuationCalloutReset();
        SmartCPQProductSync_JobSpec.signalFinished(jobSpecContext,productCodeOffset,lastProcessedProducts);
        
    }
    
   private static List<Product2> getAllActiveSFDCProducts(Integer customOffsetLimit, String offsetProduct, Date lastUpdate){
       List<Product2> pp = [SELECT 	Id, 
                            		Name, 
                            		ProductCode,
                            		IsActive, 
                            		PRODUCT_LINE_GROUP__c,
                            		MARKET_BASE_CODE__c,
                            		GRADE_CODE__c,
                            		BRAND_NAME__c,
                            		PIECE_WEIGHT__c,
                            		NET_CASE_WT_LBS__c,
                            		CATCH_WEIGHT_FLAG__c,
                            		FRESH_FROZEN_TEMP__c,
                            		PUMP__c,
                            		ProductSubGroup__c,
                            		ProductGroup__c,
                            		PACKAGE_TYPE__c,
                            		ATMOSPHERE_NAME__c,
                            		ProductStartDate__c,
                            		ProductEndDate__c,
                            		LEGACY_SYSTEM__c,
                            		LEGACY_BUSINESS__c,
                            		PRODUCT_HIER_3__c,
                            		CPQCollection__c,
                             		SKU_Description__c,
                            		SKU_NO__C,
                            		Product_Id__c,
                            		Description_French__c
              				FROM Product2 
                            WHERE 	/*IsActive = TRUE AND*/
                            	Product_Id__c != null
                            	AND LEGACY_BUSINESS__c != null
                            	AND LastModifiedDate >=: lastUpdate
                            	AND SKU_NO__C >: offsetProduct 
                                AND CPQCollection__c != null
                            ORDER BY SKU_NO__C 
                            LIMIT: customOffsetLimit 
                            //OFFSET: offsetSize
                            ];
        return pp;
    
    
    }

    /**
* Step 1. Create a slot
* Step 2. Load the file to the slot
* Step 3. Launch the import task
* Step 4. Check for status until import is done
*/
    // @testVisible   
    public static HttpRequest continuationCallout(HttpResponse res) {
        final String contentTypeString = 'Content-Type';
        final String applicationJsonString = 'application/json';
        final String stepCurrent_0_EndPntURL = 'eximpWS/rest-services/imports';
        final String stepCurrent_1_EndPntURL = 'eximpWS/rest-services/import/';
        final String fileString = '/file';
        final String stepCurrent_2_EndPntURL = 'eximpWS/rest-services/eximp/imports/';
        final String stepCurrent_3_4_EndPntURL = 'eximpWS/rest-services/eximp/status';
        final String stepCurrent_5_EndPntURL = 'eximpWS/rest-services/eximp/progress';
        final String authorizationString = 'Authorization';
        final String prodCatlogString = 'catalog_';
        final String appOctStreamString = 'application/octet-stream';
        final String contDispString = 'Content-Disposition';
        final String fileNameString = 'filename="';
        final String doubleQuotesString = '"';
        final String xmlString = '.xml';
        final String idString = 'id';
        final String requestBodyString = '{' + '"versionInfo": {' + ' "name": "' + SmartCPQProductSync_Globals.versionLabelWorking + '",' + ' "working": true' + '},' + '"importOption": {' + ' "activateConflictFileGeneration": false,' + ' "createWorkspace": false,' + ' "importType": "IMPORT_OVERRIDE_CHANGES"' + '}' + '}';
        Integer countValue;
        HttpRequest req = null;
        String requestBody = null;
        
        countValue = Integer.Valueof(CPQResetSetting__c.getInstance(SmartCPQProductSync_Globals.defaultString).Count__c);
        
        while (true) {
            if (iStepCurr == 0) {
                System.debug('-------0 Callout------');
                SmartCPQProductSync_Globals.info('CPQCatalog', 'Step0:Initialize');
                iStepCurr = 1;
                req = new HttpRequest();
                req.setEndpoint(SmartCPQProductSync_Globals.url + stepCurrent_0_EndPntURL);
                req.setMethod(SmartCPQProductSync_Globals.POSTMethod);
                req.setHeader(contentTypeString, applicationJsonString);
                req.setHeader(authorizationString, SmartCPQProductSync_Globals.authToken);                
            } else if (iStepCurr == 1) {
                System.debug('-------1 Callout------');
                SmartCPQProductSync_Globals.info('CPQCatalog', 'Step1:Complete:' + res.getStatus() + ':' + res.getBody());
                iStepCurr = 2;
                req = new HttpRequest();
                JSONParser parser = JSON.createParser(res.getBody());
                slotNo = null;
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == idString)) {
                        parser.nextToken();
                        slotNo = parser.getText();
                        break;
                    }
                }
                requestBody = buildProductXML(pp, 0, chunk);
                
                uploadFileName = prodCatlogString  + UNDERSCORESTRING + countValue + UNDERSCORESTRING + system.now().format(SmartCPQProductSync_Globals.sDateFormat) + xmlString;
                SmartCPQProductSync_Globals.info('CPQCatalog', 'Step2:Filename:' + uploadFileName + ':' + ppBeg + ':' + ppEnd + ':' + requestBody.length() + ' bytes');
                
                req = new HttpRequest();
                req.setEndpoint(SmartCPQProductSync_Globals.url + stepCurrent_1_EndPntURL + slotNo + fileString);
                req.setMethod(SmartCPQProductSync_Globals.PUTMethod);
                req.setHeader(authorizationString, SmartCPQProductSync_Globals.authToken);
                req.setHeader(contentTypeString, appOctStreamString);
                req.setHeader(contDispString, fileNameString + uploadFileName + doubleQuotesString);
                req.setBody(requestBody);
            } else if (iStepCurr == 2) {
                System.debug('-------2 Callout------');
                SmartCPQProductSync_Globals.info('CPQCatalog', 'Step2:Complete:' + res.getStatus());
                iStepCurr = 3;
                req = new HttpRequest();
                
                req.setEndpoint(SmartCPQProductSync_Globals.url + stepCurrent_2_EndPntURL + slotNo);
                req.setMethod(SmartCPQProductSync_Globals.PUTMethod);
                req.setHeader(authorizationString, SmartCPQProductSync_Globals.authToken);
                req.setHeader(contentTypeString, applicationJsonString);
                requestBody = requestBodyString;
                req.setBody(requestBody);
            } else if (iStepCurr == 3) {
                System.debug('-------3 Callout------');
                if (res != null) {
                    SmartCPQProductSync_Globals.info('CPQCatalog', 'Step3:Complete:' + res.getStatus());
                    if (bWaitFirstOtherwiseLast) {
                        break;
                    }
                } else {
                    if (bWaitFirstOtherwiseLast) {
                        SmartCPQProductSync_Globals.info('CPQCatalog', 'Step3:WaitBegn');
                    } else {
                        SmartCPQProductSync_Globals.error('CPQCatalog', 'iStepCurr == 3 && res == null && !bWaitFirstOtherwiseLast');
                        break;
                    }
                }
                iStepCurr = 4;
                WaitBegMilliseconds = System.Now().millisecond();
                req = new HttpRequest();
                req.setEndpoint(SmartCPQProductSync_Globals.url + stepCurrent_3_4_EndPntURL);
                req.setHeader(authorizationString, SmartCPQProductSync_Globals.authToken);
                req.setMethod('GET');
                
                
            } else if (iStepCurr == 4) {
                System.debug('-------4 Callout------');
                if (res!=null && !res.getStatus().equals(SmartCPQProductSync_Globals.OKStatus)) {
                    SmartCPQProductSync_Globals.info('CPQCatalog', 'Step4:Failure :' + res.getStatus() + ':' + res.getBody());
                } else if (res!=null && res.getBody().indexOf(SmartCPQProductSync_Globals.READYStatus) >= 0) {
                    if(res!=null)
                        SmartCPQProductSync_Globals.info('CPQCatalog', 'Step4:Complete:' + res.getStatus() + ':' + res.getBody());
                    ppBeg = ppEnd + 1;
                    ppEnd = Math.min(pp.size() - 1, ppBeg + chunk - 1);
                    if (ppBeg < pp.size()) {
                        iStepCurr = 0;
                        continue;
                    }
                } else {
                    if(res!=null)
                        SmartCPQProductSync_Globals.info('CPQCatalog', 'Step4:Continue:' + res.getStatus() + ':' + res.getBody());
                    req = new HttpRequest();
                    req.setEndpoint(SmartCPQProductSync_Globals.url + stepCurrent_3_4_EndPntURL);
                    req.setHeader(authorizationString, SmartCPQProductSync_Globals.authToken);
                    req.setMethod(SmartCPQProductSync_Globals.GETMethod);
                }
                
            } else if (iStepCurr == 5) {
                System.debug('-------5 Callout------');
                req = new HttpRequest();
                req.setEndpoint(SmartCPQProductSync_Globals.url + stepCurrent_5_EndPntURL);
                req.setHeader(authorizationString, SmartCPQProductSync_Globals.authToken);
                req.setMethod(SmartCPQProductSync_Globals.GETMethod);
            }
            break;
        }
        return req;
    }
    
    public static String buildProductXML(Product2[] p, Long iBeg, Long iEnd) {
        final String DATESTRING = 'yyyy-MM-dd';
        final String TSTRING = 'T';
        final String TIMEFORMAT = 'hh:mm:ss';
        final String TIMESTAMP = '.000-06:00';
        final String EXPORTSTRING = '</export>\n';
        
       
        String header = System.String.format(sHeader_FMT, new String[] {
            System.now().format(DATESTRING) + TSTRING + System.now().format(TIMEFORMAT) + TIMESTAMP
                });
        String body_StandardSalesItem;
        String body_ProductCollection;
        if(pp!=null && iBeg!=null && iEnd!=null){
            body_StandardSalesItem = buildStandardSalesItemTags(pp, iBeg, iEnd);
            body_ProductCollection = buildProductCollectionTags(pp, iBeg, iEnd);
        }    
        //Put Collections first to avoid forced objects creation
        return header + body_StandardSalesItem + body_ProductCollection + EXPORTSTRING;  
        //return header + body_ProductCollection + body_StandardSalesItem   + EXPORTSTRING;      
        
    }
    
    /**
    @Author - PROS
    @method name - buildStandardSalesItemTags
    @CreateDate - 12-11-2017
    @Description - Generates StandardSalesItemTags and BusinessValueTags
    @Param - product, iBeg, iEnd, biz
    @Version - 1.0
    @reference - NR
    */
    Public static String buildStandardSalesItemTags(Product2[] product, Long iBeg, Long iEnd) {
        List < String > result = new List < String > ();
        Integer k; // for tags index
        Long j; //for Sequence
        String[] ss = new String[3];
        String[] stdSIBeg = new String[5];
        String bpsName = null;
       	String currentLegacyBusiness = null;
        String currentProteanType = null;
        String currentName = null;
        String currentDescr = null;
        Boolean isProductActive = false;
        String productId = null;
        Date yesterday = Date.today().addDays(-1);
       
        
        //Get the product/plant realtionship for all products in the list into a Map
        Map<Id,Set<String>> productPlantMap = getProductPlantAssociation(product);
        
        //Looping over Products to create business properties and business values
        for (Integer i = iBeg.intValue(); i < iEnd; i++) {
            j = 0;
            if (product[i] != null && product[i].SKU_NO__C != null) {
                //Checking if current product is active or not
                isProductActive = product[i].isActive;
                productId = product[i].Id;
                
                //Retrieving BPS to implement based on Product's Business
                bpsName = BPS_GB;
                currentLegacyBusiness = String.valueOf(product[i].LEGACY_BUSINESS__c);
                if (currentLegacyBusiness != null){
                    if (currentLegacyBusiness.equalsIgnoreCase(LEGACY_PROTEAN)){
                        currentProteanType =  product[i].PRODUCT_HIER_3__c;
                        if (currentProteanType != null){
                            if (LEGACY_LIST_DELI.containsIgnoreCase(currentProteanType)){
                                //Deli Attributes to implement
                                bpsName = BPS_DELI;
                            }else if (LEGACY_LIST_TURKEY.containsIgnoreCase(currentProteanType)){
                                //Turkey Attributes to implement
                                 bpsName = BPS_TURKEY;
                            }
                        }
                    }else if (currentLegacyBusiness.equalsIgnoreCase(LEGACY_BB)){
                        //Boxed Beef Attributes to implement
                        bpsName = BPS_BB;                    
                    }
                    else if (currentLegacyBusiness.equalsIgnoreCase(LEGACY_GB)){
                        //Ground Beef Attributes to implement
                        bpsName = BPS_GB;
                    }          
                }
                
                k = 0;
                currentName = product[i].SKU_NO__C == null ? EMPTYSTRING : product[i].SKU_NO__C;
                stdSIBeg[k] = currentName;
                k++;
                
                //ss[k] = product[i].Name == null ? EMPTYSTRING : product[i].Name.escapeXML()+ HYPENSTRING +product[i].ProductCode.escapeXML(); k++;
                currentDescr = product[i].SKU_Description__c == null ? EMPTYSTRING : product[i].SKU_Description__c.escapeXML();
                stdSIBeg[k] = OPENBRACKETSTRING +  currentName + CLOSEBRACKETSTRING + SPACEBRACKETSTRING + currentDescr;
                
                k++;
                stdSIBeg[k] = bpsName;
                k++;
                
                /* Udpate 05012018 - RDE - We do not take into account Product Start/End Date but rather the Active Flag*/
                /*if (product[i].ProductStartDate__c == Null && product[i].ProductEndDate__c == Null) {
                    result.add(System.String.format(standardSalesItem_Beg_FMT, stdSIBeg));
                } else if (product[i].ProductStartDate__c != Null && product[i].ProductEndDate__c == Null) {
                    stdSIBeg[k] = String.Valueof(product[i].ProductStartDate__c) + TIMESTRING;
                    k++;
                    result.add(System.String.format(standardSalesItem_Beg_FMT1, stdSIBeg));
                } else if (product[i].ProductStartDate__c == Null && product[i].ProductEndDate__c != Null) {
                    stdSIBeg[k] = String.Valueof(product[i].ProductEndDate__c) + TIMESTRING;
                    k++;
                    result.add(System.String.format(standardSalesItem_Beg_FMT2, stdSIBeg));
                } else {
                    stdSIBeg[k] = String.Valueof(product[i].ProductStartDate__c) + TIMESTRING;
                    k++;
                    stdSIBeg[k] = String.Valueof(product[i].ProductEndDate__c) + TIMESTRING;
                    k++;
                    result.add(System.String.format(standardSalesItem_Beg_FMT3, stdSIBeg));
                }*/
                if(isProductActive){
                    result.add(System.String.format(standardSalesItem_Beg_FMT, stdSIBeg));
                }else{
                    //If Product is active, Set up its end date at yesterday
                    stdSIBeg[k] = String.Valueof(yesterday) + TIMESTRING;
                    k++;
                    result.add(System.String.format(standardSalesItem_Beg_FMT2, stdSIBeg));
                }

				/* END - Udpate 05012018 - RDE - We do not take into account Product Start/End Date but rather the Active Flag*/
                if (bpsName != null && isProductActive){
                    if (bpsName.equalsIgnoreCase(BPS_BB)) {
                        /***Boxed Beef Attributes***/
                        //Product Line Group
                        k = 0;
                        ss[k] = BP_BB_PRODUCTLINEGROUP;
                        k++;
                        ss[k] = product[i].PRODUCT_LINE_GROUP__c == null ? EMPTYSTRING : product[i].PRODUCT_LINE_GROUP__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Market Base Code
                        k = 0;
                        ss[k] = BP_BB_MARKETBASECODE;
                        k++;
                        ss[k] = product[i].MARKET_BASE_CODE__c == null ? EMPTYSTRING : product[i].MARKET_BASE_CODE__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss)); 
                        
                        //Grade Code
                        k = 0;
                        ss[k] = BP_BB_GRADECODE;
                        k++;
                        ss[k] = product[i].GRADE_CODE__c == null ? EMPTYSTRING : product[i].GRADE_CODE__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Brand Name
                        k = 0;
                        ss[k] = BP_BB_BRANDNAME;
                        k++;
                        ss[k] = product[i].BRAND_NAME__c == null ? EMPTYSTRING : product[i].BRAND_NAME__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Piece Weight
                        k = 0;
                        ss[k] = BP_BB_PIECEWEIGHT;
                        k++;
                        ss[k] = product[i].PIECE_WEIGHT__c == null ? ZEROSTRING : String.valueOf(product[i].PIECE_WEIGHT__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Case Weight
                        k = 0;
                        ss[k] = BP_BB_CASEWEIGHT;
                        k++;
                        ss[k] = product[i].NET_CASE_WT_LBS__c == null ? ZEROSTRING : String.valueOf(product[i].NET_CASE_WT_LBS__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Catch Weight Flag
                        k = 0;
                        ss[k] = BP_BB_CATCHWEIGHT;
                        k++;
                        ss[k] = product[i].CATCH_WEIGHT_FLAG__c == null ? FALSESTRING : String.valueOf(product[i].CATCH_WEIGHT_FLAG__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Spec Page
                        k = 0;
                        ss[k] = BP_BB_SPECPAGE;
                        k++;
                        ss[k] = BEEFWEBLINK.escapeXml();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Legacy System
                        k = 0;
                        ss[k] = BP_LEGACYSYSTEM;
                        k++;
                        ss[k] = product[i].Legacy_System__c == null ? EMPTYSTRING : String.valueOf(product[i].Legacy_System__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                    }else if(bpsName.equalsIgnoreCase(BPS_GB)) {
                        /***Ground Beef Attributes***/
                        //Product Line Group
                        k = 0;
                        ss[k] = BP_GB_PRODUCTLINEGROUP;
                        k++;
                        ss[k] = product[i].PRODUCT_LINE_GROUP__c == null ? EMPTYSTRING : product[i].PRODUCT_LINE_GROUP__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Market Base Code
                        k = 0;
                        ss[k] = BP_GB_MARKETBASECODE;
                        k++;
                        ss[k] = product[i].MARKET_BASE_CODE__c == null ? EMPTYSTRING : product[i].MARKET_BASE_CODE__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss)); 
                        
                        //Grade Code
                        k = 0;
                        ss[k] = BP_GB_GRADECODE;
                        k++;
                        ss[k] = product[i].GRADE_CODE__c == null ? EMPTYSTRING : product[i].GRADE_CODE__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Brand Name
                        k = 0;
                        ss[k] = BP_GB_BRANDNAME;
                        k++;
                        ss[k] = product[i].BRAND_NAME__c == null ? EMPTYSTRING : product[i].BRAND_NAME__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Piece Weight
                        k = 0;
                        ss[k] = BP_GB_PIECEWEIGHT;
                        k++;
                        ss[k] = product[i].PIECE_WEIGHT__c == null ? ZEROSTRING : String.valueOf(product[i].PIECE_WEIGHT__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Package Type
                        k = 0;
                        ss[k] = BP_GB_PACKAGETYPE ;
                        k++;
                        ss[k] = product[i].PACKAGE_TYPE__c == null ? EMPTYSTRING : product[i].PACKAGE_TYPE__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        
                        //Atmosphere Name
                        k = 0;
                        ss[k] = BP_GB_ATMOSPHERENAME;
                        k++;
                        ss[k] = product[i].ATMOSPHERE_NAME__c == null ? EMPTYSTRING : product[i].ATMOSPHERE_NAME__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                         //Case Weight
                        k = 0;
                        ss[k] = BP_GB_CASEWEIGHT;
                        k++;
                        ss[k] = product[i].NET_CASE_WT_LBS__c == null ? ZEROSTRING : String.valueOf(product[i].NET_CASE_WT_LBS__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Catch Weight Flag
                        k = 0;
                        ss[k] = BP_GB_CATCHWEIGHT;
                        k++;
                        ss[k] = product[i].CATCH_WEIGHT_FLAG__c == null ? FALSESTRING : String.valueOf(product[i].CATCH_WEIGHT_FLAG__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Legacy System
                        k = 0;
                        ss[k] = BP_LEGACYSYSTEM;
                        k++;
                        ss[k] = product[i].Legacy_System__c == null ? EMPTYSTRING : String.valueOf(product[i].Legacy_System__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                    }else if(bpsName.equalsIgnoreCase(BPS_DELI)){
                        /***Deli Attributes***/                
                        //Fresh Frozen temp
                        k = 0;
                        ss[k] = BP_DELI_FRESHFROZEN ;
                        k++;
                        ss[k] = product[i].FRESH_FROZEN_TEMP__c == null ? EMPTYSTRING : product[i].FRESH_FROZEN_TEMP__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Net Case Weight
                        k = 0;
                        ss[k] = BP_DELI_NETCASESIZE ;
                        k++;
                        ss[k] = product[i].NET_CASE_WT_LBS__c == null ? EMPTYSTRING : String.valueOf(product[i].NET_CASE_WT_LBS__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));   
                        
                        //Pump
                        k = 0;
                        ss[k] = BP_DELI_PUMP ;
                        k++;
                        ss[k] = product[i].PUMP__c == null ? ZEROSTRING : (!SmartCPQProductSync_Globals.isNumeric(product[i].PUMP__c) ? ZEROSTRING : product[i].PUMP__c.escapeXML());
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Brand Name
                        k = 0;
                        ss[k] = BP_DELI_BRANDNAME;
                        k++;
                        ss[k] = product[i].BRAND_NAME__c == null ? EMPTYSTRING : product[i].BRAND_NAME__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        
                        //Product Sub Group
                        k = 0;
                        ss[k] = BP_DELI_SUBGROUP;
                        k++;
                        ss[k] = product[i].ProductSubGroup__c == null ? EMPTYSTRING : product[i].ProductSubGroup__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        
                        //Product Group
                        k = 0;
                        ss[k] = BP_DELI_PRODUCTGROUP;
                        k++;
                        ss[k] = product[i].ProductGroup__c == null ? EMPTYSTRING : product[i].ProductGroup__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Legacy System
                        k = 0;
                        ss[k] = BP_LEGACYSYSTEM;
                        k++;
                        ss[k] = product[i].Legacy_System__c == null ? EMPTYSTRING : String.valueOf(product[i].Legacy_System__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                    }else if (bpsName.equalsIgnoreCase(BPS_TURKEY)){
                        /***Turkey Attributes***/    
                        //Fresh Frozen temp
                        k = 0;
                        ss[k] = BP_TURKEY_FRESHFROZEN ;
                        k++;
                        ss[k] = product[i].FRESH_FROZEN_TEMP__c == null ? EMPTYSTRING : product[i].FRESH_FROZEN_TEMP__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Net Case Weight
                        k = 0;
                        ss[k] = BP_TURKEY_NETCASESIZE ;
                        k++;
                        ss[k] = product[i].NET_CASE_WT_LBS__c == null ? ZEROSTRING : String.valueOf(product[i].NET_CASE_WT_LBS__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss)); 
                        
                        //Brand Name
                        k = 0;
                        ss[k] = BP_TURKEY_BRANDNAME;
                        k++;
                        ss[k] = product[i].BRAND_NAME__c == null ? EMPTYSTRING : product[i].BRAND_NAME__c.escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                        
                        //Legacy System
                        k = 0;
                        ss[k] = BP_LEGACYSYSTEM;
                        k++;
                        ss[k] = product[i].Legacy_System__c == null ? EMPTYSTRING : String.valueOf(product[i].Legacy_System__c).escapeXML();
                        k++;
                        ss[k] = EMPTYSTRING + (j++);
                        result.add(System.String.format(businessPropertySet_FMT, ss));
                    }
                }

                //Add Eligibility rule fo XLDM products (hidden for NOF/PPP Pricing Type)
                if ((product[i].Legacy_System__c != null) && (product[i].Legacy_System__c.equalsIgnoreCase('XLDM'))){
                    k = 0;
                    if (product[i].Description_French__c != null){
                       ss[k] = product[i].Description_French__c.escapeXML();
                    }else{
                       ss[k] = currentDescr;
                    }
                    result.add(System.String.format(standardSalesItem_End_FMT1a, ss));                   
                    //result.add(standardSalesItem_End_FMT1a);                   
                    
                    k = 0;
                    ss[k] = BRC_ELIGIBILITY_HIDE_IN_NOF_PPP;
                    result.add(System.String.format(eligibilityBRC_FMT, ss));

                    k = 0;
                    ss[k] = PRODUCTCPNAME;                    
                    result.add(System.String.format(standardSalesItem_End_FMT1b, ss));
                    
                    //Add Product/Plant association
                    result.addAll(addPlantAssociation(productId,productPlantMap));
                    
                    //Close Stanadrd item creation tag
					result.add(standardSalesItem_End_FMT2);                    
                }else{
                    //Regular Tag End for current product
                    k = 0;
                    if (product[i].Description_French__c != null){
                       ss[k] = product[i].Description_French__c.escapeXML();
                    }else{
                       ss[k] = currentDescr;
                    }
                    
                    
                    k++;                    
                    ss[k] = PRODUCTCPNAME;
                    result.add(System.String.format(standardSalesItem_End_FMT1, ss));                    
                    
                    //Add Product/Plant association
                    result.addAll(addPlantAssociation(productId,productPlantMap));
                    
                    //Close Stanadrd item creation tag
					result.add(standardSalesItem_End_FMT2);  
                }
            }
            
        }
        return String.join(result, EMPTYSTRING);
       
    }   

        /**
    @Author      - IDC PROS
    @method name - buildProductCollectionTags
    @CreateDate  - 22-05-2017
    @Description - This method generates ProductCollectionTags.
    @Param       - product, iBeg, iEnd
    @Version     - 1.0
    @reference   - NR
    */
    //@testVisible
    public static String buildProductCollectionTags(Product2[] product, Long iBeg, Long iEnd) {
		List < String > result = new List < String > ();
        List<String> siList = new List<String>();
        Set < String > colList = new Set < String > ();
        Map <String , List<String>>  siMap = new Map <String , List<String>> ();
        
        String currentCollection = null;
        String[] fieldList = new String[6];
        
        Integer k;
     	for (Integer i = iBeg.intValue(); i < iEnd; i++) {
            if (product[i] == null || !product[i].isActive || product[i].SKU_NO__C == null) continue;
            
            if (product[i].CPQCollection__c != null){
                currentCollection = product[i].CPQCollection__c;
            /*}else{
                currentCollection  = CAT_UNASSIGNED;
            }*/
            
                if (!colList.contains(currentCollection)){
                    colList.add(currentCollection);
                }
                
                if(siMap.get(currentCollection) == null){
                    siMap.put(currentCollection, new List<String>());                
                }
                siMap.get(currentCollection).add(product[i].SKU_NO__C);
            }
        }
        
        for(String col : colList){
            siList.clear();
            for (String si : siMap.get(col)){
               siList.add(System.String.format(link_FMT, new String[] { EMPTYSTRING + siList.size(), si.escapeXML() }));               
            }
          result.add(System.String.format(productCollection_FMT, new String[] {
                                    FALSESTRING, col, EMPTYSTRING, string.join(siList, EMPTYSTRING), EMPTYSTRING, EMPTYSTRING
                                        }));       
        }
        
        return string.join(result, EMPTYSTRING);
    }
    
    @future(callout = true)
    public static void runWait(String jobSpecContext) {
        bWaitFirstOtherwiseLast = true;
        iStepCurr = 5;
        Http http = new Http();
        HttpRequest req = continuationCallout(null);
        HttpResponse res = null;
        try {
            SmartCPQProductSync_Globals.info('CPQCatalog', 'HttpR:RequestB:runWait');
            //
        //    if(Test.isRunningTest()==false){
                req.setCompressed(true);
                res = http.send(req); 
        //    }
            System.debug('-----response*----'+res);
            System.debug('-----responseBody*----'+res.getBody());
            SmartCPQProductSync_Globals.info('CPQCatalog', 'HttpR:RequestE:runWait');
        } catch (System.CalloutException e) {
            SmartCPQProductSync_Globals.error('CPQCatalog', 'HttpR:RequestF:runWait:Failure:' + e + ':' + res.toString());
        }
    //    if(Test.isRunningTest()==false){
            SmartCPQProductSync_JobSpec.signalFinished(jobSpecContext, res);
    //    }    
    }
    
    private static Product2[] removeDuplicates(Product2[] originalPP, String lastProcessedProducts){
        Product2[] newPPs = new List<Product2>();
        if (lastProcessedProducts == null){
            lastProcessedProducts = '';
        }
        for(Product2 prod : originalPP){
            
            if (lastProcessedProducts.equals(prod.SKU_NO__C)){
                //Duplicate detected; apply process
                //Add if only newProd is active and XLGO Legacy System
                if(prod.isActive && prod.Product_Id__c.containsIgnoreCase('|XLGO')){
                   
                    //Add to new Product List
                    newPPs.add(prod);                        
                }
            }else{
                //Add to processedProd List if Active & XLDN OR XLGO legacy system
                if(prod.isActive && (prod.Product_Id__c.containsIgnoreCase('|XL'))){
                   // add to the last processed product
                    lastProcessedProducts = prod.SKU_NO__C; 
                }
                
                //Add to new Product List
                newPPs.add(prod);
            }
        }
        return newPPs;
    }
    
    private static List<String> addPlantAssociation(Id productId, Map<Id,Set<String>> productPlantMap){
        List < String > result = new List < String > ();
        String[] ss = new String[2];
        Integer seq = 0;
        Integer k =0;
        Set<String> plantList = null;
        if(productPlantMap.get(productId) != null){
            
            plantList = productPlantMap.get(productId);
            
            //Adds all plant before starting process
            k=0;
            ss[k] = String.valueOf(seq);
            k++;
            ss[k]= 'ANYPLANT';
            result.add(System.String.format(plantLink_FMT, ss));
            seq++;       	
            
            for (String plant : plantList){
                k=0;
                ss[k] = String.valueOf(seq);
                k++;
                ss[k]= plant;
                result.add(System.String.format(plantLink_FMT, ss));
                seq++;
            }            
        }

        return result;
    }  
    
    	private static Map<Id,Set<String>> getProductPlantAssociation(Product2[] pp){
			Map<Id,Set<String>> productPlantMap = new Map<Id,Set<String>>();
            Set<Id> productIds = new Set<Id>();
            for(Product2 p : pp){
                productIds.add(p.Id);			
            }
            
            List<ProductPlantAssociation__c> prodPlantList = [SELECT Id,External_Id__c,Plant__r.Location__c,CargillProduct__c,Product_Avail_Delay__c,Status__c FROM ProductPlantAssociation__c WHERE Plant__r.Location_Type__c = 'P' AND  CargillProduct__c IN: productIds AND Plant__r.Location__c != null];
            for (ProductPlantAssociation__c prodPlant : prodPlantList){
                if (productPlantMap.get(prodPlant.CargillProduct__c) == null){
                    productPlantMap.put(prodPlant.CargillProduct__c,new Set<String>());   
                }
                productPlantMap.get(prodPlant.CargillProduct__c).add(prodPlant.Plant__r.Location__c);            
            }
			return productPlantMap;
		
	}
}