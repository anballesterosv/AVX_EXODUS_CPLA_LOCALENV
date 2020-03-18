({
   selectRecord : function(component, event, helper){      
    // get the selected record from list  
      var getSelectRecord = component.get("v.oRecord");
    // call the event 
    console.log('####custom lookup');  
      var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.  
         compEvent.setParams({"recordByEvent" : getSelectRecord });  
    // fire the event  
         compEvent.fire();
    },
})