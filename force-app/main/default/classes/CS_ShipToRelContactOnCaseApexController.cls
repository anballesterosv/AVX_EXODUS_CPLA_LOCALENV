/**
    * @author       Manikandan Radhakrishnapillai 
    * @version      1.0
    * @createddate  Feb 2, 2019
    * @name         CS_ShipToRelContactOnCaseApexController
    * @description  Controller class for CS_ShipToRelatedContactOnCase component
    * @referencedby CS_ShipToRelatedContactOnCase component
    * @modifiedby   
    * @modifieddate 
    */ 


public with sharing class CS_ShipToRelContactOnCaseApexController {
    
   /**
 * @Description :
 *  This function will return the 'DataTableResponse' Object which contains the 
 *  headers and body of the <lightning:Datatable>
 * 
 * @author : Manikandan Radhakrishnapillai
 * @param caseId : the record Id of the Case    
 * @return Object of type DataTableResponse is returned 
 */

    @AuraEnabled
    public static DataTableResponse getShipToContactFromCase(String caseId){  
      DataTableResponse response = new DataTableResponse(); 
      try{             
          
          populateResponse(caseId,response); 
          //Get the fields from FieldSet
          Schema.SObjectType sObjectTypeObj = Schema.getGlobalDescribe().get('CS_Ship_To_Contact_Relation__c');
          Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();            
          Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get('shipTo_ContactOnCase');
          //To hold the table hearders
          List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
          
          //Field to be queried - fetched from fieldset
          List<String> lstFieldsToQuery = new List<String>();
          
          for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
              
              DataTableColumns datacolumns = populateDataColumns(eachFieldSetMember);             
              lstDataColumns.add(datacolumns);
              lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
          }
          
          response.lstDataTableColumns = lstDataColumns;
          //Form an SOQL to fetch the data - Set the wrapper instance and return as response
          getlstDataTableData(response,lstFieldsToQuery);
          getResponseData(response,caseId);
        
      }catch(Exception e){
         printExceptions(e);
         throwException(e.getMessage());    
      }
      system.debug('CS_ShipToRelContactOnCase - response :'+response);
        return response;
    }
    

