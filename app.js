const path = require('path')
const rio = require('rio')
const Converter = require("csvtojson").Converter

const express = require('express')
const app = express()

const args = {
    rawdata: path.join(__dirname, "titanic.raw.rdata")
}

app.set('view engine', 'ejs')

app.get('/', function (req, res) {

  rio.$e({
      filename: path.join(__dirname, "titanic.R"),
      entrypoint: "maintitanic",
      data: args,
  }).then( (data)=>{
    data = JSON.parse(data)
    res.render('index', { title:"rdata", ruleviz: data.ruleviz, cart: data.cart, rule: data.rule })
  }).catch( (err) => {
    if(err.code=="ECONNREFUSED"){
      res.send('ERR: Please start Rserve() in R.')
    }else{
      res.send(err)
    }
  })

})


app.get('/json', function (req, res) {

  let converter = new Converter({})
  converter.fromFile("./titanic.csv", (err,jsonResult) => {
    rio.$e({
        filename: path.join(__dirname, "titanic.R"),
        entrypoint: "testjson",
        data: jsonResult,
    }).then( (data)=>{
      data = JSON.parse(data)
      res.render('index', { title:"json", ruleviz: data.ruleviz, cart: data.cart, rule: data.rule })
    }).catch( (err) => {
      if(err.code=="ECONNREFUSED"){
        res.send('ERR: Please start Rserve() in R.')
      }else{
        res.send(err)
      }
    })
  })

})


app.listen(8080, function () {
  console.log('Example app listening on port 8080!')
})