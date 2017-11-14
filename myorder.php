<!DOCTYPE html>
<html>
<head>
    <?php include 'reqs.php';?>
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
    <link rel = "stylesheet" href = "cart.css">
    <title>Grocery Store</title>
    <script>checklogin();</script>
</head>
<body>
    <?php include 'navbar.php';?>
    <div id="container">
        <br/>
        <h1 align = middle> My Orders </h1>
        <hr/>
        <div class="container" id="orders">
        </div>
    </div>
</body>
<script>
    $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "myorder"
            },        
            dataType: "html",
            cache: false,               
            success: function(data) {                    
                $("#orders").html(data);
            }
        });
</script>