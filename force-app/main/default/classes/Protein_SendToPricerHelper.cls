/*
Author: Latha A
Description : This is a helper class for Protein_SendToPricerController class
Method Name : updateEmailMessageBeforeInsert      

*/

public with sharing class Protein_SendToPricerHelper {

    public static boolean validateSendToPricer(Product_Request__c pr,Boolean isSentToPricer)
    {
        if(pr.Sent_to_Pricer__c == true){
           return (isSentToPricer=true);   
                     
        }
        else{
            return false;  //validateFieldCheckOne(pr,isFieldCheck);
        } 
               
    }
    public static boolean validateFieldCheckOne(Product_Request__c pr,Boolean isFieldCheck)
    {
        if(pr.Sent_to_Pricer__c == false && pr.Pricing_Due_Date__c == null && pr.Pricing_Timeframe__c == null && pr.Status__c != System.Label.Protein_SentPricerStatus ){
            return (isFieldCheck = true);               
        }
        else{
             return validateFieldCheckTwo(pr,isFieldCheck);
        } 
    }
    private static boolean validateFieldCheckTwo(Product_Request__c pr,Boolean isFieldCheck)
    {
        if(pr.Sent_to_Pricer__c == false && pr.Pricing_Due_Date__c == null && pr.Pricing_Timeframe__c != null && pr.Status__c != System.Label.Protein_SentPricerStatus ){
              return (isFieldCheck = true);          
        }
        else{
           return validateFieldCheckThree(pr,isFieldCheck);
        }
    }
    private static boolean validateFieldCheckThree(Product_Request__c pr,Boolean isFieldCheck)
    {
        if(pr.Sent_to_Pricer__c == false && pr.Pricing_Due_Date__c != null && pr.Pricing_Timeframe__c == null && pr.Status__c != System.Label.Protein_SentPricerStatus ){
              return (isFieldCheck = true);               
        }
        else{
            return validateFieldCheckFour(pr,isFieldCheck);
        }
    }
    private static boolean validateFieldCheckFour(Product_Request__c pr,Boolean isFieldCheck)
    {
        if(pr.Sent_to_Pricer__c == false && pr.Pricing_Due_Date__c != null && pr.Pricing_Timeframe__c != null && pr.Status__c != System.Label.Protein_SentPricerStatus ){
                return (isFieldCheck = true);               
        }
        else{
            return validateFieldCheckFive(pr,isFieldCheck);
        }
    }
    private static boolean validateFieldCheckFive(Product_Request__c pr,Boolean isFieldCheck)
    {
        if(pr.Sent_to_Pricer__c == false && pr.Pricing_Due_Date__c == null && pr.Pricing_Timeframe__c == null && pr.Status__c == System.Label.Protein_SentPricerStatus ){
              return (isFieldCheck = true);            
        }
        else{
             return validateFieldCheckSix(pr,isFieldCheck);
        }
    }
    private static boolean validateFieldCheckSix(Product_Request__c pr,Boolean isFieldCheck)
    {
        if(pr.Sent_to_Pricer__c == false && pr.Pricing_Due_Date__c != null && pr.Pricing_Timeframe__c == null && pr.Status__c == System.Label.Protein_SentPricerStatus ){
               return (isFieldCheck = true);               
        }
        else{
             return validateFieldCheckSeven(pr,isFieldCheck);
        }
    }
    private static boolean validateFieldCheckSeven(Product_Request__c pr,Boolean isFieldCheck)
    {
        if(pr.Sent_to_Pricer__c == false && pr.Pricing_Due_Date__c == null && pr.Pricing_Timeframe__c != null && pr.Status__c == System.Label.Protein_SentPricerStatus ){
               return (isFieldCheck = true);              
        }
        return false;
    } 

}