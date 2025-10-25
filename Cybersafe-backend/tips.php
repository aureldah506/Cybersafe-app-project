<?php
require __DIR__ . '/config.php';
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
  http_response_code(405); echo json_encode(['error'=>'method not allowed']); exit;
}
$stmt = $pdo->query('SELECT * FROM tips ORDER BY id');
echo json_encode($stmt->fetchAll());
