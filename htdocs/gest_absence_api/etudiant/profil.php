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
if (isset($_GET["id"])) {
    $id = $_GET["id"]; 
    $sql = "SELECT ut.nom, ut.prenom, ut.email, c.nom as classe,c.niveau FROM etudiants et INNER JOIN utilisateurs ut ON et.utilisateur_id = ut.id INNER JOIN  classes c on c.id=et.classe_id WHERE et.id='$id';";
    $result = $db->query($sql);
    http_response_code(200);
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $tmp[] = $row;
        }
        http_response_code(200);
        $response["success"] = 1;
        $response["message"] = "Fetch Done";
        $response["data"] = $tmp;
        echo json_encode($response);
    } else {
        http_response_code(404);
        $response["success"] = 0;
        $response["message"] = "student not found";
        echo json_encode($response);
    }
} else if(isset($_GET["utilisateur_id"])) {
    $utilisateur_id = $_GET["utilisateur_id"]; 
    $sql = "SELECT ut.nom, ut.prenom, ut.email, c.nom as classe ,c.niveau FROM etudiants et INNER JOIN utilisateurs ut ON et.utilisateur_id = ut.id INNER JOIN  classes c on c.id=et.classe_id WHERE et.utilisateur_id='$utilisateur_id';";
    $result = $db->query($sql);
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $tmp[] = $row;
        }
        http_response_code(200);
        $response["success"] = 1;
        $response["message"] = "Fetch Done";
        $response["data"] = $tmp;
        echo json_encode($response);
    } else {
        http_response_code(404);
        $response["success"] = 0;
        $response["message"] = "student not found";
        echo json_encode($response);
    }

} 
else {
    http_response_code(400);
    $response["success"] = 0;
    $response["message"] = "Error StudentId is not provided";
    echo json_encode($response);
}
