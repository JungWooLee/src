public with sharing class ShowOrderListController {
    public String page {get;set;}
    public String searchKeyword {get;set;}
    public String branchId {get;set;}
    public List<BranchProduct__c> OrderList {get;set;}
    
    public ShowOrderListController(){
    	initParam();
    }
    
    public void initParam(){
    	page = apexPages.currentPage().getParameters().get('page');
    	searchKeyword = apexPages.currentPage().getParameters().get('searchKeyword');
    	branchId = apexPages.currentPage().getParameters().get('Id');
    	OrderList = [SELECT ProductDetail__c, ProductCount__c FROM BranchProduct__c WHERE BranchProduct__c = :branchId];
    }
    
    public PageReference goProductList(){
    	String url = '/apex/SearchProduct?page=' + page + '&searchKeyword=' + searchKeyword + '&Id=' + branchId;
    	PageReference goPage = new PageReference(url);
    	goPage.setRedirect(true);
    	return goPage;
    }
}