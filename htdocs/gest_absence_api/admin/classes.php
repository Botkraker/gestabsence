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



$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
	if (isset($_GET['id'])) {
		$id = (int)$_GET['id'];
		$stmt = $db->prepare("SELECT id, nom, niveau FROM classes WHERE id = ?");
		$stmt->bind_param("i", $id);
		$stmt->execute();
		$result = $stmt->get_result();

		if ($result->num_rows === 0) {
			respond(404, false, "Class not found");
		}

		respond(200, true, "Class fetched", $result->fetch_assoc());
	}

	$result = $db->query("SELECT id, nom, niveau FROM classes ORDER BY id DESC");
	$rows = array();

	while ($row = $result->fetch_assoc()) {
		$rows[] = $row;
	}

	respond(200, true, "Classes fetched", $rows);
}

if ($method === 'POST') {
	$body = getBody();
	$nom = isset($body['nom']) ? trim($body['nom']) : '';
	$niveau = isset($body['niveau']) ? trim($body['niveau']) : null;

	if ($nom === '') {
		respond(400, false, "Field nom is required");
	}

	$stmt = $db->prepare("INSERT INTO classes (nom, niveau) VALUES (?, ?)");
	$stmt->bind_param("ss", $nom, $niveau);

	if (!$stmt->execute()) {
		respond(500, false, "Failed to create class");
	}

	respond(201, true, "Class created", array("id" => $db->insert_id));
}

respond(405, false, "Method not allowed");
?>
