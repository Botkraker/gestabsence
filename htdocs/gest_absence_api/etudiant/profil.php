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

$etudiantId = isset($_GET['etudiant_id']) ? (int)$_GET['etudiant_id'] : 0;

if ($etudiantId <= 0) {
	respond(400, false, "Query parameter etudiant_id is required");
}

$sql = "
	SELECT e.id AS etudiant_id, e.utilisateur_id, e.classe_id,
		   u.nom, u.prenom, u.email, u.role,
		   c.nom AS classe_nom, c.niveau AS classe_niveau
	FROM etudiants e
	INNER JOIN utilisateurs u ON u.id = e.utilisateur_id
	INNER JOIN classes c ON c.id = e.classe_id
	WHERE e.id = ?
";

$stmt = $db->prepare($sql);
$stmt->bind_param("i", $etudiantId);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
	respond(404, false, "Student profile not found");
}

respond(200, true, "Student profile fetched", $result->fetch_assoc());
?>
