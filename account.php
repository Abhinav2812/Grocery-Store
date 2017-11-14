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
        <div id="userdata" class = "container-fluid">
            
        </div>
        <hr>
        <div id="address" class = "container-fluid">

        </div>
        <div class="container-fluid">
            <button type='button' class='button' data-toggle = "collapse" data-target="#new-address"><span class='glyphicon glyphicon-plus' aria-hidden='true'></span>Add Address</button>
        </div>
        <div id="new-address" class = "collapse container-fluid">
            <form method = "POST" action="#" onsubmit="event.preventDefault()">
                <input type = "text" placeholder="Address Line 1" id="a1"><br>
                <input type = "text" placeholder="Address Line 2" id="a2"><br>
                <input type = "text" placeholder="City" id="city"><br>
                <input type = "text" placeholder="State" id="state"><br>
                <input type = "text" placeholder="Pin Code" id="pincode"><br>
                <input type = "button" value="Submit" onclick="addAddress()">
            </form>
            <div class="alert alert-success" id="addsuccess" role="alert">
                <strong>Added Successfully!</strong>
            </div>
            <div class="alert alert-danger" id="adderror" role="alert">
            </div>
        </div>
        <br/>
    </div>
</body>
</html>
<script>
    $(".collapse").on('shown.bs.collapse', function () {
        this.scrollIntoView();
    });
    function addAddress()
    {
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "add-address",
                a1: $("#a1").val(),
                a2: $("#a2").val(),
                city: $("#city").val(),
                state: $("#state").val(),
                pincode: $("#pincode").val()
            },        
            dataType: "html",
            cache: false,               
            success: function(data) { 
                $("#adderror").hide();
                $("#addsuccess").hide();        
                if(!$.trim(data))
                {   
                    $("#addsuccess").show();
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
                }
                else
                {
                    $("#adderror").html(data);
                    $("#adderror").show();
                }
            }
        });
    }
    $(document).ready(function(){
        $("#adderror").hide();
        $("#addsuccess").hide();
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