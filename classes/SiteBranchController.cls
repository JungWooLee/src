public with sharing class SiteBranchController {
    public Branch__c branch{get;set;}	
    public Boolean viewPoion{get;set;}
    public String siteUrl{get;set;}
    	
    public SiteBranchController(){
    	branch = new Branch__c();
    	viewPoion = false;
    }
    
    public void login(){
    	List<Branch__c> temps = [SELECT Id FROM Branch__c WHERE BranchID__c =: branch.BranchID__c AND BranchPW__c =: branch.BranchPW__c];
    	if(temps.size() < 1){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ID, PassWord를 확인해 주세요.'));
    	}else{
    		siteUrl = '/apex/branchProduct?Id='+temps[0].Id;
    		viewPoion = true;	
    	}
    }
}