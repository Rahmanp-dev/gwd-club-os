require('dotenv').config();

const bcrypt = require('bcryptjs');
const cors = require('cors');
const express = require('express');
const http = require('http');
const jwt = require('jsonwebtoken');
const os = require('os');
const path = require('path');
const { MongoClient } = require('mongodb');
const { Server } = require('socket.io');

const workspaceId = process.env.WORKSPACE_ID || 'gwd-club-global';
const validRoles = new Set([
  'president', 'vicePresident', 'generalSecretary',
  'marketingLead', 'prLead', 'eventManagementLead',
  'productionLead', 'cinematographerLead', 'clubMember',
  'ceo', 'cooCmo', 'cpoFieldGrowth'
]);
const validWorkstreams = new Set([
  'sales', 'productTech', 'strategy', 'operations', 'marketing', 'production', 'fieldGrowth',
  'executive', 'publicRelations', 'eventManagement', 'cinematography'
]);
const validSources = new Set(['selfCommitment', 'founderRequest', 'aiGenerated', 'leadDelegated']);
const validStatuses = new Set(['requested', 'committed', 'inProgress', 'submitted', 'verified', 'blocked']);
const required = ['MONGODB_URI', 'JWT_SECRET', 'FOUNDER_INVITE_CODE'];

for (const key of required) {
  if (!process.env[key]) throw new Error(`Missing ${key}. Copy server/.env.example to server/.env and set the server-side value.`);
}

const port = Number(process.env.PORT || 3000);
const clientOrigin = process.env.CLIENT_ORIGIN || '*';
const mongoClient = new MongoClient(process.env.MONGODB_URI);
const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: clientOrigin, methods: ['GET', 'POST', 'PATCH'] } });

const founders = [
  { id: 'ceo', role: 'ceo', label: 'CEO', responsibility: 'Strategy, sales, technical direction, groundwork, communication and production.' },
  { id: 'coo-cmo', role: 'cooCmo', label: 'COO & CMO', responsibility: 'Operating rhythm, marketing execution, delivery coordination and internal systems.' },
  { id: 'cpo-field-growth', role: 'cpoFieldGrowth', label: 'CPO & Field Growth', responsibility: 'Product direction, academy demos, product mastery and on-ground sales.' },
];

app.use(cors({ origin: clientOrigin }));
app.use(express.json({ limit: '1mb' }));
const webDistPath = path.join(__dirname, '../../build/web');
app.use(express.static(webDistPath));

function workspaceRoom(id) {
  return `workspace:${id}`;
}

function fail(message, status = 400) {
  const error = new Error(message);
  error.status = status;
  throw error;
}

function requireText(value, name) {
  if (typeof value !== 'string' || value.trim().length === 0) fail(`${name} is required.`);
  return value.trim();
}

function database() {
  return mongoClient.db(process.env.MONGODB_DB || 'mehnat_founder_os');
}

function userDto(document) {
  return { email: document.email, role: document.role, workspaceId: document.workspaceId };
}

function taskDto(document) {
  const { _id, workspaceId: ignored, ...task } = document;
  return { id: _id, ...task };
}

function checkInDto(document) {
  const { _id, workspaceId: ignored, ...checkIn } = document;
  return checkIn;
}

function createToken(user) {
  return jwt.sign(
    { sub: user._id, email: user.email, role: user.role, workspaceId: user.workspaceId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '12h' },
  );
}

function sessionDto(user) {
  return { token: createToken(user), user: userDto(user) };
}

function readToken(token) {
  try {
    const session = jwt.verify(token, process.env.JWT_SECRET);
    if (!session.workspaceId || !validRoles.has(session.role)) fail('Invalid session.', 401);
    return session;
  } catch (error) {
    if (error.status) throw error;
    fail('Your session is invalid or has expired. Please sign in again.', 401);
  }
}

function authenticate(request, response, next) {
  try {
    const header = request.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) fail('Sign in is required.', 401);
    request.auth = readToken(header.slice('Bearer '.length));
    next();
  } catch (error) {
    next(error);
  }
}

