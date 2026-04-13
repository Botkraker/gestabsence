<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
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
	$baseSql = "
		SELECT e.id AS enseignant_id, e.utilisateur_id, e.specialite,
			   u.nom, u.prenom, u.email, u.role
		FROM enseignants e
		INNER JOIN utilisateurs u ON u.id = e.utilisateur_id
	";

	if (isset($_GET['id'])) {
		$id = (int)$_GET['id'];
		$stmt = $db->prepare($baseSql . " WHERE e.id = ?");
		$stmt->bind_param("i", $id);
		$stmt->execute();
		$result = $stmt->get_result();

		if ($result->num_rows === 0) {
			respond(404, false, "Teacher not found");
		}

		respond(200, true, "Teacher fetched", $result->fetch_assoc());
	}

	$result = $db->query($baseSql . " ORDER BY e.id DESC");
	$rows = array();

	while ($row = $result->fetch_assoc()) {
		$rows[] = $row;
	}

	respond(200, true, "Teachers fetched", $rows);
}

if ($method === 'POST') {
	$body = getBody();
	$nom = isset($body['nom']) ? trim($body['nom']) : '';
	$prenom = isset($body['prenom']) ? trim($body['prenom']) : '';
	$email = isset($body['email']) ? trim($body['email']) : '';
	$password = isset($body['password']) ? (string)$body['password'] : '';
	$specialite = isset($body['specialite']) ? trim($body['specialite']) : null;

	if ($nom === '' || $prenom === '' || $email === '' || $password === '') {
		respond(400, false, "Fields nom, prenom, email and password are required");
	}

	$role = 'enseignant';
	$db->begin_transaction();

	try {
		$stmtUser = $db->prepare("INSERT INTO utilisateurs (nom, prenom, email, password, role) VALUES (?, ?, ?, ?, ?)");
		$stmtUser->bind_param("sssss", $nom, $prenom, $email, $password, $role);

		if (!$stmtUser->execute()) {
			throw new Exception("Failed to create user");
		}

		$utilisateurId = $db->insert_id;

		$stmtEns = $db->prepare("INSERT INTO enseignants (utilisateur_id, specialite) VALUES (?, ?)");
		$stmtEns->bind_param("is", $utilisateurId, $specialite);

		if (!$stmtEns->execute()) {
			throw new Exception("Failed to create teacher");
		}

		$enseignantId = $db->insert_id;
		$db->commit();

		respond(201, true, "Teacher created", array("enseignant_id" => $enseignantId, "utilisateur_id" => $utilisateurId));
	} catch (Exception $e) {
		$db->rollback();
		if ($db->errno === 1062) {
			respond(409, false, "Email already exists");
		}
		respond(500, false, "Failed to create teacher");
	}
}

if ($method === 'PUT') {
	$body = getBody();
	$enseignantId = isset($body['id']) ? (int)$body['id'] : 0;
	$nom = isset($body['nom']) ? trim($body['nom']) : '';
	$prenom = isset($body['prenom']) ? trim($body['prenom']) : '';
	$email = isset($body['email']) ? trim($body['email']) : '';
	$specialite = isset($body['specialite']) ? trim($body['specialite']) : null;
	$password = isset($body['password']) ? (string)$body['password'] : '';

	if ($enseignantId <= 0 || $nom === '' || $prenom === '' || $email === '') {
		respond(400, false, "Fields id, nom, prenom and email are required");
	}

	$stmt = $db->prepare("SELECT utilisateur_id FROM enseignants WHERE id = ?");
	$stmt->bind_param("i", $enseignantId);
	$stmt->execute();
	$result = $stmt->get_result();

	if ($result->num_rows === 0) {
		respond(404, false, "Teacher not found");
	}

	$utilisateurId = (int)$result->fetch_assoc()['utilisateur_id'];
	$db->begin_transaction();

	try {
		if ($password !== '') {
			$stmtUser = $db->prepare("UPDATE utilisateurs SET nom = ?, prenom = ?, email = ?, password = ? WHERE id = ?");
			$stmtUser->bind_param("ssssi", $nom, $prenom, $email, $password, $utilisateurId);
		} else {
			$stmtUser = $db->prepare("UPDATE utilisateurs SET nom = ?, prenom = ?, email = ? WHERE id = ?");
			$stmtUser->bind_param("sssi", $nom, $prenom, $email, $utilisateurId);
		}

		if (!$stmtUser->execute()) {
			throw new Exception("Failed to update user");
		}

		$stmtEns = $db->prepare("UPDATE enseignants SET specialite = ? WHERE id = ?");
		$stmtEns->bind_param("si", $specialite, $enseignantId);

		if (!$stmtEns->execute()) {
			throw new Exception("Failed to update teacher");
		}

		$db->commit();
		respond(200, true, "Teacher updated");
	} catch (Exception $e) {
		$db->rollback();
		if ($db->errno === 1062) {
			respond(409, false, "Email already exists");
		}
		respond(500, false, "Failed to update teacher");
	}
}

if ($method === 'DELETE') {
	$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

	if ($id <= 0) {
		respond(400, false, "Field id is required");
	}

	$stmt = $db->prepare("SELECT utilisateur_id FROM enseignants WHERE id = ?");
	$stmt->bind_param("i", $id);
	$stmt->execute();
	$result = $stmt->get_result();

	if ($result->num_rows === 0) {
		respond(404, false, "Teacher not found");
	}

	$utilisateurId = (int)$result->fetch_assoc()['utilisateur_id'];
	$db->begin_transaction();

	try {
		$stmtDeleteTeacher = $db->prepare("DELETE FROM enseignants WHERE id = ?");
		$stmtDeleteTeacher->bind_param("i", $id);

		if (!$stmtDeleteTeacher->execute()) {
			throw new Exception("Failed to delete teacher");
		}

		$stmtDeleteUser = $db->prepare("DELETE FROM utilisateurs WHERE id = ?");
		$stmtDeleteUser->bind_param("i", $utilisateurId);

		if (!$stmtDeleteUser->execute()) {
			throw new Exception("Failed to delete linked user");
		}

		$db->commit();
		respond(200, true, "Teacher deleted");
	} catch (Exception $e) {
		$db->rollback();
		respond(500, false, "Failed to delete teacher");
	}
}

respond(405, false, "Method not allowed");
?>
