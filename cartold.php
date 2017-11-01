<!DOCTYPE html>
<html>
<head>
    <?php include 'reqs.php';?>
    <title>Grocery Store</title>
    <script>
        checklogin();
    </script>
</head>
<body>
    <?php include 'navbar.php';?>
    <br/>
    <div id="container" class="container-fluid">
        <div class="container-fluid" id = "items">
        </div>
    </div>
</body>
</html>
<script>
    $(document).ready(function(){
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "viewcart"
            },        
            dataType: "html",
            cache: false,               
            success: function(data) {                    
                $("#items").html(data); 
            }
        });
    })
</script>