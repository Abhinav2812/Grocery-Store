<?php
            include 'reqs.php';
            include 'config.php';
            if($_SERVER["REQUEST_METHOD"] == 'POST' && isset($_POST["type"]))
            {     
                  if($_POST["type"] == "userdata")
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
                        <table class='table'>
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
                        $query = "SELECT * FROM Address WHERE User_id = $username";
                        $out = mysqli_query($conn,$query);
                        if(!($out))
                              echo "<p>You haven't added an address yet</p>";
                        else
                        {
                              while($row = mysqli_fetch_array($out))
                              {
                                    echo "
                                    <table class = 'table'>
                                          <tr>

                                          </tr>
                                    </table>
                                    ";
                              }
                        }
                        echo "<button type='button' class='button'><span class='glyphicon glyphicon-plus' aria-hidden='true'></span>Add Address</button>";
                  }
            }
?>
