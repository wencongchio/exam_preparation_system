<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" type="image/png" href="css/images/favicon.png">
        <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
        <link rel="stylesheet" type = "text/css" href = "css/style.css">
        <link rel="stylesheet" type="text/css" href="css/bootstrap.css">
        <title>Success</title>
        <script src="//code.jquery.com/jquery-1.10.2.js"></script>
        <script>
            $(function () {
                $("#header").load("header.jsp");
            });
        </script> 
    </head>
    </head>
    <body>
        <%
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

            if (session.getAttribute("userType") == null || !(session.getAttribute("userType").equals("instructor"))) {
                response.sendRedirect("login.jsp");
            }
        %>
        <div id="header"></div>
        <div class="success-form container">
            <div class="row">
                <div class="col-4 text-right">
                    <img src="css/images/save.png" alt="success">
                </div>
                <div class="col-6 mt-5 ml-5">
                    <h1><b>Success!</b></h1>
                    <p class="mt-4">Your exam paper has been saved.</p>
                    <p>You could go back to the <a href="index.jsp">home page</a> to view your paper.</p> 
                </div>
            </div>
        </div>    
    </body>
</html>
