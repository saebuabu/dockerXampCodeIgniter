<?php

namespace App\Controllers;

use CodeIgniter\Controller;

class DatabaseTest extends Controller
{
    public function index()
    {
        $output = '<h1>CodeIgniter Database Connection Test</h1>';

        try {
            $db = \Config\Database::connect();

            // Test 1: Check connection
            $output .= '<h2>✓ Database connection established!</h2>';

            // Test 2: Get SQL Server version
            $query = $db->query("SELECT @@VERSION as version");
            $result = $query->getRow();

            $output .= '<h3>SQL Server Version:</h3>';
            $output .= '<pre>' . htmlspecialchars($result->version) . '</pre>';

            // Test 3: Get database name
            $query = $db->query("SELECT DB_NAME() as dbname");
            $result = $query->getRow();

            $output .= '<h3>Current Database:</h3>';
            $output .= '<p><strong>' . htmlspecialchars($result->dbname) . '</strong></p>';

            // Test 4: List tables
            $query = $db->query("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME");
            $tables = $query->getResult();

            $output .= '<h3>Tables in database:</h3>';
            if (count($tables) > 0) {
                $output .= '<ul>';
                foreach ($tables as $table) {
                    $output .= '<li>' . htmlspecialchars($table->TABLE_NAME) . '</li>';
                }
                $output .= '</ul>';
            } else {
                $output .= '<p><em>No tables found. This is normal for a new database.</em></p>';
            }

            // Test 5: Show connection info
            $output .= '<h3>Connection Configuration:</h3>';
            $output .= '<table border="1" cellpadding="5">';
            $output .= '<tr><th>Setting</th><th>Value</th></tr>';
            $output .= '<tr><td>Driver</td><td>' . $db->DBDriver . '</td></tr>';
            $output .= '<tr><td>Hostname</td><td>' . $db->hostname . '</td></tr>';
            $output .= '<tr><td>Database</td><td>' . $db->database . '</td></tr>';
            $output .= '<tr><td>Username</td><td>' . $db->username . '</td></tr>';
            $output .= '<tr><td>Port</td><td>' . $db->port . '</td></tr>';
            $output .= '</table>';

        } catch (\Exception $e) {
            $output .= '<h2 style="color: red;">✗ Database connection failed!</h2>';
            $output .= '<p><strong>Error:</strong> ' . htmlspecialchars($e->getMessage()) . '</p>';
            $output .= '<pre>' . htmlspecialchars($e->getTraceAsString()) . '</pre>';
        }

        return $output;
    }
}
