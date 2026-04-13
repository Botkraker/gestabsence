<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS");
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

function ensureTable($db)
{
	$sql = "CREATE TABLE IF NOT EXISTS class_matieres (
		id INT AUTO_INCREMENT PRIMARY KEY,
		classe_id INT NOT NULL,
		matiere_id INT NOT NULL,
		UNIQUE KEY unique_class_matiere (classe_id, matiere_id),
		FOREIGN KEY (classe_id) REFERENCES classes(id) ON DELETE CASCADE,
		FOREIGN KEY (matiere_id) REFERENCES matieres(id) ON DELETE CASCADE
	)";

	$db->query($sql);
}

ensureTable($db);
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
	$sql = "
		SELECT cm.id, cm.classe_id, cm.matiere_id, c.nom AS classe_nom, m.nom AS matiere_nom
		FROM class_matieres cm
		INNER JOIN classes c ON c.id = cm.classe_id
		INNER JOIN matieres m ON m.id = cm.matiere_id
		ORDER BY c.nom ASC, m.nom ASC
	";

	$result = $db->query($sql);
	$rows = array();

	while ($row = $result->fetch_assoc()) {
		$rows[] = $row;
	}

	respond(200, true, "Class-matiere assignments fetched", $rows);
}

if ($method === 'POST') {
	$body = getBody();
	$classeId = isset($body['classe_id']) ? (int)$body['classe_id'] : 0;
	$matiereId = isset($body['matiere_id']) ? (int)$body['matiere_id'] : 0;

	if ($classeId <= 0 || $matiereId <= 0) {
		respond(400, false, "Fields classe_id and matiere_id are required");
	}

	$stmt = $db->prepare("INSERT INTO class_matieres (classe_id, matiere_id) VALUES (?, ?)");
	$stmt->bind_param("ii", $classeId, $matiereId);

	if (!$stmt->execute()) {
		if ($db->errno === 1062) {
			respond(409, false, "This class is already assigned to this matiere");
		}
		respond(500, false, "Failed to assign class to matiere");
	}

	respond(201, true, "Assignment created", array("id" => $db->insert_id));
}

if ($method === 'DELETE') {
	$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

	if ($id <= 0) {
		respond(400, false, "Field id is required");
	}

	$stmt = $db->prepare("DELETE FROM class_matieres WHERE id = ?");
	$stmt->bind_param("i", $id);

	if (!$stmt->execute()) {
		respond(500, false, "Failed to delete assignment");
	}

	if ($stmt->affected_rows === 0) {
		respond(404, false, "Assignment not found");
	}

	respond(200, true, "Assignment deleted");
}

respond(405, false, "Method not allowed");
?>
