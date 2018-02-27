<%@ page contentType="text/html; charset=utf-8"  language="java"  
	import="java.sql.*, java.util.*, java.io.*, java.lang.*" errorPage="" %>
<% 
	request.setCharacterEncoding("UTF-8"); 
	
	String DBNAME="DB_NAME";
	String URL = "127.0.0.1:1433"
	String USER = "";
	String PASSWORD = "";
	String DEFAULT_TABLE_NAME="DEFAULT_TABLE_NAME";
	
	Connection conn= null; //db서버에 접속해주는 클래스
	PreparedStatement pstmt = null;//쿼리문을 실행해주는 객체
	try
	{
		ResultSet rs = null;
		
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");//.newInstance();
		conn = DriverManager.getConnection("jdbc:sqlserver://" + URL + ";databaseName="+DBNAME+";user="+USER+";password="+PASSWORD);

		//만약 여기서부터 자바파일이면 따로 메서드화 하기. [String getDBtoJSON (Connection con, String TableName){...}])
		String TableName = request.getParameter("tablename");
		String DBParam = request.getParameter("dbparam");
		String DBParamFull = request.getParameter("dbparamfull");
		
		String SQL_ADDITIONAL = (DBParam==null || DBParam.isEmpty() || DBParam.equals(" ") )?"":DBParam;
		String SQL_TABLE_NAME = (TableName==null || TableName.isEmpty() || TableName.equals(" ") )?DEFAULT_TABLE_NAME:TableName.toUpperCase();
		String SQL_COUNT_COLUMN = "select count(*) from INFORMATION_SCHEMA.Columns where table_name = '"+SQL_TABLE_NAME+"'";
		String SQL_COUNT_ITEM = "select count(*) from "+SQL_TABLE_NAME+" "+SQL_ADDITIONAL;
		String SQL_COLUMN = "select column_name from INFORMATION_SCHEMA.Columns where table_name = '"+SQL_TABLE_NAME+"'";
		String SQL_ITEM = "select * from "+SQL_TABLE_NAME+" "+SQL_ADDITIONAL; //+" order by TIMESTAMP asc";

        String[] nameArray = null;
        String[][] tableArray = null;
        int item_cnt = 0;
        
        //컬럼 갯수 가져오기
		pstmt = conn.prepareStatement(SQL_COUNT_COLUMN); 
        rs = pstmt.executeQuery();//쿼리 실행
        if(rs.next())nameArray = new String[rs.getInt(1)];
        pstmt.close();
        
        //컬럼명 가져오기
        pstmt = conn.prepareStatement(SQL_COLUMN); 
        rs = pstmt.executeQuery();//쿼리 실행
        int cnt = 0;
        while(rs.next()){nameArray[cnt] = rs.getString(1); cnt++;}
        pstmt.close();
        
        //아이템 갯수 가져오기
       	pstmt = conn.prepareStatement(SQL_COUNT_ITEM); 
        rs = pstmt.executeQuery();//쿼리 실행
        if(rs.next())item_cnt = rs.getInt(1);
        pstmt.close();
        
      	//아이템 가져오기
		pstmt = conn.prepareStatement(SQL_ITEM); 
        rs = pstmt.executeQuery();//쿼리 실행
        
        //2차원 데이터베이스 테이블 초기화
		tableArray = new String[nameArray.length][item_cnt];

        //[해야할것]데이터베이스에서 아이템속성이 null 이면 JSON 에 "" 안붙이고 null 만 표시하게 하기
		int a = 0;
		while(rs.next())
		{
			for(int i = 0; i < nameArray.length; i++)
				tableArray[i][a] = rs.getString(nameArray[i]);
			a++;
		}
		
		//데이터베이스를 JSON 으로 변환
    	StringBuilder sb = new StringBuilder("{\"status\":\"ok\",\"message\":\"목록을 불러왔습니다.\",\"contents\":[");

		for (int i = 0; i < nameArray.length; i++) 
		{
			if(i > 0)sb.append(",");
			sb.append("{\"column\":\""+
				nameArray[i].replace("\\", "\\\\").replace("\r", "\\r").replace("\n", "\\n").replace("\"", "\\\"")+
				"\",\"values\":[");
			
			for(int j = 0; j < tableArray[i].length; j++)
			{
				if(tableArray[i].length > 0)
    			{
					String b = tableArray[i][j] == null ? null :
							tableArray[i][j].replace("\\", "\\\\").replace("\r", "\\r").replace("\n", "\\n").replace("\"", "\\\"");
					if(j == 0)sb.append(b == null?"null":"\""+b+"\"");
					else sb.append(b == null?",null":",\""+b+"\"");
    			}
			}
			sb.append("]}");
		}
    	sb.append("]}");
		
    	PrintWriter pw = response.getWriter();
    	String JSON = sb.toString();
    	pw.write(JSON);
	}
	catch(SQLException ex)
	{
		String JSONMmsg = "{\"status\":\"fail\",\"message\":\"데이터베이스 문제로 조회에 실패하였습니다.\",\"exception\":\""+ex.getMessage()+"\",\"sqlcode\":"+ex.getErrorCode()+"}";
		
		PrintWriter pw = response.getWriter();
		pw.write(JSONMmsg);
		//response.sendError(ex.getErrorCode(), ex.getMessage());
	}
	catch(Exception ex)
	{
		String JSONMmsg = "{\"status\":\"fail\",\"message\":\"알 수 없는 오류로 조회에 실패하였습니다.\",\"exception\":\""+ex.getMessage()+"\"}";
		PrintWriter pw = response.getWriter();
		pw.write(JSONMmsg);
		//response.sendError(ex.getErrorCode(), ex.getMessage());
	}
	finally
	{
		try{conn.close();}catch(Exception ex){}
		try{pstmt.close();}catch(Exception ex){}
	}
	
%>