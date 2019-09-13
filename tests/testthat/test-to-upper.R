context("to-upper")

test_that("to_upper", {
  x <- c("DaTa", "DATA", "`DaTA`", "[DATa]", "\"dATA\"", '"DaTA"')
  expect_identical(is_quoted(x), c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE))
  expect_identical(
    to_upper(x),
    c("DATA", "DATA", "`DaTA`", "[DATa]", "\"dATA\"", "\"DaTA\"")
  )
  expect_identical(
    quotes(x),
    c("", "", "`", "[", "\"", "\"")
  )
  expect_identical(
    unquote(to_upper(x)),
    c("DATA", "DATA", "DaTA", "DATa", "dATA", "DaTA")
  )
})
