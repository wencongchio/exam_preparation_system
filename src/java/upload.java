
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(urlPatterns = {"/upload"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 10,
        maxFileSize = 1024 * 1024 * 50,
        maxRequestSize = 1024 * 1024 * 100)

public class upload extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");

        String savePath = getServletContext().getRealPath("") + "\\document";
        String subjectCode = request.getParameter("subjectCode");
        String semester = request.getParameter("semester");
        String id = "";

        try {
            Class.forName("com.mysql.jdbc.Driver");
            java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/eps", "root", "root");
            java.sql.Statement stmt = con.createStatement();

            String sql = "INSERT INTO past_paper (subjectID, semester) VALUES ('" + subjectCode + "', '" + semester + "');";
            stmt.executeUpdate(sql);

            java.sql.Statement stmt2 = con.createStatement();
            String retrieveLastID = "SELECT LAST_INSERT_ID() AS last_id FROM past_paper;";
            ResultSet pastID = stmt2.executeQuery(retrieveLastID);
            while (pastID.next()) {
                id = pastID.getString("last_id");
            }

            Part filePart = request.getPart("file");
            String fileName = filePart.getSubmittedFileName();
            InputStream fileContent = filePart.getInputStream();
            byte[] buffer = new byte[fileContent.available()];
            fileContent.read(buffer);
            
            String finalName = id + "-" + fileName;

            File targetFile = new File(savePath + File.separator + finalName);

            OutputStream outStream = new FileOutputStream(targetFile);
            outStream.write(buffer);
            
            java.sql.Statement stmt3 = con.createStatement();
            String insertUrl = "UPDATE past_paper SET url = \"document/" + finalName + "\" WHERE pastPaperID = '" + id + "';";
            stmt3.executeUpdate(insertUrl);

            con.close();

            response.sendRedirect("admin.jsp");

        } catch (Exception ex) {
            PrintWriter out = response.getWriter();
            out.println(ex);
        }

    }
}
