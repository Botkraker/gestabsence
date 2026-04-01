<?php
include "../config/database.php";
$response=array();
if (isset($_GET["email"])&& isset($_GET["password"])){
    $email=$_GET["email"];
    $pwd=$_GET["password"];
    $req=mysqli_query($cnx,"SELECT * FROM `utilisateurs` WHERE `utilisateurs`.`email`='$email' AND `utilisateurs`.`password`='$pwd';");
    if(mysqli_num_rows($req)>0){
        $tmp=array();
        $response["user"]=array();
        $cur=mysqli_fetch_array($req);
        $tmp["id"]=$cur["id"];
        $tmp["name"]=$cur["nom"];
        $tmp["lastname"]=$cur["prenom"];
        $tmp["role"]=$cur["role"];
        array_push($response["user"],$tmp);

        $response["success"]=1;
        echo json_encode($response);
        }
        else{
            $response["success"]=0;
            $response["message"]="No User Found";
            echo json_encode($response);
        }
}
else{
    $response["success"]=-1;
    $response["message"]="email or password not provided";
    echo json_encode($response);
}
?>