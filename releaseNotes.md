
Changes in v1.2.0:

1.  reports auto-update when transactions are saved, edited, and deleted, and when
      balances are saved
2.  list of transaction ids auto-updates when a transaction is saved

------------------------------------------------------------------------------------------

Changes in v1.1.0:

1.  comboboxes, checkboxes, and text entries now turn red when contents are modified
      the color is reset when the data is saved/processed
2.  end-of-month-balances is no longer "live": it does not fetch data from the database
      (but it still saves it there)
      be careful, though -- it's easy to inadvertently overwrite values (no warning)

------------------------------------------------------------------------------------------

Changes in v1.0.3a:

1.  "Reports" window now has menu
      free-floating buttons ("Save Report" and "Choose row color")
      moved into menu, along with "Close window" command
2.  No more output written to STDOUT (written to logfile instead)

------------------------------------------------------------------------------------------

Changes in v1.0.2:

1.  add two new reports:
      30 most recently added transactions
      total after each transaction
2.  view reports in separate window
3.  add menu to main gui
      'file' menu: open reports, quit
      'help' menu: about, website
4.  table access is finer grained (select-only from most tables)

------------------------------------------------------------------------------------------

Changes in v1.0.1:

1.  add a couple of new reports (implemented as database views)
2.  remove one superfluous report
3.  remove complicated SQL code from the Controller.pm class
4.  make reports more consistent
        identical columns should now have identical names
        columns appear in the same order (i.e. always month before year)
        column names are more meaningful (`sum of transactions` vs `sum`)
5.  add tests to ensure that all reports will run in database server

--------------------------------------------------------------------------------------------

Summary of v1.0.0:

??