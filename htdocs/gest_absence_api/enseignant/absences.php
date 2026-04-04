<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(array("success" => 0, "message" => "Method not allowed"));
    exit();
}

include_once '../config/database.php';

function respond($statusCode, $success, $message, $data = null)
{
    http_response_code($statusCode);
    $response = array(
        "success" => $success ? 1 : 0,
        "message" => $message
    );

    if ($data !== null) {
        $response["data"] = $data;
    }

    echo json_encode($response);
    exit();
}

if ($db->connect_error) {
    respond(500, false, "Database connection failed");
}

$body = json_decode(file_get_contents("php://input"), true);
if (!is_array($body)) {
    respond(400, false, "Invalid JSON body");
}

$enseignantId = isset($body['enseignant_id']) ? (int)$body['enseignant_id'] : 0;
$seanceId = isset($body['seance_id']) ? (int)$body['seance_id'] : 0;
$listAbsence = isset($body['listabsence']) && is_array($body['listabsence']) ? $body['listabsence'] : array();

if ($enseignantId <= 0 || $seanceId <= 0 || empty($listAbsence)) {
    respond(400, false, "Fields enseignant_id, seance_id and listabsence are required");
}

$stmtSeance = $db->prepare("SELECT id FROM seances WHERE id = ? AND enseignant_id = ?");
$stmtSeance->bind_param("ii", $seanceId, $enseignantId);
$stmtSeance->execute();
if ($stmtSeance->get_result()->num_rows === 0) {
    respond(403, false, "This session does not belong to the teacher");
}

$db->begin_transaction();

try {
    $updated = 0;
    foreach ($listAbsence as $item) {
        if (!is_array($item) || count($item) < 2) {
            throw new Exception("Each listabsence item must be [etudiant_id, statut]");
        }

        $etudiantId = (int)$item[0];
        $statut = (string)$item[1];

        if ($etudiantId <= 0 || ($statut !== 'present' && $statut !== 'absent')) {
            throw new Exception("Invalid absence item values");
        }

        $stmtStudent = $db->prepare("SELECT id FROM etudiants WHERE id = ?");
        $stmtStudent->bind_param("i", $etudiantId);
        $stmtStudent->execute();
        if ($stmtStudent->get_result()->num_rows === 0) {
            throw new Exception("Student not found: " . $etudiantId);
        }

        $stmtUpsert = $db->prepare(
            "INSERT INTO absences (seance_id, etudiant_id, statut)
             VALUES (?, ?, ?)
             ON DUPLICATE KEY UPDATE statut = VALUES(statut)"
        );
        $stmtUpsert->bind_param("iis", $seanceId, $etudiantId, $statut);

        if (!$stmtUpsert->execute()) {
            throw new Exception("Failed to save absence");
        }

        $updated++;
    }

    $db->commit();
    respond(200, true, "Absences saved", array("count" => $updated));
} catch (Exception $e) {
    $db->rollback();
    respond(400, false, $e->getMessage());
}
?>