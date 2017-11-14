<html>
    <head>
       <?php include 'reqs.php';?>
       <link rel="stylesheet" href="form.css">
        <title>Grocery Store</title>
        <script src="form.js"></script>
    </head>
    <body>
          <?php
            session_set_cookie_params(3600,"/");
            if(isset($_SESSION["username"])){
                            header("Location: index.php");
            }
          ?>
          <?php include 'navbar.php';?>
          <div class="cont_principal">
          <div class="cont_centrar">
          <div class="cont_login">
            <form action="enter.php" method="POST">
            <div class="cont_tabs_login">
              <ul class='ul_tabs'>
                <li class="active"><a href="#" onclick="sign_in()">SIGN IN</a>
                <span class="linea_bajo_nom"></span>
                </li>
                <li><a href="#" onclick="sign_up()">SIGN UP</a><span class="linea_bajo_nom"></span>
                </li>
              </ul>
              </div>
                    <div class="cont_text_inputs">
                        <input type="text" class="input_form_sign d_block active_inp" placeholder="Username*" name="uname" />  
                        <input type="text" class="input_form_sign d_block" placeholder="First Name*" name="fname" />
                        <input type="text" class="input_form_sign d_block" placeholder="Last Name" name="lname" />
                        <input type="text" class="input_form_sign d_block" placeholder="Email*" name="email" /> 
                        <input type="text" class="input_form_sign d_block" placeholder="Mobile Number" name="mno" />
                        <input type="password" class="input_form_sign d_block  active_inp" placeholder="Password*" name="pass" />
                        <input type="password" class="input_form_sign d_block" placeholder="Confirm Password*" name="conf_pass" />    
                        <input type="hidden" name="act" id="act" value="login"/>  
                    </div>
                    <div class="cont_btn">
                       <button class="btn_sign">SIGN IN</button>
                    </div>
            </form>
            </div>
          </div>
          

        </div>
        <?php
            if($_SERVER["REQUEST_METHOD"] == 'POST')
            {
                require_once 'config.php';
                $username = $password = $confirm_password = $email = $first_name = $last_name = $mobile_no = NULL;
                if($_POST["act"] == "signup")
                {
                    echo "<script>sign_up()</script>";
                    $username = mysql_real_escape_string(trim($_POST["uname"]));
                    $first_name = mysql_real_escape_string(trim($_POST["fname"]));
                    $last_name = mysql_real_escape_string(trim($_POST["lname"]));
                    $email = mysql_real_escape_string(trim($_POST["email"]));
                    $password = trim($_POST["pass"]);
                    $confirm_password = trim($_POST["conf_pass"]);
                    $mobile_no = mysql_real_escape_string(trim($_POST["mno"]));
                    if($username == "")
                    {
                        echo "<script>alert('Username cannot be left empty!')</script>";
                        die();
                    }
                    if($first_name == "")
                    {
                        echo "<script>alert('First Name cannot be left empty!')</script>";
                        die();
                    }
                    if($email == "")
                    {
                        echo "<script>alert('Email cannot be left empty!')</script>";
                        die();
                    }
                    if($password == "")
                    {
                        echo "<script>alert('Password cannot be left empty!')</script>";
                        die();
                    }
                    $password = password_hash($password,PASSWORD_DEFAULT);
                    if($confirm_password == "")
                    {
                        echo "<script>alert('Confirm Password cannot be left empty!')</script>";
                        die();
                    }    
                    if(!password_verify($confirm_password,$password))
                    {
                        echo "<script>alert('Passwords do not match!')</script>";
                        die();
                    }
                    if($last_name == "")
                    {
                        $last_name = NULL;
                    }
                    if($mobile_no == "")
                    {
                        $mobile_no = NULL;
                    }
                    $check = "SELECT * from USER where user_id='$username'";
                    if(mysqli_num_rows(mysqli_query($conn,$check)) != 0)
                    {
                        echo "<script>alert('Username is already taken!')</script>";
                        die();
                    }
                    $check = "SELECT * from USER where email_id='$email'";
                    if(mysqli_num_rows(mysqli_query($conn,$check)) != 0)
                    {
                        echo "<script>alert('User with that Email ID already exists!')</script>";
                        die();
                    }
                    $query = "INSERT INTO USER VALUES('$username','$email','$password','$first_name','$last_name','$mobile_no')";
                    $out = mysqli_query($conn,$query);
                    if(!$out)
                    {
                        echo "<script>alert('$conn->error')</script>";
                        die();
                    }
                    $return = $_SESSION['ploc'];
                    $_SESSION['username'] = $username;
                    $_SESSION['first_name'] = $first_name;
                    $_SESSION['last_name'] = $last_name;
                    $_SESSION['email'] = $email;
                    $_SESSION['mobile'] = $mobile_no;
                    echo "<script>window.location = '$return';</script>";
                }
                else if($_POST["act"] == "login")
                {
                    $username = mysql_real_escape_string(trim($_POST["uname"]));
                    $password = trim($_POST["pass"]);
                    if($username == "")
                    {
                            echo "<script>alert('Username cannot be left empty!')</script>";
                            die();
                    }
                    if($password == "")
                    {
                            echo "<script>alert('Password cannot be left empty!')</script>";
                            die();
                    }
                    $check = "SELECT * from USER where user_id='$username' LIMIT 1";
                    $out = mysqli_query($conn,$check);
                    if(mysqli_num_rows($out) == 0)
                    {
                        echo "<script>alert('Invalid username or Password!')</script>";
                        die();
                    }
                    $out = mysqli_query($conn,$check);
                    $out = mysqli_fetch_assoc($out);
                    if(!password_verify($password,$out["password"]))
                    {
                        echo "<script>alert('Invalid username or Password!')</script>";
                        die();
                    }
                    $return = $_SESSION['ploc'];
                    $_SESSION['username'] = $username;
                    $_SESSION['first_name'] = $out['first_name'];
                    $_SESSION['last_name'] = $out['last_name'];
                    $_SESSION['email'] = $out['email_id'];
                    $_SESSION['mobile'] = $out['mobile_no'];
                    echo "<script>window.location = '$return';</script>";
                }
            }
        ?>
    </body>
</html>