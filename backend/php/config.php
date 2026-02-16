<?php
// Change these for your local MySQL
return [
  'db_host' => getenv('DB_HOST') ?: '127.0.0.1',
  'db_name' => getenv('DB_NAME') ?: 'darmon_service',
  'db_user' => getenv('DB_USER') ?: 'root',
  'db_pass' => getenv('DB_PASS') ?: '',
  'token_ttl_hours' => 72
];
