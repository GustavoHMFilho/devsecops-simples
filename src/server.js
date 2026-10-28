import { createApp } from './app.js';
const server = createApp();
server.listen(3000, '0.0.0.0', () => console.log('API na porta 3000'));
process.on('SIGTERM', () => server.close());
