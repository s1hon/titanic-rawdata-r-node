const path = require('path')
const rio = require('rio')
const Converter = require("csvtojson").Converter
const converter = new Converter({})

converter.fromFile("./titanic.csv", (err,jsonResult) => {

  rio.$e({
      filename: path.join(__dirname, "titanic.R"),
      entrypoint: "testjson",
      data: jsonResult,
  }).then( (data) => {
    console.log(data)
  })

})