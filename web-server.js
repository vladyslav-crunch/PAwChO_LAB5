const express = require("express");
const os = require("os");
const { networkInterfaces } = require("os");
const dotenv = require("dotenv");
dotenv.config();
const app = express();
const PORT = process.env.PORT || 3000;

const getIP = () => {
  const nets = networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === "IPv4" && !net.internal) {
        return net.address;
      }
    }
  }
  return "Undefine";
};

app.get("/", (req, res) => {
  res.json({
    server_ip: getIP(),
    hostname: os.hostname(),
    version: process.env.VERSION,
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running at http://localhost:${PORT}`);
});
