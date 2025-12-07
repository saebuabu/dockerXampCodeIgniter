<?php
/**
 * SQL Server Connection Test Script
 * Access via: http://localhost:8080/test-db.php
 */

echo "<h1>SQL Server Connection Test</h1>";

// Load environment variables from parent directory
$envFile = dirname(__DIR__) . '/.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;

        list($name, $value) = explode('=', $line, 2);
        $name = trim($name);
        $value = trim($value, " \t\n\r\0\x0B'\"");

        if ($name) {
            $_ENV[$name] = $value;
        }
    }
}

$serverName = $_ENV['database.default.hostname'] ?? 'host.docker.internal';
$database = $_ENV['database.default.database'] ?? 'ExamenDatabase';
$username = $_ENV['database.default.username'] ?? 'docker_user';
$password = $_ENV['database.default.password'] ?? '';

echo "<h2>Connection Info:</h2>";
echo "<table border='1' cellpadding='5'>";
echo "<tr><th>Parameter</th><th>Value</th></tr>";
echo "<tr><td>Server</td><td>$serverName</td></tr>";
echo "<tr><td>Database</td><td>$database</td></tr>";
echo "<tr><td>Username</td><td>$username</td></tr>";
echo "<tr><td>Password</td><td>" . (empty($password) ? '<span style="color:red;">NOT SET</span>' : '<span style="color:green;">SET (' . strlen($password) . ' chars)</span>') . "</td></tr>";
echo "</table>";

echo "<h2>PHP Extensions Check:</h2>";
echo "<table border='1' cellpadding='5'>";
echo "<tr><th>Extension</th><th>Status</th></tr>";
echo "<tr><td>sqlsrv</td><td>" . (extension_loaded('sqlsrv') ? '<span style="color:green;">✓ Loaded</span>' : '<span style="color:red;">✗ Not loaded</span>') . "</td></tr>";
echo "<tr><td>pdo_sqlsrv</td><td>" . (extension_loaded('pdo_sqlsrv') ? '<span style="color:green;">✓ Loaded</span>' : '<span style="color:red;">✗ Not loaded</span>') . "</td></tr>";
echo "</table>";

echo "<h2>Connection Test:</h2>";

// Test with sqlsrv
if (extension_loaded('sqlsrv')) {
    echo "<h3>Testing with sqlsrv driver...</h3>";

    $connectionOptions = [
        "Database" => $database,
        "Uid" => $username,
        "PWD" => $password,
        "TrustServerCertificate" => true,
        "Encrypt" => false
    ];

    $conn = sqlsrv_connect($serverName, $connectionOptions);

    if ($conn) {
        echo "<p style='color:green; font-weight:bold;'>✓ Connection successful with sqlsrv!</p>";

        // Get SQL Server version
        $sql = "SELECT @@VERSION as version";
        $stmt = sqlsrv_query($conn, $sql);
        if ($stmt) {
            $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
            echo "<p><strong>SQL Server Version:</strong><br><pre>" . htmlspecialchars($row['version']) . "</pre></p>";
            sqlsrv_free_stmt($stmt);
        }

        // List available tables
        $sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'";
        $stmt = sqlsrv_query($conn, $sql);
        if ($stmt) {
            echo "<h3>Tables in database:</h3><ul>";
            while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
                echo "<li>" . htmlspecialchars($row['TABLE_NAME']) . "</li>";
            }
            echo "</ul>";
            sqlsrv_free_stmt($stmt);
        }

        sqlsrv_close($conn);
    } else {
        echo "<p style='color:red; font-weight:bold;'>✗ Connection failed!</p>";
        echo "<h3>Error Details:</h3>";
        $errors = sqlsrv_errors();
        if ($errors) {
            echo "<pre>";
            print_r($errors);
            echo "</pre>";
        }

        echo "<h3>Troubleshooting:</h3>";
        echo "<ul>";
        echo "<li>Check if SQL Server is running on your host machine</li>";
        echo "<li>Verify that TCP/IP is enabled in SQL Server Configuration Manager</li>";
        echo "<li>Confirm SQL Server is listening on port 1433</li>";
        echo "<li>Check Windows Firewall settings</li>";
        echo "<li>Verify username and password are correct</li>";
        echo "<li>Ensure the docker_user has access to ExamenDatabase</li>";
        echo "</ul>";
    }
}

// Test with PDO
if (extension_loaded('pdo_sqlsrv')) {
    echo "<h3>Testing with PDO driver...</h3>";

    try {
        $dsn = "sqlsrv:Server=$serverName;Database=$database;TrustServerCertificate=true;Encrypt=false";
        $pdo = new PDO($dsn, $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        echo "<p style='color:green; font-weight:bold;'>✓ Connection successful with PDO!</p>";

        $pdo = null;
    } catch (PDOException $e) {
        echo "<p style='color:red; font-weight:bold;'>✗ PDO Connection failed!</p>";
        echo "<p>Error: " . htmlspecialchars($e->getMessage()) . "</p>";
    }
}

echo "<hr>";
echo "<p><small>Test completed at " . date('Y-m-d H:i:s') . "</small></p>";
?>
