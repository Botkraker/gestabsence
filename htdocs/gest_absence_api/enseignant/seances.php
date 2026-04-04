<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(array("success" => 0, "message" => "Method not allowed"));
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

    echo json_encode($response);
    exit();
}

if ($db->connect_error) {
    respond(500, false, "Database connection failed");
}

$enseignantId = isset($_GET['enseignant_id']) ? (int)$_GET['enseignant_id'] : 0;
$seanceId = isset($_GET['id']) ? (int)$_GET['id'] : 0;

if ($enseignantId <= 0) {
    respond(400, false, "Query parameter enseignant_id is required");
}

$sql = "
    SELECT s.id, s.enseignant_id, s.classe_id, s.matiere_id,
           s.date_seance, s.heure_debut, s.heure_fin,
           c.nom AS classe_nom,
           m.nom AS matiere_nom
    FROM seances s
    INNER JOIN classes c ON c.id = s.classe_id
    INNER JOIN matieres m ON m.id = s.matiere_id
    WHERE s.enseignant_id = ?
";

if ($seanceId > 0) {
    $sql .= " AND s.id = ? ORDER BY s.date_seance DESC, s.heure_debut DESC";
    $stmt = $db->prepare($sql);
    $stmt->bind_param("ii", $enseignantId, $seanceId);
} else {
    $sql .= " ORDER BY s.date_seance DESC, s.heure_debut DESC";
    $stmt = $db->prepare($sql);
    $stmt->bind_param("i", $enseignantId);
}

$stmt->execute();
$result = $stmt->get_result();

$rows = array();
while ($row = $result->fetch_assoc()) {
    $rows[] = $row;
}

respond(200, true, "Sessions fetched", $rows);
?>