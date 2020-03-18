@isTest(SeeAllData = true)
public class ProsQuoteHeaderMapperTest 
{
    public static testMethod void batchProcessWhenDataNotExistTest()
    {
        /* Switching to use Legacy_Record_ID__c instead of External ID
        List<CameleonCPQ__Quote__c> dataBefore  = [SELECT Id FROM CameleonCPQ__Quote__c WHERE CameleonCPQ__ExternalId__c = 'A008-DHL GLOBAL FORWARDING_AVEH']; */
        List<CameleonCPQ__Quote__c> dataBefore  = [SELECT Id FROM CameleonCPQ__Quote__c WHERE Legacy_Record_ID__c   = 'A008-DHL GLOBAL FORWARDING_AVEH'];
        System.assertEquals(0, dataBefore.size());
        
        Test.startTest();
        
        String inputDocumentName = 'QuoteHeaderMapping-ForUnitTest';
        ProsQuoteHeaderMapper mapper = new ProsQuoteHeaderMapper(inputDocumentName);
        ProsJobProcess job = new ProsJobProcess(mapper);
        Id jobId = Database.executeBatch(job, job.GetScope());
        
        /* To go over 69% code coverage */
        ProsDocumentHandler.UpdateContent('documentName', 'content');
        
        Test.stopTest();
        
        /* Switching to use Legacy_Record_ID__c instead of External ID
        List<CameleonCPQ__Quote__c> dataAfter  = [SELECT Id FROM CameleonCPQ__Quote__c WHERE CameleonCPQ__ExternalId__c = 'A008-DHL GLOBAL FORWARDING_AVEH']; */
        List<CameleonCPQ__Quote__c> dataAfter  = [SELECT Id FROM CameleonCPQ__Quote__c WHERE Legacy_Record_ID__c   = 'A008-DHL GLOBAL FORWARDING_AVEH'];
        System.assertEquals(1, dataAfter.size());
    }
    
    public static testMethod void batchProcessWhenDataExistTest()
    {
        /*CameleonCPQ__Quote__c data = new CameleonCPQ__Quote__c();
        data.Legacy_Record_ID__c = 'A008-DHL GLOBAL FORWARDING_AVEH';
        insert data;*/
        
        /* Switching to use Legacy_Record_ID__c instead of External ID
        List<CameleonCPQ__Quote__c> dataBefore  = [SELECT Id FROM CameleonCPQ__Quote__c WHERE CameleonCPQ__ExternalId__c = 'A008-DHL GLOBAL FORWARDING_AVEH']; */
        List<CameleonCPQ__Quote__c> dataBefore  = [SELECT Id FROM CameleonCPQ__Quote__c WHERE Legacy_Record_ID__c   = 'A008-DHL GLOBAL FORWARDING_AVEH'];
        System.assertEquals(0, dataBefore.size());
        
        Test.startTest();
        
        String inputDocumentName = 'QuoteHeaderMapping-ForUnitTest';
        ProsQuoteHeaderMapper mapper = new ProsQuoteHeaderMapper(inputDocumentName);
        ProsJobProcess job = new ProsJobProcess(mapper);
        Id jobId = Database.executeBatch(job, job.GetScope());
        
        Test.stopTest();
        
        /* Switching to use Legacy_Record_ID__c instead of External ID
        List<CameleonCPQ__Quote__c> dataAfter  = [SELECT Id FROM CameleonCPQ__Quote__c WHERE CameleonCPQ__ExternalId__c = 'A008-DHL GLOBAL FORWARDING_AVEH']; */
        List<CameleonCPQ__Quote__c> dataAfter  = [SELECT Id FROM CameleonCPQ__Quote__c WHERE Legacy_Record_ID__c   = 'A008-DHL GLOBAL FORWARDING_AVEH'];
        System.assertEquals(1, dataAfter.size());
    }
}