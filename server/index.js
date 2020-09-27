const keys = require('./keys');

// Express App setup
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Postgres client setup
const  { Pool } = require('pg');
console.log("keys1", keys); 
const pgClient = new Pool({
  host: keys.pgHost,
  user: keys.pgUser,
  database: keys.pgDatabase,
  password: keys.pgPassword,
  port: keys.pgPort
});
// const pgClient = new Pool({
//   host: 'localhost',
//   user: 'postgres',
//   database: 'course',
//   password: '123456',
//   port: 5432,
//   max: '20'
// });

pgClient.on('error', (err, client) => console.log("Lost PG connect"));
setTimeout(() => {
  pgClient.query('CREATE TABLE IF NOT EXISTS values(number INT)')
  .catch((err) => console.log(">======= error query", err));
}, 3000);

// Redis setup
const redis = require('redis');
const redisClient = redis.createClient({
  host: keys.redisHost,
  port: keys.redisPort,
  retry_strategy: () => 1000
});

const redisPublisher = redisClient.duplicate();

// Express

app.get('/', (req, res) => {
  res.send("Hi");
})

app.get('/values/all', async (req, res) => {
  const values = await pgClient.query('SELECT * FROM values');
  res.send(values.rows);
})

app.get('/values/current', async (req, res) => {
  redisClient.hgetall('values', (err, values) => {
    res.send(values);
  })
})

app.post('/values', async (req, res) => {
  const index = req.body.index;
  if (Number(index) > 40) {
    return res.status(422).send('Index too high');
  }

  redisClient.hset('values', index, 'Nothig yet!');
  redisPublisher.publish('insert', index);
  pgClient.query('INSERT INTO values(number) VALUES ($1)', [index]);

  res.send({
    working: true
  })
})

app.listen(5000, err => {
  console.log('Listening')
})

// const { Client } = require('pg');
// // const client = new Client({
// //   user: 'postgres',
// //   password: 'postgres',
// //   host: 'postgres',
// //   port: 5432,
// //   database: 'hussieindb'
// // })

// client.connect()
// .then(() => console.log("okk"))
// .catch(e => console.log)
// .finally(() => client.end())

// console.log("init")