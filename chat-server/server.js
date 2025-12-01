// server.js - Socket.IO server with rooms
const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);

// Socket.IO server
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Health check endpoint
app.get('/', (req, res) => {
  res.send('Chat server is up');
});

io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  // Join a specific chat room
  socket.on('join', (room) => {
    socket.join(room);
    console.log(`Socket ${socket.id} joined room ${room}`);
  });

  // Leave a chat room
  socket.on('leave', (room) => {
    socket.leave(room);
    console.log(`Socket ${socket.id} left room ${room}`);
  });

  // Send message to a room
  socket.on('send_message', (data) => {
    console.log('send_message:', data);
    // Emit message to all clients in the same room
    io.to(data.room).emit('receive_message', {
      text: data.text,
      sender: data.sender || "Anon",
      sentAt: data.sentAt,
      serverTimestamp: new Date().toISOString()
    });
  });

  socket.on('disconnect', (reason) => {
    console.log('Client disconnected:', socket.id, 'reason:', reason);
  });
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Socket server listening on http://localhost:${PORT}`));
