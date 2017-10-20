<?php
    session_start();
    $return = $_SESSION['ploc'];
    session_destroy();
    header("location:$return");
?>