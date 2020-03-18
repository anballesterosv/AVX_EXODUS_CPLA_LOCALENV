/**
   @Author - Aditi.o.sharma
   @name -  ProjectCreationValidation
   @Description - validating the products while creating Project
   @Revision- 1.0
*/
public class ProjectCreationValidation{
    Private static final String ERRORMSG = 'A project can not be inserted if no product is there';
     /*
    @methodname-projectValidation
    @aurguments-lstOfProject
    @return - void
    */
    public static void projectValidation(list<project__c> lstOfProject){
        map<id,opportunitylineitem>mapOfOppLineItem = new map<id,opportunitylineitem>([select id,opportunityid,product2id from opportunitylineitem LIMIT 49999]);
        for(opportunitylineitem objProducts:[select id,opportunityid,product2id ,name from opportunitylineitem where opportunityid !=null LIMIT 49999]){
            mapOfOppLineItem.put(objProducts.opportunityid,objProducts);
        }
        for(project__c objProject:lstOfProject){
            if(!(mapOfOppLineItem.containskey(objProject.opportunity__c)) || (mapOfOppLineItem.containskey(objProject.opportunity__c) && mapOfOppLineItem.get(objProject.opportunity__c).product2id==null)){
                objProject.addError(ERRORMSG);
            }
        } 
    }
}