<?php
            session_start();
            include 'config.php';
            if($_SERVER["REQUEST_METHOD"] == 'POST' && isset($_POST["type"]))
            {     
                  if($_POST["type"] == "checklogin")
                  {
                        if(!isset($_SESSION['username']))
                        {
                            header("Location:/gstore/enter.php");
                            die();
                        }     
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
                              echo "<table class = 'table table-striped table-responsive table-hover'>";
                              $cnt = 1;
                              while($row = mysqli_fetch_array($out))
                              {
                                    echo "
                                          <tr>
                                                <tr>
                                                      <div class='panel panel-primary'>
                                                            <div class='panel-heading'>
                                                                <h3 class='panel-title'>Address $cnt</h3>
                                                            </div>
                                                            <div class='panel-body'>
                                                                <p>".$row['Address_1']."</p>
                                                      <p>".$row['Address_2']."<p>".$row['city']."</p> <p>".$row['state']."</p> <p> Pin Code - ".$row['zip_code']."</p>
                                                            </div>
                                                      </div>
                                                </tr>
                                          </tr>
                                    ";
                                    $cnt = $cnt + 1;
                              }
                              echo "</table>";
                        }
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
            }
?>
