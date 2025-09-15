<?php
header("Content-Type: application/json");
require_once("config/db.php");

$db = new Database();
$conn = $db->getConnection();

$resource = $_GET['resource'] ?? '';
$action   = $_GET['action'] ?? '';

try {
    switch($resource) {
      
        
        case "usuario":
            switch($action) {
                // Registrar usuario
                case "register":
                    $data = json_decode(file_get_contents("php://input"), true);

                    $stmt = $conn->prepare("CALL RegistrarUsuario(:nombre, :telefono, :estatura, :peso, :password, :id_dep, :id_prov, :id_dist)");
                    $stmt->execute([
                        ":nombre" => $data['nombre'],
                        ":telefono" => $data['telefono'],
                        ":estatura" => $data['estatura'],
                        ":peso" => $data['peso'],
                        ":password" => $data['password'],
                        ":id_dep" => $data['id_departamento'],
                        ":id_prov" => $data['id_provincia'],
                        ":id_dist" => $data['id_distrito']
                    ]);

                    echo json_encode(["success" => true, "message" => "Usuario registrado"]);
                    break;

                // Login usuario
                case "login":
                    $data = json_decode(file_get_contents("php://input"), true);

                    $stmt = $conn->prepare("CALL LoginUsuario(:telefono, :password)");
                    $stmt->execute([
                        ":telefono" => $data['telefono'],
                        ":password" => $data['password']
                    ]);
                    $user = $stmt->fetch(PDO::FETCH_ASSOC);

                    if ($user) {
                        echo json_encode(["success" => true, "usuario" => $user]);
                    } else {
                        echo json_encode(["success" => false, "message" => "Credenciales inválidas"]);
                    }
                    break;

                default:
                    echo json_encode(["error" => "Acción no válida en usuario"]);
            }
            break;

        case "equipo":
            switch($action) {
                // Crear equipo
                case "create":
                    $data = json_decode(file_get_contents("php://input"), true);

                    $stmt = $conn->prepare("CALL CrearEquipo(:id_usuario, :nombre, :escudo, :apodo, :cantidad, :calificacion, :id_dep, :id_prov, :id_dist)");
                    $stmt->execute($data);

                    echo json_encode(["success" => true, "message" => "Equipo creado"]);
                    break;

                // Listar equipos de un usuario
                case "list":
                    $id_usuario = $_GET['id_usuario'];
                    $stmt = $conn->prepare("CALL ListarEquiposPorUsuario(:id_usuario)");
                    $stmt->bindParam(":id_usuario", $id_usuario);
                    $stmt->execute();

                    $equipos = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    echo json_encode($equipos);
                    break;

                default:
                    echo json_encode(["error" => "Acción no válida en equipo"]);
            }
            break;


        case "reto":
            switch($action) {
                // Crear reto
                case "create":
                    $data = json_decode(file_get_contents("php://input"), true);

                    $stmt = $conn->prepare("CALL CrearReto(:id_usuario, :nombre, :cantidad, :lugar, :fecha_hora, :id_dep, :id_prov, :id_dist, :numero_contacto)");
                    $stmt->execute($data);

                    echo json_encode(["success" => true, "message" => "Reto creado"]);
                    break;

                // Listar retos por ubicación
                case "list":
                    $stmt = $conn->prepare("CALL ListarRetosPorUbicacion(:id_dep, :id_prov, :id_dist)");
                    $stmt->execute([
                        ":id_dep" => $_GET['id_departamento'],
                        ":id_prov" => $_GET['id_provincia'],
                        ":id_dist" => $_GET['id_distrito']
                    ]);

                    $retos = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    echo json_encode($retos);
                    break;

                default:
                    echo json_encode(["error" => "Acción no válida en reto"]);
            }
            break;

        default:
            echo json_encode(["error" => "Recurso no válido"]);
    }
} catch(Exception $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
