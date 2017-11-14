<?php
        session_start();
        include 'config.php';
        if($_SERVER["REQUEST_METHOD"] == 'POST' && isset($_POST["type"]))
        {     
            if($_POST["type"] == "checklogin")
            {
                if(!isset($_SESSION['username']))
                {
                    $myobj = new stdClass();
                    $myobj->loc = "/gstore/enter.php";
                    echo json_encode($myobj);
                    die();
                }
                echo "{}";     
            }
            else if($_POST["type"] == "userdata")
            {
                if(!isset($_SESSION['username']))
                {
                    header("Location:/gstore/enter.php");
                    die();
                }
                $username = $_SESSION['username'];
                $first_name = $_SESSION['first_name'];
                $last_name = $_SESSION['last_name'];
                $email = $_SESSION['email'];
                $mobile = $_SESSION['mobile'];
                echo "
                <table class='table table-striped table-bordered table-responsive table-hover'>
                <tr>
                <td>Username</td>
                <td>$username</td>
                </tr>
                <tr>
                <td>Name</td>
                <td>$first_name $last_name</td>
                </tr>
                <tr>
                <td>Email Id</td>
                <td>$email</td>
                </tr>
                <tr>
                <td>Mobile Number</td>
                <td>+91-$mobile</td>
                </tr>            
                </table>
                ";
            }
            else if($_POST["type"] == "address")
            {
                $username = $_SESSION['username'];
                echo "<h3>My Addresses</h3>";
                $query = "SELECT * FROM ADDRESS WHERE user_id = '$username'";
                $out = mysqli_query($conn,$query);
                if(!($out))
                    echo "<p>You haven't added an address yet</p>";
                else
                {
                    $cnt = 1;
                    while($row = mysqli_fetch_array($out))
                    {
                        echo "
                            <div class='panel panel-primary'>
                                <div class='panel-heading' data-toggle = 'collapse' data-target='#collapse$cnt'>
                                    <h3 class='panel-title'>Address $cnt</h3>
                                </div></a>
                                <div class='panel-collapse collapse' id='collapse$cnt'>
                                    <div class='panel-body'>
                                        <p>".$row['Address_1']."</p>
                                <p>".$row['Address_2']."<p>".$row['city']."</p> <p>".$row['state']."</p> <p> Pin Code - ".$row['zip_code']."</p>
                                    </div>
                                </div>
                            </div>
                        ";
                        $cnt = $cnt + 1;
                    }
                }
            }
            else if($_POST["type"] == "seladdress")
            {
                $username = $_SESSION['username'];
                echo "<h3>My Addresses</h3>";
                $query = "SELECT * FROM ADDRESS WHERE user_id = '$username'";
                $out = mysqli_query($conn,$query);
                if(!($out))
                    echo "<p>You haven't added an address yet</p>";
                else
                {
                    $cnt = 1;
                    while($row = mysqli_fetch_array($out))
                    {
                        echo "
                            <div class='panel panel-primary' style='cursor:pointer;' id = 'add$cnt' onclick='setadd($cnt,".$row['Address_id'].");'>
                                <div class='panel-heading'>
                                    <h3 class='panel-title'>Address $cnt</h3>
                                </div></a>
                                    <div class='panel-body'>
                                        <p>".$row['Address_1']."</p>
                                <p>".$row['Address_2']."<p>".$row['city']."</p> <p>".$row['state']."</p> <p> Pin Code - ".$row['zip_code']."</p>
                                </div>
                            </div>
                        ";
                        $cnt = $cnt + 1;
                    }
                }
            }
            else if($_POST["type"] == "setaddid")
            {
                $_SESSION['addid'] = $_POST['aid'];
                echo $_POST['aid'];
            }
            else if($_POST["type"] == "add-address")
            {
                $a1 = mysql_real_escape_string($_POST['a1']);
                $a2 = mysql_real_escape_string($_POST['a2']);
                $city = mysql_real_escape_string($_POST['city']);
                $state = mysql_real_escape_string($_POST['state']);
                $pincode = mysql_real_escape_string($_POST['pincode']);
                $username = $_SESSION['username'];
                $query = "INSERT INTO `ADDRESS`(`Address_1`, `Address_2`, `zip_code`, `city`, `state`, `user_id`) VALUES ('$a1','$a2',$pincode,'$city','$state','$username')";
                $out = mysqli_query($conn,$query);
                if(!$out)
                {
                    echo "<strong>".mysqli_error($conn)."</strong>";
                    die();
                }
            }
            else if($_POST["type"] == "items")
            {
                $query = "SELECT Product_id,Product_name,Units,Picture,Category_name,Manufacturer_name,Price,Product_description FROM PRODUCT,CATEGORY,MANUFACTURER WHERE PRODUCT.Category_id = CATEGORY.Category_id AND PRODUCT.Manufacturer_id = MANUFACTURER.Manufacturer_id AND (Product_name LIKE '%".$_POST['pattern']."%' OR Manufacturer_name LIKE '%".$_POST['pattern']."%' OR Category_name LIKE '%".$_POST['pattern']."%') ORDER BY CATEGORY.Category_id,MANUFACTURER.Manufacturer_id";
                $out = mysqli_query($conn,$query);
                if(!($out))
                    echo "<p>No Products Available</p>";
                else
                {
                    while($row = mysqli_fetch_array($out))
                    {
                        echo "
                                    <div class='panel panel-primary'>
                                        <div class='panel-heading'>
                                            <h3 class='panel-title'>".$row['Product_name']." <span class='badge'>Units Available:".$row['Units']."</span></h3>
                                        </div>
                                        <div class='panel-body'>
                                    <img height = 150 src = 'images/".$row['Picture']."'>
                                    <p> Category:".$row['Category_name']."</p> 
                                    <p> Manufacturer:".$row['Manufacturer_name']."</p> 
                                    <p>Description:-<br/>".$row['Product_description']."</p>
                                    <p> Price: ₹".$row['Price']."</p>
                                    <button class = 'btn btn-primary' onclick='addSuccess(\"".$row['Product_name']."\",".$row['Product_id'].")'><span class='glyphicon glyphicon-shopping-cart'></span> Add to cart</button>
                                        </div>
                                    </div>
                        ";
                    }
                }
            }
            else if($_POST["type"] == "viewcart")
            {
                $username = $_SESSION['username'];
                $query = "SELECT PRODUCT.Product_id, Product_name, Quantity, Manufacturer_name,Picture,Price,Product_description FROM CART, PRODUCT, MANUFACTURER WHERE CART.Product_id = PRODUCT.Product_id AND PRODUCT.Manufacturer_id = MANUFACTURER.Manufacturer_id AND user_id = '$username' ORDER BY Product_name;";
                $out = mysqli_query($conn,$query);
                if((!$out) || $out->num_rows == 0)
                    echo "<p>No items in Cart</p>";
                else
                {
                    while($row = mysqli_fetch_array($out))
                    {
                        $sum = 0.0;
                        echo "
                            <tr id='tr".$row['Product_id']."'>
                                <td data-th='Product'>
                                    <div class='row'>
                                        <div class='col-sm-2 hidden-xs'><img src='images/".$row['Picture']."' class='img-responsive'/></div>
                                        <div class='col-sm-10'>
                                            <h4 class='nomargin'>".$row['Product_name']." (".$row['Manufacturer_name'].")</h4>
                                            <p>".$row['Product_description']."</p>
                                        </div>
                                    </div>
                                </td>
                                <td data-th='Price' id='price".$row['Product_id']."'>₹".$row['Price']."</td>
                                <td data-th='Quantity'>
                                    <input type='number' min='1' class='form-control text-center' id='qty".$row['Product_id']."' value='".$row['Quantity']."'>
                                </td>
                                <td data-th='Subtotal' class='text-center subtotal' id='sub".$row['Product_id']."'>₹".($row['Price']*$row['Quantity'])."</td>
                                <td class='actions'>
                                    <button class='btn btn-info btn-sm' onclick = \"updateQ(".$row['Product_id'].")\"><i class='fa fa-refresh'></i></button>
                                    <button class='btn btn-danger btn-sm' onclick = \"deleteQ(".$row['Product_id'].")\"><i class='fa fa-trash-o'></i></button>                                
                                </td>
                            </tr>
                        ";
                    }
                }
            }
            else if($_POST["type"] == "addtocart")
            {
                if(!isset($_SESSION['username']))
                {
                    $myobj = new stdClass();
                    $myobj->err = "Login first";
                    echo json_encode($myobj);
                    die();
                }
                $username = $_SESSION['username'];
                $query1 = "Select Units FROM PRODUCT WHERE Product_id=".$_POST['product_id'].";";
                $out1 = mysqli_query($conn,$query1);
                $query2 = "Select Quantity FROM CART WHERE Product_id=".$_POST['product_id']." AND user_id = '$username';";
                $out2 = mysqli_query($conn,$query2);
                if($out1->num_rows == 0)
                {
                    $myobj = new stdClass();
                    $myobj->err = "database error:item not found";
                    echo json_encode($myobj);
                    die();
                }
                $out1 = mysqli_fetch_assoc($out1);
                $itemc = 0;
                $flag = 1;
                if(($out2) && ($out2->num_rows != 0))
                {
                    $out2 = mysqli_fetch_assoc($out2);
                    $itemc = $out2['Quantity'];
                }
                else
                {
                    $flag = 0;
                }
                if($out1['Units'] <= $itemc)
                {
                    $myobj = new stdClass();
                    $myobj->err = "insufficient no of items available";
                    echo json_encode($myobj);
                    die();
                }
                if($flag == 0)
                {
                    $query = "INSERT INTO CART VALUES('$username',".$_POST['product_id'].",1);";
                    mysqli_query($conn,$query);
                }
                else
                {
                    $query = "UPDATE CART SET Quantity = Quantity + 1 WHERE user_id = '$username' AND Product_id = ".$_POST['product_id'].";";
                    mysqli_query($conn,$query);
                }
                echo "{}";
            }
            else if($_POST['type'] == 'deleteCart')
            {
                $username = $_SESSION['username'];
                $query = "DELETE FROM CART WHERE user_id = '$username' and product_id = ".$_POST['Product_id'].";";
                $obj = mysqli_query($conn,$query);
                if(!$obj)
                {
                    $myobj = new stdClass();
                    $myobj->err = mysqli_error($conn);
                    echo json_encode($myobj);
                    die();
                }
                echo "{}";
            }
            else if($_POST['type'] == 'updateCart')
            {
                $username = $_SESSION['username'];
                $query = "SELECT Units FROM PRODUCT WHERE Product_id = ".$_POST['Product_id']."";
                $obj = mysqli_query($conn,$query);
                if(!($obj))
                {
                    $myobj = new stdClass();
                    $myobj->err = mysqli_error($conn);
                    echo json_encode($myobj);
                    die();
                } 
                $obj = mysqli_fetch_assoc($obj);
                if($obj['Units'] < $_POST['qty'])
                {
                    $myobj = new stdClass();
                    $myobj->err = "Insufficient Units Available, setting to max no of units";
                    $myobj->qty = $obj['Units'];
                    echo json_encode($myobj);
                    $query = "UPDATE CART SET Quantity = ".$obj['Units']." WHERE user_id = '$username' and product_id = ".$_POST['Product_id'].";";
                    $obj = mysqli_query($conn,$query);
                    die();
                }
                $query = "UPDATE CART SET Quantity = ".$_POST['qty']." WHERE user_id = '$username' and product_id = ".$_POST['Product_id'].";";
                $obj = mysqli_query($conn,$query);
                if(!$obj)
                {
                    $myobj = new stdClass();
                    $myobj->err = mysqli_error($conn);
                    echo json_encode($myobj);
                    die();
                }
                echo "{}";
            }
            else if($_POST["type"] == "vieworder")
            {
                $username = $_SESSION['username'];
                $query = "SELECT PRODUCT.Product_id, Product_name, Quantity, Manufacturer_name,Picture,Price,Product_description FROM CART, PRODUCT, MANUFACTURER WHERE CART.Product_id = PRODUCT.Product_id AND PRODUCT.Manufacturer_id = MANUFACTURER.Manufacturer_id AND user_id = '$username' ORDER BY Product_name;";
                $out = mysqli_query($conn,$query);
                if((!$out) || $out->num_rows == 0)
                    echo "<p>No items in Cart</p>";
                else
                {
                    while($row = mysqli_fetch_array($out))
                    {
                        $sum = 0.0;
                        echo "
                            <tr id='tr".$row['Product_id']."'>
                                <td data-th='Product' >
                                    <div class='row'>
                                        <div class='col-sm-2 hidden-xs'><img src='images/".$row['Picture']."' class='img-responsive'/></div>
                                        <div class='col-sm-10'>
                                            <h4 class='nomargin'>".$row['Product_name']." (".$row['Manufacturer_name'].")</h4>
                                            <p>".$row['Product_description']."</p>
                                        </div>
                                    </div>
                                </td>
                                <td data-th='Price' id='price".$row['Product_id']."'>₹".$row['Price']."</td>
                                <td data-th='Quantity'>
                                    <p id='qty".$row['Product_id']."'>".$row['Quantity']."</p>
                                </td>
                                <td data-th='Subtotal' class='text-center subtotal' id='sub".$row['Product_id']."'>₹".($row['Price']*$row['Quantity'])."</td>
                            </tr>
                        ";
                    }
                }
            }
            else if($_POST["type"] == "addcnt")
            {
                $myobj = new stdClass();
                $query = "SELECT COUNT(*) AS cnt FROM ADDRESS WHERE user_id = '".$_SESSION['username']."';";
                $out = mysqli_fetch_array(mysqli_query($conn,$query));
                $myobj->cnt = $out['cnt'];
                echo json_encode($myobj);
                die();
            }
            else if($_POST["type"] == "orderdone")
            {
                $myobj = new stdClass();
                $query = "CALL PLACEORDER('".$_SESSION['username']."','".$_POST['paymode']."',".$_SESSION['addid'].");";
                $out = mysqli_query($conn,$query);
                if(!($out))
                {
                    $myobj->err = mysqli_error($conn);
                }
                echo json_encode($myobj);
                die();
            }
            else if($_POST["type"] == "checkcartempty")
            {
                $myobj = new stdClass();
                $query = "SELECT COUNT(*) AS cnt FROM CART WHERE user_id = '".$_SESSION['username']."';";
                $out = mysqli_fetch_array(mysqli_query($conn,$query));
                $myobj->cnt = $out['cnt'];
                echo json_encode($myobj);
                die();
            }
            else if($_POST["type"] == "myorder")
            {
                $username = $_SESSION['username'];
                $query = "SELECT * FROM G_ORDER WHERE user_id = '$username';";
                $out = mysqli_query($conn,$query);
                if((!$out) || $out->num_rows == 0)
                    echo "<p>No Orders yet</p>";
                else
                {
                    $cnt = 1;
                    while($row = mysqli_fetch_array($out))
                    {
                        echo "<h3>Order #$cnt</h3>";
                        echo "<p>Order time: ".$row['Order_time']."</p>";
                        echo "<p>Payment Method: ".$row['Payment_Method']."</p>";
                        echo "<p>Billing Id: ".$row['Billing_id']."</p>";
                        echo "<p>Shipping Id: ".$row['Shipping_id']."</p>";
                        echo "<h4>Delivery Address:-</h4>";
                        $query = "SELECT * FROM ADDRESS WHERE Address_id = '".$row['Address_id']."'";
                        $out2 = mysqli_fetch_assoc(mysqli_query($conn,$query));
                        echo "<p>".$out2['Address_1'].", ".$out2['Address_2']."</p>";
                        echo "<p>".$out2['city'].", ".$out2['state'].", Pin Code: ".$out2['zip_code']."</p>";
                        echo "  <table id='cart' class='table table-hover table-condensed'>
                                <thead>
                                    <tr>
                                        <th style='width:50%' align=middle>Product</th>
                                        <th style='width:10%' align=middle>Price</th>
                                        <th style='width:8%' align=middle>Quantity</th>
                                        <th style='width:22%' class='text-center'>Subtotal</th>
                                    </tr>
                                </thead>
                                <tbody id='items'>";
                        $query = "SELECT * FROM PRODUCT JOIN PRODUCT_ORDER ON PRODUCT.Product_id = PRODUCT_ORDER.Product_id JOIN MANUFACTURER ON MANUFACTURER.Manufacturer_id = PRODUCT.Manufacturer_id WHERE PRODUCT_ORDER.Order_id = ".$row['Order_id'].";";
                        $out2 = mysqli_query($conn,$query);
                        while($row2 = mysqli_fetch_array($out2))
                        {
                            $sum = 0.0;
                            echo "
                                <tr id='tr".$row2['Product_id']."'>
                                    <td data-th='Product' >
                                        <div class='row'>
                                            <div class='col-sm-2 hidden-xs'><img src='images/".$row2['Picture']."' class='img-responsive'/></div>
                                            <div class='col-sm-10'>
                                                <h4 class='nomargin'>".$row2['Product_name']." (".$row2['Manufacturer_Name'].")</h4>
                                                <p>".$row2['Product_description']."</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td data-th='Price' id='price".$row2['Product_id']."'>₹".$row2['Price']."</td>
                                    <td data-th='Quantity'>
                                        <p id='qty".$row2['Product_id']."'>".$row2['Quantity']."</p>
                                    </td>
                                    <td data-th='Subtotal' class='text-center subtotal' id='sub".$row2['Product_id']."'>₹".($row2['Price']*$row2['Quantity'])."</td>
                                </tr>
                            ";
                        }            
                        echo   "</tbody>
                                <tfoot>
                                    <tr>
                                        <td colspan='3' class='hidden-xs'></td>
                                        <td class='hidden-xs text-center' id='total$cnt'><strong>Total ₹".$row['Amount']."</strong></td>
                                    </tr>
                                </tfoot>
                            </table>";
                        // echo "
                        //     <tr id='tr".$row['Product_id']."'>
                        //         <td data-th='Product' >
                        //             <div class='row'>
                        //                 <div class='col-sm-2 hidden-xs'><img src='images/".$row['Picture']."' class='img-responsive'/></div>
                        //                 <div class='col-sm-10'>
                        //                     <h4 class='nomargin'>".$row['Product_name']." (".$row['Manufacturer_name'].")</h4>
                        //                     <p>".$row['Product_description']."</p>
                        //                 </div>
                        //             </div>
                        //         </td>
                        //         <td data-th='Price' id='price".$row['Product_id']."'>₹".$row['Price']."</td>
                        //         <td data-th='Quantity'>
                        //             <p id='qty".$row['Product_id']."'>".$row['Quantity']."</p>
                        //         </td>
                        //         <td data-th='Subtotal' class='text-center subtotal' id='sub".$row['Product_id']."'>₹".($row['Price']*$row['Quantity'])."</td>
                        //     </tr>
                        // ";
                        echo "<br><hr/>";
                        $cnt++;
                    }
                }
            }
        }
?>
