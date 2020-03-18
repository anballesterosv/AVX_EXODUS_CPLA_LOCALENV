public with sharing class AccountListController {
   
    private final static String PERCENTAGE = '%';
    private final static String SPACE ='';
    private final static String RECORD_ID ='Id';
    
    private AccountListController(){}
    public static List<List<String>> searchRecords(String objectName,String searchField, String searchTerm, Boolean startsWith) {
        String searchClause;
        if (startsWith) {
            searchClause = searchTerm + PERCENTAGE;    
        } else {
           searchClause = PERCENTAGE + searchTerm + PERCENTAGE;  
        }
     String query =  'SELECT Id, ' + searchField +' '+
                        'FROM ' + ' '+objectName + ' ' +
                        'WHERE '+searchField + ' LIKE \'' + searchClause + '\' ' +
                        'ORDER BY ' + searchField + ' ' +
                        'LIMIT 100';
        List<List<String>> records = new List<List<String>>();
        
            for (sObject s: Database.query(query)) {
            records.add(new List<String>{s.get(RECORD_ID)+SPACE, s.get(searchField)+SPACE});
        } 
        return records;
    }
}