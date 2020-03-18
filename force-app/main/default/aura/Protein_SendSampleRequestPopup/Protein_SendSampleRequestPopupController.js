({
	closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        component.set("v.isOpen", false);
        
   },
   doInit: function(component, event, helper) {
       console.log('%%start here');
       helper.checkSampleProductDataAdded(component, event,function(){
       if(component.get("v.isSamProductsAdded") == true)
       {
          // alert('please add atleast one product');
           //var dismissActionPanel = $A.get("e.force:closeQuickAction");
           ///dismissActionPanel.fire();
           component.set("v.isOpen",true);
           console.log('***isopen=='+component.get("v.isOpen"));
                      
       }
       if(component.get("v.isSamProductsAdded") == false)
       {
       	   component.set("v.isOpen",false);    
       var action = component.get('c.populateCFNASampleRequestFormData');
       var reqId = component.get("v.recordId");
       action.setParams({sampleRequestId:reqId});
       console.log('%%start here22');
       action.setCallback(this, function(response) {
            component.set("v.Spinner", false); 
           if (response.getState() == "SUCCESS") {
               var ret = response.getReturnValue();
               //console.log(ret.data);
               component.set("v.excelData",ret.data);
               var xlsData = component.get("v.excelData");
               var xls = new openXml.OpenXmlPackage(xlsData);
               var worksheet = xls.workbookPart().worksheetParts()[0];
               //console.log('%%%worksheet=='+worksheet);
               
               var XName = Ltxml.XName, 
                   XElement = Ltxml.XElement,
                   XAttribute = Ltxml.XAttribute,
                   S = openXml.S;
               var doc = worksheet.getXDocument();
               var cells = doc.descendants(S.c);
               
               helper.prepareExcelDocument(component, event, helper,cells,xls);
               /*var samReqDate = component.get("v.sampleRequestData.Request_Date__c"); 
               console.log('@@@@samReqDate=='+component.get("v.sampleRequestData") );
               helper.populateCells(cells,{"L8": samReqDate,
                "L9": 'QWERTY'});
               console.log('@@@@Saved');
               component.set("v.modifiedexcelData",xls.saveToBase64());
              console.log(xls.saveToBase64());*/
               
           }
       });
       $A.enqueueAction(action);
       component.set("v.Spinner", true); 
       
       }  
    });
   },
    
   fetchSampleRequestInfo : function(component, event, helper) {
        
		var action = component.get('c.getSampleRequestWrapperList');
        var reqId = component.get("v.recordId");
        action.setParams({sampleRequestId:reqId});
        console.log('#### reqId id=='+reqId); 
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                console.log(ret.data);
                if(ret.data.length>0)
                component.set("v.wrapper",ret.data[0]);
                console.log(component.get("v.wrapper")); 
                
            }
        });
        $A.enqueueAction(action);
	},
    sendSampleRequestForm : function(component, event, helper){
                
        console.log('#### enter page here=');
        console.log(component.get("v.recordId")); 
    	var action = component.get('c.sendSampleRequest');  
        var recId =  component.get("v.recordId");
        var wrapper = component.get("v.wrapper")
        var wrapperRecords = JSON.stringify(wrapper);
        console.log(JSON.stringify(wrapper));
        action.setParams({sampleRequestId:recId,sampleWrapper:wrapperRecords,excelData:component.get("v.modifiedexcelData")});
       
        action.setCallback(this, function(response) {
            console.log(response.getState());
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                console.log('&&&&&emailto info====');
                console.log(ret.data);
                component.set("v.mailStatus", true);
                alert('Email sent to :'+ret.data.emailTo);
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
        		dismissActionPanel.fire();
                component.set("v.isOpen", false);
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})