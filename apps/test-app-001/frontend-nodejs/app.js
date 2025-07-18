const express = require('express');
const app = express();
const port = 3000;

app.set('view engine', 'ejs');
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.render('index', { message: 'Hello from Dockerized Node.js UI App!' });
});

app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`);
});
