import { createServer } from 'node:http';
import spawn from 'cross-spawn';

export function createApp() {
  return createServer((req, res) => {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    if (req.method !== 'GET') {
      res.writeHead(405, { Allow: 'GET' });
      return res.end(JSON.stringify({ error: 'Método não permitido' }));
    }
    switch (req.url) {
      case '/':
        return res.end(JSON.stringify({ message: 'Pipeline DevSecOps' }));
      case '/health':
        return res.end(JSON.stringify({ status: 'ok' }));
      case '/runtime': {
        // Executável e argumentos fixos; nenhuma entrada HTTP vira comando.
        const result = spawn.sync(process.execPath, ['--version'], { timeout: 2000 });
        if (result.status !== 0) {
          res.writeHead(503);
          return res.end(JSON.stringify({ error: 'Runtime indisponível' }));
        }
        return res.end(JSON.stringify({ node: result.stdout.toString().trim() }));
      }
      default:
        res.writeHead(404);
        return res.end(JSON.stringify({ error: 'Rota não encontrada' }));
    }
  });
}
