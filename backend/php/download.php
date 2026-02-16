<?php
require __DIR__ . '/db_connect.php';
require __DIR__ . '/helpers.php';

$token = $_GET['token'] ?? '';
$receipt = $_GET['receipt_id'] ?? '';

$u = auth_user($pdo, $token);
if(!$u){ http_response_code(403); echo "Forbidden"; exit; }

$stmt = $pdo->prepare("SELECT file_path, test_name FROM lab_results WHERE user_id=? AND receipt_id=? AND status='Ready' LIMIT 1");
$stmt->execute([(int)$u['id'], $receipt]);
$row = $stmt->fetch();
if(!$row || !$row['file_path']){ http_response_code(404); echo "Not found"; exit; }

$path = dirname(__DIR__,2) . '/' . $row['file_path']; // project-root relative
if(!file_exists($path)){ http_response_code(404); echo "File missing"; exit; }

header('Content-Type: application/pdf');
header('Content-Disposition: attachment; filename="result_'.$receipt.'.pdf"');
readfile($path);
