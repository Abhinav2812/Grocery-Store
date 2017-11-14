<!DOCTYPE html>
<html>
<head>
    <?php include 'reqs.php';?>
    <title>Grocery Store</title>
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
        <?php
            if(isset($_GET['q']))
            {
                echo "pattern = '".$_GET['q']."';";   
            }
            else
            {
                echo "pattern = '';";
            }
        ?>
        $.ajax({
             type: "POST",
            url: "data.php",
            data: {
                type: "items",
                pattern: pattern
            },        
            dataType: "html",
            cache: false,               
            success: function(data) {                    
                $("#items").html(data); 
            }
        }); 
    });
    function addSuccess(itemname,itemid)
    {
        $.ajax({
        type: "POST",
        url: "data.php",
        data: {
            type: "addtocart",
            product_id: itemid
        },        
        cache: false,               
        success: function(data) { 
            obj = JSON.parse(data);
            if('err' in obj)
                $.toaster(obj['err'],'Error','warning');
            else
                $.toaster('Added to cart',itemname,'info');                   
        }
        });
    }
</script>