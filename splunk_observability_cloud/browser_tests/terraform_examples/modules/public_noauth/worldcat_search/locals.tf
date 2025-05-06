locals {
    search_root_url = "https://search.worldcat.org/search"
    search_string = "katie"
    search_query_url = "${local.search_root_url}?q=${local.search_string}"
    start_page_number = "3"
    start_page_query_details = "&limit=10&offset=21"
    search_print_books_with_startpage = "${local.search_query_url}&itemSubType=book-printbook${local.start_page_query_details}&itemSubTypeModified=book-printbook"
}
