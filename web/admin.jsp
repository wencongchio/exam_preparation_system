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
        <title>Homepage</title>
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
        <div class="container mt-5 admin-main">
            <div class="header">
                <span class="title"><b>Past Year Paper</b></span>
                <div class="button-panel">
                    <a class="btn btn-success" href="upload.jsp"><i class="fas fa-upload mr-2"></i>UPLOAD</a>
                </div>
            </div>
            <div class="mt-3">
                <%
                    try {
                        Class.forName("com.mysql.jdbc.Driver");
                        java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
                        java.sql.Statement stmt3 = con.createStatement();

                        String retrievePastPaper = "SELECT * FROM past_paper;";
                        ResultSet pastPapers = stmt3.executeQuery(retrievePastPaper);

                        if (pastPapers.next()) {
                            out.print("<table class=\"table table-bordered w-100\">"
                                    + "<thead class=\"thead-dark\">"
                                    + "<tr>"
                                    + "<th>Subject Code</th>"
                                    + "<th class=\"text-center\">Subject Name</th>"
                                    + "<th class=\"text-center\">Semester</th>"
                                    + "<th></th>"
                                    + "</tr></thead><tbody>");
                            do {
                                String pastPaperID = pastPapers.getString("pastPaperID");
                                String subjectCode = pastPapers.getString("subjectID").toUpperCase();
                                String subjectName = "";
                                String semester = pastPapers.getString("semester");
                                String url = pastPapers.getString("url");

                                java.sql.Statement stmt4 = con.createStatement();
                                String retrieveSubjectName = "SELECT * FROM subject WHERE subjectID = \"" + subjectCode + "\";";
                                ResultSet subjectDetail = stmt4.executeQuery(retrieveSubjectName);

                                while (subjectDetail.next()) {
                                    subjectName = subjectDetail.getString("subjectName");
                                }

                                out.print("<tr>");
                                out.print("<td class=\"medium-column\"><a href=\"" + url + "\" download>" + subjectCode + "</a></td>");
                                out.print("<td class=\"text-center \">" + subjectName + "</td>");
                                out.print("<td class=\"text-center small-column\">" + semester + "</td>");
                                out.print("<td class=\"text-center small-column\"><form action=\"removePastPaper\" method=\"POST\">"
                                        + "<button type=\"submit\" class=\"btn btn-danger\" name=\"pastPaperID\" value=\"" + pastPaperID + "\">"
                                        + "<i class=\"fas fa-trash mr-2\"></i>Remove</button></form></td>");
                                out.print("</tr>");
                            } while (pastPapers.next());

                            out.print("</tbody></table>");
                        } else {
                            out.println("<div class=\"error-message\">No exam paper available</div>");
                        }

                    } catch (Exception e) {
                        out.println(e);
                    }
                %>                     
            </div>
        </div>        
    </body>
</html>
