/*
*    @description:    Test class for AddOpportunityCompetitorProductsCX.
*    @author:         Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
*    @createddate:    April 20, 2016
*/
@isTest
private class AddOpportunityCompetitorProductsCX_Test {
    //for testing remove button of selected products
    private AddOpportunityCompetitorProductsCX_Test(){}
    public static testMethod void AddOpportunityCompetitorProductsCX_Test1() {
         Account newCompetitor = new Account();
        newCompetitor.Name = 'TestName';
        newCompetitor.BillingCity = 'TestBillingCity';
        newCompetitor.BillingState = 'Iowas';
        newCompetitor.BillingStreet = 'TestBillingStreet';
        newCompetitor.BillingPostalCode = 'TestBilling';
        newCompetitor.ShippingCity = 'TestShippingCity';
        newCompetitor.ShippingState = 'Iowa';
        newCompetitor.ShippingStreet = 'TestShippingStreet';
        newCompetitor.ShippingPostalCode = 'TestShipping';
        newCompetitor.Market_Channel__c='Retail Channel';
        insert newCompetitor;
        
        //RecordType opportunityRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'New Opportunity'];
        Opportunity newOpportunity = new Opportunity(Name = 'Opportunity Test 1',
                                                        AccountId = newCompetitor.Id,
                                                        CloseDate = System.Today() + 7,
                                                        StageName = 'Rascunho'
                                                        //Numero_de_concorrentes__c = '1'
                                                        );
        insert newOpportunity;
        
        Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Competitor__c = newCompetitor.Id,
                                                                                Sub_sector_segment_application__c = 'Bakery'
                                                                                );
        insert newCompetitorProduct;
        
        Opportunity_Competitor_Product__c newOpportunityCompetitorProduct = new Opportunity_Competitor_Product__c(Opportunity__c = newOpportunity.id
                                                                                                                    );
        insert newOpportunityCompetitorProduct;
        
