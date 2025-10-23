const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.set('view engine', 'ejs');
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.render('index', { message: '🎉 Welcome to ERDC POC Project 🎉' });
});

app.listen(port, () => {
  console.log(`✅ App running on http://localhost:${port}`);
});
