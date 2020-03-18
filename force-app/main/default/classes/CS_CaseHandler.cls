/**
* @author       Manikandan Radhakrishnapillai
* @version      1.0
* @createddate  Feb 2, 2019
* @name         CS_CaseHandler
* @description  Helper class for Case Trigger
* @referencedby CaseTrigger
* @modifiedby   
* @modifieddate 
*/ 
public with sharing class CS_CaseHandler {
    //The Protein Case Recordtype Id
    private static final Id PROTEIN_CASE_RECORDTYPEID;
    static { //get the Protein Case Recordtype Id
        PROTEIN_CASE_RECORDTYPEID = CS_SystemConstants.getRecordTypeId( CS_SystemConstants.PROTEIN_SERVICE_RECORD_TYPE , Case.SObjectType );
    }
    
    /*
     * @description : This method will execute the business logic required to execute before insert of a case. It does the below functionality:
     *                1. For Email-to-Case and Manual Case have no ShipTo, it populate the Ship To & Account of Case, if associated Contact is related to only 1 active 
     *                   Ship To. It fetch the related Ship To of contact and assign that Ship To and Ship To's commercial account to Case.
     *                2. For Manual Case only, it populates the Account on Case with associated Ship To's commercial account.
     *                3. For Manual Case only, If Contact and ShipTo are assigned to Case, then it Validates if they are related.
     *                4. Populates the Closed When Created custom field when case is created (either email-to-case or manually) with Closed status.
     *                5. Check the Case Subject for certain keywords and update Case Priority To High for all cases created.
     *                6. Assign the entitlement to case created.
     * @param List<Case> caseList List of New Case records (Trigger.New)
    */
    public void beforeInsertCase(List<Case> caseList) {
        
        if(!caseList.isEmpty()) {
            
            //System.debug('Inside Before Insert: ' + caseList);
            
            //list of all protein cases
            List<Case> proteinCases = new List<Case>();

            Set<Id> contactIdsForSingleShipTo = new Set<Id>(); //get all contact ids of email-to-case & manual case if no ship to entered for single ship to flow
            Set<Id> shipToIdsForAccount = new Set<Id>(); //get all ship to ids of manual case to populate account
            
            //Map of collection of ContactIDs and ShipToIDs of Case to validate their relation
            Map<String, Set<Id>> mapContactAndShiptoIdsToValidate = new Map<String, Set<Id>>{'Contact' => new Set<Id>(), 'ShipTo' => new Set<Id>()};
            List<Case> caseListToValidate = new List<Case>(); //List of cases identfied for validation process
            
            Set<Id> caseAccountIds = new Set<Id>(); //Set of AccountId of Case to assign Entitlement
            
            //get all protein case and prepare data for before insert case business flows
            for(Case temp :caseList) {
                if(temp.RecordTypeId == PROTEIN_CASE_RECORDTYPEID) {
                    proteinCases.add(temp);
                    CS_CaseHelper.getShipToIdsForAccount(temp, shipToIdsForAccount); //Capture ShipTo Ids for manual case
                    CS_CaseHelper.getContactIdsForSingleShipTo(temp, contactIdsForSingleShipTo); //Capture ContactIds for email-to-case or manual case
                    //Capture ContactId and ShipTo Id combination and Cases to validate the relation between Contact and ShipTo
                    CS_CaseHelper.prepareToValidateShipToContactRelation(temp, mapContactAndShiptoIdsToValidate, caseListToValidate);
                }
            }
            
            //System.debug('contactIdsForSingleShipTo: ' + contactIdsForSingleShipTo);
            //System.debug('shipToIdsForAccount: ' + shipToIdsForAccount);
            //System.debug('mapContactAndShiptoIdsToValidate: ' + mapContactAndShiptoIdsToValidate);
            //System.debug('caseListToValidate: ' + caseListToValidate);
            
            if(!proteinCases.isEmpty()) { //if protein case found
                
                //Validate Ship To and Contact on Case are related or not
                CS_CaseHelper.validateShipToContactRelation(caseListToValidate, mapContactAndShiptoIdsToValidate);
                
                //get the Ship To related to contact if contact has only 1 active ship to
                Map<Id,CS_Ship_To_Contact_Relation__c> contactShipToRelationMap = CS_CaseHelper.getContactWithSingleShipToRelation(contactIdsForSingleShipTo);
                
                // Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
                if(contactShipToRelationMap.isEmpty()){
                    contactShipToRelationMap = CS_CaseHelper.getContactWithSingleShipToRelationFromShipTo(shipToIdsForAccount);
                }
                //  Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai                

                
                //get the Commercial Account related to Ship To for manual case
                Map<Id,Ship_To__c> mapShipToCommercialAccount = CS_CaseHelper.getShipToCommercialAccountMap(shipToIdsForAccount);
                
                //Get the high priority identifier keyword from custom metadata type
                List<CS_high_priority_Variables__mdt> priorityValues = [select MasterLabel from CS_high_priority_Variables__mdt where isRequired__c =true];
                
                //update protein case records
                for(Case temp :proteinCases) {
                    //Update ShipTo and Account of case
                    // Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
                    if(temp.ContactId != null){
                        CS_CaseHelper.populateSingleShipToAndAccount(temp, contactShipToRelationMap.get(temp.ContactId), mapShipToCommercialAccount.get(temp.CS_Ship_To__c));
                    }else if(temp.CS_Ship_To__c != null){
                        CS_CaseHelper.populateSingleShipToAndAccount(temp, contactShipToRelationMap.get(temp.CS_Ship_To__c), mapShipToCommercialAccount.get(temp.CS_Ship_To__c));
                    }
                    // Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
                    
                    //Code to populate the Closed When Created custom field when case is created with Closed status
                    temp.CS_Case_Closed_When_Created__c = (temp.Status == 'Closed' ? true : false);
                    
                    //Check Case Subject and Update Priority to High
                    checkAndUpdateCasePriorityToHigh(temp, priorityValues);
                    
                    //Set of AccountIds for determining Entitlement of case
                    getAccountIdsForEntitlement(temp.AccountId, caseAccountIds);
                }
                //method to determine entitlement of case
                assignEntitlement(proteinCases, caseAccountIds);
            }
        }
    }

    /*
     * @description This method will determines and assigns the entitlement to case based on the account id and case origin of case. If no entitlement found 
                    for the account then it assigns the entitlement of dummy account "Protein Service Account".
     * @param List<case> caseList List of New Case records (Trigger.New)
     * @param Set<Id> accountIds accounts associated with case
    */
    private void assignEntitlement(List<case> caseList, Set<Id> accountIds) {
        //System.debug('Inside assignEntitlement.');
        String dummyAccountId;
        List<Account> accList = CS_SystemConstants.getAccountByName( CS_SystemConstants.DUMMY_ACCOUNT_NAME ); //get dummy account record
        if(!accList.isEmpty()) {
            accountIds.add( accList.get(0).id );
            dummyAccountId = accList.get(0).id;
        }
        
        Map<String,Entitlement> entitlementMap = new Map<String,Entitlement>(); //Map of AccountId+EntitlementType with Entitlement Record
        //query on EntitleMent object to fetch Entitlement records related to account id
        for( Entitlement eRec: [ select id,Type,AccountId from
                                Entitlement where AccountId IN: accountIds and
                                Status =: CS_SystemConstants.ACTIVE_STATUS and ( StartDate = null or StartDate <= Today ) and
                                ( EndDate = null or EndDate >= Today )
                               ] 
           )
        {
            //prepare map of accountid+Entitlement Type and Entitlement record
            entitlementMap.put( eRec.AccountId + eRec.Type, eRec );
        }
        
        Entitlement tempEntitlement; //for caching to reduce get call on map
        String tempType; //for caching to reduce get call on map
        //assign the entitlement to cases
        for(Case temp :caseList) {
            tempType = CS_SystemConstants.CASE_ORIGIN_SUPPORT_MAP.get(temp.Origin);
            tempEntitlement = entitlementMap.get(temp.AccountId + tempType);
            //System.debug('tempEntitlement: ' + tempEntitlement + ' Type: ' + tempType);
            if(tempEntitlement == null) {
                tempEntitlement = entitlementMap.get(dummyAccountId + tempType);
            }
            temp.EntitlementId = tempEntitlement.Id;
        }
    }
    
    /*
     * @description This method will prepare the set of account ids associated with case.
     * @param Id accountId Id of account associated with case
     * @param Set<Id> caseAccountIds Set of account ids
    */
    private void getAccountIdsForEntitlement(Id accountId, Set<Id> caseAccountIds) {
        //System.debug('Inside getAccountIdsForEntitlement.');
        if( accountId != null ) {
            caseAccountIds.add( accountId );   
        }
    }
    
    /*
     * @description This method will check the case subject for certain independent keywords and if those keywords found then
                    update the Case to High priority. The method checks the below conditions
                    1. If Keyword is independently contains in subject
                    2. If subject starts with the keyword
                    3. If subject ends with the keyword
                    4. If subject only consist of the keyword
     * @param Case tempCase Case to check and update
     * @param List<CS_high_priority_Variables__mdt> priorityValues List of Keywords to check
    */
    private void checkAndUpdateCasePriorityToHigh(Case tempCase, List<CS_high_priority_Variables__mdt> priorityValues) {
        //System.debug('Inside checkAndUpdateCasePriorityToHigh.');
        for( CS_high_priority_Variables__mdt priorityValue :priorityValues ) {
            if(String.isNotBlank(tempCase.subject) && 
                    (tempCase.subject.containsIgnoreCase(' '+priorityValue.MasterLabel+' ') || tempCase.subject.startsWithIgnoreCase(priorityValue.MasterLabel+' ') 
                    || tempCase.subject.endsWithIgnoreCase(' '+priorityValue.MasterLabel) || tempCase.subject.equalsIgnoreCase(priorityValue.MasterLabel))) {
                        
                        tempCase.Priority='High';
                        break;
            }
        }
    }
    
    /*
     * @description This method check if contact is changed on the case during update.
     * @param Case newCase
     * @param Case oldCase
    */
    private Boolean isContactChanged(Case newCase, Case oldCase) {
        return (newCase.ContactId != oldCase.ContactId);
    }
    
    /*
     * @description This method check if ShipTo is changed on the case during update.
     * @param Case newCase
     * @param Case oldCase
    */
    private Boolean isShipToChanged(Case newCase, Case oldCase) {
        return (newCase.CS_Ship_To__c != oldCase.CS_Ship_To__c);
    }
    
    /*
     * @description This method check if contact or ShipTo is changed on the case during update.
     * @param Case newCase
     * @param Case oldCase
    */
    private Boolean isContactOrShipToChanged(Case newCase, Case oldCase) {
        return (isContactChanged(newCase, oldCase) || isShipToChanged(newCase, oldCase));
    }
    
    /*
     * @description This method checks if owner changed from CSR to another CSR or queue then captures the previous owner.
     * @param Case newCase
     * @param Case oldCase
    */
    private void checkAndUpdatePriorCaseOwner(Case newCase, Case oldCase) {
        //System.debug('Inside checkAndUpdatePriorCaseOwner.');
        if(String.valueOf(oldCase.OwnerId).startsWith('005')) { //Case old owner of CSR (User)
            if(!oldCase.OwnerId.equals(newCase.OwnerId)) {
                newCase.CS_Prior_Case_Owner__c = oldCase.OwnerId;
            }
        } else { //if Old Owner Queue then clears the prior owner field
            newCase.CS_Prior_Case_Owner__c = null;
        }
    }

    /*
     * @description This method checks if case is assigned to a parent case, then populates that case attributes.
     * @param Case newCase - New Values of case
     * @param Case oldCase - Prior Values of case
     * @param Map<Case, Id> childCaseMap - Map to store all child cases with theit parent case id
    */
    private void checkAndUpdateChildCase(Case newCase, Case oldCase, Map<Case, Id> childCaseMap) {
        //System.debug('Inside checkAndUpdateChildCase.');
        if(String.isNotBlank(newCase.ParentId) && newCase.ParentId != oldCase.ParentId) { //If a Parent Case is assigned
            //update case reason to Duplicate Case.
            newCase.Reason = CS_SystemConstants.CASE_REASON_DUPLICATE;
            //update case sub-reason to blank.
            newCase.CS_Case_Sub_Reason__c = null;
            //update case Reassignment reason to Merge Record
            newCase.CS_Case_Reassignment_Reason__c = String.isNotBlank(newCase.CS_Case_Reassignment_Reason__c) ? newCase.CS_Case_Reassignment_Reason__c : 'Merge Record';
            //update status to closed
            newCase.Status = CS_SystemConstants.CASE_STATUS_CLOSED;
            //populate the child case map with Case and its parent id
            childCaseMap.put(newCase, newCase.ParentId);
        }
    }
    
    /*
     * @description This method assign the parent case owner to child case owner and also capture the prior case owner on child case.
     * @param Map<Case, Id> childCaseMap - Map of child cases with theit parent case id
    */
    private void updateChildCaseOwner(Map<Case, Id> childCaseMap) {
        //System.debug('Inside checkAndUpdateChildCase.');
        if(!childCaseMap.isEmpty()) { //If a Parent Case is assigned
            Map<Id,Case> parentCaseMap = new Map<Id,Case>([Select Id, OwnerId From Case Where Id IN :childCaseMap.values()]);
            for(Case childCase :childCaseMap.keySet()) {
                Case cloneCase = childCase.clone();
                childCase.OwnerId = parentCaseMap.get(childCaseMap.get(childCase)).OwnerId;
                checkAndUpdatePriorCaseOwner(childCase, cloneCase);
            }
        }
    }

    /*
     * @description : This method will execute the business logic required to execute before update of a case. It does the below functionality:
     *                1. If either contact or ship to on case is changed then validate that both are related.
     *                2. If the Ship To is changed then update the Account on Case with new Ship To’s commercial account.
     *                3. If Case Owner is changed from 1 CSR to another CSR or Queue, then populate the Prior Case Owner field with previous owner of case.
     * @param Map<Id,case> newCaseMap Map of New Case records (Trigger.NewMap)
     * @param Map<Id,case> oldCaseMap Map of Old Case records (Trigger.oldMap)
    */
    public void beforeUpdateCase(Map<Id,case> newCaseMap, Map<Id,case> oldCaseMap) {
        
        //list of all protein cases
        List<Case> proteinCases = new List<Case>();
        
        Set<Id> shipToIdsForAccount = new Set<Id>(); //set of all changed ship to ids of cases to populate account
        Set<Id> caseIdsForChangedShipTo = new Set<Id>(); //set of case ids whose Ship To is changed
        
        //Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
        Set<Id> shipToIdsForSingleContact = new Set<Id>(); //get all contact ids of email-to-case & manual case if no ship to entered for single ship to flow
        
        //Map of collection of ContactIDs and ShipToIDs of Case to validate their relation
        Map<String, Set<Id>> mapContactAndShiptoIdsToValidate = new Map<String, Set<Id>>{'Contact' => new Set<Id>(), 'ShipTo' => new Set<Id>()};
        List<Case> caseListToValidate = new List<Case>(); //List of cases identfied for validation process
        
        //Parent Child Cases - Map of child case and its parent id
        Map<Case, Id> childCaseMap = new Map<Case, Id>();
        
        //get all protein case and prepare data for before update case flows
        for(Case temp :newCaseMap.values()) {
            if(temp.RecordTypeId == PROTEIN_CASE_RECORDTYPEID) {
                proteinCases.add(temp);
                
                //Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
                CS_CaseHelper.getShipToIdsForSingleContact(temp, shipToIdsForSingleContact); //Capture ContactIds for email-to-case or manual case
                System.debug('getShipToIdsForSingleContact : '+shipToIdsForSingleContact);
                
                //If Contact or Ship To or both changes, then mark the case for Ship To Contact Relation validation
                if(isContactOrShipToChanged(temp, oldCaseMap.get(temp.Id))) {
                    CS_CaseHelper.prepareToValidateShipToContactRelation(temp, mapContactAndShiptoIdsToValidate, caseListToValidate);
                }
                
                //If Ship To is changed, then prepare case for Account update
                if(isShipToChanged(temp, oldCaseMap.get(temp.Id))) {
                    CS_CaseHelper.getShipToIdsForAccount(temp, shipToIdsForAccount);
                    caseIdsForChangedShipTo.add(temp.Id);
                }
                
                //If Case Owner is changed from CSR1 to CSR2/Queue, then capture Prior Case Owner
                checkAndUpdatePriorCaseOwner(temp, oldCaseMap.get(temp.Id));
                
                //If Child Case, then populates child case attributes
                checkAndUpdateChildCase(temp, oldCaseMap.get(temp.Id), childCaseMap);
            }
        }
        
        //System.debug('shipToIdsForAccount: ' + shipToIdsForAccount);
        //System.debug('mapContactAndShiptoIdsToValidate: ' + mapContactAndShiptoIdsToValidate);
        //System.debug('caseListToValidate: ' + caseListToValidate);
        
        if(!proteinCases.isEmpty()) { //if protein case found

            //Validate Ship To and Contact of Case are related
            CS_CaseHelper.validateShipToContactRelation(caseListToValidate, mapContactAndShiptoIdsToValidate);

            //get the Commercial Account related to Ship To for manual case
            Map<Id,Ship_To__c> mapShipToCommercialAccount = CS_CaseHelper.getShipToCommercialAccountMap(shipToIdsForAccount);
            
            //Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai
            //get the Ship To related to contact if contact has only 1 active ship to
            Map<Id,CS_Ship_To_Contact_Relation__c> contactShipToRelationMap = CS_CaseHelper.getContactWithSingleShipToRelationFromShipTo(shipToIdsForSingleContact);
            
            //Sprint M : 46141 - Supply contacts when ship to is chosen | by Manikandan Radhakrishnapillai 
            //| passing parameter contactShipToRelationMap.get(newCaseMap.get(tempId).CS_Ship_To__c)
            //Update the Account of Case for Changed Ship To
            for(Id tempId :caseIdsForChangedShipTo) {
                CS_CaseHelper.populateSingleShipToAndAccount(newCaseMap.get(tempId), contactShipToRelationMap.get(newCaseMap.get(tempId).CS_Ship_To__c), mapShipToCommercialAccount.get(newCaseMap.get(tempId).CS_Ship_To__c));
            }
            
            //Parent Child Case Owner Id assignment
            updateChildCaseOwner(childCaseMap);
        }
    }
}