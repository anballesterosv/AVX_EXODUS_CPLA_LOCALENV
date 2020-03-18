/**
   @Author - Aditi.O.Sharma
   @name -  Utils
   @Description - Used as a helper class for cloneOpportunityController 
   @Revision- 1.0
*/
public class Utils{ 
    Private Static Final string COMMASTRING = ',';
    
    
    /*
    @methodname-getCreatableFieldsSOQL
    @aurguments-objectName
    @description- Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    */
    public static string getCreatableFieldsSOQL(String objectName){
        String selects = '';
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + COMMASTRING;
            }
            if (selects.endsWith(COMMASTRING)){
                selects = selects.substring(0,selects.lastIndexOf(COMMASTRING));
            }
            
        }
        
        return  selects;
        
    }
    
}