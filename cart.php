<!-- Credits of layout : https://bootsnipp.com/snippets/featured/responsive-shopping-cart-->
<!DOCTYPE html>
<html>
<head>
    <?php include 'reqs.php';?>
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
    <link rel = "stylesheet" href = "cart.css">
    <title>Grocery Store</title>
    <script>
        checklogin();
    </script>
</head>
<body>
    <?php include 'navbar.php';?>
    <div id="container">
        <div class="container">
            <table id="cart" class="table table-hover table-condensed">
                            <thead>
                                <tr>
                                    <th style="width:50%">Product</th>
                                    <th style="width:10%">Price</th>
                                    <th style="width:8%">Quantity</th>
                                    <th style="width:22%" class="text-center">Subtotal</th>
                                    <th style="width:10%"></th>
                                </tr>
                            </thead>
                            <tbody id="items">
                                
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td><a href="index.php" class="btn btn-warning"><i class="fa fa-angle-left"></i> Continue Shopping</a></td>
                                    <td colspan="2" class="hidden-xs"></td>
                                    <td class="hidden-xs text-center" id="total"></td>
                                    <td><a href="placeorder.php" class="btn btn-success btn-block" onclick = "return verifyAddress();">Checkout <i class="fa fa-angle-right"></i></a></td>
                                </tr>
                            </tfoot>
                        </table>
        </div>
    </div>
</body>
</html>
<script>
    function verifyAddress()
    {
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "addcnt",
            },        
            cache: false,               
            success: function(data) {  
                console.log(data);                  
                obj = JSON.parse(data);
                if(obj['cnt'] == 0)
                {
                    $.toaster('Please add address in account page before checking out','Info','info');
                    $val1 = 1;
                }
                else
                {
                    window.location = "placeorder.php";
                }
            }
        });
        return false;
    }
    function updateTotal()
    {
        $sum = 0;
        $(".subtotal").each(function(idx){
            $sum += parseFloat($(this).text().substring(1));
        });
        $('#total').html("<strong>Total ₹" + $sum + "</strong>");
    }
    function updateQ(Product_id)
    {
        $qtyid = "#qty" + Product_id;
        $subid = "#sub" + Product_id;
        $priceid = "#price" + Product_id;
        $qty = parseInt($($qtyid).val());
        if($qty<1) $qty = 1;
        $price = parseInt($($priceid).text().substring(1))*$qty;
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "updateCart",
                Product_id: Product_id,
                qty: $qty
            },        
            cache: false,               
            success: function(data) {  
                console.log(data);                  
                obj = JSON.parse(data);
                if('err' in obj)
                {
                     $.toaster(obj['err'],'Error','danger');
                     if('qty' in obj)
                     {
                        $qty = parseInt(obj['qty']);
                        console.log($qty);
                        $price = parseInt($($priceid).text().substring(1))*$qty;
                        $($qtyid).val($qty);
                        $($subid).html("₹"+$price);
                        updateTotal();
                     }
                }
                else
                {
                     $.toaster('Cart updated successfully','Success','success');
                     $($qtyid).html($qty);
                     $($subid).html("₹"+$price);
                     updateTotal();
                }
            }
        });
        if($qty < 0) $qty = 0;

    }
    function deleteQ(Product_id)
    {
        $remrow = $("#tr"+Product_id);
        $.ajax({
            type: "POST",
            url: "data.php",
            data: {
                type: "deleteCart",
                Product_id: Product_id,
            },        
            cache: false,               
            success: function(data) {  
                obj = JSON.parse(data);
                if('err' in obj)
                {
                     $.toaster({title:'Error',message:obj['error'],priority:'info'});
                }
                else
                {
                     $.toaster('Removed from cart successfully','Success','info');
                     $remrow.remove();
                     updateTotal();
                }
            }
        });
        $remrow.remove();
    }
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
                updateTotal(); 
            }
        });
    })
</script>