<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" type="image/png" href="css/images/favicon.png">
        <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro" rel="stylesheet">
        <link rel="stylesheet" type = "text/css" href = "css/style.css">
        <link rel="stylesheet" type="text/css" href="css/bootstrap.css">
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.2.0/css/all.css">
        <title>Upload Paper</title>
    </head>
    <body>
        <%
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            if (session.getAttribute("userType") == null || !(session.getAttribute("userType").equals("admin"))) {
                response.sendRedirect("login.jsp");
            }
        %>
        <nav class="topnav">
            <div class="container">
                <a href="admin.jsp"><img src="css/images/logo.png" alt="logo"></a>
                <div class="logout"><a href="logout">Logout</a></div>
            </div>
        </nav>
        <div class="container mt-5">
            <div class="upload-form">
                <div class="title"><b>Upload Past Year Paper</b></div>
                <div class="mt-3">
                    <form action="upload" method="POST" enctype = "multipart/form-data">
                        <div class="form-group">
                            <label for="subject">Subject</label>
                            <select name="subjectCode" class="form-control" id="subject">
                                <%
                                    try {
                                        Class.forName("com.mysql.jdbc.Driver");
                                        java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
                                        java.sql.Statement stmt = con.createStatement();

                                        String retrieveSubject = "SELECT * FROM subject;";
                                        ResultSet subjects = stmt.executeQuery(retrieveSubject);

                                        while (subjects.next()) {
                                            String subjectID = subjects.getString("subjectID");
                                            String subjectName = subjects.getString("subjectName");

                                            out.println("<option value=\"" + subjectID + "\">" + subjectID.toUpperCase() + " - " + subjectName + "</option>");
                                        }

                                        con.close();

                                    } catch (Exception e) {
                                        out.println(e);
                                    }
                                %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Semester</label>
                            <input type="text" class="form-control" placeholder="eg. 2018-01" name="semester" required>
                        </div>
                        <div class="form-group">
                            <label for="fileUpload">Past Year Paper PDF</label>
                            <input type="file" name="file" class="form-control-file" id="fileUpload" required>
                        </div>
                        <div class="mt-4">
                            <button type="submit" class="btn btn-primary form-control"><i class="fas fa-upload mr-2"></i>Upload</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>
