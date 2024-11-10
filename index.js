const express = require("express");
const bodyparser = require("body-parser");
app = express();
app.use(bodyparser.urlencoded({ extended: false }));
app.listen(3000);
app.get("", function (req, res) {
  res.sendFile(__dirname + "/templets/index.html");
});
