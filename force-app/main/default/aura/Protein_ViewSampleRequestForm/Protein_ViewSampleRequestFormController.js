({
	doInit: function(component, event, helper) {
       var action = component.get('c.populateCFNASampleRequestFormData');
       var reqId = component.get("v.recordId");
       action.setParams({sampleRequestId:reqId});
       action.setCallback(this, function(response) {
           if (response.getState() == "SUCCESS") {
               var ret = response.getReturnValue();
               //console.log(ret.data);
               component.set("v.excelData",ret.data);
               var xlsData = component.get("v.excelData");
               var xls = new openXml.OpenXmlPackage(xlsData);
               var worksheet = xls.workbookPart().worksheetParts()[0];
               
               var XName = Ltxml.XName, 
                   XElement = Ltxml.XElement,
                   XAttribute = Ltxml.XAttribute,
                   S = openXml.S;
               var doc = worksheet.getXDocument();
               var cells = doc.descendants(S.c);
               
               helper.prepareExcelDocument(component, event, helper,cells,xls);
               //var xlsData = xls.saveToBlob();
               // saveAs(xlsData, "sadasd.xls");  
              
           }
       });
       $A.enqueueAction(action);   
   }
})