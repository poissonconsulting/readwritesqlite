context("sqlite-name")

test_that("sqlite_name", {
  x <- c("DaTa", "DATA", "`DaTA`", "[DATa]", "\"dATA\"", '"DaTA"')
  y <- as.sqlite_name(x)
  expect_false(is.sqlite_name(x))
  expect_true(is.sqlite_name(y))
  expect_identical(as.character(y), x)
  y3 <- rep(y, 3)
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
