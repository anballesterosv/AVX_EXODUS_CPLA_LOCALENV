public class CloneOpportunityProducts {
    @AuraEnabled
    public static List<String> getCloneOpp(String oldId) {
        // Initialize setup variables
        List<String> lstReturnValues = new List<String>();
        String objectName = 'Opportunity'; 
        String query = 'SELECT';
        //Next 6 lines of code added by sakshi for CFD Pilot Requirement
        Id EggRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Egg').getRecordTypeId();
        Id BeefRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Boxed_Beef_Ground_Beef').getRecordTypeId();
        Id TurkeyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Turkey').getRecordTypeId();
        Id DeliRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deli').getRecordTypeId();
        Id OtherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Non_CPQ').getRecordTypeId();
        Id DisAndTradeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Distribution_Trade').getRecordTypeId();
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        // get all Opportunity fields
        for(String s : objectFields.keySet()) {
           query += ' ' + s + ', ';
        }

        // removing comma
        if (query.subString(query.Length()-2,query.Length()-1) == ','){
            query = query.subString(0,query.Length()-2);
        }
        // create Query statement
        query += ' FROM ' + objectName;
        // Add WHERE condition
        query += ' WHERE Id =  \''+ oldId +'\'  LIMIT 1';
        Opportunity opp = database.query(query);
        
        Opportunity newOpp = opp.clone(false, false, false, false);
        
        newOpp.Name= opp.Name.subString(opp.Name.lastIndexOf('|'),opp.Name.length());
        newOpp.OriginalName__c= opp.OriginalName__c;
        //Next 10 lines of code is edited by sakshi for CFD Pilot requirement
        
        if(opp.RecordTypeId == EggRecordTypeId
           || opp.RecordTypeId == BeefRecordTypeId
           || opp.RecordTypeId == TurkeyRecordTypeId
           || opp.RecordTypeId == DeliRecordTypeId
           || opp.RecordTypeId == OtherRecordTypeId){
               newOpp.StageName = 'Explore';
           }
        else if(opp.RecordTypeId == DisAndTradeRecordTypeId){
            newOpp.StageName = 'Discovery';
        }
        
        newOpp.amount=0;
        newOpp.closeDate=date.today().addDays(30);
        newOpp.SourceOpportunity__c = Opp.Id;
        //newOpp.Clone_Source_Opp__c = Opp.Id; // Latha added
        newOpp.IsApexCloned__c = true;
        newOpp.Result__c = null;
        newOpp.RenewalDate__c = null;
        newOpp.Pricing_Start_Date__c = null;
        newOpp.Pricing_End_Date__c = null;
        newOpp.Lost_Reason__c =null;
        newOpp.Count_of_CMROs__c =0; /// added by Mani @21/10/2019
        newOpp.HasOpportunityProductRequest__c = false; ///added by Mani @21/10/2019
        newOpp.Number_of_Cloned_Opp__c = 0;// added by Mani @24/10/2019 for Sprint M 
        newOpp.OwnerId = UserInfo.getUserId(); //Added by Sri Harshitha as per the User Story with the VSTS ID #38137.
        newOpp.Renewed_Opportunity__c = FALSE; // Added by Sri Harshitha on 30/10/2019 as per US #46510 in Sprint-N (Protein Sales).
        insert newOpp;
        //The below code till insertion of newProdList has been modified by Sri Harshitha as requested by Cory Thompson reg. Inactive Products Issue as per the User Story with the VSTS ID #41678.
        Boolean hasInactiveProduct = false;
        if (opp.HasOpportunityLineItem == true) {
            List<OpportunityLineItem> products = [SELECT ActiveProduct2__c,ActualAnnualVolume0Year__c,ActualAnnualVolume1Year__c,ActualAnnualVolume2Year__c,ActualAnnualVolume3Year__c,ActualAnnualVolumeCM0Year__c,ActualAnnualVolumeCM1Year__c,ActualAnnualVolumeCM2Year__c,ActualAnnualVolumeCM3Year__c,Application__c,Category__c,Competitor_Accounts__c,CreatedById,ServiceDate,Discount,ExtendedFloorPrice__c,ExtendedStartPrice__c,ExtendedTargetPrice__c,Floor__c,IfLostCompetitorLostTo__c,IfWonCompetitorWonAgainst__c,KGUnitPrice__c,KGUnitQuantity__c,LastModifiedById,Description,ListPrice,Margin__c,OpportunityId,Payment_Terms__c,LBUnitPrice__c,LBUnitQuantity__c,PricingGuidanceStartPrice__c,PricingGuidanceTargetPrice__c,PricingGuildanceFloorPrice__c,Product2Id,ProductCode,ProductWeightQuantityImperial__c,ProductWeightQuantityMetric__c,ProductWeightUnitOfMeasureMetric__c,ProductWeightUnitOfMeasureImperial__c,Renewal_Status__c,Project_Product_Id__c,ProjectedAnnualVolume0Year__c,ProjectedAnnualVolume1Year__c,ProjectedAnnualVolume2Year__c,ProjectedAnnualVolume3Year__c,ProjectedAnnualVolumeCM0Year__c,ProjectedAnnualVolumeCM1Year__c,ProjectedAnnualVolumeCM2Year__c,ProjectedAnnualVolumeCM3Yearr__c,Quantity,UnitPrice,Start__c,Subtotal,Target__c,UnitOfMeasure__c,PricebookEntryId FROM OpportunityLineITem WHERE OpportunityId = :opp.Id];
            List<OpportunityLineItem> newProdList = new List<OpportunityLineItem>();
            for (OpportunityLineItem prod:products) {
                if(prod.ActiveProduct2__c) {
                    OpportunityLineItem newProd = prod.clone(false, false, false, false);
                    newProd.OpportunityId = newOpp.id;
                    newProd.UnitPrice=0;
                    newProdList.add(newProd);
                }
                else {
                    hasInactiveProduct = true;
                }
            } 
            insert(newProdList);       
        }
        // Code added by Sri Harshitha ends here--------------------------------
        
         //Insert Product Groups
        list<Product_Group__c> lstProdGroups = new list<Product_Group__c>();
        list<Product_Group__c> newlstProdGroups = new list<Product_Group__c>();
        lstProdGroups  = [select Brand__c, Branded__c, Grade__c, Product_Family__c, Protein__c, Protein_Category__c, Sub_Protein__c, Unit_of_Mesure__c, Volume__c from Product_Group__c  where Opportunity__c= :opp.Id];
        if(!lstProdGroups.isEmpty()){
            for(Product_Group__c pg:lstProdGroups){
                Product_Group__c newPG = pg.clone(false, false, false, false);
                newPG.Volume__c = 0;
                newPG.opportunity__c = newOpp.id;
                newlstProdGroups.add(newPG);
            }
        }
        if(!newlstProdGroups.isEmpty()){
            insert newlstProdGroups;
        }
        
        //Commenting out Quote creation - as this is being handled by PROS for cloned Opportunities
        /**
        //Add Active Quote & Quote Line Items
        list<CameleonCPQ__Quote__c> oppQuote = new list<CameleonCPQ__Quote__c>();
        CameleonCPQ__Quote__c oppQuoteCloned = new CameleonCPQ__Quote__c();
        oppQuote= [select Primary_Quote__c,CameleonCPQ__AccountId__c,FOBDelivered__c,CameleonCPQ__ActiveRelease__c,CameleonCPQ__BeingSynchronized__c,CameleonCPQ__BillingCity__c,CameleonCPQ__BillingCountry__c,CameleonCPQ__BillingName__c,CameleonCPQ__BillingState__c,CameleonCPQ__BillingStreet__c,CameleonCPQ__BillingPostalCode__c,CameleonCPQ__CameleonTouch__c,CameleonCPQ__CameleonTouchParam__c,CameleonCPQ__CommPctPrice1__c,CameleonCPQ__CommPctPrice2__c,CameleonCPQ__PrimaryContactId__c,CameleonCPQ__ContractAmendmentDate__c,CameleonCPQ__ContractEndDate__c,CameleonCPQ__ContractStartDate__c,CameleonCPQ__ContractType__c,CameleonCPQ__Expires__c,CameleonCPQ__ExternalId__c,Formula_Type__c,OpportunityId__c,OwnerId,CameleonCPQ__ParentAccountId__c,CameleonCPQ__ParentQuoteId__c,Pricing_End_Date__c,Pricing_Start_Date__c,Pricing_Type__c,Name,CameleonCPQ__ShippingCity__c,CameleonCPQ__ShippingCountry__c,CameleonCPQ__ShippingName__c,CameleonCPQ__ShippingState__c,CameleonCPQ__ShippingStreet__c,CameleonCPQ__ShippingPostalCode__c,CameleonCPQ__PROS_SoldToCity__c,CameleonCPQ__PROS_SoldToCountry__c,CameleonCPQ__PROS_SoldToName__c,CameleonCPQ__PROS_SoldToState__c,CameleonCPQ__PROS_SoldToStreet__c,CameleonCPQ__PROS_SoldToPostalCode__c,CameleonCPQ__Status__c,CameleonCPQ__TotalComm1__c,CameleonCPQ__TotalComm2__c,CameleonCPQ__TotalPrice1__c,CameleonCPQ__TotalPrice2__c from CameleonCPQ__Quote__c where OpportunityId__c=:opp.Id and Primary_Quote__c=true order by Lastmodifieddate desc Limit 1];
        if(!oppQuote.isEmpty()){
            oppQuoteCloned = oppQuote[0].clone(false,true,false,false);
            oppQuoteCloned.OpportunityId__c = newOpp.id;
            insert oppQuoteCloned;
            
           
            //Add Quote Line Items
            list<CPQQuoteLineItem__c> oppQLI = new list<CPQQuoteLineItem__c>();
            list<CPQQuoteLineItem__c> oppQLICloned = new list<CPQQuoteLineItem__c>();
            oppQLI = [select Actual_Volume__c,ContractSyncID__c,Initial_Volume__c,PROS_Quote__c,Name,USDA_IMPS__c from CPQQuoteLineItem__c where PROS_Quote__c=:oppQuote[0].id];
            if(!oppQLI.isEmpty()){
                oppQLICloned = oppQLI.deepclone(false,true,false);
                for(CPQQuoteLineItem__c qli:oppQLICloned){
                    qli.PROS_Quote__c = oppQuoteCloned.id;
                }
                insert oppQLICloned;
            }
        }      
        **/
        lstReturnValues.add(newOpp.id);
        if(hasInactiveProduct)
            lstReturnValues.add('true');
        else
            lstReturnValues.add('false');
        System.debug('lstReturnValues: '+lstReturnValues);
        return lstReturnValues;
    }
}