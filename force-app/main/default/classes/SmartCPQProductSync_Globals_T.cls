@isTest
public class SmartCPQProductSync_Globals_T {
    static testmethod void testGlobalsVars(){
        System.assertNotEquals(null, SmartCPQProductSync_Globals.sWorkspace);
        System.assertNotEquals(null, SmartCPQProductSync_Globals.versionLabelWorking);
        System.assertNotEquals(null, SmartCPQProductSync_Globals.url);
        System.assertNotEquals(null, SmartCPQProductSync_Globals.user);
        //System.assertNotEquals(null, SmartCPQProductSync_Globals.password);
        System.assertNotEquals(null, SmartCPQProductSync_Globals.authToken);
        
        System.assertEquals('Default', SmartCPQProductSync_Globals.defaultString);
        System.assertEquals('PUT', SmartCPQProductSync_Globals.PUTMethod);
        System.assertEquals('POST', SmartCPQProductSync_Globals.POSTMethod);
        System.assertEquals('GET', SmartCPQProductSync_Globals.GETMethod);
        System.assertEquals('OK', SmartCPQProductSync_Globals.OKStatus);
        System.assertEquals('READY', SmartCPQProductSync_Globals.READYStatus);

    }
    
        static testmethod void testGlobalsMethods(){
       
        System.assertEquals(true, SmartCPQProductSync_Globals.isNumeric('2.3'));
        System.assertEquals(false, SmartCPQProductSync_Globals.isNumeric('Mommy'));

    }
}