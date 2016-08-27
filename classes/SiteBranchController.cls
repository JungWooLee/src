public with sharing class SiteBranchController {
    public Branch__c branch{get;set;}	
    public Boolean view{get;set;}
    public String siteUrl{get;set;}
    
    private BranchLoginInfo__c loginsave;
    private map<String,String> userAGENT;
    private String ipAddress;
    private String textArray;
    
    public SiteBranchController(){
    	branch = new Branch__c();
    	view = false;
    	textArray = '';
    	userAGENT = ApexPages.currentPage().getHeaders();
    	for(String key : userAGENT.keySet()){
    		textArray += key +' : '+ userAGENT.get(key) + '\n';
    	}
    	ipAddress = getUserIPAddress();
    }
    
    public static String getUserIPAddress() {
		string ReturnValue = '';  
		// True-Client-IP has the value when the request is coming via the caching integration.
		ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
		// X-Salesforce-SIP has the value when no caching integration or via secure URL.
		if (ReturnValue == '' || ReturnValue == null) {
			ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
		} // get IP address when no caching (sandbox, dev, secure urls)
		if (ReturnValue == '' || ReturnValue == null) {
			ReturnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
		} // get IP address from standard header if proxy in use
		return ReturnValue;
	}
    
    public void login(){
    	loginsave = new BranchLoginInfo__c();
    	List<Branch__c> temps = [SELECT Id FROM Branch__c WHERE BranchID__c =: branch.BranchID__c AND BranchPW__c =: branch.BranchPW__c limit 1];
    	if(temps.size() < 1){
    		//로그인 시도 및 실패 내용 기록.
    		List<Branch__c> logtemp = [SELECT Id FROM Branch__c WHERE BranchID__c =: branch.BranchID__c limit 1];
    		if(logtemp.size() < 1) loginsave.Reason__c = '대리점 Id 틀림';
    		else loginsave.Reason__c = '대리점 비밀번호 틀림';
    		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ID, PassWord를 확인해 주세요.'));
    	}else{
    		loginsave.Branch__c = temps[0].Id;
    		
    		siteUrl = '/SearchProduct?Id='+temps[0].Id;
    		view = true;	
    	}
    	
    	loginsave.IpAddress__c = ipAddress;
    	loginsave.Type__c = '로그인';
    	loginsave.EtcInfo__c = textArray;
    	loginsave.BranchId__c = branch.BranchID__c;
    	insert loginsave;
    }
    
    public PageReference logout(){
    	String url = '/Branch';
    	PageReference goPage = new PageReference(url);
    	goPage.setRedirect(true);
    	return goPage;
    }
    
}