/**
     * populateResponse :
     * Utility method to populate ContactId and shipToId  
     * @param  caseId   : caseId of current case
     * @param  response : response object 
     */
    private static void populateResponse(Id caseId, DataTableResponse response){
        
        Case currentCase;
        //The final wrapper response to return to component
        if(caseId != null){
              if(Schema.sObjectType.Case.fields.ContactId.isAccessible() &&
                 Schema.sObjectType.Case.fields.CS_Ship_To__c.isAccessible()){
                currentCase = [SELECT id,ContactId,CS_Ship_To__c FROM Case WHERE id =:caseId];
              }
              if(currentCase != null){
                //The final wrapper response to return to component
          
                if(currentCase.contactId != null){
                    response.hasContact = true;
                    response.contactId = currentCase.ContactId;
                }
                
                if(currentCase.CS_Ship_To__c != null){
                    response.hasShipTo = true;
                    response.shipToId = currentCase.CS_Ship_To__c;
                }
              }
          }
    }

    /**
     * populateDataColumns        : 
     * Prepare DataColumns 
     * @param  eachFieldSetMember eachFieldSetMember description
     * @return                    return description
     */
    private static DataTableColumns populateDataColumns(Schema.FieldSetMember eachFieldSetMember){
        DataTableColumns datacolumns;
        String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
        //This way we can set the type of a column
        //We do not get the exact type from schema object which matches to lightning:datatable component structure
        if(dataType == 'datetime'){
            dataType = 'date';
        }
        
        //Create a wrapper instance and store label, fieldname and type.
        if(dataType == 'reference'){
            
            Field f = new Field('linkLabel');
            Attributes a = new Attributes(f,'_self');
            
            datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                'url', a );
        }else{
            datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                String.valueOf(eachFieldSetMember.getType()).toLowerCase(),null);
        }

        return datacolumns ;                                       
    }

    private static void getlstDataTableData(DataTableResponse response, List<String> lstFieldsToQuery){
        try{
            String query = '';
            String status = 'Active';
            String contactIdVal = '';
            if(response.contactId != null){
                contactIdVal = String.escapeSingleQuotes(response.contactId);
            }else if(response.contactId == null){
                contactIdVal = null;
            }

            if(!lstFieldsToQuery.contains('CS_Ship_To__c') && contactIdVal != null && status=='Active'){
                query = 'SELECT id, ' + String.join(lstFieldsToQuery, ',') + ',CS_Ship_To__c,CS_Ship_To__r.Name FROM CS_Ship_To_Contact_Relation__c WHERE CS_Ship_To_Status__c =: status AND CS_Contact__r.id=: contactIdVal ';
            }
            else if(contactIdVal != null){
                query = 'SELECT id, ' + String.join(lstFieldsToQuery, ',') + ',CS_Ship_To__r.Name FROM CS_Ship_To_Contact_Relation__c WHERE CS_Ship_To_Status__c =: status AND CS_Contact__r.id=:contactIdVal';
            }
            System.debug('query : '+query);
            if(query != null && query != ''){
                response.lstDataTableData = Database.query(string.escapeSingleQuotes(query));
            }
        }catch(Exception ex){
            printExceptions(ex);
            throwException(ex.getMessage());    
        }
    }
    
    /**
     * getListOfEmptyShipToContactRelation 
     * method to create an Empty List of CS_Ship_To_Contact_Relation__c when no ShipToContactRelation records are found
     * @param  lstFieldsToQuery : List of fields to be put
     * @return                  : List<CS_Ship_To_Contact_Relation__c>
     */
    private static List<CS_Ship_To_Contact_Relation__c>  getListOfEmptyShipToContactRelation(List<String> lstFieldsToQuery){
            
            CS_Ship_To_Contact_Relation__c shipToContactReln= new CS_Ship_To_Contact_Relation__c();
            for(String shipToContactRelationfield : lstFieldsToQuery){
                shipToContactReln.put(ShipToContactRelationfield,null);
            }
             
            return new List<CS_Ship_To_Contact_Relation__c>{shipToContactReln} ;
    }
 
    /**
    * @Description :
    *  This function will set the 'DataTableResponse' Object with single ship to and other attributes necessary to populate Datatable
    * 
    * @author : Manikandan Radhakrishnapillai
    * @param caseId : List<DataTableColumns> lstDataColumns,Id contactId, DataTableResponse response    
    * @return null
    */
    
    private static void getResponseData(DataTableResponse response, Id caseId){
        try{
            Boolean newShipTo = false;
            for(CS_Ship_To_Contact_Relation__c stc : (List<CS_Ship_To_Contact_Relation__c>)response.lstDataTableData){
                if(response.shipToId == stc.CS_Ship_To__c){
                    newShipTo = true;
                }
            }
            
            if(response.lstDataTableData.size() == 1 && (response.shipToId == null || newShipTo)){
                mapShipToCase(JSON.serialize(response.lstDataTableData[0]),caseId);
                response.isSingleShipTo = true;
            }
                        
        }catch(Exception ex){
                printExceptions(ex);
                throwException(ex.getMessage()); 
        }
    
    }
    
    /**
* @author       Manikandan Radhakrishnapillai
* @version      1.0
* @createddate  Feb 10, 2019
* @name       DataTableColumns
* @description  Wrapper class for  <lightning:datatable columns="?"> 
* @referencedby CS_ShipToContactRelationTrigger
* @modifiedby   
* @modifieddate 
*/ 
public class DataTableColumns {
    @AuraEnabled
    public String label;
    @AuraEnabled       
    public String fieldName;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public Attributes typeAttributes;
    
    
    //Create and set three variables label, fieldname and type as required by the lightning:datatable
    public DataTableColumns(String label, String fieldName, String type, Attributes typeAttributes){
        this.label = label;
        this.fieldName = fieldName;
        this.type = type; 
        this.typeAttributes = typeAttributes;
    }
}

/*
* @author       Manikandan Radhakrishnapillai
* @version      1.0
* @createddate  Feb 10, 2019
* @name       Attributes
* @description  Wrapper class for  attributes in DataTableColumns class 
* @referencedby Attributes
* @modifiedby   
* @modifieddate 
*/  
public class Attributes{
    @AuraEnabled
    public Field label;
    @AuraEnabled
    public String target;
    
