@isTest
Public class SmartCPQProductSync_JobSpec_T{
    Static testmethod void testVersionGenerator(){ 
        //Setting Email Id 
        //RecipientEmailAddressForCPQ__c   setEmail = new RecipientEmailAddressForCPQ__c();
        //setEmail.Email__c = 'abc@abc.com'; 
        //setEmail.Name = 'abc';            
        //Insert setEmail;
        
        //
        CPQResetSetting__c reset = new CPQResetSetting__c();
        reset.Name = 'Default';
        reset.Count__c = 12;
        reset.hasNextRecords__c = 'false';
        Insert reset;
        
        String jsonStr = '{"EJSNOTSTARTED1":"0","EJSLOADING1":"1","EJSLOADWAITING1":"2","EJSVERSIONING1":"3","EJSVERSIONWAITING1":"4","sProductCode_Beg1":"null"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartCPQProductSync_Test_Mock_Callout());
        //SmartCPQProductSync_JobSpec cp = new CPQ006_JobSpec();
        
        SmartCPQProductSync_JobSpec cc = new SmartCPQProductSync_JobSpec();        
        HttpResponse res = null;
        //SmartCPQProductSync_JobSpec.thiss(jsonStr);
        SmartCPQProductSync_JobSpec.getProductCodeBeg(jsonStr);
        SmartCPQProductSync_JobSpec.getProductCodeEnd(jsonStr);
        SmartCPQProductSync_JobSpec.getVersionLabelDyn(jsonStr);
        SmartCPQProductSync_JobSpec.getOffsetCount(jsonStr);
        SmartCPQProductSync_JobSpec.run(jsonStr);
        SmartCPQProductSync_JobSpec.signalFinished(jsonStr,res);
        SmartCPQProductSync_JobSpec.signalFinished(jsonStr);
        SmartCPQProductSync_JobSpec.getChronString(1);
        cc.schedule();
        cc.next(res);
        cc.sendEmail('SUCCESS','TEST');
        cc.resetCPQResetSetting();
        Test.stopTest();
    }
}