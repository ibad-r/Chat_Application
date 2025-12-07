const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');
const admin = require('firebase-admin');

// ✅ Load Firebase service account from environment variable
if (!process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
  console.error("❌ FIREBASE_SERVICE_ACCOUNT_JSON not set!");
  process.exit(1);
}

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const firestore = admin.firestore();

const app = express();
app.use(cors());
app.use(express.json());
const server = http.createServer(app);

const io = new Server(server, {
  cors: { origin: "*", methods: ["GET", "POST"] }
});

// Health check
app.get('/', (req, res) => res.send('Chat server is up'));

// ✅ Auth middleware
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;
    if (!token) throw new Error('no_token');

    const decoded = await admin.auth().verifyIdToken(token);
    socket.uid = decoded.uid;
    socket.phone = decoded.phone_number || null;

    // Ensure user exists in Firestore
    const userRef = firestore.collection('users').doc(socket.uid);
    if (!(await userRef.get()).exists) {
      await userRef.set({
        phone: socket.phone,
        registered: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    next();
  } catch (err) {
    console.log('Socket auth failed:', err.message);
    next(new Error('unauthorized'));
  }
});

io.on('connection', (socket) => {
  console.log('Client connected:', socket.uid);

  socket.emit('auth_ok', { uid: socket.uid });

  // Join room
  socket.on('join', (room) => {
    socket.join(room);
    socket.emit('joined', { room });
  });

  // Send message
  socket.on('send_message', async (msg) => {
    const { room, text, sender, sentAt } = msg;
    if (!room || !text || !sender) return;

    const messageData = {
      senderUid: sender,
      text,
      sentAt: sentAt || new Date().toISOString()
    };

    // Save to Firestore
    const chatRef = firestore.collection('chats').doc(room);
    const msgRef = await chatRef.collection('messages').add(messageData);

    // Update chat metadata
    await chatRef.set({
      members: room.split('_'),
      lastMessage: text,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    // Broadcast
    io.to(room).emit('receive_message', {
      ...messageData,
      messageId: msgRef.id,
      chatId: room
    });
  });

  socket.on('disconnect', (reason) => {
    console.log('Client disconnected:', socket.uid, 'reason:', reason);
  });
});

const PORT = 3000;
server.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
