<!DOCTYPE html>
<html>
<head>
    <?php include 'reqs.php';?>
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
    <link rel = "stylesheet" href = "cart.css">
    <title>Grocery Store</title>
    <script>
        checklogin();
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "addcnt",
            },        
            cache: false,               
            success: function(data) {  
                obj = JSON.parse(data);
                if(obj['cnt'] == 0)
                {
                    alert("Please add address in account page before checking out");
                    window.location = "index.php";
                }
            }
        });
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "checkcartempty",
            },        
            cache: false,               
            success: function(data) {
                obj = JSON.parse(data);
                if(obj['cnt'] == 0)
                {
                    alert("Cart Is Empty");
                    window.location = "index.php";
                }
            }
        });
        function updateTotal()
        {
            $sum = 0;
            $(".subtotal").each(function(idx){
                $sum += parseFloat($(this).text().substring(1));
            });
            $('#total').html("<strong>Total ₹" + $sum + "</strong>");
        }
    </script>
</head>
<body>
    <?php include 'navbar.php';?>
    <div id="container">
        <h1 align=middle>Confirm Order</h1>
        <hr>   
        <div class="container">
            <table id="cart" class="table table-hover table-condensed">
                            <thead>
                                <tr>
                                    <th style="width:50%" align=middle>Product</th>
                                    <th style="width:10%" align=middle>Price</th>
                                    <th style="width:8%" align=middle>Quantity</th>
                                    <th style="width:22%" class="text-center">Subtotal</th>
                                </tr>
                            </thead>
                            <tbody id="items">
                                
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td><a href="index.php" class="btn btn-warning"><i class="fa fa-angle-left"></i> Continue Shopping</a></td>
                                    <td colspan="2" class="hidden-xs"></td>
                                    <td class="hidden-xs text-center" id="total"></td>
                                    <td><span class="btn btn-success btn-block" id="odbutton">Place Order <i class="fa fa-angle-right"></i></span></td>
                                </tr>
                            </tfoot>
                        </table>
        </div>
        <hr>
        <h1 align=middle>Select Payment Method</h1>
        <select class="form-control" id="sel1">
            <option>Cash</option>
            <option>Net Banking</option>
            <option>Credit Card</option>
            <option>Debit Card</option>
        </select>
        <br/>
        <h1 align=middle>Select Address</h1>
        <div class = "container-fluid" id="address">
            
        </div>
        <hr>
    </div>   
</body>
<script>
    $('#odbutton').click(function(){
        $x = $( "#sel1" ).find( "option:selected" ).text();
        console.log($x);
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "orderdone",
                paymode: $x
            },        
            cache: false,               
            success: function(data) {     
                console.log(data);
                obj = JSON.parse(data);
                if('err' in obj)
                {
                    alert("Error in placing order, please refresh all items in your cart");
                }
                window.location = "index.php";            
            }
        });
        return true;
    });
    function setadd($a,$aid)
    {
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "setaddid",
                aid: $aid
            },        
            cache: false,               
            success: function(data) {        
                $.toaster('Address ' + $a + ' selected','Success','info');                
            }
        });
    }
    $(document).ready(function(){
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "vieworder"
            },        
            dataType: "html",
            cache: false,               
            success: function(data) {                    
                $("#items").html(data);
                updateTotal();
            }
        });
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "seladdress"
            },        
            dataType: "html",
            cache: false,               
            success: function(data) {                    
                $("#address").html(data);
                $("#add1").click();
            }
        });
    })
</script>