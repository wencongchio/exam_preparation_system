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
        <title>Homepage</title>
        <script src="//code.jquery.com/jquery-1.10.2.js"></script>
        <script>
            $(function () {
                $("#header").load("header.jsp");
            });
            function getSubjectCode() {
                var subjectCode = prompt("Please enter subject code");
                if (subjectCode != null && subjectCode != "") {
                    window.location.href = "examPaper.jsp?subjectCode=" + subjectCode;
                }
            }

        </script> 
    </head>
    <body>

        <%
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            if (session.getAttribute("userType") == null || !(session.getAttribute("userType").equals("instructor"))) {
                response.sendRedirect("login.jsp");
            }

            String userID = session.getAttribute("userID").toString();
        %>
        <div id="header"></div>
        <div class="container mt-5 homepage">
            <div class="exam-paper">
                <div class="header">
                    <span class="title"><b>Exam Paper</b></span>
                    <div class="button-panel">
                        <button class="btn btn-success" onclick="getSubjectCode()"><i class="fas fa-plus mr-2"></i>CREATE PAPER</button>
                    </div>
                </div>
                <div class="mt-3">
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
                            java.sql.Statement stmt = con.createStatement();

                            String retrieveExamPaper = "SELECT * FROM exam_paper WHERE createdBy =\"" + userID + "\";";
                            ResultSet examPapers = stmt.executeQuery(retrieveExamPaper);

                            if (examPapers.next()) {
                                out.print("<table class=\"table table-bordered w-100\">"
                                        + "<thead class=\"thead-dark\">"
                                        + "<tr>"
                                        + "<th>Subject Code</th>"
                                        + "<th class=\"text-center\">Subject Name</th>"
                                        + "<th class=\"text-center\">Semester</th>"
                                        + "<th></th>"
                                        + "</tr></thead><tbody>");
                                do {
                                    String examPaperID = examPapers.getString("examPaperID");
                                    String subjectCode = examPapers.getString("subjectID").toUpperCase();
                                    String subjectName = "";
                                    String semester = examPapers.getString("semester");

                                    java.sql.Statement stmt2 = con.createStatement();
                                    String retrieveSubjectName = "SELECT * FROM subject WHERE subjectID = \"" + subjectCode + "\";";
                                    ResultSet subjectDetail = stmt2.executeQuery(retrieveSubjectName);

                                    while (subjectDetail.next()) {
                                        subjectName = subjectDetail.getString("subjectName");
                                    }

                                    out.print("<tr>");
                                    out.print("<td class=\"medium-column\"><a href=\"examPaper.jsp?subjectCode=" + subjectCode + "\">" + subjectCode + "</a></td>");
                                    out.print("<td class=\"text-center \">" + subjectName + "</td>");
                                    out.print("<td class=\"text-center small-column\">" + semester + "</td>");
                                    out.print("<td class=\"text-center small-column\"><form action=\"removePaper\" method=\"POST\">"
                                            + "<button type=\"submit\" class=\"btn btn-danger\" name=\"examPaperID\" value=\"" + examPaperID + "\">"
                                            + "<i class=\"fas fa-trash mr-2\"></i>Remove</button></form></td>");
                                    out.print("</tr>");
                                } while (examPapers.next());

                                out.print("</tbody></table>");
                            } else {
                                out.println("<div class=\"error-message\">No exam paper available</div>");
                            }
                            
                            con.close();

                        } catch (Exception e) {
                            out.println(e);
                        }
                    %>                     
                </div>
            </div>
            <div class="past-paper mt-5">
                <div class="header">
                    <span class="title"><b>Past Year Paper</b></span>
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
                                    out.print("<td class=\"text-center small-column\"><a class=\"btn btn-success\" href=\"" + url + "\" download>"
                                            + "<i class=\"fas fa-download mr-2\"></i>Download</a></td>");
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
        </div>    
    </body>
</html>
