@IsTest
public with sharing class BranchControllerTest {
	@IsTest
	public static void testBranchController(){
		
			Branch__c branch = new Branch__c();
			Contact cont = new Contact();
			BranchProduct__c bpd = new BranchProduct__c();
			
			

			branch.Name = 'google';
			branch.BranchID__c = 'google';
			branch.BranchPW__c = 'g1234';
			branch.Ranking__c = 'A';
			branch.ManagerEmail__c = 'ggg@gmail.com';
			branch.ZipCode__c = '12345';
			branch.Address__c='united';
			branch.AddressDetail__c = 'states';
			branch.Employees__c = 33;
			
			cont.BranchContact__c = branch.Id;
			cont.Phone='353-3333';
			cont.LastName='google';
			
			insert branch;
			insert cont;
			
			
			
			ApexPages.StandardController stdCon = new ApexPages.StandardController(branch);
			BranchController bc = new BranchController(stdCon);
			bc.contact = cont;
			
			
			bc.branchList();
			bc.getpage('ggg');
			bc.branch = branch;
			
	
			bc.save();
			bc.deletebranch();
			
			
				
	}
    
}