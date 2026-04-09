<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
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

function getBody()
{
	$decoded = json_decode(file_get_contents("php://input"), true);
	return is_array($decoded) ? $decoded : array();
}

function ensureExists($db, $table, $id)
{
	$sql = "SELECT id FROM " . $table . " WHERE id = ?";
	$stmt = $db->prepare($sql);
	$stmt->bind_param("i", $id);
	$stmt->execute();
	return $stmt->get_result()->num_rows > 0;
}

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
	$baseSql = "
		SELECT s.id, s.enseignant_id, s.classe_id, s.matiere_id,
			   s.date_seance, s.heure_debut, s.heure_fin,
			   c.nom AS classe_nom,
			   m.nom AS matiere_nom,
			   u.nom AS enseignant_nom,
			   u.prenom AS enseignant_prenom,
			   COUNT(a.id) AS absence_total,
			   SUM(CASE WHEN a.statut = 'absent' THEN 1 ELSE 0 END) AS absent_count
		FROM seances s
		INNER JOIN classes c ON c.id = s.classe_id
		INNER JOIN matieres m ON m.id = s.matiere_id
		INNER JOIN enseignants e ON e.id = s.enseignant_id
		INNER JOIN utilisateurs u ON u.id = e.utilisateur_id
		LEFT JOIN absences a ON a.seance_id = s.id
	";

	if (isset($_GET['id'])) {
		$id = (int)$_GET['id'];
		$stmt = $db->prepare($baseSql . " WHERE s.id = ?");
		$stmt->bind_param("i", $id);
		$stmt->execute();
		$result = $stmt->get_result();

		if ($result->num_rows === 0) {
			respond(404, false, "Session not found");
		}

		respond(200, true, "Session fetched", $result->fetch_assoc());
	}

	$result = $db->query($baseSql . " GROUP BY s.id, s.enseignant_id, s.classe_id, s.matiere_id, s.date_seance, s.heure_debut, s.heure_fin, c.nom, m.nom, u.nom, u.prenom ORDER BY s.date_seance DESC, s.heure_debut DESC");
	$rows = array();

	while ($row = $result->fetch_assoc()) {
		$rows[] = $row;
	}

	respond(200, true, "Sessions fetched", $rows);
}

if ($method === 'POST') {
	$body = getBody();
	$enseignantId = isset($body['enseignant_id']) ? (int)$body['enseignant_id'] : 0;
	$classeId = isset($body['classe_id']) ? (int)$body['classe_id'] : 0;
	$matiereId = isset($body['matiere_id']) ? (int)$body['matiere_id'] : 0;
	$dateSeance = isset($body['date_seance']) ? trim($body['date_seance']) : '';
	$heureDebut = isset($body['heure_debut']) ? trim($body['heure_debut']) : '';
	$heureFin = isset($body['heure_fin']) ? trim($body['heure_fin']) : '';

	if ($enseignantId <= 0 || $classeId <= 0 || $matiereId <= 0 || $dateSeance === '' || $heureDebut === '' || $heureFin === '') {
		respond(400, false, "Fields enseignant_id, classe_id, matiere_id, date_seance, heure_debut and heure_fin are required");
	}

	if (!ensureExists($db, 'enseignants', $enseignantId) || !ensureExists($db, 'classes', $classeId) || !ensureExists($db, 'matieres', $matiereId)) {
		respond(404, false, "One or more related records do not exist");
	}

	$stmt = $db->prepare("INSERT INTO seances (enseignant_id, classe_id, matiere_id, date_seance, heure_debut, heure_fin) VALUES (?, ?, ?, ?, ?, ?)");
	$stmt->bind_param("iiisss", $enseignantId, $classeId, $matiereId, $dateSeance, $heureDebut, $heureFin);

	if (!$stmt->execute()) {
		respond(500, false, "Failed to create session");
	}

	respond(201, true, "Session created", array("id" => $db->insert_id));
}

respond(405, false, "Method not allowed");
?>
