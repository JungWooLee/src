/**
* Object        : product__c
* Function      : productController 
* Author        : JungWoo LEE.
* Date          : 2016. 8. 29 
* Description   : 
*/
public with sharing class productController {
	public Boolean detailflag{get;set;}
    public String pageMode{get;set;}
    public String sectionSeq{get;set;}
    public String productId{get;set;}
    public String productDetailId{get;set;}
    
    public Product__c product{get;set;}			//상품입력 object변수
    public Account account{get;set;}			//거래처 object변수
    public ProductDetail__c editProductDetail{get;set;}
    
    public List<ProductDetail__c> productDetailList{get;set;}
    public List<ProductDetail__c> productDetailDeleteList{get;set;}
    
    public productController(ApexPages.StandardController stdCon){
    	detailflag = false;
        productId = stdCon.getId();
        sectionSeq = Apexpages.currentPage().getParameters().get('seq'); 
        productDetailList = new List<ProductDetail__c>();
        productDetailDeleteList = new List<ProductDetail__c>();
        if(productId == null){
            pageMode = 'E';
            product = new Product__c();
        }else{
            pageMode = 'V';
            getproduct();
            getProductDetail();
        }
        
        if(sectionSeq == null) sectionSeq = '1';
        
    }
    
    public pageReference save(){
        boolean isError = false;
        if(product.Consignment__c == null){
                product.Consignment__c.addError('위탁여부를 선택해야 합니다.');
                isError = true;     
        }else if(product.Consignment__c == '상품위탁'){
            if(product.Account__c == null){
                product.Account__c.addError('거래처를 선택해야 합니다.');
                isError = true;
            }
        }
        
        if(isError == true){
            return null;
        }
        
        insert product;
        pageReference goPage;
        goPage = new PageReference('/apex/productNew?Id=' + product.Id);
        goPage.setRedirect(true);
        return goPage;      
    }
    
    public pageReference productList(){
        Schema.DescribeSObjectResult r = Product__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        pageReference goPage;
        goPage = new PageReference('/'+keyPrefix+'/o');
        goPage.setRedirect(true);
        return goPage;   
    }
    
    public void edit(){
        pageMode = 'E';
    }
    
    public pageReference goMoveSection() {
        String linkURL;
        
        if(sectionSeq == '1'){
        	if(product.Id == null){
        		linkURL = '/apex/productNew?Seq='+sectionSeq;
        	}else linkURL = '/apex/productNew?Id=' + product.Id+'&Seq='+sectionSeq;
        }else if(sectionSeq == '2'){
        	if(product.Id == null){
        		sectionSeq = '1';
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '상품을 먼저 등록해 주세요.'));
        		return null;
        	}
        	linkURL = '/apex/productDetail?Id=' + product.Id+'&Seq='+sectionSeq;
        }        
        pageReference goPage = new PageReference(LinkURL);
        goPage.setRedirect(true);
        return goPage;          
    }
    
    public void detailPlus(){
		ProductDetail__c temp = new ProductDetail__c();
		temp.Sort__c = productDetailList.size();
		temp.Product__c = product.Id;
		productDetailList.add(temp);
    }
    
    public void detailMinus(){
    	Integer pId = productDetailList.size();
    	if(pId == 1){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '상품상세 정보는 1개이상 있어야 합니다.'));
    	}else{
    		if(productDetailList.get(pId-1).Id <> null){
    			productDetailDeleteList.add(productDetailList.get(pId-1));
    		}
    		productDetailList.remove(pId-1);
    	}
    }
    
    public void detailSave(){
    	try{
    		upsert productDetailList;
    		if(productDetailDeleteList.size() > 0) delete productDetailDeleteList;	
    	}catch (Exception e){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '상품상세를 저장할 수 없습니다. Error Message:('+e+')'));	
    	}
    }
    
    public void detailUpdate(){
    	detailflag = false;
    	try{
    		update editProductDetail;
    		getProductDetail();
		}catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '상품상세를 수정할 수 없습니다. Error Message:('+e+')'));
    	}    		
    }
    
    public void detailCancel(){
    	detailflag = false;
    	editProductDetail = new ProductDetail__c();
    }
    
    public void detailEdit(){
		detailflag = true;    	
    	try{
	    	editProductDetail = [SELECT Id, ModelCode__c, Horizontal__c, Height__c, Vertical__c, Count__c
	                                , Color__c, ProductionYear__c, OrgPrice__c, SoldOut__c, DiscountRate__c 
								FROM ProductDetail__c WHERE Id =: productDetailId];
    	}catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '상품상세를 수정할 수 없습니다. Error Message:('+e+')'));
    	}
    }
    
    private void getproduct(){
        product = [SELECT Id, Name, Code__c, Consignment__c, Account__c, Category1__c, Category2__c, Category3__c, 
                            Manufacturer__c, vat__c, ProductYear__c, Weight__c, Description__c
                    FROM Product__c WHERE Id =: productId];
    }
    private void getProductDetail(){
        productDetailList = [SELECT Id, ModelCode__c, Horizontal__c, Height__c, Vertical__c, Product__c,  Count__c
                                , Color__c, ProductionYear__c, OrgPrice__c, SoldOut__c, Price__c, DiscountRate__c, Sort__c
                            FROM ProductDetail__c WHERE Product__c =: productId order by Sort__c];
        if(productDetailList.size() < 1){
            ProductDetail__c temp = new ProductDetail__c();
            temp.Sort__c = 0;
            temp.Product__c = product.Id;
            productDetailList.add(temp);
        }                           
    }
}