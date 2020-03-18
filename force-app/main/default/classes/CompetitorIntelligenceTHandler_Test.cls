/**
 Test class to cover functionality of class: CompetitorIntelligenceTriggerHandler
 */
 //seeAlldata is true to access ConnectApi
@isTest(SeeAllData=true) 
private class CompetitorIntelligenceTHandler_Test {
	public static Account newCompetitor;
	public static CollaborationGroup newChatterGroup;
	public static Competitor_Intelligence__c newCompetitorIntelligence;
	
	//method to create test data
	public static void createTestData()
	{
		Map<String,Schema.RecordTypeInfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        newCompetitor = new Account(RecordTypeId = recordTypeMap.get('Competitor').getRecordTypeId(),
                          Name = 'Competitor Test 1',Market_Channel__c='Retail Channel'
                          );
        insert newCompetitor;
        
        newChatterGroup = new CollaborationGroup(Name = 'Chatter Group Test 1',
                                      CollaborationType = 'Public'
                                      );
        insert newChatterGroup;
        
        ChatterPostGroupMention__c chatterGroupSetting = new ChatterPostGroupMention__c(Name = 'Chatter Group Setting Test 1',
                                                Group_Id__c = newChatterGroup.Id,
                                                Competitive_Intelligence_Type__c = 'Intelligence'
                                                );
        insert chatterGroupSetting;
        
        newCompetitorIntelligence = new Competitor_Intelligence__c(Competitor__c = newCompetitor.Id,
                                                    Name = 'Competitor Intelligence Test 1',
                                                    Type__c = 'Intelligence'
                                                    );
        insert newCompetitorIntelligence;
	}
	
    static testMethod void autoCreateChatterPostTest() {
        //call test data creation method
        createTestData();
        //test execution begin
        Test.StartTest();
        List<Competitor_Intelligence__c> cList = new List<Competitor_Intelligence__c>();
        cList.add(newCompetitorIntelligence);
        CompetitorIntelligenceTriggerHandler.autoCreateChatterPost(cList);
        
        Test.StopTest();
        
        
    }
}