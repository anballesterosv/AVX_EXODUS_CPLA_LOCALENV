/*
*    @description:    Controller for AddOpportunityCompetitorProducts page.
*    @author:         Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
*    @createddate:    April 15, 2016
*/
public class AddOpportunityCompetitorProductsCX {

    public Opportunity currentOpportunity {get;set;}
    //public String selectedCompetitorProductName {get;set;}
    public Id selectedCompetitorProductId {get;set;}
    public List<CompetitorProductsWrapper> productWrapperList {get; set;}
    public List<SearchedCompetitorProductsWrapper> searchedProductWrapperList {get; set;}
    public Id oppCustomerId;
    
    public AddOpportunityCompetitorProductsCX(ApexPages.StandardSetController controller) {
        //get the current page opportunity
        currentOpportunity = [SELECT Id, Name, AccountId, Account.Name FROM Opportunity WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        oppCustomerId = currentOpportunity.AccountId;
        productWrapperList = new List<CompetitorProductsWrapper>();
        searchedProductWrapperList = new List<SearchedCompetitorProductsWrapper>();
        searchMore = false;
    }
    
    public List<selectOption> getCompetitors() {
        List<selectOption> options = new List<selectOption>();
        for (Account competitor : [SELECT Id, Name FROM Account ORDER BY Name ASC]) {
            options.add(new selectOption(competitor.Id, competitor.Name));
        }
        return options;
    }
    
    public List<selectOption> getCompetitorProducts() {
        List<selectOption> options = new List<selectOption>();
        if(currentOpportunity.AccountId != null) {
            //get the existing opportunity competitor products
            List<Opportunity_Competitor_Product__c> existingOppProductsList = [SELECT Id, Name, Competitor_Product__c FROM Opportunity_Competitor_Product__c WHERE Opportunity__c = :currentOpportunity.Id];
            Set<Id> productIds = new Set<Id>();
            for(Opportunity_Competitor_Product__c oppProduct : existingOppProductsList) {
                productIds.add(oppProduct.Competitor_Product__c);
            }
            
            if(!(productIds.isEmpty())) {
                //get all competitor products of selected competitor
                List<Competitor_Product__c> competitorProductsOfselectedCompetitor = [SELECT Id, Name, Competitor__c FROM Competitor_Product__c WHERE Competitor__c = :currentOpportunity.AccountId AND Id NOT IN :productIds ORDER BY Name ASC];
                if(competitorProductsOfselectedCompetitor.size() > 0) {
                    for (Competitor_Product__c competitorProduct : competitorProductsOfselectedCompetitor) {
                        options.add(new selectOption(competitorProduct.Id, competitorProduct.Name));
                    }
                } else {
                    options.add(new selectOption('', 'No Competitor Products'));
                }
            }
        }
        return options;
    }
    
    public void loadSelectedCompetitorProductsTable() {
    	if(selectedCompetitorProductId == null) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'No Product selected.'));
        } else {
        //if(selectedCompetitorProductId != null || selectedCompetitorProductId != '') {
        	Map<Id, Id> mapSelectedCompetitorProduct = new Map<Id, Id>();	//
        	if(productWrapperList.size() > 0) {
        		for(CompetitorProductsWrapper wrapper : productWrapperList) {
        			mapSelectedCompetitorProduct.put(wrapper.compProduct.Id, wrapper.compProduct.Id);
        		}
        	}
            for(Competitor_Product__c competitorProduct : [SELECT Id, Name, Competitor__r.Name, Price_Point__c, Positioning__c, Sub_sector_segment_application__c, Total_Capacity__c, Competitor__c FROM Competitor_Product__c WHERE Id = :selectedCompetitorProductId]) {
                if(!(mapSelectedCompetitorProduct.isEmpty())) {
                	if(competitorProduct.Id != mapSelectedCompetitorProduct.get(competitorProduct.Id)) {
                		productWrapperList.add(new CompetitorProductsWrapper(competitorProduct, false));
                	} else {
                		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Product already added.'));
                	}
                }
            }
        }
    }
    
    public class CompetitorProductsWrapper {
        public Competitor_Product__c compProduct {get;set;}
        public Boolean isDelete {get;set;}
        
        public CompetitorProductsWrapper(Competitor_Product__c compProduct, Boolean isDelete) {
            this.compProduct = compProduct;
            this.isDelete = isDelete;
        }
    }
    
    public Id prodId {get;set;}
    public void removeProduct() {
        Competitor_Product__c prod = [SELECT Id, Name FROM Competitor_Product__c WHERE Id = :prodId];
        for(Integer i=productWrapperList.size()-1; i>=0; i--) {
            if(prod.id == productWrapperList[i].compProduct.id) {
                productWrapperList.remove(i);
            }
        }
    }
    
    public PageReference save() {
        PageReference gotorecord;
        if(productWrapperList.size() > 0) {
            List<Opportunity_Competitor_Product__c> productsToaddList = new List<Opportunity_Competitor_Product__c>();
            List<Competitor_Product__c> competitorProductsToAdd = new List<Competitor_Product__c>();
            for(CompetitorProductsWrapper wrapper : productWrapperList) {
                Opportunity_Competitor_Product__c oppProduct = new Opportunity_Competitor_Product__c();
                    oppProduct.Opportunity__c = currentOpportunity.Id;
                    oppProduct.Competitor_Product__c = wrapper.compProduct.id;
                    oppProduct.Customer__c = oppCustomerId;
                productsToaddList.add(oppProduct);
                
                /*Competitor_Product__c compProduct = new Competitor_Product__c();
                    compProduct.Opportunity__c = currentOpportunity.Id;
                    compProduct.Competitor__c = wrapper.compProduct.Competitor__c;
                competitorProductsToAdd.add(compProduct);*/
            }
                
            try {
                if(productsToaddList.size() > 0) {
                    insert productsToaddList;
                }
                /*
                if(competitorProductsToAdd.size() > 0) {
                    insert competitorProductsToAdd;
                }*/
                
                gotorecord = new PageReference('/' + currentOpportunity.Id);
                gotorecord.setRedirect(true);
                return gotorecord;
            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            }
        } else {
            gotorecord = null;
        }
        return gotorecord;
    }
    
    public PageReference cancel() {
        PageReference gotorecord = new PageReference('/' + currentOpportunity.Id);
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    public Boolean searchMore {get;set;}
    public String searchText {get;set;}
    
    //use to display the search section
    public void searchButton() {
        searchMore = true;
    }
    
    //use to display search results
    public void searchProducts() {
        //start search
        if(searchText != null) {
            //check for text length
            if(searchText.length() > 2) {
                List<String> parts = searchText.split(' ');
                List<String> allTexts = new List<String>();
                for(String s : parts) {
                    s = ' ' + s + ' ';
                    String s2 = s.replaceAll(' ', '%');
                    allTexts.add(s2);
                }
                
                //get all searched competitor products
                List<Competitor_Product__c> searchedCompetitorProductsList = [SELECT Id, Name, Competitor__c FROM Competitor_Product__c WHERE Competitor__c = :currentOpportunity.AccountId AND Name LIKE :allTexts];
                if(searchedCompetitorProductsList.size() > 0) {
                    for(Competitor_Product__c compProduct : searchedCompetitorProductsList) {
                        //put all searched competitor products to the searchedProductsWrapper
                        searchedProductWrapperList.add(new SearchedCompetitorProductsWrapper(compProduct, false));
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No results.'));
                }
                
            } else if(searchText.length() > 0 && searchText.length() < 3) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Minimum characters: 2'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter text.'));
        }
    }
    
    public class SearchedCompetitorProductsWrapper {
        public Competitor_Product__c compProduct {get;set;}
        public Boolean isDelete {get;set;}
        
        public SearchedCompetitorProductsWrapper(Competitor_Product__c compProduct, Boolean isDelete) {
            this.compProduct = compProduct;
            this.isDelete = isDelete;
        }
    }
    
    public Id searchedProdId {get;set;}
    public void addSearchedProduct() {
        if(searchedProdId != null || searchedProdId != '') {
            //add the selected product to the competitor products list
            for(Competitor_Product__c competitorProduct : [SELECT Id, Name, Competitor__r.Name, Price_Point__c, Positioning__c, Sub_sector_segment_application__c, Total_Capacity__c, Competitor__c FROM Competitor_Product__c WHERE Id = :searchedProdId]) {
                productWrapperList.add(new CompetitorProductsWrapper(competitorProduct, false));
            }
            
            //after adding the selected product to productWrapperList, remove it to the search results list
            Competitor_Product__c prod = [SELECT Id, Name FROM Competitor_Product__c WHERE Id = :searchedProdId];
            for(Integer i=searchedProductWrapperList.size()-1; i>=0; i--) {
                if(prod.id == searchedProductWrapperList[i].compProduct.id) {
                    searchedProductWrapperList.remove(i);
                }
            }
            
            //if productWrapperList is empty, hide the search section
            if(searchedProductWrapperList.isEmpty()) {
                searchMore = false;
            }
        }
    }
    
    public void hideSearchSection() {
        searchMore = false;
    }
}