public with sharing class BranchController {
	 
	public String pageMode{get;set;}
	public String branchId{get;set;}
	public Branch__c branch{get;set;}
	public Contact contact{get;set;}
	
	
	
	public BranchController(ApexPages.StandardController stdCon){
		branchId = stdCon.getId();
		
		String isRegister = Apexpages.currentPage().getParameters().get('register');
		
		if(branchId == null){
			pageMode = 'E';
			branch = new Branch__c();
		}else{
			pageMode= isRegister=='yes'? 'V' : 'E';
			getbranch();
		}	
		
	}
	
	public pageReference save(){
		
		/*
		처음 대리점을 만들때는 getparameter로 ID가 들어가지 않고 
		만들어진 대리점을 수정할때는 getParameter로 ID가 들어간다.
		화면은 똑같다
		*/
		if(branchId==null) 
		insert branch;
		else
		update branch;
		
		return getPage('/apex/RegisterBranch?Id=' + branch.Id
		+ '&register=yes');
	}
	
	public pageReference branchList(){
        
        Schema.DescribeSObjectResult r = Branch__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        return getPage('/'+keyPrefix+'/o');   
    }
    
    public pageReference getPage(String url){
    	
    	pageReference goPage;
        goPage = new PageReference(url);
        goPage.setRedirect(true);
        return goPage; 
    	
    }
	
	public pageReference deletebranch(){
		
		List<BranchProduct__c> branchProducts = [select BranchProduct__c from BranchProduct__c 
		where BranchProduct__c.BranchProduct__c =: branch.Id];
		
		if(branchProducts.size() == 0)	//같은게 없다면 묶여있는 branchproduct가 없으니까 그냥 지운다.
			delete branch;
		else{
			branch.isActive__c = false;
			update branch;
		}
			 
		return branchList();
	
	}
	
	
	
	public void getbranch(){
		branch = [SELECT Id, Name, BranchID__c,  Ranking__c, ManagerEmail__c, 
		ZipCode__c, Address__c, AddressDetail__c, Employees__c FROM Branch__c WHERE Id =: branchId];
	}
	
    
}