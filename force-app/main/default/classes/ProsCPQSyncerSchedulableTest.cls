@isTest
public class ProsCPQSyncerSchedulableTest {
    public static testMethod void cpqSyncerSchedulableTest (){
        Test.startTest();
        ProsCPQSyncerSchedulable testPCSS = new ProsCPQSyncerSchedulable();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, testPCSS); 
        
        Test.stopTest();
    }
}