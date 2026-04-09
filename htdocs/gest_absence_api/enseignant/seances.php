<?php
// 1. Set Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] != 'GET') {
    http_response_code(405);
    echo json_encode(["message" => "Méthode non autorisée. Utilisez GET."]);
    exit();
}
include_once '../config/database.php';
$data = json_decode(file_get_contents("php://input"));
$response = array();
$sql="SELECT `seances`.*, `classes`.`nom` as `classe_nom`, `matieres`.`nom` as `matiere_nom` FROM `seances` join `classes` on `seances`.`classe_id` = `classes`.`id` join `matieres` on `seances`.`matiere_id` = `matieres`.`id` WHERE 1";
if (isset($_GET["id"])){
    $id=$_GET["id"];
    $sql=$sql." and seances.id=$id"; 
    }
if (isset($_GET["enseignant_id"])){
    $eid=$_GET["enseignant_id"];
    $sql=$sql." and seances.enseignant_id=$eid";
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