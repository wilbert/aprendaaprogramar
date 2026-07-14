module.exports = {
  apps: [{
    name: "aprendaaprogramar",
    script: "npm",
    args: "run start",
    cwd: "/var/www/aprendaaprogramar",
    instances: "max", // Utilizes all available CPU cores on your Contabo VPS
    exec_mode: "cluster", // Enables zero-downtime reloads
    env: {
      NODE_ENV: "production",
      PORT: 4050
    }
  }]
};
