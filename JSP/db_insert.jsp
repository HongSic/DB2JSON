<%@ page contentType="text/html;" language="java" pageEncoding="UTF-8"
	import="java.sql.*, java.util.*"
	import="java.io.*" 
	import="java.net.URLDecoder" errorPage="" %>
<% 
	
	String b_barnum= request.getParameter("b_barnum");  //바코드넘버
	String b_isstore = request.getParameter("b_isstore"); 
	//try{ b_isstore = new Integer(request.getParameter("b_isstore"));}catch(Exception ex){}//0이면 입고, 1이면 출고
	//try{ b_isstore = int.parseInt(request.getParameter("b_isstore"));}catch(Exception ex){}//0이면 입고, 1이면 출고
	
	String b_numcard = request.getParameter("b_numcard");//카드수량
	String b_numproc = request.getParameter("b_numproc");//작업매수
	String b_deptname = request.getParameter("b_deptname");//부서
	String b_procname = request.getParameter("b_procname");//공정
	String b_memo = request.getParameter("b_memo");//메모
	
	/*
	//한글 변환
	byte[] aa = request.getParameter("b_deptname").getBytes("8859_1");
	b_deptname = new String(aa, "KSC5601");*/
	
	/*
	if(request.getMethod().equals("POST"))
	{
		request.setCharacterEncoding("UTF-8");
		
		b_deptname = request.getParameter("b_deptname");//부서
		b_procname = request.getParameter("b_procname");//공정
	}
	else 
	{
		if(request.getParameter("b_deptname") != null)b_deptname = URLDecoder.decode(request.getParameter("b_deptname"), "UTF-8");//부서
		if(request.getParameter("b_procname") != null)b_procname = URLDecoder.decode(request.getParameter("b_procname"), "UTF-8");//공정	
	}
	PrintWriter pw1 = response.getWriter();
	pw1.write(request.getMethod()+"<br>");
	pw1.write(request.getParameter("b_deptname")+" : "+b_deptname+"<br>");
	*/

	String DRIVER = "oracle.jdbc.driver.OracleDriver";
	String URL_Internal = "jdbc:oracle:thin:@(DB IP Address):(Port)";
	String URL_External = "jdbc:oracle:thin:@(DB IP Address):(Port)";
	String USER = ""
	String PASSWORD = "";

	Connection conn = null; //db서버에 접속해주는 클래스
	PreparedStatement pstmt = null; //쿼리문을 실행해주는 객체

	try
	{
		Class.forName(DRIVER);//.newInstance();
		conn = DriverManager.getConnection(URL_External, USER, PASSWORD);

		String SQL = "insert into STU1634.BARCODE "+
								"(BarNum, TimeStamp, IsStore, Num_Card, Num_Proc, DeptName, ProcName, Memo) "+
								"values (?,CURRENT_TIMESTAMP,?,?,?,?,?,?)";
								//TO_TIMESTAMP(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS')

		pstmt = conn.prepareStatement(SQL);
		pstmt.setString(1, b_barnum);
		pstmt.setString(2, b_isstore);//.toString()
		pstmt.setString(3, b_numcard);
		pstmt.setString(4, b_numproc);
		pstmt.setString(5, b_deptname);
		pstmt.setString(6, b_procname);
		pstmt.setString(7, b_memo);
		
		//String tmp  = pstmt.toString();
		//System.out.println(tmp);
		
		int cnt = pstmt.executeUpdate(); //SQL쿼리문 실행
		pstmt.close();
		
		String JSOMmsg = "{\"status\":\"ok\",\"message\":\"등록되었습니다.\",\"count\":"+cnt+"}";
		PrintWriter pw = response.getWriter();
		pw.write(JSOMmsg);
		/*
		// key와 value로 구성되어있는 HashMap 생성.
        Map<String, String> m = new HashMap<String, String>();
		m.put("status", "OK");
		m.put("count", cnt);
        JSONObject json = new JSONObject();
        json.accumulateAll(map);*/
	}
	//catch(ClassNotFoundException ex){out.println("<br/>Class Not Found: "+ex.getMessage()+"<br/>");}
	catch(SQLException ex)
	{
		//out.println("<br/>SQL Exception: "+ex.getMessage()+"<br/>");
		String JSONmsg = "{\"status\":\"fail\",\"message\":\"데이터베이스 문제로 등록에 실패하였습니다.\",\"exception\":\""+ex.getMessage()+"\",\"sqlcode\":"+ex.getErrorCode()+"}";
		
		PrintWriter pw = response.getWriter();
		pw.write(JSONmsg);
	    //out.println(JSONmsg);
		pw.close();
		
		//response.sendError(ex.getErrorCode(), ex.getMessage());
	}
	catch(Exception ex)
	{
		String JSONMmsg = "{\"status\":\"fail\",\"message\":\"알 수 없는 오류로 등록에 실패하였습니다.\",\"exception\":"+ex.getMessage()+"}";
		PrintWriter pw = response.getWriter();
		pw.write(JSONMmsg);
	}
	finally
	{
		try{conn.close();}catch(Exception ex){}
		try{pstmt.close();}catch(Exception ex){}
	}
%>