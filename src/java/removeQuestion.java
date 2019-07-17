/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author User
 */
@WebServlet(urlPatterns = {"/removeQuestion"})
public class removeQuestion extends HttpServlet {


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String questionNo = request.getParameter("questionNo");
        String subjectCode = request.getParameter("subjectCode");
        String examPaperID = "201805" + subjectCode;
        int questionCount = 0;
        
        saveQuestion(request, response, examPaperID);
        
        try{
            Class.forName("com.mysql.jdbc.Driver");
            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
            java.sql.Statement stmt = con.createStatement();
            String sql = "SELECT COUNT(*) FROM main_question WHERE paperID = '" + examPaperID + "' AND questionNumber = '" + questionNo + "';";
            ResultSet questionCounts = stmt.executeQuery(sql);
            while (questionCounts.next()){
                questionCount = questionCounts.getInt(1);
            }
            
            if (questionCount>0){
                String removeMainQuestion = "DELETE FROM main_question WHERE paperID = '" + examPaperID + "' AND questionNumber = '" + questionNo + "' AND sequence = '" + questionCount + "';";
                stmt.executeUpdate(removeMainQuestion);
            
                stmt.close();
            }
            

            response.sendRedirect("examPaper.jsp?subjectCode=" + subjectCode);
            
        }catch(Exception ex){
            PrintWriter out = response.getWriter();
            out.println(ex);
        } 
    }
    
    private void saveQuestion(HttpServletRequest request, HttpServletResponse response, String examPaperID) throws IOException {
        Map<String, Integer> keywordLevel = new HashMap<String, Integer>();
        keywordLevel.put("define", 1);
        keywordLevel.put("list", 1);
        keywordLevel.put("state", 1);
        keywordLevel.put("discuss", 2);
        keywordLevel.put("explain", 2);
        keywordLevel.put("summarize", 2);
        keywordLevel.put("draw", 3);
        keywordLevel.put("show", 3);
        keywordLevel.put("sketch", 3);
        keywordLevel.put("compare", 4);
        keywordLevel.put("classify", 4);
        keywordLevel.put("differentiate", 4);
        keywordLevel.put("construct", 5);
        keywordLevel.put("organize", 5);
        keywordLevel.put("propose", 5);
        keywordLevel.put("evaluate", 6);
        keywordLevel.put("relate", 6);
        keywordLevel.put("support", 6);

        try {
            Class.forName("com.mysql.jdbc.Driver");
            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
            java.sql.Statement stmt = con.createStatement();

            String sql = "SELECT * FROM main_question WHERE paperID = '" + examPaperID + "';";
            ResultSet questions = stmt.executeQuery(sql);
            while (questions.next()) {
                String questionID = questions.getString("questionID");
                String[] values = request.getParameterValues(questionID);
                java.sql.Statement stmt2 = con.createStatement();

                String keyword = values[0];
                String questionContent = values[1];
                if (questionContent.equals("")) {
                    questionContent = null;
                }else{
                    questionContent = "'" + questionContent + "'";
                }
                String mark = values[2];
                if (mark.equals("")) {
                    mark = null;
                }
                int cognitiveLevel = keywordLevel.get(keyword);

                String saveQuestion = "UPDATE main_question SET question = " + questionContent + ", keyword = '" + keyword + "', cognitiveLevel = " + cognitiveLevel + ", mark = " + mark + " WHERE questionID = '" + questionID + "';";
                stmt2.executeUpdate(saveQuestion);

                stmt2.close();
            }

            java.sql.Statement stmt3 = con.createStatement();
            String sql2 = "SELECT * FROM sub_question WHERE paperID = '" + examPaperID + "';";
            ResultSet subQuestions = stmt3.executeQuery(sql2);
            while (subQuestions.next()) {
                String subQuestionID = subQuestions.getString("subQuestionID");
                String subQuestionContent = request.getParameter(subQuestionID);
                java.sql.Statement stmt4 = con.createStatement();
                if (subQuestionContent.equals("")){
                    subQuestionContent = null;
                }else{
                    subQuestionContent = "'" + subQuestionContent + "'";
                }

                String saveSubQuestion = "UPDATE sub_question SET question = " + subQuestionContent + " WHERE subQuestionID = '" + subQuestionID + "';";
                stmt4.executeUpdate(saveSubQuestion);

                stmt4.close();
            }

        } catch (Exception ex) {
            PrintWriter out = response.getWriter();
            out.println(ex);
        }
    }

}
