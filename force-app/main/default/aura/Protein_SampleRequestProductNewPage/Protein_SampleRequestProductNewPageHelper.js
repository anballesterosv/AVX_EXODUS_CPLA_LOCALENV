({
	deleteToastGrey : function() {
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title' : 'Success',
            'message' : 'Record Deleted Successfully'
        });
        showToast.fire();
	},
    
    deleteToastGreen : function() {
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title' : 'Success!',
            'message' : 'Record Deleted Successfully.',
            'type' : 'success'
        });
        showToast.fire();
    },
    
    upsertToast : function() {
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title' : 'Success!',
            'message' : 'Record(s) Added/Updated Successfully.',
            'type' : 'success'
        });
        showToast.fire();
    },
    
    validateSRProduct : function(records){
        var isValid = true;
        for(var i=0;i<records.length;i++) {
            if(records[i].srProduct != undefined) {
                console.log(records[i].srProduct.Quantity__c);
                console.log('%%%%ID test');
                console.log(records[i].relatedProduct);
                console.log(records[i].relatedProductId);
                console.log(records[i].srProduct.CFNA_Type__c);
                
                if((records[i]['relatedProductId'] == undefined) || (records[i]['relatedProductId'] == null) || (records[i]['relatedProductId'] == '') 
                   || (records[i]['srProduct']['Quantity__c'] == undefined) || (records[i]['srProduct']['Quantity__c'] == '') || (records[i]['srProduct']['Quantity__c'] <= 0)
                   || (records[i]['srProduct']['CFNA_Type__c'] == undefined) || (records[i]['srProduct']['CFNA_Type__c'] == '--- None ---'))
                {
                    isValid = false;
                    break;
                }
            }
            else
                isValid = false;  
        }
        return isValid;
    },
    
    doSaveSRProducts : function(component, data){
        var recId = component.get("v.recordId");
        var sampleBU = component.get("v.sampleBU");
        var upsertSRProducts = component.get("c.upsertSRProducts");
        var jsonData = JSON.stringify(data);
        console.log(jsonData);
        upsertSRProducts.setParams({
            sampleId : recId,
            data : jsonData,
            sampleBU : sampleBU
        });
        upsertSRProducts.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS") {
                console.log('Server call inside doSaveSRProducts finished.');
                
                var errMsg = response.getReturnValue();
                if(errMsg != '') {
                    console.log('errMsg: ' +errMsg);
                    component.set("v.isContactValidationError",true);
                    component.set("v.DisplayMsg", errMsg);
                    return;
                }
                this.upsertToast();
                component.updateSRProductsTable(); // Calling <aura:method> for reloading the SRPs table on page
                $A.get('e.force:refreshView').fire(); 
            }
        });
        $A.enqueueAction(upsertSRProducts);
    }
    
})