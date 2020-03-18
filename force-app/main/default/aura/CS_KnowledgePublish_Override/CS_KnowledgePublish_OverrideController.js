({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getknowledgeRec");
        action.setParams({
            'knowledgeId' : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
                var res1= response.getReturnValue();
                 var res,recLock;
                for(var i in res1){
                     res = res1[i];
                     recLock = i;
                }
                
               
                if(recLock == 'false'){
                   
                   
                    if(res.PublishStatus == 'Draft'){
                        if(res.CS_Category__c !='Credit' && res.CS_Category__c !='Transportation Schedule' && res.CS_Category__c !='Job Aid'){
                            
                            component.set('v.validated',"BeforeSubmit");
                            console.log(component.get('v.validated'));
                        }
                        else{
                            
                            var laction = component.get("c.publishArticle");
                            laction.setParams({
                                'knowledgeId' : res.KnowledgeArticleId
                            });
                            laction.setCallback(this, function(response) {
                                var state = response.getState();
                                
                                if (state === "SUCCESS") {
                                    var res1= response.getReturnValue();
                                    component.set("v.validated","AfterSubmit");
                                    console.log(component.get('v.validated')); 
                                    helper.reInit(component,event,helper);
                                }
                            });
                            $A.enqueueAction(laction);   
                        }
                    }
                    else{
                        
                        component.set("v.validated","AlreadySubmitted"); 
                        console.log(component.get('v.validated'));
                    }
                }else{
                    component.set("v.validated","RecordLocked"); 
                  
                }
                
            }
            
            
        });
        $A.enqueueAction(action);
        
    }
    
})