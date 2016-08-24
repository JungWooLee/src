public with sharing class SiteBranchProductController {
	public Id branchId{get;set;}
	
	public SiteBranchProductController(){
		branchId = Apexpages.currentPage().getParameters().get('Id');
		if(branchId == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '대리점 ID를 확인 할 수 없습니다.\n 버튼을 클릭해 로그인 화면으로 이동 하세요.'));
		}else{
			
		}
	}     
}