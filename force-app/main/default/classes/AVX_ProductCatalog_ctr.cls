public without sharing class AVX_ProductCatalog_ctr {
    static final String FURLBASE = URL.getSalesforceBaseUrl().toExternalForm();
    //@AuraEnabled public string FURLBASE = URL.getSalesforceBaseUrl().toExternalForm() + Label.AVX_ServletShepherd;
    
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getPriceBookList(String priceBookName, Integer offSetString, String pageSizeString, String orderByTypeString, String orderByDirString, String searchValue, String filterValue) {
        String searchQuery = '';
        String filterQuery = '';
        String searchValueResponse = searchValue;
        Integer intOffSetNumber = offSetString;
        Integer intPageSize = Integer.valueOf(pageSizeString);
        Integer intTotalPages = 0;
        Integer totalLines = 0;

        Set<String> lProdIdSet = new Set<String>();        
        List<ImageResponse> lstImageLink = new List<ImageResponse>();
        List<Pricebookentry> listPriceBook = new List<Pricebookentry>();

        if(!String.isBlank(searchValue)){
            searchValue = '%' + searchValue + '%';
            searchQuery = 'AND (product2.name LIKE: searchValue OR Product2.ProductCode LIKE: searchValue) ';
        }
        if(!String.isBlank(filterValue)){
            String queryLast = '';
            List<String> filterString = new List<String>();
            filterString = filterValue.replace('[','').replace(']','').replace('"','').split(',');
            for (String strFilter : filterString) {
                List<String> splitFinal = strFilter.split('\\|');
                if(filterQuery == ''){                    
                    filterQuery += 'AND ('+ splitFinal[0] + ' = \''+String.escapeSingleQuotes(splitFinal[1])+'\' ';
                    queryLast = splitFinal[0];
                }else{
                    if(queryLast != splitFinal[0]){
                        filterQuery += ') ';
                        filterQuery += 'AND ('+ splitFinal[0] + ' = \''+String.escapeSingleQuotes(splitFinal[1])+'\' ';
                        queryLast = splitFinal[0];
                    }else{                        
                        filterQuery += ' OR '+ splitFinal[0] + ' = \''+String.escapeSingleQuotes(splitFinal[1])+'\'';
                        queryLast = splitFinal[0];
                    }
                }
            }
            filterQuery += ') ';
        }

        if(String.isBlank(searchValue)){searchValue = '';}
        if(orderByDirString == 'none' ){orderByDirString = '';}
        if(intOffSetNumber>0){intOffSetNumber = intOffSetNumber * intPageSize;}

        String queryString = 'SELECT id, toLabel(Product2.StorageCode__c), Product2.GrossWeight__c, Product2.NetWeight__c, toLabel(Product2.Family2__c), Product2.DurationConservation__c, Product2.MaterialType__c, Product2.Taxed__c, Product2.Business__c, Product2.DEFAULT_PRICING_UOM__c, Product2.Default_UOM__c, product2.name, Product2.Description, toLabel(Product2.Brand__c), Product2.ProductCode, Pricebook2Id, toLabel(Product2.Family), toLabel(Product2.PackType__c), Unitprice, Product2.SalesArea__r.SalesOrg__c FROM Pricebookentry WHERE pricebook2.name =: priceBookName '+ searchQuery + filterQuery+' ORDER BY '+orderByTypeString+' '+orderByDirString+' NULLS LAST LIMIT '+ intPageSize +' OFFSET :intOffSetNumber' ;      
        listPriceBook = Database.Query(queryString);
        String queryStringAR = 'SELECT COUNT(Id) FROM Pricebookentry WHERE pricebook2.name =: priceBookName ' + searchQuery + filterQuery ;        
        AggregateResult[] arList = Database.Query(queryStringAR);
        if(arList != null && !arList.isEmpty()){
            totalLines = arList[0].get('expr0') != null? Integer.valueOf(String.valueOf(arList[0].get('expr0'))):0;
            Double dblTotalPages = totalLines / intPageSize;
            intTotalPages = Integer.valueof(Math.mod(totalLines, 10) != 0 ? Math.round(dblTotalPages + 1) : dblTotalPages);
        }
        
        PaginationWrapper paginationWrapper = new PaginationWrapper();
            paginationWrapper.offSetResponse = offSetString;
            paginationWrapper.pageSizeResponse = intPageSize;
            paginationWrapper.orderByTypeResponse = String.valueOf(orderByTypeString);
            paginationWrapper.orderByDirResponse = String.valueOf(orderByDirString);
            paginationWrapper.totalPagesResponse = intTotalPages;
            paginationWrapper.totalLinesSizeResponse = totalLines;
            paginationWrapper.searchValueResponse = searchValueResponse;

        for (Pricebookentry pbList : listPriceBook) {            
            lProdIdSet.add(pbList.Product2Id);
        }

        if(lProdIdSet.size() > 0){
            lstImageLink = getUrlProductImage(lProdIdSet);        
        } 

        ResponseWrapper responseWrapper = new ResponseWrapper();
            responseWrapper.priceBookList = objectToWrapper(listPriceBook, lstImageLink);
            responseWrapper.paginationData = paginationWrapper;

        return responseWrapper; 
    }
    

    private static List<PriceBookWrapper> objectToWrapper(List<Pricebookentry> listPriceBook, List<ImageResponse> lstImageLink){
        //System.debug('objectToWrapper ');
        List<PriceBookWrapper> returnWrapper = new List<PriceBookWrapper>();
        try {
            if(listPriceBook.size()>0){
                for (Pricebookentry tmpPB : listPriceBook) {
                    PriceBookWrapper newPB = new PriceBookWrapper();
                        newPB.objPriceBookEntry = tmpPB;
                        newPB.id = tmpPB.Id;
                        newPB.product2Id = tmpPB.Product2Id;
                        newPB.unitPrice = Integer.valueOf(tmpPB.UnitPrice);
                        newPB.pricebook2Id = tmpPB.Pricebook2Id;
                        newPB.name = tmpPB.Product2.Name;
                        newPB.productCode = tmpPB.Product2.ProductCode;
                        newPB.packType = tmpPB.Product2.PackType__c;
                        newPB.idProduct2 = tmpPB.Product2.Id;
                        newPb.brand = tmpPB.Product2.Brand__c;
                        newPb.salesOrg = tmpPB.Product2.SalesArea__r.SalesOrg__c;
                        newPb.family = tmpPB.Product2.Family;
                        newPB.description = tmpPB.Product2.Description;
                        newPB.defaultPricingUom = tmpPB.Product2.DEFAULT_PRICING_UOM__c;
                        newPB.defaultUom = tmpPB.Product2.Default_UOM__c;
                        newPB.materialType = tmpPB.Product2.MaterialType__c;
                        newPB.taxed = tmpPB.Product2.Taxed__c;
                        newPB.business = tmpPB.Product2.Business__c;
                        newPB.storageCode = tmpPB.Product2.StorageCode__c;
                        newPB.grossWeight = tmpPB.Product2.GrossWeight__c;
                        newPB.netWeight = tmpPB.Product2.NetWeight__c;
                        newPB.family2 = tmpPB.Product2.Family2__c;
                        newPB.durationOfConservation = tmpPB.Product2.DurationConservation__c;

                    if(lstImageLink.size()>0){
                        String urlImageFirst ='';
                        List<ImageLinkkWrapper> listImgWrp =  new List<ImageLinkkWrapper>();
                        for (ImageResponse img : lstImageLink) {
                            if(newPB.product2Id == img.product2Id){
                                ImageLinkkWrapper imgWrp = new ImageLinkkWrapper();
                                imgWrp.imageName = img.imageName;
                                imgWrp.imageUrl = img.imageLink;
                                listImgWrp.add(imgWrp);
                                if(img.imageName.split('_')[1] == '1'){
                                    urlImageFirst = img.imageLink;
                                }
                            }
                        }

                        if(listImgWrp.size()>0){                            
                            newPB.urlLst = listImgWrp;
                            newPB.urlImage = newPB.urlLst[0].imageUrl;
                            if(!String.isBlank(urlImageFirst)){
                                newPB.urlImage = urlImageFirst;
                            }
                        }else{
                            newPB.urlImage = FURLBASE + '/resource/1581453208000/AVX_NoImageDefaultCatalog ';
                        }
                    }else{
                        newPB.urlImage = FURLBASE + '/resource/1581453208000/AVX_NoImageDefaultCatalog ';
                    }
                    returnWrapper.add(newPB);
                }
            }
        }catch (Exception e) {
            System.debug('error: '+e);
        }
        
        return returnWrapper;
    }
    
    private static List<ImageResponse> getUrlProductImage(Set<String> lProdIdSet) {
        List<ContentDocumentLink> lstDocumentLink = new List<ContentDocumentLink>();
        List<String> lstDocumentId = new List<String>();
        Map<Id,String> entryMap = new Map<Id,String>();
        List<ImageResponse> listResponse = new List<ImageResponse>();
        
        
        lstDocumentLink = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :lProdIdSet];
        if(!lstDocumentLink.isEmpty()){                
            for(ContentDocumentLink content : lstDocumentLink){
                lstDocumentId.add(content.ContentDocumentId);
                entryMap.put(content.ContentDocumentId, content.LinkedEntityId);
            }
        }
        List<ContentVersion> lstContentVersion = [SELECT Id, ContentDocument.Title, ContentDocument.id, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN: lstDocumentId AND ContentDocument.Title LIKE '%catalog%'];
        //System.debug('lstContentVersion: '+lstContentVersion);
        if(!lstContentVersion.isEmpty()){
            for(ContentVersion lContentDoc : lstContentVersion) {
                ImageResponse response = new ImageResponse();            
                response.product2Id = entryMap.get(lContentDoc.ContentDocumentId);
                response.imageLink = FURLBASE + Label.AVX_ServletShepherd + lContentDoc.id;
                response.imageName = lContentDoc.ContentDocument.Title;
                listResponse.add(response);
            }  
        }
        return listResponse;
    }

    private static List<Product_Catalog_Category__mdt> getCategories() {
        List<Product_Catalog_Category__mdt> lstCategories = [SELECT MasterLabel, Field_API_Name__c, Query_Field__c, toLabel(ShowName__c), Order__c, isOnQuery__c FROM Product_Catalog_Category__mdt ORDER BY Order__c ASC];
        System.debug('Lista de retorno: ' + lstCategories.size());
        return lstCategories;
    }

    @AuraEnabled(cacheable=true)
    public static List<CategoryWrapper> getFilter(String stringPriceBook){
        String fieldString = '';
        String queryString;
        String errorMsg;
        List<FilterWrapper> response = new List<FilterWrapper>();        
        List<Pricebookentry> priceBookList = new List<Pricebookentry>();
        Map<String,CategoryWrapper> mapCategoriesWrapper_full = new Map<String,CategoryWrapper>();
        Map<String,CategoryWrapper> mapCategoriesWrapper = new Map<String,CategoryWrapper>();
        Set<CategoryWrapper> setCategoriesWrapper = new Set<CategoryWrapper>();
        List<Product_Catalog_Category__mdt> lstCategories = getCategories();

        if(lstCategories.size() > 0){
            for (Product_Catalog_Category__mdt mdtList : lstCategories) {
                if(mdtList.isOnQuery__c){        
                    fieldString += ' ' +mdtList.Query_Field__c + ',';
                }    
            }
        }else{
            errorMsg = 'Metadata Product Catalog Category not found';
        }

        if(!String.isBlank(fieldString)){
            queryString = 'SELECT ' + fieldString + 'Pricebook2.name, Pricebook2Id FROM Pricebookentry WHERE Pricebook2.name =: stringPriceBook LIMIT 50000' ;        
            priceBookList = Database.Query(queryString);
            System.debug('Size price book list: ' + priceBookList.size());
        }else{
            errorMsg = 'No active query in metadata Product Catalog Category';
            System.debug('Erro no price bool list size');
        }
        
        // List<ProductWrapper> lstProductWrapper = (List<ProductWrapper>) JSON.deserialize(strProductWrapper,List<ProductWrapper>.class);
        
        String strJSONTemp;
        List<Map<String, Object>> lstJSONProducts = new List<Map<String, Object>>();
        for(Pricebookentry objProductWrapper : priceBookList){
            strJSONTemp = JSON.serialize(objProductWrapper);
            lstJSONProducts.add((Map<String, Object>) JSON.deserializeUntyped(strJSONTemp));
        }

        List<String> lstFields;
        String strOutput;
        System.debug('Lista 2: ' + lstJSONProducts);
        Map<String, Object> mapJsonDeserialized;
        for(Product_Catalog_Category__mdt objCategory : lstCategories){
            lstFields = objCategory.Field_API_Name__c.split('\\.');
            System.debug('fiel api name: ' + objCategory.Field_API_Name__c);
            System.debug('entroi no 1 for');
            for(Map<String, Object> objJSONProduct : lstJSONProducts){
                strOutput =  null;
                mapJsonDeserialized = objJSONProduct;
                for(Integer i = 0; i <  lstFields.size() ; i++){
                    if(mapJsonDeserialized != null){
                        System.debug('Entrou no if');
                        if(i == lstFields.size() - 1){
                            System.debug('Entro aqui 1');
                            strOutput = String.valueOf( mapJsonDeserialized.get(lstFields.get(i)));
                        }else{
                            System.debug('Entrou aqui 2');
                            mapJsonDeserialized = (Map<String, Object>) mapJsonDeserialized.get(lstFields.get(i));
                        }
                    }else{
                        break;
                    }
                }

                System.debug('Busca no map: ' + objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c +'--'+ strOutput);

                if(strOutput == null){
                    continue;
                }
                System.debug('Entrou no 2 for');
            
                if(!mapCategoriesWrapper_full.containsKey(objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c +'--'+ strOutput) && strOutput != null){
                    if(mapCategoriesWrapper.containsKey(objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c)){
                        if(strOutput == 'true'){
                            System.debug('Entrou no true');
                            continue;
                        }else{
                            CategoryWrapper objCategoryWrapper = mapCategoriesWrapper.get(objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c);
                            if(strOutput != 'false'){
                                objCategoryWrapper.Keyword.add(new PicklistWrapper(strOutput, objCategory.Query_Field__c + '|' + strOutput.replace(',','-')));
                                mapCategoriesWrapper.put(objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c, objCategoryWrapper);
                                mapCategoriesWrapper_full.put(objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c+'--'+strOutput ,objCategoryWrapper);
                                System.debug('Entrou no 1');
                                setCategoriesWrapper.add(objCategoryWrapper);
                            }
                        }                            
                    }else{
                        CategoryWrapper objCategoryWrapper = new CategoryWrapper(); 
                        if(objCategory.ShowName__c != null){
                            objCategoryWrapper.Type = objCategory.ShowName__c;
                        }else{
                            objCategoryWrapper.Type = objCategory.MasterLabel;
                        }
                        objCategoryWrapper.Field = objCategory.Field_API_Name__c;
                        if(strOutput == 'true'){
                            if(objCategory.ShowName__c != null){
                                objCategoryWrapper.Keyword.add(new PicklistWrapper(objCategory.ShowName__c, objCategory.Field_API_Name__c + '|true'));
                            }
                            else{
                                objCategoryWrapper.Keyword.add(new PicklistWrapper(objCategory.MasterLabel, objCategory.Field_API_Name__c + '|true'));
                            }
                            objCategoryWrapper.isUnique = true;
                            System.debug('Entrou no 2');
                            setCategoriesWrapper.add(objCategoryWrapper);
                            mapCategoriesWrapper.put(objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c, objCategoryWrapper);
                            mapCategoriesWrapper_full.put(objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c+'--'+strOutput ,objCategoryWrapper);
                        }else if(strOutput != 'false'){
                            System.debug('Entrou no 3');
                            objCategoryWrapper.Keyword.add(new PicklistWrapper(strOutput, objCategory.Query_Field__c + '|' + strOutput.replace(',','-')));
                            setCategoriesWrapper.add(objCategoryWrapper);
                            mapCategoriesWrapper.put(objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c, objCategoryWrapper);
                            mapCategoriesWrapper_full.put(objCategory.MasterLabel+'--'+objCategory.Field_API_Name__c+'--'+strOutput ,objCategoryWrapper);
                        }
                    }
                }                
            }
        }    
        System.debug('Lista de retorno wrapper: ' + setCategoriesWrapper.size());    
        return new List<CategoryWrapper>(setCategoriesWrapper);
    }
    
    public class CategoryWrapper {
        @AuraEnabled public String Type {get;set;}
        @AuraEnabled public String Field {get;set;}
        @AuraEnabled public List<PicklistWrapper> Keyword {get;set;}
        @AuraEnabled public Boolean isUnique {get;set;}
        
        public CategoryWrapper() {
            this.Type = null;
            this.Field = null;
            this.Keyword = new List<PicklistWrapper>();
            this.isUnique = false;
        }
    }
    public class PicklistWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        
        public PicklistWrapper(String strLabel, String strvalue) {
            this.label = strLabel;
            this.value = strvalue;
        }
    }


    public class FilterWrapper{        
        @AuraEnabled public String filterType{set;get;}
        @AuraEnabled public String fieldPath{set;get;}
        @AuraEnabled public List<FieldsWrapper> filterFields{set;get;}
        @AuraEnabled public String errorMSG{set;get;}
        
        public FilterWrapper() {
            this.filterType = '';
            this.fieldPath = '';
            this.filterFields = new List<FieldsWrapper>();
            this.errorMSG = null;
        }
    }
    public class FieldsWrapper{        
        @AuraEnabled public String fieldValue{set;get;}
        
        public FieldsWrapper() {
            this.fieldValue = '';
        }
    }

    public class ResponseWrapper{        
        @AuraEnabled public List<PriceBookWrapper> priceBookList{set;get;}
        @AuraEnabled public PaginationWrapper paginationData{set;get;}
        
        public ResponseWrapper() {
            this.priceBookList = new List<PriceBookWrapper>();
            this.paginationData = new PaginationWrapper();
        }
    }
    

	public class PriceBookWrapper {
        @AuraEnabled public PriceBookEntry objPriceBookEntry{set;get;}
		@AuraEnabled public String id{set;get;}
		@AuraEnabled public String product2Id{set;get;}
		@AuraEnabled public Integer unitPrice{set;get;}
		@AuraEnabled public Integer quantity{set;get;}
		@AuraEnabled public Integer weight{set;get;}
		@AuraEnabled public String pricebook2Id{set;get;}
        @AuraEnabled public String name{set;get;}
		@AuraEnabled public String productCode{set;get;}
		@AuraEnabled public String packType{set;get;}
		@AuraEnabled public String idProduct2{set;get;}
		@AuraEnabled public String urlImage{set;get;}
        @AuraEnabled public List<ImageLinkkWrapper> urlLst{set;get;}
        @AuraEnabled public String errorMsg{set;get;}
        @AuraEnabled public String family{set;get;}
        @AuraEnabled public String description{set;get;}
        @AuraEnabled public String brand{set;get;}
        @AuraEnabled public String defaultPricingUom{set;get;}
        @AuraEnabled public String defaultUom{set;get;}
        @AuraEnabled public String materialType{set;get;}
        @AuraEnabled public String business{set;get;}
        @AuraEnabled public String salesOrg{set;get;}
        @AuraEnabled public Boolean taxed{set;get;}
        @AuraEnabled public String storageCode{set;get;}
        @AuraEnabled public Double grossWeight{set;get;}
        @AuraEnabled public Double netWeight{set;get;}
        @AuraEnabled public String family2{set;get;}
        @AuraEnabled public Double durationOfConservation{set;get;}
        
        public PriceBookWrapper(){
            this.objPriceBookEntry = null;
            this.id = null;
            this.product2Id = null;
            this.unitPrice = null;
            this.quantity = null;
            this.weight = null;
            this.pricebook2Id = null;
            this.name = null;
            this.productCode = null;
            this.packType = null;
            this.idProduct2 = null;
            this.urlImage = null;
            this.urlLst = null;
            this.errorMsg = null;
            this.family = null;
            this.description = null;
            this.brand = null;
            this.defaultPricingUom = null;
            this.defaultUom = null;
            this.materialType = null;
            this.business = null;
            this.salesOrg = null;
            this.taxed = null;
            this.storageCode = null;
            this.grossWeight = null;
            this.netWeight = null;
            this.family2 = null;
            this.durationOfConservation = null;
        }
	}
    public class ImageLinkkWrapper {
		@AuraEnabled public String imageUrl{set;get;}
		@AuraEnabled public String imageName{set;get;}
        public ImageLinkkWrapper(){
            this.imageUrl = null;
			this.imageName = null;            
        }
    }
    public class ImageResponse {
		@AuraEnabled public String imageName{set;get;}
		@AuraEnabled public String product2Id{set;get;}
		@AuraEnabled public String imageLink{set;get;}
        public ImageResponse(){
            this.imageName = null;
            this.product2Id = null;
            this.imageLink = null;
        }
    }
    
    public class PaginationWrapper {
		@AuraEnabled public Integer offSetResponse{set;get;}
		@AuraEnabled public Integer pageSizeResponse{set;get;}
		@AuraEnabled public String orderByTypeResponse{set;get;}
		@AuraEnabled public String orderByDirResponse{set;get;}
		@AuraEnabled public Integer totalPagesResponse{set;get;}
		@AuraEnabled public Integer totalLinesSizeResponse{set;get;}
		@AuraEnabled public String searchValueResponse{set;get;}


        public PaginationWrapper() {
            this.offSetResponse = null;
            this.pageSizeResponse = null;
            this.orderByTypeResponse = null;
            this.orderByDirResponse = null;
            this.totalPagesResponse = null;
            this.totalLinesSizeResponse = null;
            this.searchValueResponse = null;
        }
    }
    
}