/**
    * @author       Manikandan Radhakrishnapillai 
    * @version      1.0
    * @createddate  19 Sep, 2019
    * @name         CS_ContactsRelShipToOnCaseApexController
    * @description  Controller class for CS_ContactsRelatedShipToOnCase component
    * @referencedby CS_ContactsRelatedShipToOnCase component
    * @modifiedby   
    * @modifieddate 
    */ 

public with sharing class CS_ContactsRelShipToOnCaseApexController {
     
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
    public static DataTableResponse getContactsRelToShipToFromCase(String caseId){  
      DataTableResponse response = new DataTableResponse(); 
      try{             

          populateResponse(caseId,response);   
          //Get the fields from FieldSet
          Schema.SObjectType sObjectTypeObj = Schema.getGlobalDescribe().get('CS_Ship_To_Contact_Relation__c');
          Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();            
          Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get('contacts_shipToOnCase');
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
      system.debug('CS_ContactsRelShipToOnCase - response :'+response);
        return response;
    }
    

    /**
     * populateResponse : It populates dataTableResponse Object with contactId and ShipTo id if any selected from the UI
     * @param  caseId   : caseId of the current case
     * @param  response : response ref object to be passed from the main method
     */
    private static void populateResponse(Id caseId, DataTableResponse response){
        Case currentCase;
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
     * populateDataColumns : It populates DataTableColumns for the final response Object, it mainly contains the 
                             header for the main Table on the page
     * @param  eachFieldSetMember : It contains the field Information to be displayed on the UI
     * @return                    : DataTableColumns object
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

        return datacolumns;                                         
    }
 
    /**
    * @Description :
    *  This function will set the 'DataTableResponse' Object with single Contact and other attributes necessary to populate Datatable
    * 
    * @author : Manikandan Radhakrishnapillai
    * @param caseId : List<DataTableColumns> lstDataColumns,Id contactId, DataTableResponse response    
    * @return null
    */
    
    private static void getResponseData(DataTableResponse response, Id caseId){
        try{
            if(!response.lstDataTableData.isEmpty()){
                Boolean newContact = false;
                for(CS_Ship_To_Contact_Relation__c stc : (List<CS_Ship_To_Contact_Relation__c>)response.lstDataTableData){
                    if(response.contactId == stc.CS_Contact__c){
                        newContact = true;
                    }
                }
                
                if(response.lstDataTableData.size() == 1 && (response.contactId == null || newContact)){
                    mapContactToCase(JSON.serialize(response.lstDataTableData[0]),caseId);
                    response.isSingleContact = true;
                }
            }            
        }catch(Exception ex){
            printExceptions(ex);
            throwException(ex.getMessage());    
        }
    
    }

    /**
     * getlstDataTableData : populates the list of sObjects which infact are the rows to be displayed on the UI in 
                            lightning datatable
     * @param  response    : final DataTableResponse objects refernece
     * @param  lstFieldsToQuery : fields to be queried
     */
    private static void getlstDataTableData(DataTableResponse response, List<String> lstFieldsToQuery){
        try{
            String query = '';
            String status = 'Active';
            String shipToIdVal = '';
            if(response.shipToId != null){
                shipToIdVal = String.escapeSingleQuotes(response.shipToId);
            }else if(response.shipToId == null){
                shipToIdVal = null;
            }

            if(!lstFieldsToQuery.contains('CS_Contact__c') && shipToIdVal != null && status=='Active'){
                query = 'SELECT id, ' + String.join(lstFieldsToQuery, ',') + ',CS_Contact__c,CS_Contact__r.Name,CS_Contact__r.id FROM CS_Ship_To_Contact_Relation__c WHERE CS_Contact_Status__c =: status AND CS_Ship_To__r.id=: shipToIdVal';
            }
            else if(shipToIdVal != null){
                query = 'SELECT id, ' + String.join(lstFieldsToQuery, ',') + ',CS_Contact__r.Name,CS_Contact__r.id FROM CS_Ship_To_Contact_Relation__c WHERE CS_Contact_Status__c = :status AND CS_Ship_To__r.id=: shipToIdVal';
            }
            System.debug('query : '+ query);
            if(query != null && query != ''){
                response.lstDataTableData = Database.query(string.escapeSingleQuotes(query));
            }
        }catch(Exception ex){
            printExceptions(ex);
            throwException(ex.getMessage());    
        }
    }

    
    /**
    * @author       Manikandan Radhakrishnapillai
    * @version      1.0
    * @createddate  Sep 19, 2019
    * @name       DataTableColumns
    * @description  Wrapper class for  <lightning:datatable columns="?"> 
    * @referencedby CS_ContactsRelatedShipToOnCase component
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
    * @createddate  Sep 19, 2019
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
    * @createddate  Sep 19, 2019
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
    * @createddate  Sep 19, 2019
    * @name       DataTableResponse
    * @description  Wrapper calss to hold response - This response is used in the lightning:datatable component 
    * @referencedby CS_ContactsRelatedShipToOnCase component
    * @modifiedby   
    * @modifieddate 
    */ 

    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns;
        @AuraEnabled
        public List<sObject> lstDataTableData;
        @AuraEnabled
        public Boolean isSingleContact;
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
            isSingleContact = false;
            hasShipTo = false;
            hasContact = false;
        }
        
    }

    /**
    * @Description
    *  This function will return true if we are able to map a CS_Ship_To_Contact_Relation__c which is passed as JSON object 
    *  and the corresponding case whose caseid to which it needs to get associated is also passed. The code will extract 'ContactId' 
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
    public static Boolean mapContactToCase(String jsonShipToRelation, Id caseId){
        try{
            if(jsonShipToRelation != null){
                System.debug('CS_ContactsRelShipToOnCase - jsonShipToRelation : '+jsonShipToRelation);
                CS_Ship_To_Contact_Relation__c shipToRelation = (CS_Ship_To_Contact_Relation__c)JSON.deserialize(jsonShipToRelation, CS_Ship_To_Contact_Relation__c.class);
                system.debug('CS_ContactsRelShipToOnCase - shipToRelation : '+shipToRelation);
                Case currentCase;
                
                            
                if(caseId != null && Schema.sObjectType.Case.fields.contactId.isAccessible()){
                        currentCase = [SELECT id,contactId FROM Case WHERE id=:caseId];
                }

                if(shipToRelation.CS_Contact__r.id != null && currentCase.contactId != shipToRelation.CS_Contact__r.id) {
                    currentCase.contactId = shipToRelation.CS_Contact__r.id;
                    if(Schema.sObjectType.Case.fields.contactId.isUpdateable()){
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

    public static void printExceptions(Exception ex){
        system.debug('CS_ContactsRelShipToOnCase - Exception Cause       : ' + ex.getCause());
        system.debug('CS_ContactsRelShipToOnCase - Exception LineNo      : ' + ex.getLineNumber());
        system.debug('CS_ContactsRelShipToOnCase - Exception Message     : ' + ex.getMessage());
        system.debug('CS_ContactsRelShipToOnCase - Exception StackTrace  : ' + ex.getStackTraceString());
    }

    public static void throwException(String msgInfo){
        throw new AuraHandledException(msgInfo);
    }
}