function sameWorkspace(request, response, next) {
  if (request.auth.workspaceId !== request.params.workspaceId) {
    return next(Object.assign(new Error('You do not have access to this workspace.'), { status: 403 }));
  }
  return next();
}

function normaliseTask(input) {
  const points = Number(input.points);
  if (!Number.isInteger(points) || points < 1 || points > 13) fail('Points must be an integer from 1 to 13.');
  if (!validRoles.has(input.owner) || !validWorkstreams.has(input.workstream) || !validSources.has(input.source) || !validStatuses.has(input.status)) {
    fail('Task includes an invalid role, workstream, source, or status.');
  }
  return {
    id: requireText(input.id, 'Task id'),
    title: requireText(input.title, 'Title'),
    owner: input.owner,
    workstream: input.workstream,
    points,
    dueLabel: requireText(input.dueLabel, 'Due date'),
    definitionOfDone: requireText(input.definitionOfDone, 'Definition of done'),
    source: input.source,
    status: input.status,
    proof: typeof input.proof === 'string' ? input.proof.trim() : null,
    blocker: typeof input.blocker === 'string' ? input.blocker.trim() : null,
    updatedAt: new Date(),
  };
}

function taskCanChange(current, next, session) {
  if (current.owner !== next.owner || current.source !== next.source) fail('Task owner and source cannot be changed after creation.', 409);
  if (next.status === 'submitted' && !next.proof) fail('Submit proof before requesting verification.');
  if (next.status === 'blocked' && !next.blocker) fail('Describe the blocker before changing this task to blocked.');
  if (session.role === current.owner) {
    const allowed = {
      requested: new Set(['committed']),
      committed: new Set(['inProgress', 'blocked']),
      inProgress: new Set(['submitted', 'blocked']),
      blocked: new Set(['inProgress']),
      submitted: new Set(),
      verified: new Set(),
    };
    if (!allowed[current.status].has(next.status)) fail('This task state can only be changed by the owner through the next valid action.', 403);
    return;
  }
  if (current.status === 'submitted' && next.status === 'verified') return;
  fail('Only the task owner can progress work. A different founder may verify submitted proof.', 403);
}

async function ensureIndexes() {
  const db = database();
  await Promise.all([
    db.collection('tasks').createIndex({ workspaceId: 1, updatedAt: -1 }),
    db.collection('tasks').createIndex({ workspaceId: 1, _id: 1 }, { unique: true }),
    db.collection('checkins').createIndex({ workspaceId: 1, founder: 1, date: 1 }, { unique: true }),
    db.collection('founders').createIndex({ workspaceId: 1, _id: 1 }, { unique: true }),
    db.collection('users').createIndex({ email: 1 }, { unique: true }),
    db.collection('users').createIndex({ workspaceId: 1, role: 1 }, { unique: true }),
  ]);
}

async function seedFounders(id) {
  const db = database();
  await Promise.all(founders.map((founder) => db.collection('founders').updateOne(
    { workspaceId: id, _id: founder.id },
    { $setOnInsert: { ...founder, workspaceId: id, _id: founder.id, createdAt: new Date() } },
    { upsert: true },
  )));
}

app.get('/health', async (request, response, next) => {
  try {
    await database().command({ ping: 1 });
    response.json({ ok: true, storage: 'mongodb', live: 'socket.io', authentication: 'jwt' });
  } catch (error) {
    next(error);
  }
});

app.post('/api/auth/register', async (request, response, next) => {
  try {
    const email = requireText(request.body.email, 'Email').toLowerCase();
    const password = requireText(request.body.password, 'Password');
    const role = requireText(request.body.role, 'Role');
    const inviteCode = requireText(request.body.inviteCode, 'Founder invite code');
    if (!validRoles.has(role)) fail('Choose a valid founder role.');
    if (password.length < 12) fail('Use a password with at least 12 characters.');
    if (inviteCode !== process.env.FOUNDER_INVITE_CODE) fail('Founder invite code is invalid.', 403);
    const db = database();
    if (await db.collection('users').findOne({ workspaceId, role })) fail('That founder role already has an account. Ask the CEO to reset access if needed.', 409);
    if (await db.collection('users').findOne({ email })) fail('An account with this email already exists.', 409);
    const user = {
      _id: `user:${email}`,
      email,
      role,
      workspaceId,
      passwordHash: await bcrypt.hash(password, 12),
      createdAt: new Date(),
      lastLoginAt: new Date(),
    };
    await db.collection('users').insertOne(user);
    response.status(201).json(sessionDto(user));
  } catch (error) {
    next(error);
  }
});

