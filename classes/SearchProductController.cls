public with sharing class SearchProductController {
    public List<Product__c> productList {get;set;}
    public Product__c singleProduct {get;set;}
    public String searchKeyword {get;set;}
    public String encodingKeyword {get;set;}
    //페이징 처리를 위한 변수들
    private Integer counter {get;set;}
    private Integer listSize {get;set;}
    public Integer totalSize {get;set;}
    public Integer totalPage {get;set;}
    public Integer totalBlock {get;set;}
    public Integer pagePerBlock {get;set;}
    public Integer nowBlock {get;set;}
    public Integer startPagePerBlock {get;set;}
    public Integer page {get;set;}
    public List<Integer> pageList {get;set;}
    public String keyvalue{get;set;}
    
    public String branchId{get;set;}
    
    public SearchProductController(){
    	String pageParam = apexPages.currentPage().getParameters().get('page');
    	branchId = apexPages.currentPage().getParameters().get('Id');
    	system.debug('branchId - ' + branchId);
    	//로그인이 되어 있지 않으면 주문할 수 없음
		if(branchId == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '대리점 ID를 확인 할 수 없습니다.\n 버튼을 클릭해 로그인 화면으로 이동 하세요.'));
		}else{
	    	if(pageParam == null){
	    		page = 1;
	    	}else{
	    		page = Integer.valueOf(pageParam);
	    	}
	    	listSize = 2;
	    	pagePerBlock = 2;
	    	counter = (page-1) * listSize;
	    	totalSize = 0;
	    	pageList = new List<Integer>();
	    	initSearchWord();
	    	initProductList();
	    	system.debug('constructor - ' + searchKeyword);
		}
    }
    
    //맨 처음 화면 띄울 때, 페이지를 전환했을때
    public void initProductList(){
    	//페이지 처리
    	String query1 = 'SELECT count(id) FROM Product__c';
    	if((searchKeyword != '') && (searchKeyword != null)){
    		query1 += ' WHERE Name like \'%' + searchKeyword + '%\'';
    	}
    	sObject temp = Database.query(query1);
	    totalSize = Integer.valueOf(temp.get('expr0'));
    	List<Integer> tmpPageList = new List<Integer>();
    	totalPage = (Integer)Math.ceil((totalSize)/((Double)listSize));
		totalBlock = (Integer)Math.ceil((totalPage)/((Double)pagePerBlock));
		nowBlock = (Integer)Math.ceil(page/((Double)pagePerBlock));
		startPagePerBlock = (nowBlock * pagePerBlock) - pagePerBlock + 1;
		system.debug('startPagePerBlock - ' + startPagePerBlock);
		system.debug('pagePerBlock - ' + pagePerBlock);
		system.debug('nowBlock - ' + nowBlock);
		system.debug('totalPage - ' + totalPage);
		system.debug('totalBlock - ' + totalBlock);
		if(startPagePerBlock + pagePerBlock - 1 <= totalPage){
		    for(Integer i=startPagePerBlock; i<=startPagePerBlock + pagePerBlock - 1; i++){
		    	tmpPageList.add(i);
		    }
		}
		else{
			for(Integer i=startPagePerBlock; i<=totalPage; i++){
		    	tmpPageList.add(i);
		    }
		}
	    pageList = tmpPageList;
	    system.debug(pageList);
    	
    	//화면에 나올 리스트 설정
    	system.debug('initProduct - ' + searchKeyword);
    	String query = 'SELECT Code__c, Name, Category1__c, Category2__c, Category3__c, ProductYear__c FROM Product__c';
    	if((searchKeyword != '') && (searchKeyword != null)){
    		query += ' WHERE Name like \'%' + searchKeyword + '%\'';
    	}
    	query += ' LIMIT ' + listSize + ' OFFSET ' + counter;
    	productList = Database.query(query);
    }
    
    public void initSearchWord(){
    	/*
    	if(apexPages.currentPage().getParameters().get('searchKeyword') == null){
    		searchKeyword = null;
    	}
    	else{
    		encodingKeyword = EncodingUtil.urlEncode(apexPages.currentPage().getParameters().get('searchKeyword'), 'UTF-8');
    		searchKeyword = EncodingUtil.urlDecode(apexPages.currentPage().getParameters().get('searchKeyword'), 'UTF-8');
    	}
    	*/
    	searchKeyword = apexPages.currentPage().getParameters().get('searchKeyword');
    	if(keyvalue == null){
    		keyvalue = searchKeyword;
    	}
    	system.debug('init - ' + searchKeyword);
    }
    
    //새로 검색한 리스트
    public void setProductList(){
    	//페이지 처리
    	system.debug('set - ' + searchKeyword);
    	//새로 검색된 단어일때
    	if(totalSize == 0 || keyvalue <> searchKeyword){
	    	String query1 = 'SELECT count(id) FROM Product__c';
	    	if((searchKeyword != '') && (searchKeyword != null)){
	    		query1 += ' WHERE Name like \'%' + searchKeyword + '%\'';
	    	}
	    	sObject temp = Database.query(query1);
	    	totalSize = Integer.valueOf(temp.get('expr0'));
	    	system.debug(totalSize);
	    	keyvalue = searchKeyword;
	    	/*
	    	counter = 0;
    		page = 1;
		    List<Integer> tmpPageList = new List<Integer>();
		    totalPage = (Integer)Math.ceil((totalSize)/((Double)listSize));
			totalBlock = (Integer)Math.ceil((totalPage)/((Double)pagePerBlock));
			nowBlock = (Integer)Math.ceil(page/((Double)pagePerBlock));
			startPagePerBlock = (nowBlock * pagePerBlock) - pagePerBlock + 1;
			system.debug('startPagePerBlock - ' + startPagePerBlock);
			system.debug('pagePerBlock - ' + pagePerBlock);
			system.debug('nowBlock - ' + nowBlock);
			system.debug('totalPage - ' + totalPage);
			system.debug('totalBlock - ' + totalBlock);
			for(Integer i=startPagePerBlock; i<=startPagePerBlock + pagePerBlock - 1; i++){
				tmpPageList.add(i);
			}
			pageList = tmpPageList;
			*/
    	}
    	
	    counter = 0;
    	page = 1;
		List<Integer> tmpPageList = new List<Integer>();
		totalPage = (Integer)Math.ceil((totalSize)/((Double)listSize));
		totalBlock = (Integer)Math.ceil((totalPage)/((Double)pagePerBlock));
		nowBlock = (Integer)Math.ceil(page/((Double)pagePerBlock));
		startPagePerBlock = (nowBlock * pagePerBlock) - pagePerBlock + 1;
		system.debug('startPagePerBlock - ' + startPagePerBlock);
		system.debug('pagePerBlock - ' + pagePerBlock);
		system.debug('nowBlock - ' + nowBlock);
		system.debug('totalPage - ' + totalPage);
		system.debug('totalBlock - ' + totalBlock);
		if(startPagePerBlock + pagePerBlock - 1 <= totalPage){
		    for(Integer i=startPagePerBlock; i<=startPagePerBlock + pagePerBlock - 1; i++){
		    	tmpPageList.add(i);
		    }
		}
		else{
			for(Integer i=startPagePerBlock; i<=totalPage; i++){
		    	tmpPageList.add(i);
		    }
		}
	    pageList = tmpPageList;
		
    	//화면에 나올 리스트 설정
    	String query = 'SELECT Code__c, Name, Category1__c, Category2__c, Category3__c, ProductYear__c FROM Product__c';
    	if((searchKeyword != '') && (searchKeyword != null)){
    		query += ' WHERE Name like \'%' + searchKeyword + '%\'';
    	}
    	query += ' LIMIT ' + listSize + ' OFFSET ' + counter;
    	productList = Database.query(query);
    }
    
    public void setCounter(){
    	counter = (page-1) * listSize;
    	initProductList();
    }
    
    public void prevBlock(){
    	page = ((nowBlock-1) * pagePerBlock) - pagePerBlock + 1;
    	setCounter();
    }
    
    public void nextBlock(){
    	page = ((nowBlock+1) * pagePerBlock) - pagePerBlock + 1;
    	setCounter();
    }
}