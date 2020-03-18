@isTest(SeeAllData = true)
public class ProsCPQSyncerTest {
	public static testMethod void cpqSyncerTest (){
        Test.startTest();
        
        /*CameleonCPQ__Quote__c testQuote = new CameleonCPQ__Quote__c();
        insert testQuote;*/
        List<CameleonCPQ__Quote__c> dataBefore  = [SELECT Id FROM CameleonCPQ__Quote__c LIMIT 1];
        ProsCPQSyncer.CPQQuoteContentImport(dataBefore.get(0).Id, '1');
        
        ProsCPQSyncer.AsyncCreateCart('3', '1');
        
        Test.stopTest();
    }
}