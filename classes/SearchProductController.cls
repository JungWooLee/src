/**
* Object        : Product__c
* Function      : SearchProductController 
* Author        : 
* Date          : 
* Description   : 
*/
public with sharing class SearchProductController {
    public List<Product__c> productList {get;set;}
    public Product__c singleProduct {get;set;}
    public List<ProductDetail__c> detailList {get;set;}
    public List<OrderInfo> orderList {get;set;}    
    public List<BranchProduct__c> branchProductList {get;set;}
    
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
    public String seq{get;set;}
    public String checkboxValue {get;set;}
    public String productId{get;set;}
    
    public SearchProductController(){

    	branchId = apexPages.currentPage().getParameters().get('Id');
    	
    	 String pageParam = apexPages.currentPage().getParameters().get('page');
    	//로그인이 되어 있지 않으면 주문할 수 없음
		if(branchId == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '대리점 ID를 확인 할 수 없습니다.'));
		}else{
	    	if(pageParam == null){
	    		page = 1;
	    	}else{
	    		page = Integer.valueOf(pageParam);
	    	}
	    	//페이지마다 보일 리스트의 갯수
	    	listSize = 2;
	    	//한 블럭당 보일 페이지
	    	pagePerBlock = 5;
	    	counter = (page-1) * listSize;
	    	totalSize = 0;
	    	pageList = new List<Integer>();
	    	initSearchWord();
	    	initProductList();
	    	orderList = new List<OrderInfo>();
	    	branchProductList = new List<BranchProduct__c>();
	    	seq = '1';
		}
    }
    
    public class OrderInfo{
    	public Product__c product{get;set;}
    	public ProductDetail__c productDetail{get;set;}
    	public ProductDetailHistory__c history{get;set;}
    	public Integer orderAmount{get;set;}
    	public String Reason{get;set;}
    }
    
    //체크한 상품을 주문 리스트에 추가
    public void addOrderList(){
    	ProductDetail__c tmpDetail = [SELECT Id, ModelCode__c, Horizontal__c, Height__c, Vertical__c, Count__c, Color__c, 
    										ProductionYear__c, Price__c, product__c 
										FROM ProductDetail__c WHERE ModelCode__c =: checkboxValue];
		Product__c product = [SELECT Id, Name FROM Product__c WHERE Id =: tmpDetail.product__c];
										
		OrderInfo orderInfo = new OrderInfo();
		orderInfo.product = product;
		orderInfo.productDetail = tmpDetail;
		
		orderList.add(orderInfo);		    					
    }
    
    //체크 해제한 상품을 주문 리스트에서 제거
    public void deleteOrderList(){

		for(Integer i = 0; i < orderList.size(); i++){
			if(orderList[i].productDetail.ModelCode__c == checkboxValue){
				orderList.remove(i);
			}
		}
    }
    
    //주문 리스트의 상품들을 주문
    public void doOrder(){
    	List<ProductDetail__c> updateDetails = new List<ProductDetail__c>();
    	List<ProductDetailHistory__c> orderHistorys = new List<ProductDetailHistory__c>();
    	
    	for(Integer i = 0; i < orderList.size(); i++){

    		//주문한 상품이 재고수량보다 많으면 오류메시지 출력하고 주문되지 않음
    		if(orderList[i].productDetail.Count__c < orderList[i].orderAmount){
	    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'재고수량보다 많이 주문할 수 없습니다.');
				ApexPages.addMessage(myMsg);
				
				return;
    		}
    		orderList[i].productDetail.Count__c -= orderList[i].orderAmount;
    		updateDetails.add(orderList[i].productDetail);
    		
	    	BranchProduct__c tmpProduct = new BranchProduct__c();
	    	tmpProduct.BranchProduct__c = branchId;
	    	tmpProduct.ProductDetail__c = orderList[i].productDetail.Id;
	    	tmpProduct.ProductCount__c = orderList[i].orderAmount;
	    	branchProductList.add(tmpProduct);
	    	
	    	ProductDetailHistory__c orderHistory = new ProductDetailHistory__c();
	    	orderHistory.Branch__c = branchId;
	    	orderHistory.Reason__c = orderList[i].Reason;
	    	orderHistory.Count__c = orderList[i].orderAmount;
	    	orderHistory.ProductDetail__c = orderList[i].productDetail.Id;
	    	orderHistorys.add(orderHistory);

    	}
    	Savepoint sp = Database.setSavepoint();
    	
		try{
	    	update updateDetails;
	    	
	    	insert branchProductList;
	    	insert orderHistorys;
		}catch(exception ex){
			 Database.rollback(sp);
		}
		
    	orderList.clear();
    	
		seq = '3';
		initDetailList();
		branchOrderList();
    }
    
	public void initDetailList(){
    	detailList = [SELECT Id, ModelCode__c, Horizontal__c, Height__c, Vertical__c, Count__c,
    					Color__c, ProductionYear__c, Price__c, Product__c
    					FROM ProductDetail__c WHERE Product__c =: productId];
		seq = '2';
    }
    
    public void goProductList(){
    	seq = '1';
    }
    
    public void branchOrderList(){
    	List<ProductDetailHistory__c> temps = [SELECT Id, Count__c, 
    													ProductDetail__c, 
    													ProductDetail__r.ModelCode__c,
    													ProductDetail__r.Product__c,
    													ProductDetail__r.Product__r.Name,
    													ProductDetail__r.Product__r.Code__c,
    													ProductDetail__r.Product__r.Category1__c,
    													ProductDetail__r.Product__r.Category2__c,
    													ProductDetail__r.Product__r.Category3__c,
    													Reason__c, CreatedDate
    											FROM ProductDetailHistory__c WHERE Branch__c =: branchId order By CreatedDate desc];
		orderList = new List<OrderInfo>();
    	for(ProductDetailHistory__c temp:temps){
    		OrderInfo orderInfo = new OrderInfo();
    		orderInfo.product = temp.ProductDetail__r.Product__r;
    		orderInfo.productDetail = temp.ProductDetail__r;
    		orderInfo.history = temp;
    		OrderList.add(orderInfo);
    	}
		seq = '3';

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
		
		if(startPagePerBlock + pagePerBlock - 1 <= totalPage){
		    for(Integer i = startPagePerBlock; i <= startPagePerBlock + pagePerBlock - 1; i++){
		    	tmpPageList.add(i);
		    }
		}else{
			for(Integer i = startPagePerBlock; i <= totalPage; i++){
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
    
    public void initSearchWord(){
    	searchKeyword = apexPages.currentPage().getParameters().get('searchKeyword');
    	if(keyvalue == null){
    		keyvalue = searchKeyword;
    	}
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
    	}
    	
	    counter = 0;
    	page = 1;
		List<Integer> tmpPageList = new List<Integer>();
		totalPage = (Integer)Math.ceil((totalSize)/((Double)listSize));
		totalBlock = (Integer)Math.ceil((totalPage)/((Double)pagePerBlock));
		nowBlock = (Integer)Math.ceil(page/((Double)pagePerBlock));
		startPagePerBlock = (nowBlock * pagePerBlock) - pagePerBlock + 1;
		
		if(startPagePerBlock + pagePerBlock - 1 <= totalPage){
		    for(Integer i=startPagePerBlock; i<=startPagePerBlock + pagePerBlock - 1; i++){
		    	tmpPageList.add(i);
		    }
		}else{
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