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

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
	if (isset($_GET['id'])) {
		$id = (int)$_GET['id'];
		$stmt = $db->prepare("SELECT id, nom FROM matieres WHERE id = ?");
		$stmt->bind_param("i", $id);
		$stmt->execute();
		$result = $stmt->get_result();

		if ($result->num_rows === 0) {
			respond(404, false, "Matiere not found");
		}

		respond(200, true, "Matiere fetched", $result->fetch_assoc());
	}

	$result = $db->query("SELECT id, nom FROM matieres ORDER BY nom ASC");
	$rows = array();

	while ($row = $result->fetch_assoc()) {
		$rows[] = $row;
	}

	respond(200, true, "Matieres fetched", $rows);
}

if ($method === 'POST') {
	$body = getBody();
	$nom = isset($body['nom']) ? trim($body['nom']) : '';

	if ($nom === '') {
		respond(400, false, "Field nom is required");
	}

	$stmt = $db->prepare("INSERT INTO matieres (nom) VALUES (?)");
	$stmt->bind_param("s", $nom);

	if (!$stmt->execute()) {
		respond(500, false, "Failed to create matiere");
	}

	respond(201, true, "Matiere created", array("id" => $db->insert_id));
}

if ($method === 'DELETE') {
	$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

	if ($id <= 0) {
		respond(400, false, "Field id is required");
	}

	$stmt = $db->prepare("DELETE FROM matieres WHERE id = ?");
	$stmt->bind_param("i", $id);

	if (!$stmt->execute()) {
		respond(500, false, "Failed to delete matiere");
	}

	if ($stmt->affected_rows === 0) {
		respond(404, false, "Matiere not found");
	}

	respond(200, true, "Matiere deleted");
}

respond(405, false, "Method not allowed");
?>
