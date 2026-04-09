<?php
// 1. Set Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin");
// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
include "../config/database.php";
$response=array();


$data= json_decode(file_get_contents("php://input"));

if (!empty($data->email)&& !empty($data->password)){
    $email=htmlspecialchars(strip_tags($data->email));;
    $pwd=$data->password;
    $req=$db->prepare("SELECT * FROM `utilisateurs` WHERE `utilisateurs`.`email`=? AND `utilisateurs`.`password`=? LIMIT 1;");
    $req->bind_param("ss",$email,$pwd);
    $req->execute();$req=$req->get_result();
    if($req->num_rows > 0){
        $tmp=array();
        $cur=mysqli_fetch_array($req);
        $tmp["id"]=$cur["id"];
        $tmp["name"]=$cur["nom"];
        $tmp["lastname"]=$cur["prenom"];
        $tmp["role"]=$cur["role"];
        $response["user"]=$tmp;
        http_response_code(200);
        $response["success"]=1;
        echo json_encode($response);
        }
        else{
            http_response_code(401);
            $response["success"]=0;
            $response["message"]="No User Found";
            echo json_encode($response);
        }
}
else{
    http_response_code(400);
    $response["success"]=0;
    $response["message"]="email or password not provided";
    echo json_encode($response);
}
?>