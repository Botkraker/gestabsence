<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
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

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    respond(405, false, "Method not allowed");
}

$month = (int)date('n');
$year = (int)date('Y');

if ($month <= 6) {
    $currentStart = sprintf('%04d-01-01', $year);
    $currentEnd = sprintf('%04d-06-30', $year);
    $previousStart = sprintf('%04d-07-01', $year - 1);
    $previousEnd = sprintf('%04d-12-31', $year - 1);
    $semesterLabel = 'S1';
} else {
    $currentStart = sprintf('%04d-07-01', $year);
    $currentEnd = sprintf('%04d-12-31', $year);
    $previousStart = sprintf('%04d-01-01', $year);
    $previousEnd = sprintf('%04d-06-30', $year);
    $semesterLabel = 'S2';
}

$totalResult = $db->query("SELECT COUNT(*) AS total_students FROM etudiants");
if (!$totalResult) {
    respond(500, false, "Failed to fetch total students");
}

$totalStudents = (int)$totalResult->fetch_assoc()['total_students'];

$currentStmt = $db->prepare(
    "SELECT COUNT(*) AS c
     FROM etudiants e
     INNER JOIN utilisateurs u ON u.id = e.utilisateur_id
     WHERE u.role = 'etudiant' AND DATE(u.created_at) BETWEEN ? AND ?"
);

if (!$currentStmt) {
    respond(500, false, "Failed to prepare current semester query");
}

$currentStmt->bind_param("ss", $currentStart, $currentEnd);
$currentStmt->execute();
$currentCount = (int)$currentStmt->get_result()->fetch_assoc()['c'];

$previousStmt = $db->prepare(
    "SELECT COUNT(*) AS c
     FROM etudiants e
     INNER JOIN utilisateurs u ON u.id = e.utilisateur_id
     WHERE u.role = 'etudiant' AND DATE(u.created_at) BETWEEN ? AND ?"
);

if (!$previousStmt) {
    respond(500, false, "Failed to prepare previous semester query");
}

$previousStmt->bind_param("ss", $previousStart, $previousEnd);
$previousStmt->execute();
$previousCount = (int)$previousStmt->get_result()->fetch_assoc()['c'];

if ($previousCount > 0) {
    $percentage = (($currentCount - $previousCount) / $previousCount) * 100;
} else {
    $percentage = $currentCount > 0 ? 100 : 0;
}

respond(200, true, "Stats fetched", array(
    "total_students" => $totalStudents,
    "current_semester_students" => $currentCount,
    "previous_semester_students" => $previousCount,
    "percentage_change" => round($percentage, 2),
    "semester_label" => $semesterLabel,
    "current_start" => $currentStart,
    "current_end" => $currentEnd,
    "previous_start" => $previousStart,
    "previous_end" => $previousEnd
));
?>