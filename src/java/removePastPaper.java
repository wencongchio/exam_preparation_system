import java.io.IOException;
import java.io.PrintWriter;
import java.sql.DriverManager;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/removePastPaper"})
public class removePastPaper extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pastPaperID = request.getParameter("pastPaperID");
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
            java.sql.Statement stmt = con.createStatement();
            
            String sql = "DELETE FROM past_paper WHERE pastPaperID = '" + pastPaperID + "';";
            stmt.executeUpdate(sql);
            
            con.close();
            
            response.sendRedirect("admin.jsp");
            
        } catch (Exception ex) {
            PrintWriter out = response.getWriter();
            out.println(ex);
        }
    }
}
