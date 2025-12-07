<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examen Project - Docker Development</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 900px;
            width: 100%;
            padding: 40px;
        }

        h1 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 2.5em;
        }

        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.1em;
        }

        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }

        .status-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            border-left: 4px solid #667eea;
        }

        .status-card h3 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 1.2em;
        }

        .status-card p {
            color: #666;
            line-height: 1.6;
        }

        .status-indicator {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 8px;
        }

        .status-ok {
            background: #10b981;
        }

        .links {
            margin-top: 30px;
            padding-top: 30px;
            border-top: 2px solid #e5e7eb;
        }

        .links h3 {
            color: #667eea;
            margin-bottom: 15px;
        }

        .link-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }

        .link-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 20px;
            border-radius: 8px;
            text-decoration: none;
            display: block;
            transition: transform 0.2s, box-shadow 0.2s;
            text-align: center;
        }

        .link-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .link-card .title {
            font-weight: bold;
            font-size: 1.1em;
            margin-bottom: 5px;
        }

        .link-card .desc {
            font-size: 0.9em;
            opacity: 0.9;
        }

        .tech-stack {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-top: 30px;
        }

        .tech-stack h3 {
            color: #667eea;
            margin-bottom: 15px;
        }

        .tech-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .tech-badge {
            background: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
            color: #667eea;
            border: 2px solid #667eea;
            font-weight: 500;
        }

        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e5e7eb;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }

        @media (max-width: 768px) {
            h1 {
                font-size: 2em;
            }

            .container {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Examen Project</h1>
        <p class="subtitle">CodeIgniter 4 Development Environment</p>

        <div class="status-grid">
            <div class="status-card">
                <h3><span class="status-indicator status-ok"></span>Docker Container</h3>
                <p>Apache + PHP 8.2 running in containerized environment</p>
            </div>

            <div class="status-card">
                <h3><span class="status-indicator status-ok"></span>CodeIgniter 4</h3>
                <p>Framework v4.6.3 installed and configured</p>
            </div>

            <div class="status-card">
                <h3><span class="status-indicator status-ok"></span>SQL Server</h3>
                <p>Connected to SQL Server 2019 via host.docker.internal</p>
            </div>
        </div>

        <div class="links">
            <h3>Quick Links</h3>
            <div class="link-grid">
                <a href="/databasetest" class="link-card">
                    <div class="title">Database Test</div>
                    <div class="desc">CodeIgniter DB Connection</div>
                </a>

                <a href="/test-db.php" class="link-card">
                    <div class="title">Raw SQL Test</div>
                    <div class="desc">Direct PHP Connection</div>
                </a>

                <a href="https://codeigniter.com/user_guide/" target="_blank" class="link-card">
                    <div class="title">Documentation</div>
                    <div class="desc">CodeIgniter 4 Guide</div>
                </a>

                <a href="<?= base_url('DOCKER_SETUP.md') ?>" class="link-card">
                    <div class="title">Docker Setup</div>
                    <div class="desc">Container Documentation</div>
                </a>
            </div>
        </div>

        <div class="tech-stack">
            <h3>Technology Stack</h3>
            <div class="tech-list">
                <span class="tech-badge">Docker</span>
                <span class="tech-badge">PHP 8.2</span>
                <span class="tech-badge">Apache 2.4</span>
                <span class="tech-badge">CodeIgniter 4.6.3</span>
                <span class="tech-badge">SQL Server 2019</span>
                <span class="tech-badge">Composer</span>
                <span class="tech-badge">Xdebug</span>
                <span class="tech-badge">SQLSRV Driver</span>
            </div>
        </div>

        <div class="footer">
            <p>Development Environment • Port 8080 • <?= date('Y') ?></p>
            <p style="margin-top: 5px; font-size: 0.85em;">
                Server: <?= gethostname() ?> |
                PHP: <?= phpversion() ?> |
                CI: <?= \CodeIgniter\CodeIgniter::CI_VERSION ?>
            </p>
        </div>
    </div>
</body>
</html>
