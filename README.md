# FERC Form 1 Database Release

The Federal Energy Regulatory Commission (FERC) Form 1 data contains a lot of
financial data not publicly available elsewhere. Catalyst has used this

Unfortunately FERC publishes this data in a relatively archaic, poorly
supported binary format, and each year is published separately, with no
infrastructure provided to link the 25 years of available data together. This
makes it very difficult to use the Form 1 data to explore how the finances and
operations of the utilities reporting to FERC have changed over time. In
addition, Microsoft has recently discontinued support for a plugin which
allowed this data to be loaded into Excel via MS Access.

Catalyst has integrated a few of the FERC Form 1 tables into our Public Utility
Data Liberation (PUDL) project, but the overwhelming majority of the data
remains to be cleaned up and organized. However, in the course of the PUDL
project we developed a tool that clones all of the original FERC Form 1
databases and knits them together into a single SQLite database, making all of
the original data available in a modern format that's relatively accessible.

Since there's so much valuable information in this database, and we don't have
the resources to clean it all up ourselves, we wanted to make it available to
everyone as easily as possible.

## FERC 1 DB Design Notes:
* All the `_f` columns contain the IDs of footnotes, which refer to records in
  the `f1_footnote_tbl` table, offering clarifying details and annotations.

### Other DB Documentation:
* FERC Form 1 DB schematic diagram (PDF, 2015)
* Notes on the database structure (CSV, 2015)
* Blank FERC Form 1 for reference (PDF, various years)

## Known Issues

### Database Structural Issues:
* Almost every table in the FERC Form 1 database contains records for which the
  composite primary key columns specified by FERC are non-unique; sometimes
  there are thousands of such records. Rather than lose this data by enforcing
  uniqueness, we've used surrogate keys. While this sacrifices some of the
  foreign key relationships specified in the original database, those relations
  were not very useful -- they simply refer back to the `f1_respondent` table
  using the utility's respondent ID.
* In a few cases there are records in the original database which contain
  respondent IDs that don't show up in the `f1_respondent` table. To ensure
  that the overall database structure remains valid, we inject the necessary
  dummy respondents into that table with `respondent_name` values that make it
  clear they were added by us.
* The original FERC Form 1 database sometimes contains data that's inconsistent
  with the stated data type of the column it appears in. We've coerced this
  data into the appropriate type for inclusion in the SQLite database. None of
  these coercions appeared ambiguous. They included: stripping leading zeroes
  from numeric values, converting lone periods (`.`) into the floating point
  value `0.0`, and stripping unprintable null characters from strings.
* Almost every table in the original FERC Form 1 DB contains a `report_year`
  column, making it easy to concatenate the tables together without fear of
  ambiguity between years. The one exception is the `f1_respondent` table,
  which relates `respondent_id` to `respondent_name`. Rather than change the
  structure of the table, we've chosen to update records there with the most
  recent reported values. Hence, if the `respondent_name` associated with a
  given `respondent_id` has changed over time, our cloned database will only
  include the most recently reported value of `respondent_name`.

### FERC 1 DB Design Issues:
* Lack of plant IDs.
* Non-unique connections between f1_steam and f1_fuel
* Many free-form strings -- few controlled vocabularies, bad coding.
* Row mapping changes from year to year -- use row literals to untangle

### Original Data Entry Issues:
* Rarely, it appears that utilities have submitted information using the
  an earlier version of the Form 1, in which case the row mappings for those
  utilities in those years will be incorrect.
* Overwriting f1_respondent table records w/ most recent ID to Name matching
* The `f1_note_fin_stmnt` table is enormous -- half of the full DB -- and
  appears to contain binary data. It is included for completeness.
