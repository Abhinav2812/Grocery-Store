<!DOCTYPE html>
<html>
<head>
    <?php include 'reqs.php';?>
    <title>Grocery Store</title>
    <script>
        $(document).ready(function(){
             $.ajax({
                type: "POST",
                url: "data.php",
                data: {
                    type: "userdata"
                },        
                dataType: "html",
                cache: false,               
                success: function(data) {                    
                    $("#userdata").html(data); 
                }
            });
            $.ajax({
                type: "POST",
                url: "data.php",
                data: {
                    type: "address"
                },        
                dataType: "html",
                cache: false,               
                success: function(data) {                    
                    $("#address").html(data); 
                }
            }); 
        });
    </script>
</head>
<body>
    <?php include 'navbar.php';?>
    <div id="container">
        <div id="userdata" class = "container-fluid">
            
        </div>
        <hr>
        <div id="address" class = "container-fluid">
            
        </div>
    </div>
</body>
</html>