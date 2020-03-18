public class ProsUtils 
{
	public enum LogStatus
    {
        SUCCESS, FAILURE
    }
    
    public enum LogType
    {
        INFORMATION, ERROR, FATAL, WARNING, CONFIG, RECORD
    }
    
    public Static Integer GetIndexFromStringList(List<String> dataList, String valueToMatch)
    {
        Integer index = -1;
        for(String label : dataList)
        {
            index++;
            if(valueToMatch.equals(label))
            {
                break;
            }
        }
        return index;
    }
    public static void SwapValuesOnList(String oldValue, String newValue, List<String> values)
    {
        Integer index = 0;
        for (String value : values)
        {
            if (value.equals(oldValue))
            {
                values[index] = newValue;
                break;
            }
            index++;
        }
    }
    
    public static String FormatFromYYYYMMDD(String strDate)
    {
        //20171101
        if (strDate.length() == 8)
        {
            strDate = strDate.substring(0, 4) + '-' + strDate.substring(4, 6) + '-' + strDate.substring(6);
        }
        return strDate;
    }
    
    public static Date ConvertToDate(String value)
    {
        String formated = FormatFromYYYYMMDD(value);
        try
        {
            Date fsdcDate = Date.valueOf(formated);
            return fsdcDate;
        }
        Catch (exception e)
        {
            return null;
        }
    }
    
    public static Decimal ConvertToDecimal(String value)
    {
        try
        {
            Decimal dec = Decimal.valueOf(value);
            return dec;
        }
        catch(exception e)
        {
            return null;
        }
    }
    
    public static object ConvertToTheRightValue(String value)
    {
        object valueObj = ConvertToDate(value);
        if (valueObj == null)
        {
            valueObj = ProsUtils.ConvertToDecimal(value);
            if(valueObj == null) 
            {                                    
                valueObj = value;
            }
        }
        return valueObj;
    }
    
    public static Set<String> GetValuesAsSet(List<sObject> sObjects, String field)
    {
        Set<String> values = new Set<String>();
        for(sObject obj : sObjects)
        {
            values.add((String)obj.get(field));
        }
        return values;
    }
    
    public static List<String> GetValuesByIndex(List<List<String>> rows, Integer index)
    {
        List<String> externalIds = new List<String>();
        for(List<String> row : rows)
        {
            externalIds.add(row.get(index));
        }
        return externalIds;
    }
}