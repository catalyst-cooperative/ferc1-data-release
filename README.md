# FERC Form 1 Database Release v1.0.0

The Federal Energy Regulatory Commission's [Form
1](https://www.ferc.gov/docs-filing/forms/form-1/data.asp) contains a trove of
financial data not publicly available elsewhere. Unfortunately FERC compiles
and publishes this data using a proprietary database system called [Microsoft
Visual FoxPro](https://en.wikipedia.org/wiki/Visual_FoxPro). Support for the
final version of this database was [discontinued by Microsoft in January of
2015](https://support.microsoft.com/en-us/lifecycle/search/1111). The last
version of Microsoft Access to support the product was released in 2010 (See
[FERC's instructions for connecting to the
DB](https://www.ferc.gov/docs-filing/forms/ms-access.asp)).

Catalyst has integrated several FERC Form 1 tables into our [Public Utility
Data Liberation (PUDL) Project](https://catalyst.coop/pudl), but the
overwhelming majority of the data remains to be cleaned up and organized. In
the course of the PUDL project we developed a tool that clones all of the
original FERC Form 1 databases and knits them together into a single SQLite
database, making all of the original data available in a modern open source
database format that's relatively accessible.

Since there's so much valuable information in this database, and we don't have
the resources to clean it all up ourselves, we wanted to make it available to
everyone as easily as possible. If you're interested in working with this data,
or helping us clean it up further in a repeatable way, please check out
[the PUDL Project](https://catalyst.coop/pudl).

## Contained in this Release
* `ferc1-release.sh`: The bash shell script used to compile the contents of
  this release.
* `archived-environment.yml`: A specification of the `conda` environment that
  was used to compile the release.
* `ferc1-input-data.tgz`: A compressed archive of the raw input data obtained
  from FERC that was used to compile this release. It was downloaded from the
  FERC FTP site on February 2nd, 2020.
* `ferc1-release-settings.yml`: input file for the PUDL `ferc1_to_sqlite`
  Python script which converts the original FERC Form 1 data into an SQLite
  database. It specifies which tables to convert, what years of data to use,
  and which year's FERC 1 DB should be used to define the database schema.
* `ferc1-sqlite.tgz`: A compressed archive of the SQLite database output by
  the `ferc1_to_sqlite`.
* `README.md`: The file you're reading right now!
* `reproduce-ferc1-release.sh`: A bash shell script which will use the
  raw inputs and archived `conda` environment to recreate the included SQLite
  database, which should be byte-for-byte identical.
* `docs/ferc_form1_database_design_diagram_2015.pdf`: A schematic diagram of
  the full FERC Form 1 database as it was implemented in 2015, including table
  names, field names, and indications of primary and foreign key relations.
* `docs/ferc_form1_database_notes.csv`: Notes on the connections between the
  individual DBF files included in the FERC Form 1 archives, the name of the
  tables they correspond to in the database, the pages this data comes from in
  Form 1, reporting frequency of that data, and a short description of many of
  the tables. These notes are provided for informational purposes and human
  readability only. The actual structure of the FERC Form 1 database is
  inferred automatically by the PUDL software.
* `docs/ferc_form1_blank/`: A collection of PDFs of recent versions of the
  blank FERC Form 1 for reference, organized by the expiration date of that
  version of the form.

## Other PUDL Resources
* [PUDL Project homepage](https://catalyst.coop/pudl)
* [Most recent PUDL Data Release on Zenodo](https://doi.org/10.5281/zenodo.3653158)
* [PUDL issue tracker on Github](https://github.com/catalyst-cooperative/pudl/issues)
* [PUDL Documentation on Read The Docs](https://catalystcoop-pudl.readthedocs.org)
* [Sign up for email updates](https://catalyst.coop/updates)
* Follow us on Twitter: [@CatalystCoop](https://twitter.com/CatalystCoop)
* Email the project team: pudl@catalyst.coop
* [Make a donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PZBZDFNKBJW5E&source=url)
  to support this work!

## Known Issues

### Database Design
The FERC Form 1 database appears to have been designed (in the early 1990s) as
a digital container for what is still functionally a paper form, rather than
with an eye toward use of the data for any kind of analysis. The application
that these database files are actually used by generates PDFs that replicate
what a respondent would have entered on paper. That output and the data which
underlies it is generally human readable in context, but often difficult or
impossible to use programmatically.

* The data is organized by page and row number. On some pages, a given row number
  consistently refers to a particular piece of semantic information. On other
  pages the meaning of the content of the row is undefined, and only indicated
  by information provided by the respondent. Sometimes that information is
  contained on the row itself, but it's also common for respondents to create
  headers and subheaders on their own rows, meaning that information required
  to interpret the meaning of a given row is only available within another row
  -- i.e. another record in the database. Rows containing totals and subtotals
  that sum quantities reported on several other unspecified rows are also
  common, and very difficult to parse.
* In addition, even when individual rows do contain well defined pieces of
  information, the mapping between the row number and what kind of information
  it contains changes from year to year, as rows are added or re-arranged. This
  means it is not easy to track individual fields across differing years in the
  original database. However, the `f1_row_lit_tbl` table contains per-table
  and per-year associations of row numbers and descriptive text, as well as
  tracking what year the row number last changed in, so it is possible to
  construct a mapping by hand that applies across all the available years.
* This issue of row mapping is generally a consequence of poor database
  normalization. The database contains many totals and subtotals which are
  derived from other rows and columns, and most of the quantities reported as
  "rows" should really be columns. While many of the database columns should
  probably be simply indicating categorical values that are part of a record.
  Programmatic use of the data will require substantial re-shaping and
  normalization.
* While there are half a dozen tables that contain data related to individual
  plants, generation units, or other subdivisions of facilities, FERC does not
  use any kind of unique identifier to refer to these entities, meaning that
  they can often only be identified by their name and the ID of the respondent
  that is reporting the information. However, these names are not required to
  be unique, and they vary from year to year, making it very difficult to track
  individual plants through time or across different respondents in the case of
  facilities with multiple owners / operators.
* One side-effect of the above that while data reported in the `f1_steam` and
  `f1_fuel` tables will always have the same respondent ID and the same plant
  name (since they come from the same page of Form 1), these two tables cannot
  be connected with a one-to-one join, since the same utility can use the same
  name to report data for different facilities (or portions of a single
  facility) in the same year. This is uncommon, but it does happen.
* FERC has made no attempt to require controlled vocabularies or standardized
  coding in what really should be categorical fields within the database. As a
  result there literally hundreds of different free-form strings used to
  indicate fuel types, fuel units, plant types, etc. Any analysis attempting to
  use the original FERC data has to start with a necessarily imperfect attempt
  to clean up or at least identify and avoid using such fields.

### Structures and Data Types
* Most tables in the FERC Form 1 database contains records for which the
  composite primary key columns specified by FERC are non-unique; sometimes
  there are thousands of such records. Rather than lose this data by enforcing
  uniqueness, we've used surrogate keys. While this sacrifices some of the
  foreign key relationships specified in the original database, those relations
  were not very useful -- they simply refer back to the `f1_respondent_id`
  table using the utility's respondent ID.
* In a few cases there are records in the original database which contain
  respondent IDs that don't show up in the `f1_respondent_id` table. To ensure
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
  ambiguity between years. The one exception is the `f1_respondent_id` table,
  which relates `respondent_id` to `respondent_name`. Rather than change the
  structure of the table, we've chosen to update records there with the most
  recent reported values. Hence, if the `respondent_name` associated with a
  given `respondent_id` has changed over time, our cloned database will only
  include the most recently reported value of `respondent_name`.
* Over the years, new tables and fields have occasionally been added to the
  FERC Form 1 database, changing its structure. We have checked exhaustively
  and thankfully these changes have so far only been additive, meaning that we
  can simply use the most recently posted version of the database to define a
  schema within which data form all previous years can be stored. The
  continuous integration tests that we run on the PUDL software automatically
  checks whether this is the case, so if it changes we will be alerted.

### Data Entry Issues
* Occasionally, it appears that utilities have submitted information using the
  an earlier version of the Form 1, in which case the row mappings for those
  utilities in those years will be incorrect. We can tell that this is the
  happening because some pages of the Form 1 have header rows which should
  never contain data, and the pattern of those rows changes from year to year
  as the form is revised, so you can identify when a particular utility is
  using the previous revision of the form based on this pattern.

### Data Revisions
* At some point between 2018 and 2020 FERC substantially revised at least the
  2012-2013 data. Approximately 300 MB of data previously stored in the "FoxPro
  Memo File" (`F1_43.FPT`) associated with the `f1_note_fin_stmnt` table was
  removed, reducing the size of the memo file to less than 1 MB. In earlier
  and later years, it remains ~300 MB in size.
* Based on their SHA256 hashes, the contents of all the zipped FERC Form 1
  archives available on the FERC website for the years 1994-2011 remained
  unchanged between 2018 and 2020, but all of the archives for the years
  2012-2018 have been altered since their initial posting. Only the 2012-2013
  archives noted above have seen substantial changes in the overall quantity of
  information they contain.

## Miscellaneous Notes
* Every Form 1 database column has a corresponding footnote columns with the
  same name, but a `_f` suffix. These footnote columns contain the IDs of
  footnotes, which refer to records in the `f1_footnote_tbl` table, offering
  clarifying details and annotations.
* The `f1_note_fin_stmnt` table is enormous -- it accounts for half the DB --
  and appears to contain binary data. It is included for completeness.

## Acknowledgments
* Many thanks to the [Alfred P. Sloan Foundation](https://sloan.org/) for
  financial support which has allowed us to work on the PUDL Project for a full
  year.
* Liberating the FERC Form 1 data in particular would have been very difficult
  without the open source [dbfread Python
  package](https://github.com/olemb/dbfread/) originally developed by Ole
  Martin Bjørndalen.

## Changelog

### v1.0.0
Initial release.
* FERC Form 1 database covering 1994-2018.
* Generated using `catalystcoop.pudl v0.3.2`
