public with sharing class SearchProductController {
    public List<Product__c> productList {get;set;}
    public Product__c singleProduct {get;set;}
    public String searchKeyword {get;set;}
    private Integer counter {get;set;}
    private Integer listSize {get;set;}
    public Integer totalSize {get;set;}
    public String keyvalue{get;set;}
    
    public SearchProductController(){
    	initSearchWord();
    	initProductList();
    	counter = 0;
    	listSize = 1;
    	totalSize = 0;
    	system.debug('constructor - ' + searchKeyword);
    }
    
    public void initProductList(){
    	//productList = [SELECT Code__c, Name, Category1__c, Category2__c, Category3__c, ProductYear__c FROM Product__c];
    	system.debug('initProduct - ' + searchKeyword);
    	String query = 'SELECT Code__c, Name, Category1__c, Category2__c, Category3__c, ProductYear__c FROM Product__c';
    	if((searchKeyword != '') && (searchKeyword != null)){
    		query += ' WHERE Name like \'%' + searchKeyword + '%\'';
    	}
    	query += ' LIMIT ' + listSize + ' OFFSET ' + counter;
    	productList = Database.query(query);
    	totalSize = productList.size();
    }
    
    public void initSearchWord(){
    	searchKeyword = apexPages.currentPage().getParameters().get('searchKeyword');
    	if(keyvalue == null){
    		keyvalue = searchKeyword;
    	}
    	system.debug('init - ' + searchKeyword);
    }
    
    public void setProductList(){
    	system.debug('set - ' + searchKeyword);
    	if(totalSize == 0 || keyvalue <> searchKeyword){
	    	String query1 = 'SELECT count(id) FROM Product__c';
	    	if((searchKeyword != '') && (searchKeyword != null)){
	    		query1 += ' WHERE Name like \'%' + searchKeyword + '%\'';
	    	}
	    	sObject temp = Database.query(query1);
	    	totalSize = Integer.valueOf(temp.get('exp0'));
	    	keyvalue = searchKeyword;
    	}
    	
    	String query = 'SELECT Code__c, Name, Category1__c, Category2__c, Category3__c, ProductYear__c FROM Product__c';
    	if((searchKeyword != '') && (searchKeyword != null)){
    		query += ' WHERE Name like \'%' + searchKeyword + '%\'';
    	}
    	query += ' LIMIT ' + listSize + ' OFFSET ' + counter;
    	productList = (List<Product__c>)Database.query(query);
    }
}