# rabo2xero

Turns a Rabobank CSV export into something that can be read by Xero. This is all work in progress. Currently the only way to test if this is useful is by running the transformation from the commandline:

```bash
cat transactions.txt | coffee src/index.coffee > xero.txt
```


## The mapping

### Transaction Type?

While importing CSV files, Xero allows you to indicate the source column for a *Transaction Type*. It's not entirely clear what this attribute means, and how's it's used in Xero. This is what I gather from a [discussion on one of the forums](http://xerousers.com/forum/topics/transaction-types-coding-for):

① Apparently it's displayed somewhere:

> The transaction type field when included with bank statement data is purely for display purposes.

② Apparently, it's not required

> therefore to achieve a full coded statement it's not a required column on your CSV

③ It seems some values get a special treatment in Xero:

> you can use any terms - however those that do have a nice 'plain English' equivalent in Xero for display purposes are […]: ATM, CASH, CHEQUE, CREDIT, DEBIT, DEP, DIRECTDEBIT, DIRECTDEP, DIV, FEE, INT, OTHER, PAYMENT, POS, REPEATPMT, SRVCHG, TAX, XFER

It seems the `BOEKCODE` would be reasonable field, even though it doesn't map directly to the terms mentioned in the customer forums. Perhaps it should even be [the label belonging to the code](http://nl.wikipedia.org/wiki/Rekeningafschrift) instead of the code itself.

### Description

In the CSV file provided by the Rabobank, for some reason (probably legacy) the description has been split up in several fields. In all of the cases I have seen so far, the spaces have been dropped, so simply joining all `OMSCHRx` fields won't cut it. I've decided to just join the fields separated by spaces, and map it to the `Description` field.

### Analysis Code

According to [this page](https://help.xero.com/au/BankAccounts_Details_BankRules), the Analysis Code is

> typically 4 characters long and relating to a Chart of Accounts account code - sometimes used on cheques and subsequently imported into Xero on the bank statement line through an automatic bank feed.

I'm ignoring it for now.

### Reference

Going with `END_TO_END_ID` for now, even though that fields is not always set by the Rabobank. It seems it's used in Xero for matching, not entirely clear how. (Does it need to be perfect match?)

### Payee

`NAAR_NAAM` seems to be the sensible field here. `ID_TEGENREKENINGHOUDER` might be another option, but it's not always set. (Unfortunately, it's not always set to something sensible.)

### Account Code?

`TEGENREKENING`, even though it's not always set. (Jus as an example: in case of a `ba` `BOEKCODE`, it's not set, nor in case of some `db` `BOEKCODE` type of payments.)

### Transaction Amount?

In case of `BY_AF_CODE` 'C', we should take the `BEDRAG`. In case it's 'D', we need to take that same amount, but make it a negative number.

### Transaction Date

Going with `BOEKDATUM`.

## Resources

* http://xerousers.com/forum/topics/transaction-types-coding-for
* http://nl.wikipedia.org/wiki/Rekeningafschrift
* https://help.xero.com/au/BankAccounts_Details_BankRules
* https://www.rabobank.nl/images/formaatbeschrijving_csv_kommagescheiden_nieuw_29539176.pdf

