public class ProsDocumentHandler 
{
	private static ProsLogger prosLogger = new ProsLogger();
    
    public static Document createDocumentIfNotExist(String name, String content, String contentType, String typex)
    {
        Document document = GetDocumentByName(name);
        if(document == null)
        {
            document = createDocument(name, content, contentType, typex);
        } 
        else
        {
            if(!String.isEmpty(content)) {                
                document.Body = Blob.valueOf(content);
                update document;
            }
        }
        return document;
    }
    
    public static Document createDocument(String name, String content, String contentType, String typex)
    {
        Document document = new Document(); 
        document.Name = name;
        document.ContentType = contentType;
        document.Type = typex;
        if (!String.isEmpty(content))
        {            
        	document.Body = Blob.valueOf(content); 
        }
        Folder[] folders  =[select id from Folder where name ='PROS Smart CPQ'];
		if(folders != null && folders.size() > 0)
        {            
            document.folderId = folders[0].id; 
            insert document;  
        }      
        return document;
    }
    
    public static String ReadContent(String documentName)
    {
        Document document = GetDocumentByName(documentName);
        String documentContent;
        if(document != null)
        {
            Blob b = document.body;
			documentContent = b.toString();
        }
        else
        {
            DocumentNotExistLog(documentName);
        }
		return documentContent;
    }
    
    public static void UpdateContent(String documentName, String content)
    {
        Document document = GetDocumentByName(documentName);
        if(document != null)
        {
            document.Body = Blob.valueOf(content);
            update document;
        } 
        else 
        {
        	DocumentNotExistLog(documentName);    
        }
    }
    
    public static Document GetDocumentByName(String documentName)
    {
        List<Document> docs = [SELECT Id, Body FROM Document where name =:documentName LIMIT 1];
        if(docs != null && docs.size() > 0) 
        {
            return docs.get(0);
        }
        return null;
    }
    
    public static String BuildCsvContent(List<List<String>> rows, List<String> header)
    {
        String csvContent = String.join(header, ',') + '\n';
        for(List<String> row : rows)
        {
            csvContent += String.join(row, ',') + '\n';
        }
        return csvContent;
    }
    
    public static List<List<String>> ParseCSVByDocumentName(String documentName, Boolean skipHeaders)
    {               
        String contents = ReadContent(documentName);
        List<List<String>> allFields = ParseCSVByContent(contents, skipHeaders);        
        return allFields;
    }
    
    public static List<List<String>> ParseCSVByContent(String contents, Boolean skipHeaders) 
    {
        List<List<String>> allFields = new List<List<String>>();    
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",', 'DBLQT",');
        contents = contents.replaceAll('""','DBLQT');
        List<String> lines = SplitDocumentInLines(contents);
        Integer num = 0;
        for(String line : lines) 
        {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) 
            {
                break;
            }
            List<String> cleanFields = SplitCsvLineInFields(line);
            allFields.add(cleanFields);
        }
        if (skipHeaders) 
        {
            allFields.remove(0);
        }
        return allFields;		
    }
    
    public static List<String> SplitCsvLineInFields(String line)
    {
        List<String> fields = line.split(',');
        List<String> cleanFields = new List<String>();
        String compositeField;
        Boolean makeCompositeField = false;
        for(String field : fields) 
        {
            field = field.trim();
            if (field.startsWith('"') && field.endsWith('"')) 
            {
                cleanFields.add(field.replaceAll('DBLQT','"'));
            } 
            else if (field.startsWith('"')) 
            {
                makeCompositeField = true;
                compositeField = field;
            } 
            else if (field.endsWith('"'))
            {
                compositeField += ',' + field;
                cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                makeCompositeField = false;
            } 
            else if (makeCompositeField) 
            {
                compositeField +=  ',' + field;
            } 
            else 
            {
                cleanFields.add(field.replaceAll('DBLQT','"'));
            }
        }
        return cleanFields;
    }
    
    public static List<String> SplitDocumentInLines(String contents)
    {
        // split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try
        {
            lines = contents.split('\n');
        }
        catch(System.ListException e)
        {
            prosLogger.Error('Limits exceeded? ' + e.getMessage()).Save();
        }
        return lines;
    }
    
    private static void DocumentNotExistLog(String documentName)
    {
        String message = 'Document with name \'' + documentName + '\' does not exist.';
        prosLogger.Error(message).Save();
    }
}