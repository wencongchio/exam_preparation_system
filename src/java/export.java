
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.draw.VerticalPositionMark;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

@WebServlet(urlPatterns = {"/export"})
public class export extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String subjectCode = request.getParameter("subjectCode");
        String examPaperID = "201805" + subjectCode;

        saveQuestion(request, response, examPaperID);

        try {

            Document newDoc = new Document(PageSize.A4);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            PdfWriter.getInstance(newDoc, baos);

            Font roman16bold = FontFactory.getFont(FontFactory.TIMES_ROMAN, 16, Font.BOLD);
            Font roman16 = FontFactory.getFont(FontFactory.TIMES_ROMAN, 16);
            Font roman12 = FontFactory.getFont(FontFactory.TIMES_ROMAN, 12);

            Class.forName("com.mysql.jdbc.Driver");
            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
            java.sql.Statement stmt = con.createStatement();

            newDoc.open();

            Paragraph header = new Paragraph("Answer all questions.\n\n", roman16);
            newDoc.add(header);

            for (int i = 0; i < 4; i++) {
                String sql = "SELECT * FROM main_question WHERE paperID = '" + examPaperID + "' AND questionNumber = '" + (i+1) + "' ORDER BY sequence;";
                ResultSet questions = stmt.executeQuery(sql);

                Paragraph question = new Paragraph();
                question.setLeading(0,2);
                Chunk questionTitle = new Chunk("Question " + (i + 1) + "\n", roman16bold);
                questionTitle.setUnderline(0.1f, -2f);
                question.add(questionTitle);

                int count = 0;

                while (questions.next()) {
                    String questionID = questions.getString("questionID");
                    String keyword = questions.getString("keyword");
                    String bloomKeyword = keyword.substring(0, 1).toUpperCase() + keyword.substring(1);
                    String questionContent = questions.getString("question");
                    String mark = questions.getString("mark");

                    Chunk glue = new Chunk(new VerticalPositionMark());
                    Phrase mainQuestion = new Phrase();
                    Chunk mainQuestionContent = new Chunk("(" + (char)('a' + count) + ") " + bloomKeyword + " " + questionContent + ".", roman12);
                    Chunk mainQuestionMark = new Chunk("(" + mark + " marks)");
                    mainQuestion.add(mainQuestionContent);
                    mainQuestion.add(glue);
                    mainQuestion.add(mainQuestionMark);
                    question.add(mainQuestion);
                    count++;
                    
                    java.sql.Statement stmt2 = con.createStatement();
                    String retrieveSub = "SELECT * FROM sub_question WHERE mainQuestionID = '" + questionID + "' ORDER BY sequence;";
                    ResultSet subQuestions = stmt2.executeQuery(retrieveSub);
                    
                    int subCount = 0;
                    
                    while (subQuestions.next()){
                        String subQuestionContent = subQuestions.getString("question");
                        Chunk subQuestion = new Chunk("     (" + (subCount+1) + ") " + subQuestionContent + ".", roman12 );
                        question.add("\n");
                        question.add(subQuestion);
                        subCount++;
                    }                   
                    
                }
                question.add("\n\n");
                newDoc.add(question);
            }
            newDoc.close();
            
            response.setContentType("application/pdf");
            response.setContentLength(baos.size());
            response.setHeader("Content-Disposition", "attachment; filename=" + subjectCode.toUpperCase() + ".pdf");
            
            OutputStream os = response.getOutputStream();
            baos.writeTo(os);
            os.flush();
            os.close();
            
            con.close();

        } catch (Exception e) {
            PrintWriter out = response.getWriter();
            out.println(e);
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