app.post('/api/auth/login', async (request, response, next) => {
  try {
    const email = requireText(request.body.email, 'Email').toLowerCase();
    const password = requireText(request.body.password, 'Password');
    const db = database();
    const user = await db.collection('users').findOne({ email });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) fail('Email or password is incorrect.', 401);
    await db.collection('users').updateOne({ _id: user._id }, { $set: { lastLoginAt: new Date() } });
    response.json(sessionDto(user));
  } catch (error) {
    next(error);
  }
});

app.get('/api/auth/me', authenticate, async (request, response, next) => {
  try {
    const user = await database().collection('users').findOne({ _id: request.auth.sub, workspaceId: request.auth.workspaceId });
    if (!user) fail('Your account is no longer available.', 401);
    response.json({ user: userDto(user) });
  } catch (error) {
    next(error);
  }
});

app.get('/api/workspaces/:workspaceId/bootstrap', authenticate, sameWorkspace, async (request, response, next) => {
  try {
    const id = request.params.workspaceId;
    await seedFounders(id);
    const db = database();
    const [workspaceFounders, tasks, checkIns] = await Promise.all([
      db.collection('founders').find({ workspaceId: id }).sort({ label: 1 }).toArray(),
      db.collection('tasks').find({ workspaceId: id }).sort({ updatedAt: -1 }).toArray(),
      db.collection('checkins').find({ workspaceId: id }).sort({ date: -1 }).toArray(),
    ]);
    response.json({ workspaceId: id, founders: workspaceFounders.map(({ _id, workspaceId: ignored, ...founder }) => ({ id: _id, ...founder })), tasks: tasks.map(taskDto), checkIns: checkIns.map(checkInDto) });
  } catch (error) {
    next(error);
  }
});

app.post('/api/workspaces/:workspaceId/tasks', authenticate, sameWorkspace, async (request, response, next) => {
  try {
    const task = normaliseTask(request.body);
    if (task.source === 'selfCommitment' && task.owner !== request.auth.role) fail('A self-commitment must be owned by the signed-in founder.', 403);
    task.status = task.source === 'founderRequest' ? 'requested' : 'committed';
    const document = { _id: task.id, workspaceId: request.params.workspaceId, ...task, creator: request.auth.role, createdAt: new Date() };
    await database().collection('tasks').insertOne(document);
    const dto = taskDto(document);
    io.to(workspaceRoom(request.params.workspaceId)).emit('task:created', dto);
    response.status(201).json(dto);
  } catch (error) {
    next(error);
  }
});

app.patch('/api/workspaces/:workspaceId/tasks/:taskId', authenticate, sameWorkspace, async (request, response, next) => {
  try {
    const db = database();
    const filter = { workspaceId: request.params.workspaceId, _id: request.params.taskId };
    const current = await db.collection('tasks').findOne(filter);
    if (!current) return response.status(404).json({ error: 'Task not found.' });
    const task = normaliseTask({ ...request.body, id: request.params.taskId });
    taskCanChange(current, task, request.auth);
    const document = await db.collection('tasks').findOneAndUpdate(filter, { $set: task }, { returnDocument: 'after' });
    const dto = taskDto(document);
    io.to(workspaceRoom(request.params.workspaceId)).emit('task:updated', dto);
    return response.json(dto);
  } catch (error) {
    return next(error);
  }
});

app.get('/api/workspaces/:workspaceId/events', authenticate, sameWorkspace, async (request, response, next) => {
  try {
    const events = await database().collection('events').find({ workspaceId: request.params.workspaceId }).sort({ targetDate: 1 }).toArray();
    response.json({ events: events.map(({ _id, workspaceId: ignored, ...ev }) => ({ id: _id, ...ev })) });
  } catch (error) {
    next(error);
  }
});

