_           = require 'lodash'
{ parse, transform, stringify } = require 'csv'

parser = parse()

stringifier = stringify
  quoted: true

recipes = 
  
  'Description': 
    (record) ->
      _.chain record.slice(10, 16)
      .filter _.negate(_.isEmpty)
      .join ''
      .value()

  'Transaction Type':   (record) -> record[8]

  'Reference':          (record) -> record[16]

  'Payee':              (record) -> record[6]

  'Account Code':       (record) -> record[5]

  'Transaction Date':   (record) -> record[7]

  'Amount':
    (record) -> 
      if record[3] is 'C'
        record[4]
      else 
        '-' + record[4]

target = _.map [
  'Transaction Date'
  'Amount'
  'Payee'
  'Description'
  'Reference'
  'Transaction Type'
  'Amount Code'
], (name) -> recipes[name]


rabo = 
  transform: (input, output) ->
    transformer = transform (record, callback) ->
      callback null, _.map target, (extract) -> if extract? then extract(record)
    input
    .pipe parser
    .pipe transformer
    .pipe stringifier
    .pipe output

rabo.transform(process.stdin, process.stdout)  
