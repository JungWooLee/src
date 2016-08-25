public with sharing class SearchDetailController {
    public List<ProductDetail__c> detailList {get;set;}
    public List<OrderInfo> orderList {get;set;}
    public String productId {get;set;}
    public String searchKeyword {get;set;}
    public String page {get;set;}
    public String checkboxValue {get;set;}
    public String branchId {get;set;}
    public List<BranchProduct__c> branchProductList {get;set;}
    
    public SearchDetailController(){
    	initBranchId();
    	initDetailList();
    	initOrderList();
    	initSearchKeyword();
    	initPage();
    }
    
    public void initBranchId(){
    	branchId = apexPages.currentPage().getParameters().get('branchId');
    	branchProductList = new List<BranchProduct__c>();
    	system.debug('branchId - ' + branchId);
    }
    
    public void initDetailList(){
    	productId = apexPages.currentPage().getParameters().get('Id');
    	detailList = [SELECT ModelCode__c, Horizontal__c, Height__c, Vertical__c, Count__c,
    					Color__c, ProductionYear__c, Price__c FROM ProductDetail__c
    					WHERE Product__c =: productId];
    }
    
    public void initOrderList(){
    	orderList = new List<OrderInfo>();
    }
    
    public void initSearchKeyword(){
    	searchKeyword = apexPages.currentPage().getParameters().get('searchKeyword');
    }
    
    public void initPage(){
    	page = apexPages.currentPage().getParameters().get('page');
    }
    
    //체크한 상품을 주문 리스트에 추가
    public void addOrderList(){
    	ProductDetail__c tmpDetail = [SELECT ModelCode__c, Horizontal__c, Height__c, Vertical__c, Count__c,
				    					Color__c, ProductionYear__c, Price__c FROM ProductDetail__c
				    					WHERE ModelCode__c =: checkboxValue];
				    					
    	OrderInfo tmpOrderInfo = new OrderInfo(tmpDetail);
		orderList.add(tmpOrderInfo);
    }
    
    //체크 해제한 상품을 주문 리스트에서 제거
    public void deleteOrderList(){
    	ProductDetail__c tmpDetail = [SELECT ModelCode__c, Horizontal__c, Height__c, Vertical__c, Count__c,
				    					Color__c, ProductionYear__c, Price__c FROM ProductDetail__c
				    					WHERE ModelCode__c =: checkboxValue];
		
		Integer index = 0;
		for(Integer i=0; i<orderList.size(); i++){
			if(orderList[i].productDetail == tmpDetail){
				index = i;
			}
		}
				    					
		orderList.remove(index);
    }
    
    //주문 리스트의 상품들을 주문
    public PageReference doOrder(){
    	for(Integer i=0; i<orderList.size(); i++){
    		system.debug(orderList[i].orderAmount);
    		//주문한 상품이 재고수량보다 많으면 오류메시지 출력하고 주문되지 않음
    		if(orderList[i].productDetail.Count__c < orderList[i].orderAmount){
	    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'재고수량보다 많이 주문할 수 없습니다.');
				ApexPages.addMessage(myMsg);
				
				return null;
    		}
    		orderList[i].productDetail.Count__c -= orderList[i].orderAmount;
    	
	    	BranchProduct__c tmpProduct = new BranchProduct__c();
	    	tmpProduct.BranchProduct__c = branchId;
	    	tmpProduct.ProductDetail__c = orderList[i].productDetail.Id;
	    	tmpProduct.ProductCount__c = orderList[i].orderAmount;
	    	branchProductList.add(tmpProduct);
	    	
    		update orderList[i].productDetail;
    	}
    	initDetailList();
    	
    	insert branchProductList;
    	orderList.clear();
    	
    	String url = '/apex/ShowOrderList?page=' + page + '&searchKeyword=' + searchKeyword + '&Id=' + branchId;
    	PageReference goPage = new PageReference(url);
    	goPage.setRedirect(true);
    	return goPage;
    }
    
    public PageReference goProductList(){
    	String url = '/apex/SearchProduct?page=' + page + '&searchKeyword=' + searchKeyword + '&Id=' + branchId;
    	PageReference goPage = new PageReference(url);
    	goPage.setRedirect(true);
    	return goPage;
    }
}