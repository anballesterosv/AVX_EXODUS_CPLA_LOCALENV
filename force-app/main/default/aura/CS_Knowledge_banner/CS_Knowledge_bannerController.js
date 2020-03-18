({
    doInit : function(component, event, helper) {
        
        console.log(component.get("v.recordId"));
        
        var action = component.get("c.getknowledgeRecs");
        action.setParams({
            'knowledgeId' : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var res= response.getReturnValue();
                console.log(res.PublishStatus);
                console.log(res.CS_Category__c);
                console.log(res.CS_Market_Channel__c );
                console.log(res.KnowledgeArticleId );
                console.log(res.id);
                
                if(res.CS_Category__c !='Credit' && res.CS_Category__c !='Transportation Schedule' && res.CS_Category__c !='Job Aid'){
                    
                    component.set('v.validated',true);
                    console.log(component.get('v.validated'));
                }
                else{
                    
                    component.set('v.validated',false);
                    console.log(component.get('v.validated'));
                }
                
            }
            
            
        });
        $A.enqueueAction(action);
        
    }
})