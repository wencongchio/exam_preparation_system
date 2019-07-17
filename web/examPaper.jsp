<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Create Exam Paper</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="shortcut icon" type="image/png" href="css/images/favicon.png">
        <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro" rel="stylesheet">
        <link rel="stylesheet" type = "text/css" href = "css/style.css">
        <link rel="stylesheet" type="text/css" href="css/bootstrap.css">
        <script src="//code.jquery.com/jquery-1.10.2.js"></script>
        <script>
            $(function () {
                $("#header").load("header.jsp");
            });
        </script>
    </head>
    <body>
        <%
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            if (session.getAttribute("userType") == null || !(session.getAttribute("userType").equals("instructor"))) {
                response.sendRedirect("login.jsp");
            }

            String subjectCode = request.getParameter("subjectCode").toLowerCase();
            String instructorID = session.getAttribute("userID").toString();
            String examPaperID = "201805" + subjectCode;
            int count = 0;
            int subCount = 0;

            Class.forName("com.mysql.jdbc.Driver");
            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
            java.sql.Statement stmt = con.createStatement();

            String subjectName = "";
            String retrieveSubjectName = "SELECT * FROM subject WHERE subjectID = \"" + subjectCode + "\";";
            ResultSet subjectDetail = stmt.executeQuery(retrieveSubjectName);
            if (!subjectDetail.next()) {
                response.sendRedirect("error.jsp");
            } else {
                subjectName = subjectDetail.getString("subjectName");

                String sql = "SELECT * FROM exam_paper WHERE subjectID = \"" + subjectCode + "\" AND semester = \"2018-05\";";
                ResultSet examPaper = stmt.executeQuery(sql);
                if (!examPaper.next()) {
                    String createPaper = "INSERT INTO exam_paper (examPaperID, subjectID, createdBy, semester) VALUES ('" + examPaperID + "', '" + subjectCode + "', '" + instructorID + "', '2018-05');";
                    stmt.executeUpdate(createPaper);
                    for (int i = 0; i < 4; i++) {
                        String createQuestion = "INSERT INTO main_question (questionNumber, sequence, paperID) VALUES ('" + (i + 1) + "', '1', '" + examPaperID + "')";
                        stmt.executeUpdate(createQuestion);
                    }
                }
            }

            String mainQuestionID = "";
            String subQuestionID = "";
            String questionContent = "";
            String keyword = "";
            String mark = "";
            String subQuestionContent = "";

            String[][] cognitiveLevel = {{"Define", "List", "State"}, {"Discuss", "Explain", "Summarize"}, {"Draw", "Show", "Sketch"}, {"Compare", "Classify", "Differentiate"}, {"Construct", "Organize", "Propose"}, {"Evaluate", "Relate", "Support"}};
        %>
        <div id="header"></div>
        <div class="exam-form container mt-5">
            <div class="header mb-4">
                <span class="title">
                    <b><%= subjectCode.toUpperCase() + " " + subjectName%></b>
                </span>
                <div class="button-panel">
                    <button type="submit" form="examPaperForm" class="btn btn-primary" formaction="report" value="Submit">Report<i class="fas fa-chart-pie ml-2"></i></button>
                    <button type="submit" form="examPaperForm" class="btn btn-primary" formaction="export" value="Submit">Export<i class="fas fa-file-export ml-2"></i></button> 
                    <button type="submit" form="examPaperForm" class="btn btn-primary" formnovalidate="formnovalidate" value="Submit">Save<i class="fas fa-save ml-2"></i></button>
                </div>
            </div>
            <form action="savePaper" method="POST" id="examPaperForm">
                <input type="hidden" name="subjectCode" value="<%= subjectCode%>">

                <div class="question mb-4">
                    <div class="mb-3">
                        <span class="question-title">
                            <b>Question 1</b>
                        </span>  
                        <button type="submit" name="questionNo" value="1" formaction="addQuestion" class="circleBtn btn btn-success" formnovalidate="formnovalidate"><i class="fas fa-plus"></i></button>
                        <button type="submit" name="questionNo" value="1" formaction="removeQuestion" class="circleBtn btn btn-danger" formnovalidate="formnovalidate"><i class="fas fa-minus"></i></button>
                    </div>
                    <%
                        String retrieveQuestionOne = "SELECT * FROM main_question WHERE paperID = '" + examPaperID + "' AND questionNumber = '1' ORDER BY sequence";
                        ResultSet questionOneList = stmt.executeQuery(retrieveQuestionOne);
                        while (questionOneList.next()) {
                            mainQuestionID = questionOneList.getString("questionID");
                            if (questionOneList.getString("question") != null) {
                                questionContent = questionOneList.getString("question");
                            }
                            if (questionOneList.getString("keyword") != null) {
                                keyword = questionOneList.getString("keyword");
                            }
                            if (questionOneList.getString("mark") != null) {
                                mark = questionOneList.getString("mark");
                            }

                            out.println("<table class=\"w-100 question-table\"><tr><td class=\"small-column\">" + (char) ('a' + count) + ") ");
                            out.print("</td><td class=\"medium-column\"><select name=\"" + mainQuestionID + "\" class=\"form-control\">");
                            for (int i = 0; i < 6; i++) {
                                out.print("<optgroup label=\"Level " + (i + 1) + "\">");
                                for (int j = 0; j < 3; j++) {
                                    out.print("<option value=\"" + cognitiveLevel[i][j].toLowerCase() + "\" ");
                                    if (keyword.equals(cognitiveLevel[i][j].toLowerCase())) {
                                        out.print("selected");
                                    }
                                    out.print(">" + cognitiveLevel[i][j] + "</option>");
                                }
                                out.print("</optgroup>");
                            }
                            out.print("</select></td>");
                            out.println("<td><input type=\"text\" name=\"" + mainQuestionID + "\" value=\"" + questionContent + "\" placeholder=\"Question\" class=\"form-control\" required></td>"
                                    + "<td class=\"medium-column\"><input type=\"number\" name=\"" + mainQuestionID + "\" placeholder=\"Mark\" class=\"form-control\" value=\"" + mark + "\" required></td>"
                                    + "<td class=\"medium-column\"><button type=\"submit\" formaction=\"addSubQuestion\" name=\"questionID\" value=\"" + mainQuestionID + "\" class=\"btn btn-success\" formnovalidate=\"formnovalidate\"><i class=\"fa fa-plus\"></i></button> "
                                    + "<button type=\"submit\" formaction=\"removeSubQuestion\" name=\"questionID\" value=\"" + mainQuestionID + "\" class=\"btn btn-danger\" formnovalidate=\"formnovalidate\"><i class=\"fa fa-minus\"></i></button></td>"
                                    + "</tr>");

                            java.sql.Statement stmt2 = con.createStatement();
                            String retrieveSubQuestion = "SELECT * FROM sub_question WHERE mainQuestionID = '" + mainQuestionID + "';";
                            ResultSet subQuestionList = stmt2.executeQuery(retrieveSubQuestion);

                            subCount = 0;
                            while (subQuestionList.next()) {
                                subQuestionID = subQuestionList.getString("subQuestionID");
                                if (subQuestionList.getString("question") != null) {
                                    subQuestionContent = subQuestionList.getString("question");
                                }
                                out.println("<tr><td></td><td colspan=\"3\"><table class=\"w-100\"><tr><td class=\"small-column\">" + (subCount + 1) + ") </td><td><input type=\"text\" name=\"" + subQuestionID + "\" value=\"" + subQuestionContent + "\" class=\"form-control\" required></td></tr></table></td></tr>");
                                subQuestionContent = "";
                                subCount++;
                            }
                            stmt2.close();
                            out.println("</table>");
                            questionContent = "";
                            keyword = "";
                            mark = "";
                            count++;
                        }
                    %>
                </div>


                <div class="question mb-4">
                    <div class="mb-3">
                        <span class="question-title"><b>Question 2</b></span>
                        <button type="submit" name="questionNo" value="2" formaction="addQuestion" class="circleBtn btn btn-success" formnovalidate="formnovalidate"><i class="fas fa-plus"></i></button>
                        <button type="submit" name="questionNo" value="2" formaction="removeQuestion" class="circleBtn btn btn-danger" formnovalidate="formnovalidate"><i class="fas fa-minus"></i></button>
                    </div>

                    <%
                        count = 0;
                        String retrieveQuestionTwo = "SELECT * FROM main_question WHERE paperID = '" + examPaperID + "' AND questionNumber = '2' ORDER BY sequence";
                        ResultSet questionTwoList = stmt.executeQuery(retrieveQuestionTwo);
                        while (questionTwoList.next()) {
                            mainQuestionID = questionTwoList.getString("questionID");
                            if (questionTwoList.getString("question") != null) {
                                questionContent = questionTwoList.getString("question");
                            }
                            if (questionTwoList.getString("keyword") != null) {
                                keyword = questionTwoList.getString("keyword");
                            }
                            if (questionTwoList.getString("mark") != null) {
                                mark = questionTwoList.getString("mark");
                            }

                            out.println("<table class=\"w-100 question-table\"><tr><td class=\"small-column\">" + (char) ('a' + count) + ") ");
                            out.print("</td><td class=\"medium-column\"><select name=\"" + mainQuestionID + "\" class=\"form-control\">");
                            for (int i = 0; i < 6; i++) {
                                out.print("<optgroup label=\"Level " + (i + 1) + "\">");
                                for (int j = 0; j < 3; j++) {
                                    out.print("<option value=\"" + cognitiveLevel[i][j].toLowerCase() + "\" ");
                                    if (keyword.equals(cognitiveLevel[i][j].toLowerCase())) {
                                        out.print("selected");
                                    }
                                    out.print(">" + cognitiveLevel[i][j] + "</option>");
                                }
                                out.print("</optgroup>");
                            }
                            out.print("</select></td>");
                            out.println("<td><input type=\"text\" name=\"" + mainQuestionID + "\" value=\"" + questionContent + "\" placeholder=\"Question\" class=\"form-control\" required></td>"
                                    + "<td class=\"medium-column\"><input type=\"number\" name=\"" + mainQuestionID + "\" placeholder=\"Mark\" class=\"form-control\" value=\"" + mark + "\" required></td>"
                                    + "<td class=\"medium-column\"><button type=\"submit\" formaction=\"addSubQuestion\" name=\"questionID\" value=\"" + mainQuestionID + "\" class=\"btn btn-success\" formnovalidate=\"formnovalidate\"><i class=\"fa fa-plus\"></i></button> "
                                    + "<button type=\"submit\" formaction=\"removeSubQuestion\" name=\"questionID\" value=\"" + mainQuestionID + "\" class=\"btn btn-danger\" formnovalidate=\"formnovalidate\"><i class=\"fa fa-minus\"></i></button></td>"
                                    + "</tr>");

                            java.sql.Statement stmt2 = con.createStatement();
                            String retrieveSubQuestion = "SELECT * FROM sub_question WHERE mainQuestionID = '" + mainQuestionID + "';";
                            ResultSet subQuestionList = stmt2.executeQuery(retrieveSubQuestion);

                            subCount = 0;
                            while (subQuestionList.next()) {
                                subQuestionID = subQuestionList.getString("subQuestionID");
                                if (subQuestionList.getString("question") != null) {
                                    subQuestionContent = subQuestionList.getString("question");
                                }
                                out.println("<tr><td></td><td colspan=\"3\"><table class=\"w-100\"><tr><td class=\"small-column\">" + (subCount + 1) + ") </td><td><input type=\"text\" name=\"" + subQuestionID + "\" value=\"" + subQuestionContent + "\" class=\"form-control\" required></td></tr></table></td></tr>");
                                subQuestionContent = "";
                                subCount++;
                            }
                            stmt2.close();
                            out.println("</table>");
                            questionContent = "";
                            keyword = "";
                            mark = "";
                            count++;
                        }
                    %>  
                </div>


                <div class="question mb-4">
                    <div class="mb-3">
                        <span class="question-title"><b>Question 3</b></span>
                        <button type="submit" name="questionNo" value="3" formaction="addQuestion" class="circleBtn btn btn-success" formnovalidate="formnovalidate"><i class="fas fa-plus"></i></button>
                        <button type="submit" name="questionNo" value="3" formaction="removeQuestion" class="circleBtn btn btn-danger" formnovalidate="formnovalidate"><i class="fas fa-minus"></i></button>
                    </div>
                    <%
                        count = 0;
                        String retrieveQuestionThree = "SELECT * FROM main_question WHERE paperID = '" + examPaperID + "' AND questionNumber = '3' ORDER BY sequence";
                        ResultSet questionThreeList = stmt.executeQuery(retrieveQuestionThree);
                        while (questionThreeList.next()) {
                            mainQuestionID = questionThreeList.getString("questionID");
                            if (questionThreeList.getString("question") != null) {
                                questionContent = questionThreeList.getString("question");
                            }
                            if (questionThreeList.getString("keyword") != null) {
                                keyword = questionThreeList.getString("keyword");
                            }
                            if (questionThreeList.getString("mark") != null) {
                                mark = questionThreeList.getString("mark");
                            }

                            out.println("<table class=\"w-100 question-table\"><tr><td class=\"small-column\">" + (char) ('a' + count) + ") ");
                            out.print("</td><td class=\"medium-column\"><select name=\"" + mainQuestionID + "\" class=\"form-control\">");
                            for (int i = 0; i < 6; i++) {
                                out.print("<optgroup label=\"Level " + (i + 1) + "\">");
                                for (int j = 0; j < 3; j++) {
                                    out.print("<option value=\"" + cognitiveLevel[i][j].toLowerCase() + "\" ");
                                    if (keyword.equals(cognitiveLevel[i][j].toLowerCase())) {
                                        out.print("selected");
                                    }
                                    out.print(">" + cognitiveLevel[i][j] + "</option>");
                                }
                                out.print("</optgroup>");
                            }
                            out.print("</select></td>");
                            out.println("<td><input type=\"text\" name=\"" + mainQuestionID + "\" value=\"" + questionContent + "\" placeholder=\"Question\" class=\"form-control\" required></td>"
                                    + "<td class=\"medium-column\"><input type=\"number\" name=\"" + mainQuestionID + "\" placeholder=\"Mark\" class=\"form-control\" value=\"" + mark + "\" required></td>"
                                    + "<td class=\"medium-column\"><button type=\"submit\" formaction=\"addSubQuestion\" name=\"questionID\" value=\"" + mainQuestionID + "\" class=\"btn btn-success\" formnovalidate=\"formnovalidate\"><i class=\"fa fa-plus\"></i></button> "
                                    + "<button type=\"submit\" formaction=\"removeSubQuestion\" name=\"questionID\" value=\"" + mainQuestionID + "\" class=\"btn btn-danger\" formnovalidate=\"formnovalidate\"><i class=\"fa fa-minus\"></i></button></td>"
                                    + "</tr>");

                            java.sql.Statement stmt2 = con.createStatement();
                            String retrieveSubQuestion = "SELECT * FROM sub_question WHERE mainQuestionID = '" + mainQuestionID + "';";
                            ResultSet subQuestionList = stmt2.executeQuery(retrieveSubQuestion);

                            subCount = 0;
                            while (subQuestionList.next()) {
                                subQuestionID = subQuestionList.getString("subQuestionID");
                                if (subQuestionList.getString("question") != null) {
                                    subQuestionContent = subQuestionList.getString("question");
                                }
                                out.println("<tr><td></td><td colspan=\"3\"><table class=\"w-100\"><tr><td class=\"small-column\">" + (subCount + 1) + ") </td><td><input type=\"text\" name=\"" + subQuestionID + "\" value=\"" + subQuestionContent + "\" class=\"form-control\" required></td></tr></table></td></tr>");
                                subQuestionContent = "";
                                subCount++;
                            }
                            stmt2.close();
                            out.println("</table>");
                            questionContent = "";
                            keyword = "";
                            mark = "";
                            count++;
                        }
                    %>  
                </div>


                <div class="question mb-4">
                    <div class="mb-3">
                        <span class="question-title"><b>Question 4</b></span>
                        <button type="submit" name="questionNo" value="4" formaction="addQuestion" class="circleBtn btn btn-success" formnovalidate="formnovalidate"><i class="fas fa-plus"></i></button>
                        <button type="submit" name="questionNo" value="4" formaction="removeQuestion" class="circleBtn btn btn-danger" formnovalidate="formnovalidate"><i class="fas fa-minus"></i></button>
                    </div>
                    <%
                        count = 0;
                        String retrieveQuestionFour = "SELECT * FROM main_question WHERE paperID = '" + examPaperID + "' AND questionNumber = '4' ORDER BY sequence";
                        ResultSet questionFourList = stmt.executeQuery(retrieveQuestionFour);
                        while (questionFourList.next()) {
                            mainQuestionID = questionFourList.getString("questionID");
                            if (questionFourList.getString("question") != null) {
                                questionContent = questionFourList.getString("question");
                            }
                            if (questionFourList.getString("keyword") != null) {
                                keyword = questionFourList.getString("keyword");
                            }
                            if (questionFourList.getString("mark") != null) {
                                mark = questionFourList.getString("mark");
                            }

                            out.println("<table class=\"w-100 question-table\"><tr><td class=\"small-column\">" + (char) ('a' + count) + ") ");
                            out.print("</td><td class=\"medium-column\"><select name=\"" + mainQuestionID + "\" class=\"form-control\">");
                            for (int i = 0; i < 6; i++) {
                                out.print("<optgroup label=\"Level " + (i + 1) + "\">");
                                for (int j = 0; j < 3; j++) {
                                    out.print("<option value=\"" + cognitiveLevel[i][j].toLowerCase() + "\" ");
                                    if (keyword.equals(cognitiveLevel[i][j].toLowerCase())) {
                                        out.print("selected");
                                    }
                                    out.print(">" + cognitiveLevel[i][j] + "</option>");
                                }
                                out.print("</optgroup>");
                            }
                            out.print("</select></td>");
                            out.println("<td><input type=\"text\" name=\"" + mainQuestionID + "\" value=\"" + questionContent + "\" placeholder=\"Question\" class=\"form-control\" required></td>"
                                    + "<td class=\"medium-column\"><input type=\"number\" name=\"" + mainQuestionID + "\" placeholder=\"Mark\" class=\"form-control\" value=\"" + mark + "\" required></td>"
                                    + "<td class=\"medium-column\"><button type=\"submit\" formaction=\"addSubQuestion\" name=\"questionID\" value=\"" + mainQuestionID + "\" class=\"btn btn-success\" formnovalidate=\"formnovalidate\"><i class=\"fa fa-plus\"></i></button> "
                                    + "<button type=\"submit\" formaction=\"removeSubQuestion\" name=\"questionID\" value=\"" + mainQuestionID + "\" class=\"btn btn-danger\" formnovalidate=\"formnovalidate\"><i class=\"fa fa-minus\"></i></button></td>"
                                    + "</tr>");

                            java.sql.Statement stmt2 = con.createStatement();
                            String retrieveSubQuestion = "SELECT * FROM sub_question WHERE mainQuestionID = '" + mainQuestionID + "';";
                            ResultSet subQuestionList = stmt2.executeQuery(retrieveSubQuestion);

                            subCount = 0;
                            while (subQuestionList.next()) {
                                subQuestionID = subQuestionList.getString("subQuestionID");
                                if (subQuestionList.getString("question") != null) {
                                    subQuestionContent = subQuestionList.getString("question");
                                }
                                out.println("<tr><td></td><td colspan=\"3\"><table class=\"w-100\"><tr><td class=\"small-column\">" + (subCount + 1) + ") </td><td><input type=\"text\" name=\"" + subQuestionID + "\" value=\"" + subQuestionContent + "\" class=\"form-control\" required></td></tr></table></td></tr>");
                                subQuestionContent = "";
                                subCount++;
                            }
                            stmt2.close();
                            out.println("</table>");
                            questionContent = "";
                            keyword = "";
                            mark = "";
                            count++;
                        }

                        con.close();
                    %>
                </div>
            </form>
        </div>
    </body>
</html>
