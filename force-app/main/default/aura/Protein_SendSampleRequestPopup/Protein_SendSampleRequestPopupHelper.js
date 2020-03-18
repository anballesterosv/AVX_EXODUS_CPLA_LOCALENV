({
    prepareExcelDocument : function(component, event, helper,cells,xls) {
        var action = component.get('c.fetchSampleRequestInfoOnExcel');
        var reqId = component.get("v.recordId");
        action.setParams({sampleRequestId:reqId});
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                console.log(ret.data);
                component.set("v.sampleRequestData",ret.data);
                
                console.log('@@@@@sampledata==='+component.get("v.sampleRequestData.Request_Date__c")); 
                //var samReqDate = component.get("v.sampleRequestData.Request_Date__c"); 
                this.prepareSectionProductInfo(component,cells,xls);                
            /*    this.populateCells(cells,{"L8": component.get("v.sampleRequestData.Request_Date__c"),"L9": component.get("v.sampleRequestData.Requested_Delivery_Date__c"),
                                          "K11": component.get("v.sampleRequestData.Name"),"D19": userName,"D20": userPhone,
                                          "D21": userEmail,"K20": component.get("v.sampleRequestData.Reason_for_Sample__c"),
                                          "K21": component.get("v.sampleRequestData.CFNA_Business_Unit__c"),"D24": component.get("v.sampleRequestData.End_User_Company_Name__c"),
                                          "D25": component.get("v.sampleRequestData.End_User_Contact__c"),"D26": component.get("v.sampleRequestData.End_User_Location__c"),
                                          "D43": component.get("v.sampleRequestData.Ship_to_Company__c"),"D44": component.get("v.sampleRequestData.Customer_Contact__c"),
                                          "D45": component.get("v.sampleRequestData.Street__c"),"D46": component.get("v.sampleRequestData.City__c"),
                                          "D47": component.get("v.sampleRequestData.StatePicklist__c"),"F47": component.get("v.sampleRequestData.Postal_Code__c"),
                                          "D48": component.get("v.sampleRequestData.Phone__c"),"B53": component.get("v.sampleRequestData.Additional_Notes__c")});
                
                component.set("v.modifiedexcelData",xls.saveToBase64());*/
                //console.log(xls.saveToBase64());
            }
        });
        $A.enqueueAction(action);        
        
    },
    
    prepareSectionProductInfo : function(component,cells,xls) {             
        console.log('****line 34 sam entered method');
        var action = component.get('c.fetchSampleProductInfoOnExcel');
        var reqId = component.get("v.recordId");       
        action.setParams({sampleRequestId:reqId});
        console.log('$$action=='+action);
        var productData =[];
        var offset = 30; 
        var cellData = [];        
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();                
                component.set("v.sampleProdList",ret.data);
                productData = component.get("v.sampleProdList");
                //console.log('$$productData==');
                //console.log(productData); //i <= 10;
                for(var i=0; i<productData.length && i <= 10; i++){
                    cellData["C" + (offset + i)] = productData[i].Distributor_Code__c || "";
                    cellData["E" + (offset + i)] = productData[i].Product_Name__c || "";
                    cellData["G" + (offset + i)] = productData[i].Product_Description__c || "";
                    var type = productData[i].CFNA_Type__c;
                    if(type == "Other"){
                        type = productData[i].CFNA_Other_Type__c;
                    }
                    cellData["I" + (offset + i)] = productData[i].Quantity__c;  
                    cellData["L" + (offset + i)] = type; 
                }
                console.log(cellData);
                this.populateCells(cells, cellData); 
                var userName = component.get("v.record.Name");
                var userPhone = component.get("v.record.Phone");
                var userEmail = component.get("v.record.Email");
                this.populateCells(cells,{"L8": component.get("v.sampleRequestData.Request_Date__c"),"L9": component.get("v.sampleRequestData.Requested_Delivery_Date__c"),
                                          "K11": component.get("v.sampleRequestData.Name"),"D19": userName,"D20": userPhone,
                                          "D21": userEmail,"K20": component.get("v.sampleRequestData.Reason_for_Sample__c"),
                                          "K21": component.get("v.sampleRequestData.CFNA_Business_Unit__c"),"D24": component.get("v.sampleRequestData.End_User_Company_Name__c"),
                                          "D25": component.get("v.sampleRequestData.End_User_Contact__c"),"D26": component.get("v.sampleRequestData.End_User_Location__c"),
                                          "D43": component.get("v.sampleRequestData.Ship_to_Company__c"),"D44": component.get("v.sampleRequestData.Customer_Contact__c"),
                                          "D45": component.get("v.sampleRequestData.Street__c"),"D46": component.get("v.sampleRequestData.City__c"),
                                          "D47": component.get("v.sampleRequestData.StatePicklist__c"),"F47": component.get("v.sampleRequestData.Postal_Code__c"),
                                          "D48": component.get("v.sampleRequestData.Phone__c"),"B53": component.get("v.sampleRequestData.Additional_Notes__c")});
                
                component.set("v.modifiedexcelData",xls.saveToBase64());
            }
        });
        $A.enqueueAction(action);    
    },
    
    populateCells : function(cells, values) {
        var cnt = cells.count();
        for(var i=0; i < cnt; i++){
            var c = cells.elementAt(i);
            var cellRef = c.attribute("r").simpleValue;
            var v = values[cellRef];
            if(v){
                this.replaceCellText(c, v);
            }
        }
    },
    
    replaceCellText:function(cell, text) {
        var XName = Ltxml.XName, 
            XElement = Ltxml.XElement,
            XAttribute = Ltxml.XAttribute,
            S = openXml.S;
        cell.replaceWith(new XElement(S.c, 
                                      cell.attribute("r"),
                                      cell.attribute("s"),
                                      new XAttribute("t", "str"),
                                      new XElement(S.v, text)));
    },
    
  checkSampleProductDataAdded : function(component, event,callback) {
		var action = component.get('c.checkSampleProductData');
        var reqId = component.get("v.recordId");
        action.setParams({sampleRequestId:reqId});
        console.log('****** reqId id=='+reqId); 
         action.setCallback(this, function(response) {
            component.set("v.Spinner", false); 
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                console.log(ret.data); 
                if(ret.data == true)
                {
                    
                    component.set("v.isSamProductsAdded",true);
                    console.log('****isSamProductsAdded='+component.get("v.isSamProductsAdded"));    
                    
                }
                callback();
            }
        });
        component.set("v.Spinner", true); 
        $A.enqueueAction(action);	
	}
})