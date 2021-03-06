
## Transaction

 - write-once/read-only fields
   1. id
   2. savedate

 - set-able fields
   1. amount             positive number
   2. account            one of (list from db)
   3. bank date          valid yyyy-mm-dd
   4. purchase date      valid yyyy-mm-dd
   5. transaction type   one of (list from db)
   6. comment            string
 
 - setAttribute
 
 - getAttribute
 
 - validators
   - called from setAttribute
 


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
   
 - **where are fields' types found?**
 
 - **where are values for enum fields found?**
   
 - when newly created, but unsaved:
   - 'save' button
     - saves Transaction to database
   - 'cancel' button
     - removes Row
 
 - when saved:
   - 'update' button
     - updates Transaction in database
   - 'delete' button
     - deletes Transaction from database
     - removes Row
     
 - widget coloring
   - outlined in red if edited (for both saved & unsaved rows)
   - if value changed, then changed back to original, should NOT be red
 

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
   - call 'setAttribute' on each column -- throws exception if any fails validation
   - success:
     1. get id of saved Transaction from MySQL and add to Transaction object
     2. add Transaction to cache
     3. get rid of 'cancel', 'save' buttons
     4. show 'update' & 'delete' buttons
     5. get rid of red outlines
     6. Row stays visible -- even if it doesn't meet filter criteria
     7. Row stays in same spot:  no re-sort
   - failure:
     1. complain to user
     
 3. cancel 
   - preconditions:
     - if unsaved changes:  "warning, you have unsaved changes, would you like to proceed?"
     - no unsaved changes:  "delete this row?"
   - if confirmed, get rid of row
     
 4. update Transaction
   - call 'setAttribute' on each column -- throws exception if any fails validation
   - success:
     1. get rid of red outlines
     2. Row stays visible -- even if it doesn't meet filter criteria
     3. Row stays in same spot:  no re-sort
     4. Transaction in cache will be updated because we're working with a reference to it
   - failure:
     1. complain to user
 
 5. delete Transaction
   - preconditions:
     - if unsaved changes:  "warning, you have unsaved changes, would you like to proceed?"
     - no unsaved changes:  "delete this row?"
   - success:
     1. get rid of Row
   - failure:
     1. complain to user


## TransactionGrid events

 1. sort/filter
   - preconditions:
     - no outstanding changes to any saved Row
     - no unsaved Rows
   - success:
     - possibly different Rows present
     - "new" placeholder at end of Rows
   - failure:
     - complain to user
     - say what to do to get it to work
     

## Non goals

 1. assume no program is concurrently editing the data
   - this would cause the cached data to become stale
   - surprising results when editing
   
 2. ??

