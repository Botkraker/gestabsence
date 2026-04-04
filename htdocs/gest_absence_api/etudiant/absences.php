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
	SELECT a.id AS absence_id,
		   a.seance_id,
		   a.etudiant_id,
		   a.statut,
		   s.date_seance,
		   s.heure_debut,
		   s.heure_fin,
		   c.nom AS classe_nom,
		   m.nom AS matiere_nom,
		   u.nom AS enseignant_nom,
		   u.prenom AS enseignant_prenom
	FROM absences a
	INNER JOIN seances s ON s.id = a.seance_id
	INNER JOIN classes c ON c.id = s.classe_id
	INNER JOIN matieres m ON m.id = s.matiere_id
	INNER JOIN enseignants e ON e.id = s.enseignant_id
	INNER JOIN utilisateurs u ON u.id = e.utilisateur_id
	WHERE a.etudiant_id = ?
	ORDER BY s.date_seance DESC, s.heure_debut DESC
";

$stmt = $db->prepare($sql);
$stmt->bind_param("i", $etudiantId);
$stmt->execute();
$result = $stmt->get_result();

$rows = array();
while ($row = $result->fetch_assoc()) {
	$rows[] = $row;
}

respond(200, true, "Student absences fetched", $rows);
?>
