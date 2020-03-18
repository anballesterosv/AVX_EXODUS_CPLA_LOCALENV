/**
 * @author       Ramesh Yenugula
 * @version      1.0
 * @createddate  04.02.2020
 * @name         CS_deleteSpamCaseRecordsTest
 * @description  Test classs for batch class and CS_schedulablespamcaseClass
 * @modifiedby
 * @modifieddate
*/

@isTest 
public class CS_schedulablespamcaseClassTest{

     /**
    * @Description :
    *  The below test method will cover the 'execute' function  in  CS_schedulablespamcaseClass
    * 
    * @author : Ramesh Yenugula
    */
     static testMethod void testschedulablespamcaseClass() 
        {   
            Test.startTest();
            CS_schedulablespamcaseClass sch = new CS_schedulablespamcaseClass();
            sch.execute(null); 
            Test.stopTest();
            
       }


}