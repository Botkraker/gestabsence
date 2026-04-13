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
		SELECT e.id AS etudiant_id, e.utilisateur_id, e.classe_id,
			   u.nom, u.prenom, u.email, u.role,
			   c.nom AS classe_nom, c.niveau AS classe_niveau
		FROM etudiants e
		INNER JOIN utilisateurs u ON u.id = e.utilisateur_id
		INNER JOIN classes c ON c.id = e.classe_id
	";

	if (isset($_GET['id'])) {
		$id = (int)$_GET['id'];
		$stmt = $db->prepare($baseSql . " WHERE e.id = ?");
		$stmt->bind_param("i", $id);
		$stmt->execute();
		$result = $stmt->get_result();

		if ($result->num_rows === 0) {
			respond(404, false, "Student not found");
		}

		respond(200, true, "Student fetched", $result->fetch_assoc());
	}

	$result = $db->query($baseSql . " ORDER BY e.id DESC");
	$rows = array();

	while ($row = $result->fetch_assoc()) {
		$rows[] = $row;
	}

	respond(200, true, "Students fetched", $rows);
}

if ($method === 'POST') {
	$body = getBody();
	$nom = isset($body['nom']) ? trim($body['nom']) : '';
	$prenom = isset($body['prenom']) ? trim($body['prenom']) : '';
	$email = isset($body['email']) ? trim($body['email']) : '';
	$password = isset($body['password']) ? (string)$body['password'] : '';
	$classeId = isset($body['classe_id']) ? (int)$body['classe_id'] : 0;

	if ($nom === '' || $prenom === '' || $email === '' || $password === '' || $classeId <= 0) {
		respond(400, false, "Fields nom, prenom, email, password and classe_id are required");
	}

	$stmtClass = $db->prepare("SELECT id FROM classes WHERE id = ?");
	$stmtClass->bind_param("i", $classeId);
	$stmtClass->execute();
	if ($stmtClass->get_result()->num_rows === 0) {
		respond(404, false, "Class not found");
	}

	$role = 'etudiant';
	$db->begin_transaction();

	try {
		$stmtUser = $db->prepare("INSERT INTO utilisateurs (nom, prenom, email, password, role) VALUES (?, ?, ?, ?, ?)");
		$stmtUser->bind_param("sssss", $nom, $prenom, $email, $password, $role);

		if (!$stmtUser->execute()) {
			throw new Exception("Failed to create user");
		}

		$utilisateurId = $db->insert_id;

		$stmtEtu = $db->prepare("INSERT INTO etudiants (utilisateur_id, classe_id) VALUES (?, ?)");
		$stmtEtu->bind_param("ii", $utilisateurId, $classeId);

		if (!$stmtEtu->execute()) {
			throw new Exception("Failed to create student");
		}

		$etudiantId = $db->insert_id;
		$db->commit();

		respond(201, true, "Student created", array("etudiant_id" => $etudiantId, "utilisateur_id" => $utilisateurId));
	} catch (Exception $e) {
		$db->rollback();
		if ($db->errno === 1062) {
			respond(409, false, "Email already exists");
		}
		respond(500, false, "Failed to create student");
	}
}

if ($method === 'PUT') {
	$body = getBody();
	$etudiantId = isset($body['id']) ? (int)$body['id'] : 0;
	$nom = isset($body['nom']) ? trim($body['nom']) : '';
	$prenom = isset($body['prenom']) ? trim($body['prenom']) : '';
	$email = isset($body['email']) ? trim($body['email']) : '';
	$classeId = isset($body['classe_id']) ? (int)$body['classe_id'] : 0;
	$password = isset($body['password']) ? (string)$body['password'] : '';

	if ($etudiantId <= 0 || $nom === '' || $prenom === '' || $email === '' || $classeId <= 0) {
		respond(400, false, "Fields id, nom, prenom, email and classe_id are required");
	}

	$stmtClass = $db->prepare("SELECT id FROM classes WHERE id = ?");
	$stmtClass->bind_param("i", $classeId);
	$stmtClass->execute();
	if ($stmtClass->get_result()->num_rows === 0) {
		respond(404, false, "Class not found");
	}

	$stmt = $db->prepare("SELECT utilisateur_id FROM etudiants WHERE id = ?");
	$stmt->bind_param("i", $etudiantId);
	$stmt->execute();
	$result = $stmt->get_result();

	if ($result->num_rows === 0) {
		respond(404, false, "Student not found");
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

		$stmtEtu = $db->prepare("UPDATE etudiants SET classe_id = ? WHERE id = ?");
		$stmtEtu->bind_param("ii", $classeId, $etudiantId);

		if (!$stmtEtu->execute()) {
			throw new Exception("Failed to update student");
		}

		$db->commit();
		respond(200, true, "Student updated");
	} catch (Exception $e) {
		$db->rollback();
		if ($db->errno === 1062) {
			respond(409, false, "Email already exists");
		}
		respond(500, false, "Failed to update student");
	}
}

if ($method === 'DELETE') {
	$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

	if ($id <= 0) {
		respond(400, false, "Field id is required");
	}

	$stmt = $db->prepare("SELECT utilisateur_id FROM etudiants WHERE id = ?");
	$stmt->bind_param("i", $id);
	$stmt->execute();
	$result = $stmt->get_result();

	if ($result->num_rows === 0) {
		respond(404, false, "Student not found");
	}

	$utilisateurId = (int)$result->fetch_assoc()['utilisateur_id'];
	$db->begin_transaction();

	try {
		$stmtDeleteStudent = $db->prepare("DELETE FROM etudiants WHERE id = ?");
		$stmtDeleteStudent->bind_param("i", $id);

		if (!$stmtDeleteStudent->execute()) {
			throw new Exception("Failed to delete student");
		}

		$stmtDeleteUser = $db->prepare("DELETE FROM utilisateurs WHERE id = ?");
		$stmtDeleteUser->bind_param("i", $utilisateurId);

		if (!$stmtDeleteUser->execute()) {
			throw new Exception("Failed to delete linked user");
		}

		$db->commit();
		respond(200, true, "Student deleted");
	} catch (Exception $e) {
		$db->rollback();
		respond(500, false, "Failed to delete student");
	}
}

respond(405, false, "Method not allowed");
?>
