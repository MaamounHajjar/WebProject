<?php
require __DIR__ . '/db_connect.php';
require __DIR__ . '/helpers.php';

$input = json_input();
$action = $input['action'] ?? '';
$token  = $input['token'] ?? null;

switch($action){

  case 'register': {
    $name = trim($input['name'] ?? '');
    $phone = trim($input['phone'] ?? '');
    $email = strtolower(trim($input['email'] ?? ''));
    $password = $input['password'] ?? '';

    if(!$name || !$phone || !$email || strlen($password) < 6){
      json_out(['ok'=>false,'error'=>'Fill all fields (password min 6).']);
    }

    // Check existing
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email=?");
    $stmt->execute([$email]);
    if($stmt->fetch()){
      json_out(['ok'=>false,'error'=>'Email already registered.']);
    }

    $hash = password_hash($password, PASSWORD_BCRYPT);
    $stmt = $pdo->prepare("INSERT INTO users(name,phone,email,password_hash,role) VALUES(?,?,?,?, 'patient')");
    $stmt->execute([$name,$phone,$email,$hash]);

    $user_id = (int)$pdo->lastInsertId();
    $t = make_token();
    $stmt = $pdo->prepare("INSERT INTO user_tokens(user_id,token,expires_at) VALUES(?,?, DATE_ADD(NOW(), INTERVAL 72 HOUR))");
    $stmt->execute([$user_id,$t]);

    json_out(['ok'=>true,'data'=>['token'=>$t]]);
  }

  case 'login': {
    $email = strtolower(trim($input['email'] ?? ''));
    $password = $input['password'] ?? '';
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email=? LIMIT 1");
    $stmt->execute([$email]);
    $u = $stmt->fetch();
    if(!$u || !password_verify($password, $u['password_hash'])){
      json_out(['ok'=>false,'error'=>'Wrong email or password.']);
    }
    $t = make_token();
    $stmt = $pdo->prepare("INSERT INTO user_tokens(user_id,token,expires_at) VALUES(?,?, DATE_ADD(NOW(), INTERVAL 72 HOUR))");
    $stmt->execute([(int)$u['id'], $t]);
    json_out(['ok'=>true,'data'=>['token'=>$t]]);
  }

  case 'list_doctors': {
    $stmt = $pdo->query("SELECT id, full_name, specialty, experience_years FROM doctors WHERE is_active=1 ORDER BY full_name");
    json_out(['ok'=>true,'data'=>$stmt->fetchAll()]);
  }

  case 'book_appointment': {
    $u = auth_user($pdo, $token);
    if(!$u) json_out(['ok'=>false,'error'=>'Not logged in.']);

    $doctor_id = (int)($input['doctor_id'] ?? 0);
    $date = $input['appointment_date'] ?? '';
    $time = $input['time_slot'] ?? '';

    if(!$doctor_id || !$date || !$time) json_out(['ok'=>false,'error'=>'Missing fields.']);
    /* handling error in past */ 

    $nowDate = date("Y-m-d"); 
    $nowTime = date("H:i");

    if ($date < $nowDate) {
        json_out(['ok' => false, 'error' => 'Invalid Date, make sure the date is not passed.']);
    } elseif ($date == $nowDate && $time <= $nowTime) {
        json_out(['ok' => false, 'error' => 'Invalid time, make sure the timeslot is not passed.']);
    }
    
    try{
      $stmt = $pdo->prepare("INSERT INTO appointments(user_id,doctor_id,appointment_date,time_slot,status) VALUES(?,?,?,?, 'booked')");
      $stmt->execute([(int)$u['id'],$doctor_id,$date,$time]);
      json_out(['ok'=>true,'data'=>['id'=>(int)$pdo->lastInsertId()]]);
    }catch(Throwable $e){
      json_out(['ok'=>false,'error'=>'This slot is already booked. Choose another time.']);
    }
  }

  case 'quick_check': {
    $receipt = trim($input['receipt_id'] ?? '');
    $date = $input['date'] ?? '';
    if(!$receipt || !$date) json_out(['ok'=>false,'error'=>'Missing fields.']);

    $stmt = $pdo->prepare("SELECT receipt_id,test_name,status,sample_date FROM lab_results WHERE receipt_id=? AND sample_date=? LIMIT 1");
    $stmt->execute([$receipt,$date]);
    $row = $stmt->fetch();
    if(!$row) json_out(['ok'=>false,'error'=>'Not found. Check Receipt ID and Date.']);
    json_out(['ok'=>true,'data'=>$row]);
  }

  case 'my_results': {
    $u = auth_user($pdo, $token);
    if(!$u) json_out(['ok'=>false,'error'=>'Not logged in.']);

    $stmt = $pdo->prepare("SELECT receipt_id,test_name,upload_date,file_path FROM lab_results WHERE user_id=? AND status='Ready' ORDER BY upload_date DESC");
    $stmt->execute([(int)$u['id']]);
    $rows = $stmt->fetchAll();

    $data = array_map(function($r) use ($token){
      $download = null;
      if (!empty($r['file_path'])){
        $download = "backend/php/download.php?token=" . urlencode($token) . "&receipt_id=" . urlencode($r['receipt_id']);
      }
      return [
        'receipt_id'=>$r['receipt_id'],
        'test_name'=>$r['test_name'],
        'upload_date'=>$r['upload_date'],
        'download_url'=>$download
      ];
    }, $rows);

    json_out(['ok'=>true,'data'=>$data]);
  }

  case 'callback_request': {
    $fn = trim($input['first_name'] ?? '');
    $ln = trim($input['last_name'] ?? '');
    $phone = trim($input['phone'] ?? '');
    $time = trim($input['preferred_time'] ?? '');
    if(!$fn || !$ln || !$phone || !$time){
      json_out(['ok'=>false,'error'=>'Please fill all fields.']);
    }
    $stmt = $pdo->prepare("INSERT INTO callback_requests(first_name,last_name,phone,preferred_time) VALUES(?,?,?,?)");
    $stmt->execute([$fn,$ln,$phone,$time]);
    json_out(['ok'=>true]);
  }

  case 'vacancies': {
    $stmt = $pdo->query("SELECT id,title,description,requirements FROM vacancies WHERE is_active=1 ORDER BY created_at DESC");
    json_out(['ok'=>true,'data'=>$stmt->fetchAll()]);
  }

  default:
    json_out(['ok'=>false,'error'=>'Unknown action.']);
}
