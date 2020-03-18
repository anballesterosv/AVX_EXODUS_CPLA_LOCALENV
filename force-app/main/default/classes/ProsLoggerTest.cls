@isTest
public class ProsLoggerTest 
{
	public static testMethod void infoLogTest()
    {
        List<PROS_Log__c> dataBefore = [SELECT Id FROM PROS_Log__c];
        System.assertEquals(0, dataBefore.size()); 
                
        ProsLogger prosLogger = new ProsLogger();
        String infoMessage = 'info message added.';
        prosLogger.Info(infoMessage).Save();
        
        List<PROS_Log__c> dataAfter = [SELECT Id, Message__c FROM PROS_Log__c];
        System.assertEquals(1, dataAfter.size());
        System.assertEquals(infoMessage, dataAfter[0].Message__c);
    }
    
    public static testMethod void errorLogTest()
    {
        List<PROS_Log__c> dataBefore = [SELECT Id FROM PROS_Log__c];
        System.assertEquals(0, dataBefore.size()); 
                
        ProsLogger prosLogger = new ProsLogger();
        String infoMessage = 'error message added.';
        prosLogger.Error(infoMessage).Save();
        
        List<PROS_Log__c> dataAfter = [SELECT Id, Message__c FROM PROS_Log__c];
        System.assertEquals(1, dataAfter.size());
        System.assertEquals(infoMessage, dataAfter[0].Message__c);
    }
}