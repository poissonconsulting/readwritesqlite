## Test environments

release 3.6.2

* OS X (local) - release
* Ubuntu (travis) - devel, release, oldrel and 3.4
* Windows (appveyor) - release
* Windows (win-builder) - devel

## R CMD check results

0 errors | 0 warnings | 1 note

Fixed problems at https://cran.r-project.org/web/checks/check_results_readwritesqlite.html caused by recent version of sf.

Version: 0.1.0 
Check: tests 
Result: ERROR 
     Running 'testthat.R' [41s/43s]
    Running the tests in 'tests/testthat.R' failed.
    Complete output:
     > library(testthat)
     > library(readwritesqlite)
     > 
     > test_check("readwritesqlite")
     -- 1. Failure: meta reads all classes (@test-meta.R#194) ----------------------
     `remote` not identical to tibble::as_tibble(local).
     Component "geometry": Attributes: < Component "crs": Component "input": 1 string mismatch >
     Component "geometry": Attributes: < Component "crs": Component "wkt": 1 string mismatch >
     
     -- 2. Failure: meta sfc different types (@test-meta.R#500) --------------------
     `remote` not identical to tibble::as_tibble(local).
     Component "zinteger": Attributes: < Component "crs": Component "input": 1 string mismatch >
     Component "zinteger": Attributes: < Component "crs": Component "wkt": 1 string mismatch >
     Component "zreal": Attributes: < Component "crs": Component "input": 1 string mismatch >
     Component "zreal": Attributes: < Component "crs": Component "wkt": 1 string mismatch >
     Component "znumeric": Attributes: < Component "crs": Component "input": 1 string mismatch >
     Component "znumeric": Attributes: < Component "crs": Component "wkt": 1 string mismatch >
     Component "ztext": Attributes: < Component "crs": Component "input": 1 string mismatch >
     Component "ztext": Attributes: < Component "crs": Component "wkt": 1 string mismatch >
     Component "ztextold": Attributes: < Component "crs": Component "input": 1 string mismatch >
     ...
     
     -- 3. Failure: rws_get_sqlite_query works with meta = TRUE and logical (@test-qu
     `remote` not identical to tibble::as_tibble(local).
     Component "geometry": Attributes: < Component "crs": Component "input": 1 string mismatch >
     Component "geometry": Attributes: < Component "crs": Component "wkt": 1 string mismatch >
     
     -- 4. Failure: rws_read with meta = FALSE (@test-read.R#68) ------------------
     `remote` not identical to `local`.
     Component "geometry": Attributes: < Component "crs": Names: 2 string mismatches >
     Component "geometry": Attributes: < Component "crs": Component 1: Modes: character, numeric >
     Component "geometry": Attributes: < Component "crs": Component 1: target is character, current is numeric >
     Component "geometry": Attributes: < Component "crs": Component 2: 1 string mismatch >
     
     -- 5. Failure: sf data frames with single geometry passed back (@test-write.R#56
     `remote` not identical to `local`.
     Component "geometry": Attributes: < Component "crs": Names: 2 string mismatches >
     Component "geometry": Attributes: < Component "crs": Component 1: Modes: character, numeric >
     Component "geometry": Attributes: < Component "crs": Component 1: target is character, current is numeric >
     Component "geometry": Attributes: < Component "crs": Component 2: 1 string mismatch >
     
     -- 6. Failure: sf data frames with two geometries and correct one passed back (@
     `remote` not identical to `local`.
     Component "first": Attributes: < Component "crs": Names: 2 string mismatches >
     Component "first": Attributes: < Component "crs": Component 1: Modes: character, numeric >
     Component "first": Attributes: < Component "crs": Component 1: target is character, current is numeric >
     Component "first": Attributes: < Component "crs": Component 2: 1 string mismatch >
     Component "second": Attributes: < Component "crs": Names: 2 string mismatches >
     Component "second": Attributes: < Component "crs": Component 1: Modes: character, numeric >
     Component "second": Attributes: < Component "crs": Component 1: target is character, current is numeric >
     Component "second": Attributes: < Component "crs": Component 2: 1 string mismatch >
     
     -- 7. Failure: sf can change sf_column (@test-write.R#604) --------------------
     `remote` not identical to `local`.
     Component "first": Attributes: < Component "crs": Names: 2 string mismatches >
     Component "first": Attributes: < Component "crs": Component 1: Modes: character, numeric >
     Component "first": Attributes: < Component "crs": Component 1: target is character, current is numeric >
     Component "first": Attributes: < Component "crs": Component 2: 1 string mismatch >
     Component "second": Attributes: < Component "crs": Names: 2 string mismatches >
     Component "second": Attributes: < Component "crs": Component 1: Modes: character, numeric >
     Component "second": Attributes: < Component "crs": Component 1: target is character, current is numeric >
     Component "second": Attributes: < Component "crs": Component 2: 1 string mismatch >
     
     -- 8. Failure: sf data frames with two geometries and lots of other stuff and co
     `remote` not identical to `local`.
     Component "geometry": Attributes: < Component "crs": Names: 2 string mismatches >
     Component "geometry": Attributes: < Component "crs": Component 1: Modes: character, numeric >
     Component "geometry": Attributes: < Component "crs": Component 1: target is character, current is numeric >
     Component "geometry": Attributes: < Component "crs": Component 2: 1 string mismatch >
     Component "second": Attributes: < Component "crs": Names: 2 string mismatches >
     Component "second": Attributes: < Component "crs": Component 1: Modes: character, numeric >
     Component "second": Attributes: < Component "crs": Component 1: target is character, current is numeric >
     Component "second": Attributes: < Component "crs": Component 2: 1 string mismatch >
     
     -- 9. Failure: initialized even with no rows of data (@test-write.R#644) ------
     `remote` not identical to `local`.
     Component "geometry": Attributes: < Component "crs": Component "input": 1 string mismatch >
     Component "geometry": Attributes: < Component "crs": Component "wkt": 1 string mismatch >
     Component "second": Attributes: < Component "crs": Component "input": 1 string mismatch >
     Component "second": Attributes: < Component "crs": Component "wkt": 1 string mismatch >
     
     == testthat results ===========================================================
     [ OK: 496 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 9 ]
     1. Failure: meta reads all classes (@test-meta.R#194) 
     2. Failure: meta sfc different types (@test-meta.R#500) 
     3. Failure: rws_get_sqlite_query works with meta = TRUE and logical (@test-query.R#51) 
     4. Failure: rws_read with meta = FALSE (@test-read.R#68) 
     5. Failure: sf data frames with single geometry passed back (@test-write.R#560) 
     6. Failure: sf data frames with two geometries and correct one passed back (@test-write.R#582) 
     7. Failure: sf can change sf_column (@test-write.R#604) 
     8. Failure: sf data frames with two geometries and lots of other stuff and correct one passed back (@test-write.R#624) 
     9. Failure: initialized even with no rows of data (@test-write.R#644) 