        ApexPages.currentPage().getParameters().put( 'id', newOpportunity.Id );
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpportunity);
        Test.startTest();
            AddOpportunityCompetitorProductsCX controller = new AddOpportunityCompetitorProductsCX(new ApexPages.StandardSetController(oppList));
            
            controller.getCompetitors();
            controller.getCompetitorProducts();
            
            AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper wrapper1 = new AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper(newCompetitorProduct, false);
            controller.selectedCompetitorProductId = newCompetitorProduct.Id;
            controller.loadSelectedCompetitorProductsTable();
            List<AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper> wrapper1List = new List<AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper>();
            controller.prodId = newCompetitorProduct.Id;
            controller.removeProduct();
        Test.stopTest();
    }
    
    //test without competitor products account/competitor__c
    public static testMethod void AddOpportunityCompetitorProductsCX_Test2() {
        Account newCompetitor = new Account();
        newCompetitor .Name = 'Test1';
        newCompetitor .BillingCity = 'Testc';
        newCompetitor .BillingState = 'Iowa';
        newCompetitor .BillingStreet = 'Test';
        newCompetitor .BillingPostalCode = 'Testb';
        newCompetitor .ShippingCity = 'Testsh';
        newCompetitor .ShippingState = 'Iowaa';
        newCompetitor .ShippingStreet = 'Teststr';
        newCompetitor .ShippingPostalCode = 'Test';
        newCompetitor.Market_Channel__c='Retail Channel';
        insert newCompetitor;
        
        //RecordType opportunityRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'New Opportunity'];
        Opportunity newOpportunity = new Opportunity(Name = 'Opportunity Test 1',
                                                        AccountId = newCompetitor.Id,
                                                        CloseDate = System.Today() + 7,
                                                        StageName = 'Rascunho'
                                                        //Numero_de_concorrentes__c = '1'
                                                        );
        insert newOpportunity;
        
        Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Sub_sector_segment_application__c = 'Bakery'
                                                                                );
        insert newCompetitorProduct;
        
        Opportunity_Competitor_Product__c newOpportunityCompetitorProduct = new Opportunity_Competitor_Product__c(Opportunity__c = newOpportunity.id
                                                                                                                    );
        insert newOpportunityCompetitorProduct;
        
        ApexPages.currentPage().getParameters().put( 'id', newOpportunity.Id );
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpportunity);
        Test.startTest();
            AddOpportunityCompetitorProductsCX controller = new AddOpportunityCompetitorProductsCX(new ApexPages.StandardSetController(oppList));
            
            controller.getCompetitors();
            controller.getCompetitorProducts();
        Test.stopTest();
    }
    
    //test save
    public static testMethod void AddOpportunityCompetitorProductsCX_Test3() {
         Account newCompetitor = new Account();
        newCompetitor .Name = 'Test';
        newCompetitor .BillingCity = 'Test';
        newCompetitor .BillingState = 'Iowa';
        newCompetitor .BillingStreet = 'Test';
        newCompetitor .BillingPostalCode = 'Test';
        newCompetitor .ShippingCity = 'Test';
        newCompetitor .ShippingState = 'Iowa';
        newCompetitor .ShippingStreet = 'Test';
        newCompetitor .ShippingPostalCode = 'Test';
        newCompetitor.Market_Channel__c='Retail Channel';
        insert newCompetitor;
        
        //RecordType opportunityRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'New Opportunity'];
        Opportunity newOpportunity = new Opportunity(Name = 'Opportunity Test 1',
                                                        AccountId = newCompetitor.Id,
                                                        CloseDate = System.Today() + 7,
                                                        StageName = 'Rascunho'
                                                        //Numero_de_concorrentes__c = '1'
                                                        );
        insert newOpportunity;
        
        Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Name = 'Competitor Product Test 1',
                                                                                Competitor__c = newCompetitor.Id,
                                                                                Sub_sector_segment_application__c = 'Bakery'
                                                                                );
        insert newCompetitorProduct;
        
        Opportunity_Competitor_Product__c newOpportunityCompetitorProduct = new Opportunity_Competitor_Product__c(Opportunity__c = newOpportunity.id
                                                                                                                    );
        insert newOpportunityCompetitorProduct;
        
        ApexPages.currentPage().getParameters().put( 'id', newOpportunity.Id );
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpportunity);
        Test.startTest();
            AddOpportunityCompetitorProductsCX controller = new AddOpportunityCompetitorProductsCX(new ApexPages.StandardSetController(oppList));
            
            controller.getCompetitors();
            controller.getCompetitorProducts();
            
            AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper wrapper1 = new AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper(newCompetitorProduct, false);
            controller.selectedCompetitorProductId = newCompetitorProduct.Id;
            controller.loadSelectedCompetitorProductsTable();
            List<AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper> wrapper1List = new List<AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper>();
            controller.save();
            controller.cancel();
            controller.searchButton();
            controller.searchText = 'Test';
            controller.searchProducts();
        Test.stopTest();
    }
    
    //test search error on save
    public static testMethod void AddOpportunityCompetitorProductsCX_Test4() {
         Account newCompetitor = new Account();
        newCompetitor .Name = 'Test';
        newCompetitor .BillingCity = 'Test';
        newCompetitor .BillingState = 'Iowa';
        newCompetitor .BillingStreet = 'Test';
        newCompetitor .BillingPostalCode = 'Test';
        newCompetitor .ShippingCity = 'Test';
        newCompetitor .ShippingState = 'Iowa';
        newCompetitor .ShippingStreet = 'Test';
        newCompetitor .ShippingPostalCode = 'Test';
        newCompetitor.Market_Channel__c='Retail Channel';
        insert newCompetitor;
        
        //RecordType opportunityRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'New Opportunity'];
        Opportunity newOpportunity = new Opportunity(Name = 'Opportunity Test 1',
                                                        AccountId = newCompetitor.Id,
                                                        CloseDate = System.Today() + 7,
                                                        StageName = 'Rascunho'
                                                        //Numero_de_concorrentes__c = '1'
                                                        );
        insert newOpportunity;
        
        Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Competitor__c = newCompetitor.Id,
                                                                                Sub_sector_segment_application__c = 'Bakery'
                                                                                );
        insert newCompetitorProduct;
        
        Opportunity_Competitor_Product__c newOpportunityCompetitorProduct = new Opportunity_Competitor_Product__c(Opportunity__c = newOpportunity.id
                                                                                                                    );
        insert newOpportunityCompetitorProduct;
        
        ApexPages.currentPage().getParameters().put( 'id', newOpportunity.Id );
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpportunity);
        Test.startTest();
            AddOpportunityCompetitorProductsCX controller = new AddOpportunityCompetitorProductsCX(new ApexPages.StandardSetController(oppList));
            
            controller.getCompetitors();
            controller.getCompetitorProducts();
            
            AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper wrapper1 = new AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper(newCompetitorProduct, false);
            controller.selectedCompetitorProductId = newCompetitorProduct.Id;
            controller.loadSelectedCompetitorProductsTable();
            List<AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper> wrapper1List = new List<AddOpportunityCompetitorProductsCX.CompetitorProductsWrapper>();
            controller.save();
            controller.cancel();
            controller.searchButton();
            controller.searchText = 'Te';
            controller.searchProducts();
        Test.stopTest();
    }
    
    //test search
    public static testMethod void AddOpportunityCompetitorProductsCX_Test5() {
         Account newCompetitor = new Account();
        newCompetitor .Name = 'Test';
        newCompetitor .BillingCity = 'Test';
        newCompetitor .BillingState = 'Iowa';
        newCompetitor .BillingStreet = 'Test';
        newCompetitor .BillingPostalCode = 'Test';
        newCompetitor .ShippingCity = 'Test';
        newCompetitor .ShippingState = 'Iowa';
        newCompetitor .ShippingStreet = 'Test';
        newCompetitor .ShippingPostalCode = 'Test';
        newCompetitor.Market_Channel__c='Retail Channel';
        insert newCompetitor;
        
        //RecordType opportunityRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'New Opportunity'];
        Opportunity newOpportunity = new Opportunity(Name = 'Opportunity Test 1',
                                                        AccountId = newCompetitor.Id,
                                                        CloseDate = System.Today() + 7,
                                                        StageName = 'Rascunho'
                                                        //Numero_de_concorrentes__c = '1'
                                                        );
        insert newOpportunity;
        
        Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Competitor__c = newCompetitor.Id,
                                                                                Sub_sector_segment_application__c = 'Bakery'
                                                                                );
        insert newCompetitorProduct;
        
        Opportunity_Competitor_Product__c newOpportunityCompetitorProduct = new Opportunity_Competitor_Product__c(Opportunity__c = newOpportunity.id
                                                                                                                    );
        insert newOpportunityCompetitorProduct;
        
        ApexPages.currentPage().getParameters().put( 'id', newOpportunity.Id );
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(newOpportunity);
        Test.startTest();
            AddOpportunityCompetitorProductsCX controller = new AddOpportunityCompetitorProductsCX(new ApexPages.StandardSetController(oppList));
            
            controller.getCompetitors();
            controller.getCompetitorProducts();
            controller.searchedProdId = newCompetitorProduct.Id;
            controller.addSearchedProduct();
            controller.hideSearchSection();
        Test.stopTest();
    }
    
    
    //for testing remove button of selected products
    public static testMethod void AddCompetitorProductsCX_Test1() {
         Account newCompetitor = new Account();
        newCompetitor .Name = 'Test';
        newCompetitor .BillingCity = 'Test';
        newCompetitor .BillingState = 'Iowa';
        newCompetitor .BillingStreet = 'Test';
        newCompetitor .BillingPostalCode = 'Test';
        newCompetitor .ShippingCity = 'Test';
        newCompetitor .ShippingState = 'Iowa';
        newCompetitor .ShippingStreet = 'Test';
        newCompetitor .ShippingPostalCode = 'Test';
        newCompetitor.Market_Channel__c='Retail Channel';
        insert newCompetitor;
        
        Product2 newProduct = new Product2(Name = 'Product Test 1',Product_Deployment__c = 'Placeholder',
                                           Enterprise__c = 'FoodIngredientsBioIndustrialFIBI',
                                           Group__c = 'GoToMarket (GTM)', Business__c = 'Commercial Excellence NA'
                                            );
        insert newProduct;
        
        Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Competitor__c = newCompetitor.Id,
                                                                                Sub_sector_segment_application__c = 'Bakery'
                                                                                );
        insert newCompetitorProduct;
        
        Substitute_Product__c newOpportunityCompetitorProduct = new Substitute_Product__c(Product__c = newProduct.id
                                                                                                                    );
        insert newOpportunityCompetitorProduct;
        
        ApexPages.currentPage().getParameters().put( 'id', newProduct.Id );
        List<Product2> prodList = new List<Product2>();
        prodList.add(newProduct);
        Test.startTest();
            AddCompetitorProductsCX controller = new AddCompetitorProductsCX(new ApexPages.StandardSetController(prodList));
            
            controller.getCompetitors();
            controller.getCompetitorProducts();
            
            AddCompetitorProductsCX.CompetitorProductsWrapper wrapper1 = new AddCompetitorProductsCX.CompetitorProductsWrapper(newCompetitorProduct, false);
            controller.selectedCompetitorProductId = newCompetitorProduct.Id;
            controller.loadSelectedCompetitorProductsTable();
            List<AddCompetitorProductsCX.CompetitorProductsWrapper> wrapper1List = new List<AddCompetitorProductsCX.CompetitorProductsWrapper>();
            controller.prodId = newCompetitorProduct.Id;
            controller.removeProduct();
        Test.stopTest();
    }
    
    public static testMethod void AddCompetitorProductsCX_Test2() {
         Account newCompetitor = new Account();
        newCompetitor .Name = 'Test';
        newCompetitor .BillingCity = 'Test';
        newCompetitor .BillingState = 'Iowa';
        newCompetitor .BillingStreet = 'Test';
        newCompetitor .BillingPostalCode = 'Test';
        newCompetitor .ShippingCity = 'Test';
        newCompetitor .ShippingState = 'Iowa';
        newCompetitor .ShippingStreet = 'Test';
        newCompetitor .ShippingPostalCode = 'Test';
        newCompetitor.Market_Channel__c='Retail Channel';
        insert newCompetitor;
        
        Product2 newProduct = new Product2(Name = 'Product Test 1',Product_Deployment__c = 'Placeholder',
                                           Enterprise__c = 'FoodIngredientsBioIndustrialFIBI',
                                           Group__c = 'GoToMarket (GTM)', Business__c = 'Commercial Excellence NA'
                                            );
        insert newProduct;
        
        Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Competitor__c = newCompetitor.Id,
                                                                                Sub_sector_segment_application__c = 'Bakery'
                                                                                );
        insert newCompetitorProduct;

        Substitute_Product__c newOpportunityCompetitorProduct = new Substitute_Product__c(Product__c = newProduct.id
                                                                                            );
        insert newOpportunityCompetitorProduct;

        Substitute_Product__c newOpportunityCompetitorProduct2 = new Substitute_Product__c(Product__c = newProduct.id,
                                                                                            Competitor_Product__c = newCompetitorProduct.id
                                                                                            );
        insert newOpportunityCompetitorProduct2;
        
        ApexPages.currentPage().getParameters().put( 'id', newProduct.Id );
        List<Product2> prodList = new List<Product2>();
        prodList.add(newProduct);
        Test.startTest();
            AddCompetitorProductsCX controller = new AddCompetitorProductsCX(new ApexPages.StandardSetController(prodList));
            
            controller.getCompetitors();
            controller.getCompetitorProducts();
            
            AddCompetitorProductsCX.CompetitorProductsWrapper wrapper1 = new AddCompetitorProductsCX.CompetitorProductsWrapper(newCompetitorProduct, false);
            controller.selectedCompetitorProductId = newCompetitorProduct.Id;
            controller.loadSelectedCompetitorProductsTable();
            List<AddCompetitorProductsCX.CompetitorProductsWrapper> wrapper1List = new List<AddCompetitorProductsCX.CompetitorProductsWrapper>();
            AddCompetitorProductsCX.SearchedCompetitorProductsWrapper wrapper2 = new AddCompetitorProductsCX.SearchedCompetitorProductsWrapper(newCompetitorProduct, false);
            List<AddCompetitorProductsCX.SearchedCompetitorProductsWrapper> wrapper2List = new List<AddCompetitorProductsCX.SearchedCompetitorProductsWrapper>();
            controller.save();
            controller.cancel();
            controller.searchButton();
            controller.searchText = 'Test';
            controller.searchProducts();
        Test.stopTest();
    }
    
    public static testMethod void AddCompetitorProductsCX_Test3() {
         Account newCompetitor = new Account();
        newCompetitor .Name = 'Test';
        newCompetitor .BillingCity = 'Test';
        newCompetitor .BillingState = 'Iowa';
        newCompetitor .BillingStreet = 'Test';
        newCompetitor .BillingPostalCode = 'Test';
        newCompetitor .ShippingCity = 'Test';
        newCompetitor .ShippingState = 'Iowa';
        newCompetitor .ShippingStreet = 'Test';
        newCompetitor .ShippingPostalCode = 'Test';
        newCompetitor.Market_Channel__c='Retail Channel';
        insert newCompetitor;
        
        Product2 newProduct = new Product2(Name = 'Product Test 1',Product_Deployment__c = 'Placeholder',
                                           Enterprise__c = 'FoodIngredientsBioIndustrialFIBI',
                                           Group__c = 'GoToMarket (GTM)', Business__c = 'Commercial Excellence NA'
                                            );
        insert newProduct;
        
        Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Competitor__c = newCompetitor.Id,
                                                                                Sub_sector_segment_application__c = 'Bakery'
                                                                                );
        insert newCompetitorProduct;
        
        Substitute_Product__c newOpportunityCompetitorProduct = new Substitute_Product__c(Product__c = newProduct.id
                                                                                            );
        insert newOpportunityCompetitorProduct;

        Substitute_Product__c newOpportunityCompetitorProduct2 = new Substitute_Product__c(Product__c = newProduct.id,
                                                                                            Competitor_Product__c = newCompetitorProduct.id
                                                                                            );
        insert newOpportunityCompetitorProduct2;
        
        ApexPages.currentPage().getParameters().put( 'id', newProduct.Id );
        List<Product2> prodList = new List<Product2>();
        prodList.add(newProduct);
        Test.startTest();
            AddCompetitorProductsCX controller = new AddCompetitorProductsCX(new ApexPages.StandardSetController(prodList));
            
            controller.getCompetitors();
            controller.getCompetitorProducts();
            controller.searchedProdId = newCompetitorProduct.Id;
            controller.addSearchedProduct();
            controller.hideSearchSection();
        Test.stopTest();
    }
}