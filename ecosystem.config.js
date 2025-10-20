// PM2 Ecosystem Configuration
// For running the petition server on Digital Ocean Droplet

module.exports = {
  apps: [
    {
      name: 'streetjustice-petition',
      script: 'server.js',

      // Instance configuration
      instances: 1,
      exec_mode: 'cluster',

      // Restart settings
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',

      // Environment
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },

      // Logging
      error_file: 'logs/error.log',
      out_file: 'logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,

      // Advanced features
      min_uptime: '10s',
      max_restarts: 10,
      restart_delay: 4000,

      // Process management
      kill_timeout: 5000,
      listen_timeout: 3000,
      shutdown_with_message: true
    }
  ],

  // Deployment configuration (optional - for PM2 deploy)
  deploy: {
    production: {
      // SSH connection
      user: 'root',
      host: 'YOUR_DROPLET_IP',
      ref: 'origin/main',
      repo: 'YOUR_REPO_URL',
      path: '/var/www/streetjustice',

      // Deployment commands
      'pre-deploy': 'git fetch --all',
      'post-deploy': 'npm install && pm2 reload ecosystem.config.js --env production',
      'pre-setup': 'mkdir -p logs'
    }
  }
};
