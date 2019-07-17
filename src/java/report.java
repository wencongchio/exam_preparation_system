
import java.io.IOException;
import java.io.OutputStream;
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
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.data.general.DefaultPieDataset;

@WebServlet(name = "report", urlPatterns = {"/report"})
public class report extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String subjectCode = request.getParameter("subjectCode");
        String examPaperID = "201805" + subjectCode;

        saveQuestion(request, response, examPaperID);

        OutputStream outStream = response.getOutputStream();
        /* Get the output stream from the response object */
        try {
            Class.forName("com.mysql.jdbc.Driver");
            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
            
            int[] marks = new int[6];
            DefaultPieDataset myServletPieChart = new DefaultPieDataset();

            for (int i = 0; i < 6; i++){
                java.sql.Statement stmt = con.createStatement();

                String sql = "SELECT * FROM main_question WHERE paperID = '" + examPaperID + "' AND cognitiveLevel = '" + (i+1) + "';";
                ResultSet questions = stmt.executeQuery(sql);
                
                
                
                while (questions.next()){
                    int mark = Integer.parseInt(questions.getString("mark"));
                    marks[i] +=  mark;
                }
                
                myServletPieChart.setValue("Level " + (i+1), marks[i]);
            }

            JFreeChart mychart = ChartFactory.createPieChart("Paper Cognitive Domain", myServletPieChart, true, true, false);
            response.setContentType("image / png");

            ChartUtilities.writeChartAsPNG(outStream, mychart, 800, 600);
            
        } catch (Exception e) {
            PrintWriter out = response.getWriter();
            out.println(e);

        } finally {
            outStream.close();
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
                String mark = values[2];

                int cognitiveLevel = keywordLevel.get(keyword);

                String saveQuestion = "UPDATE main_question SET question = '" + questionContent + "', keyword = '" + keyword + "', cognitiveLevel = " + cognitiveLevel + ", mark = " + mark + " WHERE questionID = '" + questionID + "';";
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

                String saveSubQuestion = "UPDATE sub_question SET question = '" + subQuestionContent + "' WHERE subQuestionID = '" + subQuestionID + "';";
                stmt4.executeUpdate(saveSubQuestion);

                stmt4.close();
            }

        } catch (Exception ex) {
            PrintWriter out = response.getWriter();
            out.println(ex);
        }
    }
}
