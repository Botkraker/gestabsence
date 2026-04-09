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
    $sql = "SELECT mat.nom, s.date_seance, s.heure_debut,s.heure_fin, abs.statut FROM absences abs INNER JOIN seances s ON abs.seance_id = s.id INNER JOIN matieres mat on s.matiere_id=mat.id WHERE abs.etudiant_id='$id';";
    $result = $db->query($sql);
    http_response_code(200);
    if ($result->num_rows > 0) {
        $abscounter = 0;
        while ($row = $result->fetch_assoc()) {
            $tmp[] = $row;
            if($row["statut"]==="absent"){
                $abscounter++;
            }
        }
        http_response_code(200);
        $response["abscounter"]=$abscounter;
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
} else {
    http_response_code(400);
    $response["success"] = 0;
    $response["message"] = "Error StudentId is not provided";
    echo json_encode($response);
}
?>
