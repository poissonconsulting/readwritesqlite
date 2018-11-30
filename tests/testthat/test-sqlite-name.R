context("sqlite-name")

test_that("sqlite_name", {
  x <- c("DaTa", "DATA", "`DaTA`", "[DATa]", "\"dATA\"", '"DaTA"')
  y <- as.sqlite_name(x)
  expect_false(is.sqlite_name(x))
  expect_true(is.sqlite_name(y))
  expect_identical(check_sqlite_name(y), y)
  expect_identical(as.character(y), x)
  y3 <- rep(y, 3)
  expect_identical(check_sqlite_name(y3), y3)
  expect_identical(as.character(y3), rep(x, 3))
  expect_identical(y[1:2], as.sqlite_name(x[1:2]))
  expect_identical(y[2], as.sqlite_name(x[2]))
  expect_identical(is_quoted(y), c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE))
  expect_identical(to_upper(y), 
                   c("DATA", "DATA", "`DaTA`", "[DATa]", "\"dATA\"", "\"DaTA\""))  
  expect_identical(quotes(y), 
                   c("", "", "`", "[", "\"", "\""))  
  expect_identical(unquote(to_upper(y)), 
                   c("DATA", "DATA", "DaTA", "DATa", "dATA", "DaTA"))  
  expect_true(y[1] == y[2])
  expect_false(y[1] > y[2])
  expect_identical(y == "DATa", c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE))
  expect_identical(y == "`DaTA`", c(FALSE, FALSE, TRUE, FALSE, FALSE, FALSE))
  expect_identical(y == "\"DaTA\"", c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE))
})

test_that("sqlite_name sorts", {
  x1 <- c("DaTa", "DATA", "`DaTA`", "[DATa]", "\"dATA\"", '"DaTA"')
  x2 <- c("DaTa1", "DATA2", "`DaTA3`", "[DATa4]", "\"dATA5\"", '"DaTA6"')
  x1 <- as.sqlite_name(x1)
  x2 <- as.sqlite_name(x2)
  
  expect_identical(sort(x1), 
                   as.sqlite_name(c("\"dATA\"", "\"DaTA\"", "`DaTA`", "[DATa]", "DaTa", "DATA")))
  expect_identical(sort(x2), 
                   as.sqlite_name(c("DaTa1", "DATA2", "`DaTA3`", "[DATa4]", "\"dATA5\"", "\"DaTA6\"")))
})
