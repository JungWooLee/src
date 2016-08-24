public with sharing class SearchDetailController {
    public List<ProductDetail__c> detailList {get;set;}
    public List<OrderInfo> orderList {get;set;}
    public String productId {get;set;}
    public String searchKeyword {get;set;}
    public String checkboxValue {get;set;}
    
    public SearchDetailController(){
    	initDetailList();
    	initOrderList();
    	initSearchKeyword();
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
    
    public void addOrderList(){
    	ProductDetail__c tmpDetail = [SELECT ModelCode__c, Horizontal__c, Height__c, Vertical__c, Count__c,
				    					Color__c, ProductionYear__c, Price__c FROM ProductDetail__c
				    					WHERE ModelCode__c =: checkboxValue];
				    					
    	OrderInfo tmpOrderInfo = new OrderInfo(tmpDetail);
		orderList.add(tmpOrderInfo);
    }
    
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
    
    public void doOrder(){
    	for(Integer i=0; i<orderList.size(); i++){
    		system.debug(orderList[i].orderAmount);
    		if(orderList[i].productDetail.Count__c < orderList[i].orderAmount){
	    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'재고수량보다 많이 주문할 수 없습니다.');
				ApexPages.addMessage(myMsg);
				
				return;
    		}
    		orderList[i].productDetail.Count__c -= orderList[i].orderAmount;
    		update orderList[i].productDetail;
    	}
    	initDetailList();
    	orderList.clear();
    }
    
    public PageReference goProductList(){
    	String url = '/apex/SearchProduct?searchKeyword=' + searchKeyword;
    	PageReference goPage = new PageReference(url);
    	goPage.setRedirect(true);
    	return goPage;
    }
}