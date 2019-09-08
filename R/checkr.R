is_string <- function (x) (is.character(x) || is.factor(x)) && length(x) == 1 && !is.na(x)

chk_deparse <- function (x) {
    if (!is.character(x)) 
        x <- deparse(x)
    if (isTRUE(is.na(x))) 
        x <- "NA"
    if (!is_string(x)) 
        err(substitute(x), " must be a string")
    x
}

chk_fail <- function (..., error) {
    if (missing(error) || isTRUE(error)) 
        err(...)
    wrn(...)
}
