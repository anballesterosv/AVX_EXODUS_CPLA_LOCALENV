/**
@Author Vaishali
@name CPG_ParentAccountForStrategicObjective 
@CreateDate Sept 12, 2017
@Description Helper class for ParentAccountForStrategicObjective -process builder
@Version <1.0>
@reference Process Builder -ParentAccountForStrategicObjective
*/
Public class CPG_ParentAccountForStrategicObjective {

      @InvocableMethod(label='ParentAccount StrategicObjective' description='Customer Profile relationship for child account StrategicObjective')
      public static List<ID> setParentAcc(List<ID> CustProfIds) {  
          Set<ID> custID=new set<Id>();
          custID.addAll(CustProfIds);
          Map <ID,CustomerProfile__c> mapCustProf=new Map <ID,CustomerProfile__c>([SELECT Account__c,Account__r.ID,Account__r.ParentId FROM CustomerProfile__c where ID IN:custID]);
          List<StrategicObjective__c> lstStrObj=[SELECT Account__c,CustomerProfile__c FROM StrategicObjective__c where CustomerProfile__c IN:custID];
          List<StrategicObjective__c> newlstSB=new List<StrategicObjective__c>();
          For(StrategicObjective__c sb:lstStrObj){
              if(mapCustProf.Containskey(sb.CustomerProfile__c)){
                  CustomerProfile__c custPro=mapCustProf.get(sb.CustomerProfile__c);
                  sb.Account__c=custPro.Account__r.ParentId;
                  newlstSB.add(sb);
              }
          }
          database.update(newlstSB, false);
          return null;
      }
 }