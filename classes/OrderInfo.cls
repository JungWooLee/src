public with sharing class OrderInfo {
    public ProductDetail__c productDetail {get;set;}
    public Integer orderAmount {get;set;}
    
    public OrderInfo(ProductDetail__c tmpDetail){
    	productDetail = tmpDetail;
    	orderAmount = 0;
    }
}