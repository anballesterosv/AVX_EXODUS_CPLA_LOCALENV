@isTest
global class SmartCPQProductSync_CatalogScheduler_T {
	static void init(){ 
        Set<Id> prod2Id = new Set<Id>();
        List<Product2> products = new List<Product2>();
        
        CPQResetSetting__c cusSet = new CPQResetSetting__c();
        cusSet.Name = 'Default';
        cusSet.Count__c = 0;
        cusSet.hasNextRecords__c = 'null';
        cusSet.OFFSET_LIMIT__c = 1000;        
        insert cusSet; 
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'Product Test 1';
        newProduct.ProductCode = 'PR-00001';
        newProduct.SKU_NO__c = 'PR-00001';
        newProduct.CPQCollection__c = 'colTest1';
        newProduct.LEGACY_BUSINESS__c = 'Deli';
        newProduct.IsActive = TRUE;
        newProduct.Product_Id__c = 'PR-00001|PROTEAN';
        newProduct.BRAND_NAME__c = 'Wunderbar';
        newProduct.ProductGroup__c = 'Product Group 1';
        newProduct.ProductSubGroup__c = '20% fat';
        newProduct.FRESH_FROZEN_TEMP__c = '27';
        newProduct.NET_CASE_WT_LBS__c = 10;
        newProduct.PUMP__c = 'Yes';
        

        products.add(newProduct);
        
        Product2 newProduct2 = new Product2();
        newProduct2.Name = 'Product Test 2';
        newProduct2.ProductCode = 'PR-00002';
        newProduct2.SKU_NO__c = 'PR-00002';
        newProduct2.LEGACY_BUSINESS__c = 'Deli';
        newProduct2.IsActive = TRUE;
        newProduct2.Product_Id__c = 'PR-00002|PROTEAN';
        newProduct2.BRAND_NAME__c = 'Wunderbar';
        newProduct2.ProductGroup__c = 'Product Group 1';
        newProduct2.ProductSubGroup__c = '40% fat';
        newProduct2.FRESH_FROZEN_TEMP__c = '25';
        newProduct2.NET_CASE_WT_LBS__c = 8;
        newProduct2.PUMP__c = 'No';
        products.add(newProduct2);
        
        Product2 newProduct3 = new Product2();
        newProduct3.Name = 'Product Test 3';
        newProduct3.ProductCode = 'PR-00003';
       	newProduct3.SKU_NO__c = 'PR-00003';
        newProduct3.CPQCollection__c = 'colTest2';
        newProduct3.LEGACY_BUSINESS__c = 'Boxed Beef';
        newProduct3.IsActive = FALSE;
        newProduct3.Product_Id__c = 'PR-00003|XLGO';
        newProduct3.BRAND_NAME__c = 'Charal';
        newProduct3.PRODUCT_LINE_GROUP__c = 'Premium';
        newProduct3.MARKET_BASE_CODE__c = 'A332';
        newProduct3.GRADE_CODE__c = 'EE34';
        newProduct3.NET_CASE_WT_LBS__c = 8;
        newProduct3.PIECE_WEIGHT__c = 10;
        newProduct3.CATCH_WEIGHT_FLAG__c = 'Yes';
        products.add(newProduct3);
        
        Product2 newProduct4 = new Product2();
        newProduct4.Name = 'Product Test 4';
        newProduct4.ProductCode = 'PR-00004';
        newProduct4.SKU_NO__c = 'PR-00004';
        newProduct4.CPQCollection__c = 'colTest2';
        newProduct4.LEGACY_BUSINESS__c = 'Boxed Beef';
        newProduct4.IsActive = TRUE;
        newProduct4.Product_Id__c = 'PR-00004|XLGO';
        newProduct4.BRAND_NAME__c = 'Charal';
        newProduct4.PRODUCT_LINE_GROUP__c = 'Premium';
        newProduct4.MARKET_BASE_CODE__c = 'A333';
        newProduct4.GRADE_CODE__c = 'EE31';
        newProduct4.NET_CASE_WT_LBS__c = 9;
        newProduct4.PIECE_WEIGHT__c = 11;
        newProduct4.CATCH_WEIGHT_FLAG__c = 'No';
        
        products.add(newProduct4);
        insert products;
        
   }
    
    //Catalog scheduler instanciation Products Test
    static testmethod void method1(){
      	init();
      	Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new SmartCPQProductSync_Test_Mock_Callout());
       	SmartCPQProductSync_CatalogScheduler sh1 = new SmartCPQProductSync_CatalogScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Catalog Scheduler Check', sch, sh1); 
        Test.stopTest();
  	}

    //In Progress Products import test
  	static testmethod void method2(){
      	CPQResetSetting__c cusSet = new CPQResetSetting__c();
        cusSet.Name = 'Default';
        cusSet.Count__c = 1;
        cusSet.hasNextRecords__c = 'true';
        cusSet.OFFSET_LIMIT__c = 1000;        
        insert cusSet;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartCPQProductSync_Test_Mock_Callout());
        String jsonObj = '{"sVersionLabelDyn":"Version 1508274627775","sProductCode_End":"PR-00001","sProductCode_Beg":"PR-01000","sProcessedProducts":{"test1":true},"offsetCount":null,"current":2}';
        SmartCPQProductSync_CatalogIntegration.runWait(jsonObj);
        Test.stopTest();  
    }
    
  //Update Products Test  
  static testmethod void method3(){
      CPQResetSetting__c cusSet = new CPQResetSetting__c();
      cusSet.Name = 'Default';
      cusSet.Count__c = 1;
      cusSet.hasNextRecords__c = 'false';
      cusSet.OFFSET_LIMIT__c = 1000;        
      insert cusSet;
      
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new SmartCPQProductSync_Test_Mock_Callout());
      String jsonObj = '{"sVersionLabelDyn":"Version 1508274627775","sProductCode_End":"PR-00001","sProductCode_Beg":"PR-01000","sProcessedProducts":{"test1":true},"offsetCount":null,"current":1}';
      SmartCPQProductSync_CatalogIntegration.runWait(jsonObj);
      Test.stopTest();  
  }
  
    //GEOS MX Records
  static testmethod void method4(){
      CPQResetSetting__c cusSet = new CPQResetSetting__c();
        cusSet.Name = 'Default';
        cusSet.Count__c = 0;
        cusSet.hasNextRecords__c = 'null';
        cusSet.OFFSET_LIMIT__c = 1000;        
        insert cusSet;
      Test.startTest();
        Test.setMock(HttpCalloutMock.class, new  SmartCPQProductSync_Test_Mock_Callout());
        String jsonObj = '{"sVersionLabelDyn":"Version 1508274627775","sProductCode_End":"PR-00001","sProductCode_Beg":"PR-01000","sProcessedProducts":{"test1":true},"offsetCount":null,"current":2}';
        SmartCPQProductSync_CatalogIntegration.runWait(jsonObj);
      Test.stopTest();  
  }
    
  static testmethod void method5(){
  
   String jsonString = '{"sVersionLabelDyn":"Version 1508274627775","sProductCode_End":"PR-00001","sProductCode_Beg":"PR-01000","sProcessedProducts":{"test1":true},"offsetCount":null,"current":4}';
   Test.startTest();
   Test.setMock(HttpCalloutMock.class, new SmartCPQProductSync_Test_Mock_Callout());
   SmartCPQProductSync_VersionGenerator.runWait(jsonString );
   Test.stopTest();         
  }
  
    //Version Delete & mail test
  static testmethod void method6(){
      String jsonString = '{"sVersionLabelDyn":"Version 1508274627775","sProductCode_End":"111000","sProductCode_Beg":"100000","sProcessedProducts":{"test1":true},"offsetCount":null,"current":7}';
      //RecipientEmailAddressForCPQ__c succMail = new RecipientEmailAddressForCPQ__c ();
      //succMail.Email__c = 'abc@abc.com';
      //succMail.Name = 'abc';
      //Insert succMail;
  
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new SmartCPQProductSync_Test_Mock_Callout());
      SmartCPQProductSync_VersionDelete.deleteVersion(jsonString);
      Test.stopTest();   
  }

}