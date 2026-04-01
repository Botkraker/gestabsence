<?php
$cnx=mysqli_connect("localhost","yacin","root");
if(!$cnx){
    echo "error trying to connect to server";
}

$db=mysqli_select_db($cnx,"gest_absence");
if(!$db){
    echo "error trying to select database";
}
?>
