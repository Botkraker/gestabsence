
<?php
// 1. Set Headers
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
        "message" => $message,
    );

    if ($data !== null) {
        $response["data"] = $data;
    }

    echo json_encode($response);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (!isset($_GET['seanceid']) && !isset($_GET['id'])) {
        respond(400, false, "Error: seanceid is not provided");
    }

    $seanceId = isset($_GET['seanceid']) ? (int)$_GET['seanceid'] : (int)$_GET['id'];
    $sql = "SELECT etudiant_id, statut FROM absences WHERE seance_id = ? ORDER BY id ASC";
    $stmt = $db->prepare($sql);
    $stmt->bind_param("i", $seanceId);
    $stmt->execute();
    $result = $stmt->get_result();

    $rows = array();
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
    }

    respond(200, true, "Fetch Done", $rows);
}

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    respond(405, false, "Méthode non autorisée. Utilisez POST.");
}

$data = json_decode(file_get_contents("php://input"));
//input here (seanceid:1,listabsence:[1,"present"])
$response = array();
$response["success"] = 1;
$response["message"] = "Absence Insertion Done";

if ($data) {
    if (!empty($data->seanceid)) {
        $seanceId = (int)$data->seanceid;
        $result = $db->query("SELECT * FROM `seances` WHERE id='$seanceId' ");
        if ($result->num_rows > 0) {
            if (!empty($data->listabsence) && is_array($data->listabsence)) {
                $db->query("DELETE FROM `absences` WHERE `seance_id` = '$seanceId'");
                foreach ($data->listabsence as $student) {
                    $studentId = (int)$student[0];
                    $status = $student[1];

                    $result = $db->query("SELECT * FROM `etudiants` WHERE id='$studentId' ");
                    if ($result->num_rows > 0) {
                        if ($status === "present" || $status === "absent") {
                            $db->query("INSERT INTO `absences` (`id`, `seance_id`, `etudiant_id`, `statut`) VALUES (NULL, '$seanceId', '$studentId', '$status');");
                        } else {
                            http_response_code(400);
                            $response["success"] = 0;
                            $response["message"] = "Error: $status is not allowed as status";
                            
                        }
                    } else {
                        http_response_code(400);
                        $response["success"] = 0;
                        $response["message"] = "Error: Studentid of $studentId does not exist";
                    }
                }
            } else {
                http_response_code(400);
                $response["success"] = 0;
                $response["message"] = "Error: List Absence is not Provided";
            }
        } else {
            http_response_code(400);
            $response["success"] = 0;
            $response["message"] = "Error: seanceid does not exit";
        }
    } else {
        $response["success"] = 0;
        http_response_code(400);
        $response["message"] = "Error: seanceid is not specified";
    }
} else {
    $response["success"] = 0;
    $response["message"] = "Error: can't Read Body";
    http_response_code(400);
}
echo json_encode($response);
?>