    public Attributes(Field label, String target){
        this.label = label;
        this.target = target;
    }
    
}

/*
* @author       Manikandan Radhakrishnapillai
* @version      1.0
* @createddate  Feb 10, 2019
* @name       Field
* @description  Wrapper class for  Field in Attributes class 
* @referencedby Field
* @modifiedby   
* @modifieddate 
*/ 

public class Field{
    @AuraEnabled
    public String fieldName;
    
    public Field(String fieldName){
        this.fieldName = fieldName;
    }
}

/*
* @author       Manikandan Radhakrishnapillai
* @version      1.0
* @createddate  Feb 10, 2019
* @name       DataTableResponse
* @description  Wrapper calss to hold response - This response is used in the lightning:datatable component 
* @referencedby CS_ShipToRelatedContactOnCase component
* @modifiedby   
* @modifieddate 
*/ 

public class DataTableResponse {
    @AuraEnabled
    public List<DataTableColumns> lstDataTableColumns ;
    @AuraEnabled
    public List<sObject> lstDataTableData ;
    @AuraEnabled
    public Boolean isSingleShipTo;
    @AuraEnabled
    public Boolean hasShipTo;
    @AuraEnabled
    public Boolean hasContact;
    @AuraEnabled
    public String contactId;
    @AuraEnabled
    public String shipToId;
    
    public DataTableResponse(){
        lstDataTableColumns = new List<DataTableColumns>();
        lstDataTableData = new List<sObject>();
        isSingleShipTo = false;
        hasShipTo = false;
        hasContact = false;
    }
}

/**
 * @Description
 *  This function will return true if we are able to map a CS_Ship_To_Contact_Relation__c which is passed as JSON object 
 *  and the corresponding case whose caseid to which it needs to get associated is also passed. The code will extract 'Ship_To__c' 
 *  from the JSON Object after deserializing it.
 *
 * @author Manikandan Radhakrishnapillai
 * @date 
 * @param caseId : the record Id of the Case
 * @param jsonShipToRelation : CS_Ship_To_Contact_Relation__c object passed as a JSON object     
 * @return Boolean : true if we the update operation of Case is successful otherwise false 
 * @see      
 */
@AuraEnabled
public static Boolean mapShipToCase(String jsonShipToRelation, Id caseId){
    try{
        if(jsonShipToRelation != null){
            CS_Ship_To_Contact_Relation__c shipToRelation = (CS_Ship_To_Contact_Relation__c)JSON.deserialize(jsonShipToRelation, CS_Ship_To_Contact_Relation__c.class);
            system.debug('CS_ShipToRelContactOnCase - shipToRelation : '+shipToRelation);
            Case currentCase;
            
            if(caseId != null && Schema.sObjectType.Case.fields.CS_Ship_To__c.isAccessible()){
                currentCase = [SELECT id,CS_Ship_To__c FROM Case WHERE id=:caseId];
            }
            if(shipToRelation.CS_Ship_To__r.id != null && currentCase.CS_Ship_To__c != shipToRelation.CS_Ship_To__r.id) {
                currentCase.CS_Ship_To__c = shipToRelation.CS_Ship_To__r.id;
                if(Schema.sObjectType.Case.fields.CS_Ship_To__c.isUpdateable()){
                            update currentCase;
                }
            }
        }
    }catch(Exception e){
        printExceptions(e);
        throwException(e.getMessage());  
    }
    return true;
    
}

    /**
     * printExceptions : 
     * Utlity method to print the exceptions
     * @param  ex      : captured exception
     */
    public static void printExceptions(Exception ex){
        system.debug('CS_ShipToRelContactOnCase - Exception Cause       : ' + ex.getCause());
        system.debug('CS_ShipToRelContactOnCase - Exception LineNo      : ' + ex.getLineNumber());
        system.debug('CS_ShipToRelContactOnCase - Exception Message     : ' + ex.getMessage());
        system.debug('CS_ShipToRelContactOnCase - Exception StackTrace  : ' + ex.getStackTraceString());
    }

    /**
     * throwException  : 
     * Utlity method to throw custom exception, here only AuraHandledException
     * @param  msgInfo : custom message to be printed
     */
    public static void throwException(String msgInfo){
        throw new AuraHandledException(msgInfo);
    }


   
}