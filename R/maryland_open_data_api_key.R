#' Install a Maryland Open Data Portal API Key in Your `.Renviron` File for Repeated Use
#' @description This function will add your Maryland Open Data Portal API key to your `.Renviron` file so it can be called securely without being stored
#' in your code. After you have installed your key, it can be called any time by typing `Sys.getenv("MARYLAND_OPEN_DATA_API_KEY")` and can be
#' used in package functions by simply typing MARYLAND_OPEN_DATA_API_KEY If you do not have an `.Renviron` file, the function will create on for you.
#' If you already have an `.Renviron` file, the function will append the key to your existing file, while making a backup of your
#' original file for disaster recovery purposes.
#' @param key The API key provided to you from Maryland Open Data Portal formatted in quotes. A key be be created after signing up <https://imap.maryland.gov/Pages/open-data-portal-signup.aspx>
#' @param install if TRUE, will install the key in your `.Renviron` file for use in future sessions.  Defaults to FALSE.
#' @param overwrite If this is set to TRUE, it will overwrite an existing MARYLAND_OPEN_DATA_API_KEY that you already have in your `.Renviron` file.
#' @importFrom utils write.table read.table
#' @examples
#' \dontrun{
#' MARYLAND_OPEN_DATA_API_KEY("111111abc", install = TRUE)
#' # First time, reload your environment so you can use the key without restarting R.
#' readRenviron("~/.Renviron")
#' # You can check it with:
#' Sys.getenv("MARYLAND_OPEN_DATA_API_KEY")
#' }
#'
#' \dontrun{
#' # If you need to overwrite an existing key:
#' MARYLAND_OPEN_DATA_API_KEY("111111abc", overwrite = TRUE, install = TRUE)
#' # First time, relead your environment so you can use the key without restarting R.
#' readRenviron("~/.Renviron")
#' # You can check it with:
#' Sys.getenv("MARYLAND_OPEN_DATA_API_KEY")
#' }
#' @export

maryland_open_data_api_key <- function(key, overwrite = FALSE, install = FALSE) {
  if (install) {
    home <- Sys.getenv("HOME")
    renv <- file.path(home, ".Renviron")
    if (file.exists(renv)) {
      # Backup original .Renviron before doing anything else here.
      file.copy(renv, file.path(home, ".Renviron_backup"))
    }
    if (!file.exists(renv)) {
      file.create(renv)
    } else {
      if (isTRUE(overwrite)) {
        message("Your original .Renviron will be backed up and stored in your R HOME directory if needed.")
        oldenv <- read.table(renv, stringsAsFactors = FALSE)
        newenv <- oldenv[-grep("MARYLAND_OPEN_DATA_API_KEY", oldenv), ]
        write.table(newenv, renv,
          quote = FALSE, sep = "\n",
          col.names = FALSE, row.names = FALSE
        )
      } else {
        tv <- readLines(renv)
        if (any(grepl("MARYLAND_OPEN_DATA_API_KEY", tv))) {
          stop("An MARYLAND_OPEN_DATA_API_KEY already exists. You can overwrite it with the argument overwrite=TRUE", call. = FALSE)
        }
      }
    }

    keyconcat <- paste0("MARYLAND_OPEN_DATA_API_KEY='", key, "'")
    # Append API key to .Renviron file
    write(keyconcat, renv, sep = "\n", append = TRUE)
    message('Your API key has been stored in your .Renviron and can be accessed by Sys.getenv("MARYLAND_OPEN_DATA_API_KEY"). \nTo use now, restart R or run `readRenviron("~/.Renviron")`')
    return(key)
  } else {
    message("To install your API key for use in future sessions, run this function with `install = TRUE`.")
    Sys.setenv(MARYLAND_OPEN_DATA_API_KEY = key)
  }
}
