/*
*    @description:    Test class for CompetitorJunctionTriggerHandler.
*    @author:         Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
*    @createddate:    April 20, 2016
*/
@isTest
public class CompetitorJunctionTriggerHandler_Test {
    
    public static testMethod void countCustomerCompetitors_Test() {
        Test.startTest();
            //RecordType competitorRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
            Map<String,Schema.RecordTypeInfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
            Account newCompetitor = new Account(RecordTypeId = recordTypeMap.get('Competitor').getRecordTypeId(),
                                                Name = 'Competitor Test 1',Market_Channel__c='Retail Channel'
                                                );
            insert newCompetitor;
            
            //RecordType customerRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
            Account newCustomer = new Account(RecordTypeId = recordTypeMap.get('Competitor').getRecordTypeId(),
                                                Name = 'newCustomer Test 1',Market_Channel__c='Retail Channel'
                                                );
            insert newCustomer;
            
            Competitor_Junction__c newCompetitorJunction = new Competitor_Junction__c(Name = 'Competitor Junction Test 1',
                                                                                        Customer__c = newCustomer.Id,
                                                                                        Competitor__c = newCompetitor.Id
                                                                                        );
            insert newCompetitorJunction;
            
            
            
            //calling handler methods
            List<Competitor_Junction__c> CJList = new List<Competitor_Junction__c>();
            CJList.add(newCompetitorJunction);
           
            CompetitorJunctionTriggerHandler.countCustomerCompetitors(CJList);
            
        Test.stopTest();
    }
    
    //test 50/50 with range set and lower Up Range
    public static testMethod void updateCompetitorPerformanceTrend_Test1() {
        Test.startTest();
            RecordType competitorRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
            Account newCompetitor = new Account(RecordTypeId = competitorRT.Id,
                                                Name = 'Competitor Test 1',Market_Channel__c='Retail Channel'
                                                );
            insert newCompetitor;
            
            RecordType customerRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
            Account newCustomer = new Account(RecordTypeId = customerRT.Id,
                                                Name = 'newCustomer Test 1',Market_Channel__c='Retail Channel'
                                                );
            insert newCustomer;
            
            CompetitorPerformanceTrendRange__c rangeSetting = new CompetitorPerformanceTrendRange__c(UP_Range__c = 80,
                                                                                                        DOWN_Range__c = 60,
                                                                                                        Name = 'Range Setting Test 1'
                                                                                                        );
            insert rangeSetting;
            
            Competitor_Junction__c newCompetitorJunction = new Competitor_Junction__c(Name = 'Competitor Junction Test 1',
                                                                                        Customer__c = newCustomer.Id,
                                                                                        Competitor__c = newCompetitor.Id,
                                                                                        Competitor_Performance_Trend__c = 'Up'
                                                                                        );
            insert newCompetitorJunction;
            
            Competitor_Junction__c newCompetitorJunction2 = new Competitor_Junction__c(Name = 'Competitor Junction Test 1',
                                                                                        Customer__c = newCustomer.Id,
                                                                                        Competitor__c = newCompetitor.Id,
                                                                                        Competitor_Performance_Trend__c = 'Down'
                                                                                        );
            insert newCompetitorJunction2;
            
             //calling handler methods
            List<Competitor_Junction__c> CJList = new List<Competitor_Junction__c>();
            CJList.add(newCompetitorJunction);
            CompetitorJunctionTriggerHandler.updateCompetitorPerformanceTrend(CJList);
            
        Test.stopTest();
    }
    
    //test 50/50 with default range
    public static testMethod void updateCompetitorPerformanceTrend_Test2() {
        Test.startTest();
            RecordType competitorRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
            Account newCompetitor = new Account(RecordTypeId = competitorRT.Id,
                                                Name = 'Competitor Test 1',Market_Channel__c='Retail Channel'
                                                );
            insert newCompetitor;
            
            RecordType customerRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
            Account newCustomer = new Account(RecordTypeId = customerRT.Id,
                                                Name = 'newCustomer Test 1',Market_Channel__c='Retail Channel'
                                                );
            insert newCustomer;
            
            Competitor_Junction__c newCompetitorJunction = new Competitor_Junction__c(Name = 'Competitor Junction Test 1',
                                                                                        Customer__c = newCustomer.Id,
                                                                                        Competitor__c = newCompetitor.Id,
                                                                                        Competitor_Performance_Trend__c = 'Up'
                                                                                        );
            insert newCompetitorJunction;
            
            Competitor_Junction__c newCompetitorJunction2 = new Competitor_Junction__c(Name = 'Competitor Junction Test 1',
                                                                                        Customer__c = newCustomer.Id,
                                                                                        Competitor__c = newCompetitor.Id,
                                                                                        Competitor_Performance_Trend__c = 'Down'
                                                                                        );
            insert newCompetitorJunction2;
        Test.stopTest();
    }
    
    //test 50/50 with range set and greater Up Range
    public static testMethod void updateCompetitorPerformanceTrend_Test3() {
        Test.startTest();
            RecordType competitorRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
            Account newCompetitor = new Account(RecordTypeId = competitorRT.Id,
                                                Name = 'Competitor Test 1',Market_Channel__c='Retail Channel'
                                                );
            insert newCompetitor;
            
            RecordType customerRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
            Account newCustomer = new Account(RecordTypeId = customerRT.Id,
                                                Name = 'newCustomer Test 1',Market_Channel__c='Retail Channel'
                                                );
            insert newCustomer;
            
            CompetitorPerformanceTrendRange__c rangeSetting = new CompetitorPerformanceTrendRange__c(UP_Range__c = 40,
                                                                                                        DOWN_Range__c = 30,
                                                                                                        Name = 'Range Setting Test 1'
                                                                                                        );
            insert rangeSetting;
            
            Competitor_Junction__c newCompetitorJunction = new Competitor_Junction__c(Name = 'Competitor Junction Test 1',
                                                                                        Customer__c = newCustomer.Id,
                                                                                        Competitor__c = newCompetitor.Id,
                                                                                        Competitor_Performance_Trend__c = 'Up'
                                                                                        );
            insert newCompetitorJunction;
            
            Competitor_Junction__c newCompetitorJunction1 = new Competitor_Junction__c(Name = 'Competitor Junction Test 1',
                                                                                        Customer__c = newCustomer.Id,
                                                                                        Competitor__c = newCompetitor.Id,
                                                                                        Competitor_Performance_Trend__c='Up'
                                                                                        );
            insert newCompetitorJunction1;
            
            Competitor_Junction__c newCompetitorJunction2 = new Competitor_Junction__c(Name = 'Competitor Junction Test 1',
                                                                                        Customer__c = newCustomer.Id,
                                                                                        Competitor__c = newCompetitor.Id
                                                                                        );
            insert newCompetitorJunction2;
            
            //calling handler methods
            List<Competitor_Junction__c> CJList = new List<Competitor_Junction__c>();
            CJList.add(newCompetitorJunction);
            CJList.add(newCompetitorJunction1);
            CJList.add(newCompetitorJunction2);
            CompetitorJunctionTriggerHandler.updateCompetitorPerformanceTrend(CJList);
            
        Test.stopTest();
    }
}