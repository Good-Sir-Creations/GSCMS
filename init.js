var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var exec = require('child_process').exec;
var fs = require('fs');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use(function(req, res, next) {
    req.conf = require('./config');
    console.log(req.conf);
    next();
});

app.post('/init_db', function(req, res) {
    // validate username and password
    var cmd = [
        "psql -c \"CREATE USER ",
        req.body.username,
        " WITH LOGIN PASSWORD '",
        req.body.password,
        "' CREATEDB\""
    ].join('');
    exec(cmd, function(error, stdout, stderr) {
        req.conf.db.user = req.body.username;
        req.conf.db.pass = req.body.password;
        fs.writeFile('./config.json', JSON.stringify(req.conf), function() {
            pg.connect();
            res.send({success:true});
        });
    });
});

app.post('/', function(req, res) {

});

app.get('/', function(req, res) {
    res.render('./init_view/index');
});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: err
    });
  });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  res.render('error', {
    message: err.message,
    error: {}
  });
});


module.exports = app;