app.post('/api/workspaces/:workspaceId/events', authenticate, sameWorkspace, async (request, response, next) => {
  try {
    const event = {
      _id: requireText(request.body.id, 'Event ID'),
      workspaceId: request.params.workspaceId,
      title: requireText(request.body.title, 'Event title'),
      themeTagline: request.body.themeTagline || '',
      category: request.body.category || 'flagship',
      targetDate: new Date(request.body.targetDate),
      venue: request.body.venue || 'Campus Auditorium',
      expectedFootfall: Number(request.body.expectedFootfall || 250),
      status: request.body.status || 'planning',
      budgetLabel: request.body.budgetLabel || '',
      isFlagship: Boolean(request.body.isFlagship),
      runOfShow: Array.isArray(request.body.runOfShow) ? request.body.runOfShow : [],
      createdAt: new Date(),
    };
    await database().collection('events').insertOne(event);
    const dto = { id: event._id, ...event };
    io.to(workspaceRoom(request.params.workspaceId)).emit('event:created', dto);
    response.status(201).json(dto);
  } catch (error) {
    next(error);
  }
});

app.post('/api/workspaces/:workspaceId/checkins', authenticate, sameWorkspace, async (request, response, next) => {
  try {
    const founder = requireText(request.body.founder, 'Founder');
    const date = requireText(request.body.date, 'Date');
    if (founder !== request.auth.role) fail('You may only post your own check-in.', 403);
    const checkIn = {
      founder,
      date,
      completed: typeof request.body.completed === 'string' ? request.body.completed.trim() : '',
      focus: requireText(request.body.focus, 'Focus'),
      blocker: typeof request.body.blocker === 'string' ? request.body.blocker.trim() : '',
      updatedAt: new Date(),
    };
    await database().collection('checkins').updateOne(
      { workspaceId: request.params.workspaceId, founder, date },
      { $set: checkIn, $setOnInsert: { _id: `${request.params.workspaceId}:${founder}:${date}`, workspaceId: request.params.workspaceId, createdAt: new Date() } },
      { upsert: true },
    );
    io.to(workspaceRoom(request.params.workspaceId)).emit('checkin:posted', checkIn);
    response.status(201).json(checkIn);
  } catch (error) {
    next(error);
  }
});

io.use((socket, next) => {
  try {
    socket.auth = readToken(socket.handshake.auth?.token);
    next();
  } catch (error) {
    next(new Error('Authentication required.'));
  }
});

io.on('connection', (socket) => {
  socket.on('workspace:join', (id) => {
    if (id === socket.auth.workspaceId) socket.join(workspaceRoom(id));
  });
});

app.get('*', (request, response, next) => {
  if (request.path.startsWith('/api') || request.path.startsWith('/health')) return next();
  const indexPath = path.join(webDistPath, 'index.html');
  response.sendFile(indexPath, (err) => {
    if (err) next();
  });
});

app.use((error, request, response, next) => {
  const status = error.status || 500;
  if (status >= 500) console.error(error);
  response.status(status).json({ error: status >= 500 ? 'Server error.' : error.message });
});

function getLanIp() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

async function start() {
  try {
    await mongoClient.connect();
    await ensureIndexes();
    console.log('✅ MongoDB connected successfully.');
  } catch (err) {
    console.log('⚠️ MongoDB connection deferred (running in local prototype mode):', err.message);
  }
  server.listen(port, '0.0.0.0', () => {
    const lanIp = getLanIp();
    console.log('=================================================================');
    console.log('🚀 GWD CLUB OS — Real-Time Server & Web App Ready!');
    console.log(`📡 Local Access (PC):     http://localhost:${port}`);
    console.log(`📱 Mobile / LAN Access:   http://${lanIp}:${port}`);
    console.log(`⚡ WebSocket URL:         ws://${lanIp}:${port}`);
    console.log('=================================================================');
  });
}

async function shutdown() {
  await mongoClient.close();
  process.exit(0);
}

start().catch((error) => {
  console.error('Unable to start Mehnat API.', error);
  process.exit(1);
});
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
