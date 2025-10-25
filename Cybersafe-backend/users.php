<?php
require __DIR__ . '/config.php';
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
  $body = json_body();
  $name = isset($body['name']) ? trim((string)$body['name']) : '';
  if ($name === '') { http_response_code(400); echo json_encode(['error'=>'name required']); exit; }

  try {
    $stmt = $pdo->prepare('SELECT * FROM users WHERE name = ?');
    $stmt->execute([$name]);
    $u = $stmt->fetch();
    if ($u) { echo json_encode($u); exit; }

    $pdo->prepare('INSERT INTO users(name) VALUES (?)')->execute([$name]);
    $id = (int)$pdo->lastInsertId();
    $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
    $stmt->execute([$id]);
    echo json_encode($stmt->fetch());
  } catch (Throwable $e) {
    http_response_code(500); echo json_encode(['error'=>$e->getMessage()]);
  }
  exit;
}

if ($method === 'GET') {
  $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
  if ($id <= 0) { echo json_encode(['error'=>'id required']); exit; }
  $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
  $stmt->execute([$id]);
  $u = $stmt->fetch();
  if (!$u) { http_response_code(404); echo json_encode(['error'=>'not found']); exit; }
  echo json_encode($u); exit;
}

http_response_code(405);
echo json_encode(['error'=>'method not allowed']);
