const express = require('express');
const app = express();
const port = process.env.PORT || 3001;

app.set('view engine', 'ejs');
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.render('index', { message: '🎉 Welcome to ERDC Site , For ERDC Inernal Users - V1 🎉' });
});

app.listen(port, () => {
  console.log(`✅ App running on http://localhost:${port}`);
});
