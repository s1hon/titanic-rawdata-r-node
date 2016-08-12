# Titanic-raw-data with R & nodejs

This is an example with nodejs & R. <br> Use R-language to analyze titanic-raw-data, and sending the result to nodejs. <br>  There are two versions in this example: [1] rdata [2] json. <br> You can check two versions on the page.

## Install

If you wanna run this repo. You need to install some packages on R.

- tseries
- arules
- arulesViz
- RCurl
- RJSONIO
- rpart
- rpart.plot

And install npm-dep on nodejs

```
npm install
```

## Run

You need to start Rserve on R first.

```
R
> require("Rserve")
> Rserve()
```

and run nodejs script

```
node app.js
```

then, open the browser

```
http://localhost:8080
```

