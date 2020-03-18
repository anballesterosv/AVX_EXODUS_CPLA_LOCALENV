public class ProsCPQSyncer
{
	private static ProsLogger prosLogger = new ProsLogger();
    @future (callout=true)
 	public static void AsyncCreateCart (string quoteId, string activeRelease) 
    {        
		//final String[] CPQResult = CameleonCPQ.CPQRequestFormatter.sendCPQRequest(entityId, newEntityId, release, operationType, soapUrl);
        try 
        {
            System.debug('Entered...');
            final String[] CPQResult = CameleonCPQ.CPQRequestFormatter.sendCPQRequest(quoteId, '', activeRelease, 'openCartRelease', '');
            System.debug(CPQResult);
        } 
        catch (Exception e)
        {
            prosLogger.Error(e.getMessage()).Save();
        }
    }
    
    @future(callout=true)
    public static void CPQQuoteContentImport (Id Quoteid, String releaseNumber)
    {
        ApexClass[] apx = [SELECT ApiVersion FROM ApexClass c where c.Name like '%CPQRequestFormatter'];
        final String ApiVersion = (apx.size()>0?apx[0].ApiVersion.format():'20.0');
        final String wsURL = URL.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/c/'+ApiVersion+'/';
        
        // Execute a stateless action with parameters
        String actionName = 'ImportQuote'; // The action to be launched within CPQ
        String[] CPQResult = CameleonCPQ.CPQRequestFormatter.executeCPQAction(Quoteid, releaseNumber, 'openReleaseStateless', actionName, URL.getSalesforceBaseUrl().toExternalForm());
        
        if (!'0'.equals(CPQResult[0])) 
        {
            System.debug(Logginglevel.ERROR,'ERROR OCCURED WHILE CALLING CPQ :'+CPQResult[0]+' - CPQ ERROR ='+CPQResult[1]);
        }
    }
}