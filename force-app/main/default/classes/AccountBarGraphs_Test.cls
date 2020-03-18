/*
*    @description:    Test class for SubSectorBarGraphCX & PositioningBarGraphCX.
*    @author:         Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
*    @createddate:    April 20, 2016
*/
@isTest
public class AccountBarGraphs_Test {
    public static testMethod void SubSectorBarGraphCXTest() {
        RecordType competitorRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
        Account newCompetitor = new Account(Name = 'Competitor Test 1',Market_Channel__c='Retail Channel'
                                            );
        newCompetitor.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'].Id;
        insert newCompetitor;
        
        for(Integer i=0; i<2; i++) {
            Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Competitor__c = newCompetitor.Id,
                                                                                    Sub_sector_segment_application__c = 'Bakery'
                                                                                    );
            insert newCompetitorProduct;
        }
        
        ApexPages.currentPage().getParameters().put( 'id', newCompetitor.Id );
        
        Test.startTest();
            SubSectorBarGraphCX controller = new SubSectorBarGraphCX(new ApexPages.StandardController(newCompetitor));
            
            controller.positioningCount();
            
            SubSectorBarGraphCX.VerticalBarData wrapper = new SubSectorBarGraphCX.VerticalBarData('Bakery', 1);
            controller.getBarData();
        Test.stopTest();
    }
    
    public static testMethod void PositioningBarGraphCXTest() {
        RecordType competitorRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
        Account newCompetitor = new Account(Name = 'Competitor Test 1',Market_Channel__c='Retail Channel'
                                            );
        newCompetitor.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'].Id;                                    
        insert newCompetitor;
        
        for(Integer i=0; i<2; i++) {
            Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Competitor__c = newCompetitor.Id,
                                                                                    Positioning__c = 'Natural'
                                                                                    );
            insert newCompetitorProduct;
        }
        
        ApexPages.currentPage().getParameters().put( 'id', newCompetitor.Id );
        
        Test.startTest();
            PositioningBarGraphCX controller = new PositioningBarGraphCX(new ApexPages.StandardController(newCompetitor));
            
            controller.positioningCount();
            
            SubSectorBarGraphCX.VerticalBarData wrapper = new SubSectorBarGraphCX.VerticalBarData('Natural', 1);
            controller.getBarData();
        Test.stopTest();
    }
    public static testMethod void AllPositioningAndSubSectorBarGraphsCCTest() {
        RecordType competitorRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
        Account newCompetitor = new Account(Name = 'Competitor Test 1',Market_Channel__c='Retail Channel'
                                            );
        newCompetitor.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'].Id;    
        insert newCompetitor;
        
        for(Integer i=0; i<2; i++) {
            Competitor_Product__c newCompetitorProduct = new Competitor_Product__c(Competitor__c = newCompetitor.Id,
                                                                                    Sub_sector_segment_application__c = 'Bakery',
                                                                                    Positioning__c = 'Natural'
                                                                                    );
            insert newCompetitorProduct;
        }
        
        ApexPages.currentPage().getParameters().put( 'id', newCompetitor.Id );
        
        Test.startTest();
            AllPositioningAndSubSectorBarGraphsCC controller = new AllPositioningAndSubSectorBarGraphsCC();
            
            controller.subSectorCount();
            controller.positioningCount();
            
            AllPositioningAndSubSectorBarGraphsCC.SubSectorBarData swrapper = new AllPositioningAndSubSectorBarGraphsCC.SubSectorBarData('Bakery', 1);
            controller.getSubSectorBarData();
            
            AllPositioningAndSubSectorBarGraphsCC.PositioningBarData pwrapper = new AllPositioningAndSubSectorBarGraphsCC.PositioningBarData('Bakery', 1);
            controller.getPositioningBarData();
        Test.stopTest();
    }
}