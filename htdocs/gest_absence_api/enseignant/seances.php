<?php
// 1. Set Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

if ($_SERVER['REQUEST_METHOD'] != 'GET') {
    http_response_code(405);
    echo json_encode(["message" => "Méthode non autorisée. Utilisez GET."]);
    exit();
}
include_once '../config/database.php';
$data = json_decode(file_get_contents("php://input"));
//input here (seanceid:1,listabsence:[1,"present"])
$response = array();
$sql="SELECT * FROM `seances`";
if(isset($_GET["enseignantid"])){
    $id=$_GET["enseignantid"];
    $sql=$sql."WHERE `enseignant_id`=$id";
}
else{
    if (isset($_GET["id"])){
        $id=$_GET["id"];
        $sql=$sql."WHERE id=$id";
    }
}
$result= $db->query($sql.";");
if ($result->num_rows>0){
    while ($row = $result->fetch_assoc()) {
        $seances_arr[] = $row;
    }
    http_response_code(200);
    $response["success"]=1;
    $response["message"]="Fetch Done";
    $response["data"]=$seances_arr;
    echo json_encode($response);
}else{
    http_response_code(404);
    $response["success"]=0;
    $response["message"]="Seance Not Found";
    echo json_encode($response);
}

?>