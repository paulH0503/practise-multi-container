const keys = require('./keys');
const redis = require('redis');

console.log("Worker init", keys);
const redisClient = redis.createClient({
  host: keys.redisHost,
  port: keys.redisPort,
  retry_strategy: () => 1000
});

const sub = redisClient.duplicate();

function fib(index) {
  if (index < 2) return 1;
  return fib(index - 2) + fib(index - 1);
}

sub.on('message', (channel, msg) => {
  console.log("channel", msg);
  redisClient.hset('values', msg, fib(Number(msg)));
});

sub.subscribe('insert')