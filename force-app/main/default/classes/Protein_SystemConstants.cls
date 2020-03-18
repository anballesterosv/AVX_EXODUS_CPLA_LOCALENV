public class Protein_SystemConstants {
    /*
     Description : Method to return recordType Id based on recordType name and object name
     Input: String - recordType name, SObjectType  
     Output : String ( recordType Id )  
    */
    public static String getRecordTypeId( String recordTypeName, SObjectType objectName )
    {
        String recordTypeId;
        if( recordTypeName != null && recordTypeName != '' )
        {
            //get map specific to object
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = new Map<String,Schema.RecordTypeInfo>();
            recordTypeInfo = objectName.getDescribe().getRecordTypeInfosByDeveloperName();
            
            if( recordTypeInfo.containsKey( recordTypeName ) )
            {
                recordTypeId = recordTypeInfo.get( recordTypeName ).getRecordTypeId();
            }
        }
        return recordTypeId;
    }
    

}