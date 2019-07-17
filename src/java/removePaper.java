import java.io.IOException;
import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/removePaper"})
public class removePaper extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String examPaperID = request.getParameter("examPaperID");
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
            java.sql.Statement stmt = con.createStatement();
            
            String sql = "DELETE FROM exam_paper WHERE examPaperID = '" + examPaperID + "';";
            stmt.executeUpdate(sql);
            
            con.close();
            
            response.sendRedirect("index.jsp");
            
        } catch (Exception ex) {
            PrintWriter out = response.getWriter();
            out.println(ex);
        }
    }
}
