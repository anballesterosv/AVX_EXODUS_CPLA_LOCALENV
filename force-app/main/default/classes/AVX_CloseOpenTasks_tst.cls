@isTest
public with sharing class AVX_CloseOpenTasks_tst {
    @TestSetup
    static void makeData(){
        Date yesterdayTest = Date.Today().addDays(-1);
        User userTest = AVX_DataGenerator_cls.createUser('User 1');
        insert userTest;
        Task objTask = AVX_DataGenerator_cls.createTaskOpen('yesterday',userTest,yesterdayTest,'WorkPlan','Open');
        insert objTask;
        Task objTask2 = AVX_DataGenerator_cls.createTaskOpen('today',userTest,date.Today(),'WorkPlan','Open');
        insert objTask2; 
    }

    @isTest
    static void getCatalogContentBchTest(){
        
        Test.startTest();
        Database.executeBatch(new AVX_CloseOpenTasks_batch());
        Test.stopTest();  

        System.assertEquals([SELECT Id, Status FROM Task WHERE Subject = 'today' LIMIT 1 ].Status, 'Open');
        System.assertEquals([SELECT Id, Status FROM Task WHERE Subject = 'yesterday' LIMIT 1 ].Status, Label.AVX_CloseTaskStatus_NT);

    }

    @isTest
    static void getCatalogContentSchTest(){
        
        Test.startTest();
        AVX_CloseOpenTasks_sch sh1 = new AVX_CloseOpenTasks_sch();      
        String sch = '0  00 1 3 * ?';
        String jobId = system.schedule('Test', sch, sh1);  
        Test.stopTest(); 
    }
}