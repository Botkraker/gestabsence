
<?php
// 1. Set Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(["message" => "Méthode non autorisée. Utilisez POST."]);
    exit();
}
http_response_code(200);
include_once '../config/database.php';
$data = json_decode(file_get_contents("php://input"));
//input here (seanceid:1,listabsence:[1,"present"])
$response = array();
$response["success"]=1;
$response["message"]="Absence Insertion Done";

if ($data) {
    if (!empty($data->seanceid)) {
        $result = $db->query("SELECT * FROM `seances` WHERE id='$data->seanceid' ");
        if ($result->num_rows > 0) {
            if (!empty($data->listabsence) && is_array($data->listabsence)) {
                foreach ($data->listabsence as $student) {
                    $result = $db->query("SELECT * FROM `etudiants` WHERE id='$student[0]' ");
                    if ($result->num_rows > 0) {
                        if ($student[1] === "present" || $student[1] === "absent") {
                            $db->query("INSERT INTO `absences` (`id`, `seance_id`, `etudiant_id`, `statut`) VALUES (NULL, '$data->seanceid', '$student[0]', '$student[1]');");
                        } else {
                            http_response_code(400);
                            $response["success"] = 0;
                            $response["message"] = "Error: $student[1] is not allowed as status";
                            
                        }
                    } else {
                        http_response_code(400);
                        $response["success"] = 0;
                        $response["message"] = "Error: Studentid of $student[0] does not exist";
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