<?php
function json_input(){
  $raw = file_get_contents('php://input');
  return json_decode($raw, true) ?: [];
}

function json_out($arr){
  header('Content-Type: application/json; charset=utf-8');
  echo json_encode($arr, JSON_UNESCAPED_UNICODE);
  exit;
}

function make_token($len=48){
  return bin2hex(random_bytes(intdiv($len,2)));
}

function auth_user(PDO $pdo, ?string $token){
  if(!$token) return null;
  $stmt = $pdo->prepare("SELECT u.* FROM user_tokens t JOIN users u ON u.id=t.user_id
                         WHERE t.token=? AND (t.expires_at IS NULL OR t.expires_at > NOW())");
  $stmt->execute([$token]);
  return $stmt->fetch() ?: null;
}
