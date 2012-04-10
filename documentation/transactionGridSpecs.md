
## Row

 - visible fields:
   1. amount
   2. comment
   3. account
   4. purchase date
   5. bank date
   6. transaction type

 - hidden fields:
   1. id
   2. savedate
   
 - when newly created, but unsaved:
   
 
 - when saved:


## TransactionGrid model

 - Transaction cache
   - load all Transactions when app starts
   - hold onto Transactions until app is closed
   - enforce unique "id"s at all times
 
 - when saving a Transaction
   - if successfully saved to database, add to cache
   - otherwise, do nothing
 
 - when deleting a Transaction
   - if successfully deleted from database, add to cache
   - otherwise, do nothing
   
   
## Layout

 1. left side: sort/filter
   - drop-down for selecting sort column
   - widgets for filter conditions:
     - account
     - amount: low, high
     - ... etc...
   - button for "sort/filter"
 
 2. right side
   - scrolled grid area
   - top:  saved transactions
   - bottom: "new" placeholder
   - before "new" placeholder:  newly created, unsaved transactions


## Row events

 1. new Transaction
   - always succeeds:
     1. create new Transaction with default values
     2. pass Transaction to new Row
     3. add Row before "new" placeholder
     4. "new" placeholder remains at end

 2. save Transaction
   - success:
     1. get id of saved Transaction from MySQL and add to Transaction object
     2. add Transaction to cache
     3. get rid of 'cancel', 'save' buttons
     4. show 'update' & 'delete' buttons
     5. get rid of red outlines
   - failure:
     1. complain to user


## TransactionGrid events

