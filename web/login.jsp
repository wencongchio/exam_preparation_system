<%@page import="java.sql.*"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="java.security.MessageDigest"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String sha1(String input) throws NoSuchAlgorithmException {
        MessageDigest mDigest = MessageDigest.getInstance("SHA1");
        byte[] result = mDigest.digest(input.getBytes());
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < result.length; i++) {
            sb.append(Integer.toString((result[i] & 0xff) + 0x100, 16).substring(1));
        }
        return sb.toString();
    }

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" type="image/png" href="css/images/favicon.png">
        <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro" rel="stylesheet">
        <link rel="stylesheet" type = "text/css" href = "css/style.css">
        <link rel="stylesheet" type="text/css" href="css/bootstrap.css">
        <title>Login Page</title>
    </head>
    <body class="login-page">
        <div class="login-form">
            <img src="css/images/logo.png" alt="logo">
            <form method="POST">
                <%
                    if (request.getParameter("login") != null) {
                        String userID = request.getParameter("userID");
                        String password = sha1(request.getParameter("password"));
                        if (userID.length() < 6) {
                %>
                <p class="error">Account must be longer than 6 letters</p>
                <%
                } else {
                    try {
                        Class.forName("com.mysql.jdbc.Driver");
                        java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
                        java.sql.Statement stmt = con.createStatement();
                        String sql = "SELECT * FROM user WHERE uid = \"" + userID + "\"";
                        ResultSet rs = stmt.executeQuery(sql);
                        if (rs.next()) {
                            String str1 = rs.getString("password");
                            if (str1.equals(password)) {
                                String userType = rs.getString("userType");
                                session = request.getSession();
                                session.setAttribute("userID", userID);
                                session.setAttribute("userType", userType);
                                if (userType.equals("admin")) {
                                    response.sendRedirect("admin.jsp");
                                } else {
                                    response.sendRedirect("index.jsp");
                                }
                %>

                <p class="error"> <%=str1%></p>

                <%
                } else {
                %>

                <p class="error"> Wrong Username or Password</p>

                <%
                    }
                } else {
                %>

                <p class="error">Wrong Username or Password</p>

                <%
                                }
                                con.close();
                            } catch (Exception ex) {
                                out.println(ex);
                            }
                        }
                    }
                %>
                <div class="row">
                    <div class="col-12">
                        <input type="text" name="userID" placeholder="Username" class="form-control" required />
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-12">
                        <input type="password" name="password" placeholder="Password" class="form-control" required />
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-12">
                        <button type="submit" class="form-control btn" name="login">login</button>
                    </div>
                </div>
            </form>
        </div>
    </body>
</html>
