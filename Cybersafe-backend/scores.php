<?php
require __DIR__ . '/config.php';
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
  $b = json_body();
  $userId = isset($b['userId']) ? (int)$b['userId'] : 0;
  $module = isset($b['module']) ? trim((string)$b['module']) : '';
  $level  = isset($b['level']) ? trim((string)$b['level']) : null;
  $score  = isset($b['score']) ? (int)$b['score'] : null;
  $total  = isset($b['total']) ? (int)$b['total'] : null;

  if ($userId <= 0 || $module === '' || !is_int($score) || !is_int($total)) {
    http_response_code(400); echo json_encode(['error'=>'userId, module, score, total required']); exit;
  }
  try {
    $pdo->prepare('INSERT INTO scores(user_id,module,level,score,total) VALUES (?,?,?,?,?)')
        ->execute([$userId,$module,$level,$score,$total]);
    $id = (int)$pdo->lastInsertId();
    $stmt = $pdo->prepare('SELECT * FROM scores WHERE id = ?');
    $stmt->execute([$id]);
    echo json_encode($stmt->fetch());
  } catch (Throwable $e) {
    http_response_code(500); echo json_encode(['error'=>$e->getMessage()]);
  }
  exit;
}

if ($method === 'GET') {
  $userId = isset($_GET['userId']) ? (int)$_GET['userId'] : 0;
  $summary = isset($_GET['summary']) ? (int)$_GET['summary'] : 0;

  if ($summary === 1) {
    if ($userId <= 0) { http_response_code(400); echo json_encode(['error'=>'userId required']); exit; }
    $rows = $pdo->prepare('SELECT score,total FROM scores WHERE user_id = ?');
    $rows->execute([$userId]);
    $rows = $rows->fetchAll();
    $total = 0; $sum = 0;
    foreach ($rows as $r) { $total += (int)$r['total']; $sum += (int)$r['score']; }
    $percent = $total ? round(($sum/$total)*100) : 0;
    echo json_encode(['attempts'=>count($rows),'total'=>$total,'sum'=>$sum,'percent'=>$percent]); exit;
  }

  if ($userId > 0) {
    $stmt = $pdo->prepare('SELECT * FROM scores WHERE user_id = ? ORDER BY created_at DESC, id DESC LIMIT 100');
    $stmt->execute([$userId]);
    echo json_encode($stmt->fetchAll()); exit;
  } else {
    $stmt = $pdo->query('SELECT * FROM scores ORDER BY created_at DESC, id DESC LIMIT 100');
    echo json_encode($stmt->fetchAll()); exit;
  }
}

http_response_code(405);
echo json_encode(['error'=>'method not allowed']);
