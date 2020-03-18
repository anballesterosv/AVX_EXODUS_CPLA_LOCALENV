/*
*    @description:    Test class for CompetitorIntelligenceTriggerHandler.
*    @author:         Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
*    @createddate:    April 20, 2016
*/
@isTest
public class CITriggerHandler_Test {
	private CITriggerHandler_Test(){}
  @IsTest(SeeAllData=true)
    public static void autoCreateChatterPostTest() {
      Test.startTest();
        RecordType competitorRT = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor'];
        Account newCompetitor = new Account(RecordTypeId = competitorRT.Id,
                          Name = 'Competitor Test 1',Market_Channel__c='Retail Channel'
                          );
        insert newCompetitor;
        
        CollaborationGroup newChatterGroup = new CollaborationGroup(Name = 'Chatter Group Test 1',
                                      CollaborationType = 'Public'
                                      );
        insert newChatterGroup;
        
        ChatterPostGroupMention__c chatterGroupSetting = new ChatterPostGroupMention__c(Name = 'Chatter Group Setting Test 1',
                                                Group_Id__c = newChatterGroup.Id,
                                                Competitive_Intelligence_Type__c = 'Intelligence'
                                                );
        insert chatterGroupSetting;
        
        Competitor_Intelligence__c newCompetitorIntelligence = new Competitor_Intelligence__c(Competitor__c = newCompetitor.Id,
                                                    Name = 'Competitor Intelligence Test 1',
                                                    Type__c = 'Intelligence'
                                                    );
        insert newCompetitorIntelligence;
        
      Test.stopTest();
    }
}