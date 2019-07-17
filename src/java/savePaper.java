
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/savePaper"})
public class savePaper extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        String subjectCode = request.getParameter("subjectCode");
        String examPaperID = "201805" + subjectCode;        

        try {
            Class.forName("com.mysql.jdbc.Driver");
            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
            java.sql.Statement stmt = con.createStatement();
            
            String sql = "SELECT * FROM main_question WHERE paperID = '" + examPaperID + "';";
            ResultSet questions = stmt.executeQuery(sql);
            while (questions.next()){
                String questionID = questions.getString("questionID");
                String[] values = request.getParameterValues(questionID);
                java.sql.Statement stmt2 = con.createStatement();
                
                if (values[1] == null || values[1].equals("")){
                    String deleteQuestion = "DELETE FROM main_question WHERE questionID = '" + questionID + "';";
                    stmt2.executeUpdate(deleteQuestion);
                }else{
                    String keyword = values[0];
                    String questionContent = values[1];
                    String mark = values[2];
                    if (mark.equals("")){
                        mark = null;
                    }
                    int cognitiveLevel = keywordLevel.get(keyword);
                    
                    String saveQuestion = "UPDATE main_question SET question = '" + questionContent + "', keyword = '" + keyword + "', cognitiveLevel = " + cognitiveLevel + ", mark = " + mark + " WHERE questionID = '" + questionID + "';";
                    stmt2.executeUpdate(saveQuestion);
                }
                
                stmt2.close();
            }
            
            java.sql.Statement stmt3 = con.createStatement();
            String sql2 = "SELECT * FROM sub_question WHERE paperID = '" + examPaperID + "';";
            ResultSet subQuestions = stmt3.executeQuery(sql2);
            while (subQuestions.next()){
                String subQuestionID = subQuestions.getString("subQuestionID");
                String subQuestionContent = request.getParameter(subQuestionID);
                java.sql.Statement stmt4 = con.createStatement();
                
                if (subQuestionContent == null || subQuestionContent.equals("")){
                    String deleteSubQuestion = "DELETE FROM sub_question WHERE subQuestionID = '" + subQuestionID + "';";
                    stmt4.executeUpdate(deleteSubQuestion);
                }else{
                    String saveSubQuestion = "UPDATE sub_question SET question = '" + subQuestionContent + "' WHERE subQuestionID = '" + subQuestionID + "';" ;
                    stmt4.executeUpdate(saveSubQuestion);
                }
                
                stmt4.close();
            }
            
            con.close();
            
            response.sendRedirect("success.jsp");
            
        } catch (Exception ex) {
            PrintWriter out = response.getWriter();
            out.println(ex);
        }
    }
}
