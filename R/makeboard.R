#' @importFrom htmltools div
#' @noRd
styleField <- function(value, width = "100%", height = "16px") {
  switch(value,
         "High" = {
           bgcolor = "hsl(16, 100%, 72%)"
           color = "hsl(16, 100%, 25%)"
         },
         "Medium" = {
           bgcolor = "hsl(54, 100%, 72%)"
           color = "hsl(54, 100%, 25%)"
         },
         "Low" = {
           bgcolor = "hsl(86, 100%, 72%)"
           color = "hsl(86, 100%, 25%)"
         },
         "Done" = {
           bgcolor = "hsl(116, 60%, 90%)"
           color = "hsl(116, 30%, 30%)"
         },
         "Doing" = {
           bgcolor = "hsl(230, 70%, 90%)"
           color = "hsl(230, 45%, 25%)"
         },
         "To do" = {
           bgcolor = "hsl(350, 70%, 90%)"
           color = "hsl(350, 45%, 25%)"
         })

  div(style = list(
    display = "inline-block",
    textAlign = "center",
    padding = "0.125rem 0.75rem",
    fontWeight = "600",
    fontSize = "0.75rem",
    backgroundColor = bgcolor,
    color = color,
    borderRadius = "15px"
  ), value)
}

#' Render a reactable board
#' Renders a reactable board in a webpage
#'
#' @param data a board created through \code{makeBoard()}
#' @returns a reactable page
#'
#' @author Giuseppe D'Agostino
#'
#' @importFrom reactable reactable colDef reactableTheme
#' @export

renderBoard <- function(data) {
  reactable(
    data,
    searchable = TRUE,
    filterable = TRUE,
    columns = list(
      Priority = colDef(cell = function(value) {
        styleField(value)
      }, align = "left"),
      Status = colDef(cell = function(value) {
        styleField(value)
      }, align = "left")
    ),
    theme = reactableTheme(
      headerStyle = list(
        "&:hover[aria-sort]" = list(background = "hsl(0, 0%, 96%)"),
        "&[aria-sort='ascending'], &[aria-sort='descending']" = list(background = "hsl(0, 0%, 96%)"),
        borderColor = "#555"
      )),
    style = list(fontFamily = "Work Sans, sans-serif", fontSize = "0.875rem"),
    defaultPageSize = 20
  )
}

#' Add entry to a board
#' Adds an entry to an existing board
#'
#' @param board an existing board. if NULL, a new one will be created.
#' @param project a project name or vector of project names
#' @param item an item or vector of items
#' @param priority a priority or vector of priorities. Must only contain "Medium", "High", or "Low"
#' @param status a status or vector of statuses. Must only contain "Doing", "To do" or "Done"
#' @param assignee an assignee or vector of assignees.
#'
#' @returns an updated board
#'
#' @details Users can add rows to a board (or create a new one) by supplying
#'     vectors containing all entries for each field. All vectors must be have
#'     the same length, and there is no recycling.
#'
#' @author Giuseppe D'Agostino
#'
#' @export

addEntry <- function(board = NULL, project, item, priority, status, assignee) {

  if(!all(priority %in% c("High", "Medium", "Low")))
    stop("priority must only contain \"Medium\", \"High\", or \"Low\"")
  if(!all(status %in% c("To do", "Doing", "Done")))
    stop("priority must only contain \"To do\", \"Doing\", or \"Done\"")

  checklist = list(project, item, priority, status, assignee)
  if(length(unique(lengths(checklist))) > 1) stop("Must supply equally sized vectors")
  if(unique(lengths(checklist) == 0)) stop("All vectors are empty")

  if(is.null(board)) {
    board <- data.frame("Project" = list(),
                        "Item" = list(),
                        "Priority" = list(),
                        "Status" = list(),
                        "Assignee" = list())
  }
  addon = cbind(project, item, priority, status, assignee) |> as.data.frame()
  colnames(addon) = colnames(board)
  board = rbind(board, addon)
  colnames(board) = c("Project", "Item", "Priority", "Status", "Assignee")
  board
}

#' Remove entry from a board
#' Removes one or more entries from an existing board based on logical indexing
#'
#' @param board an existing board.
#' @param index a row index, or vector of row indices. Default is NULL.
#' @param project a project name or vector of project names. Default is NULL.
#' @param item an item or vector of items. Default is NULL
#' @param priority a priority or vector of priorities. Default is NULL.
#' @param status a status or vector of statuses. Default is NULL.
#' @param assignee an assignee or vector of assignees. Default is NULL.
#'
#' @returns an updated board
#'
#' @details The function takes vectors of indices and/or any matching field in
#'     the board, and removes the matching rows. If an user wants to delete all
#'     rows corresponding to project "submarine", they can do so by specifying
#'     \code{project = "submarine"} in the arguments. If they want to remove
#'     more than one project, they can use \code{project = c("submarine",
#'     "destroyer")} with any other field.
#'
#' @author Giuseppe D'Agostino
#'
#' @importFrom methods is
#' @export

removeEntry <- function(board, index = NULL, project = NULL,
                        item = NULL, priority = NULL, status = NULL,
                        assignee = NULL) {
  discard = c(index, which(board$Project %in% project), which(board$Item %in% item),
              which(board$Priority %in% priority), which(board$Status %in% status),
              which(board$Assignee %in% assignee))
  keep = setdiff(seq_len(nrow(board)), discard[discard > 0 & !is.null(discard)])
  board[keep,]
}

#' Update entry on a board
#' Updates one or more entries from a board
#'
#' @param board an existing board.
#' @param index a row index, or vector of row indices. Default is NULL.
#' @param new_project a new project name. Default is NULL.
#' @param new_priority a new priority or vector of priorities. Default is NULL.
#' @param new_status a new status or vector of statuses. Default is NULL.
#' @param assignee a new assignee or vector of assignees. Default is NULL.
#'
#' @returns an updated board
#'
#' @details The function takes vectors of indices and/or any matching field in
#'     the board, and updates the matching rows regarding the project, the status
#'     and/or the priority.
#'
#' @author Giuseppe D'Agostino
#'
#' @importFrom methods is
#' @export

updateEntry <- function(board, index = NULL, new_project = NULL,
                        new_priority = NULL, new_status = NULL,
                        new_assignee = NULL,
                        nj = new_project, ns = new_status,
                        np = new_priority, na = new_assignee) {

  if(!index %in% seq_len(nrow(board))) stop("Index must be within the board")

  if(!is.null(new_project)) board[index, "Project"] = new_project

  if(!is.null(new_priority)) {
    match.arg(new_priority, choices = c("High", "Medium", "Low"), several.ok = TRUE)
    board[index, "Priority"] = new_priority
  }
  if(!is.null(new_status)) {
    match.arg(new_status, choices = c("To do", "Doing", "Done"), several.ok = TRUE)
    board[index, "Status"] = new_status
  }
  if(!is.null(new_assignee)) board[index, "Assignee"] = new_assignee

  board
}
