const { createApp } = require('./app');
const { initSchema } = require('./db');

const port = Number(process.env.PORT) || 3000;

async function start() {
  await initSchema();
  const app = createApp();
  app.listen(port, () => {
    console.log(`TaskFlow API listening on port ${port}`);
  });
}

start().catch((err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
