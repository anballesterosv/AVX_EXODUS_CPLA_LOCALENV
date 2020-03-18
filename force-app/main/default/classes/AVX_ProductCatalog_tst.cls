@isTest
private class AVX_ProductCatalog_tst {
    @TestSetup
    static void makeData(){
        User objUser = AVX_DataGenerator_cls.createUser('Personv1');
        insert objUser;
        Product2 objProduct = AVX_DataGenerator_cls.createProduct('Productv1'); 
        insert objProduct;
        Pricebook2 objPricebook = AVX_DataGenerator_cls.createPricebook('Pricebookv1', objProduct);
        insert objPricebook;
        PriceBookEntry objPricebookEntry = AVX_DataGenerator_cls.createPricebookEntry(objPricebook, objProduct); 
        insert objPricebookEntry;
    }

    @isTest
    static void getCatalogContentTest(){
        User objUser = [SELECT Id, FirstName FROM User WHERE FirstName = 'Personv1' LIMIT 1];
        System.assert(objUser != null);

        Product2 objProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'Productv1' LIMIT 1];
        System.assert(objProduct != null);

        Pricebook2 objPricebook = [SELECT Id, Name FROM PriceBook2 WHERE Name = 'Pricebookv1' LIMIT 1];
        System.assert(objPricebook != null);

        PricebookEntry objPricebookEntry = [SELECT Id FROM PriceBookEntry WHERE Product2.Name = 'Productv1' AND PriceBook2.Name = 'Pricebookv1' LIMIT 1];
        System.assert(objPricebookEntry != null);

        ContentVersion lContentVersion1 = new ContentVersion();
        lContentVersion1.Title = 'catalog';
        lContentVersion1.PathOnClient = 'Text.txt';
        lContentVersion1.VersionData = Blob.valueOf('Test Content');
        lContentVersion1.IsMajorVersion = true;
        insert lContentVersion1;
     
        ContentDocument lContentDoc1 = new ContentDocument();
        lContentDoc1 = [SELECT Id FROM ContentDocument  WHERE Title = 'catalog'];

        ContentVersion lContentVersion2 = new ContentVersion();
        lContentVersion2.Title = 'catalog';
        lContentVersion2.PathOnClient = 'Text.txt';
        lContentVersion2.VersionData = Blob.valueOf('Test Content');
        lContentVersion2.IsMajorVersion = true;
        lContentVersion2.contentDocumentId = lContentDoc1.Id;
        insert lContentVersion2;
     
        ContentDocumentLink  lDocLink = new ContentDocumentLink();
        lDocLink.contentDocumentId = lContentDoc1.Id;
        lDocLink.LinkedEntityId = objProduct.Id;
        lDocLink.ShareType = 'V';
        insert lDocLink;

        AVX_ProductCatalog_ctr.CategoryWrapper categoryWrapper = new AVX_ProductCatalog_ctr.CategoryWrapper();
        AVX_ProductCatalog_ctr.FilterWrapper filterWrapper = new AVX_ProductCatalog_ctr.FilterWrapper();
        AVX_ProductCatalog_ctr.FieldsWrapper fieldsWrapper = new  AVX_ProductCatalog_ctr.FieldsWrapper();

        Test.startTest();
        System.runAs(objUser){
            AVX_ProductCatalog_ctr.getPriceBookList('Pricebookv1', 0, '3', 'Product2.Name', 'none', '123499', '["Product2.SalesArea__r.SalesOrg__c|1315"]');
            AVX_ProductCatalog_ctr.getPriceBookList('Pricebookv1', 0, '3', 'Product2.Name', 'none', '123499', '');
            AVX_ProductCatalog_ctr.getFilter('Pricebookv1');
        }
        Test.stopTest();
    }
}