terraform {
  required_providers {
    synthetics = {
      version = "2.0.3"
      source  = "splunk/synthetics"
    }
  }
}

# https://registry.terraform.io/providers/splunk/synthetics/latest/docs
provider "synthetics" {
  product = "observability"
}

resource "synthetics_create_browser_check_v2" "worldcat_search_check" {

  test {
    active              = true
    device_id           = 1 // desktop
    frequency           = 720 // twice a day
    location_ids        = ["aws-us-east-1"]
    name                = "Worldcat search check (unauthenticated)"
    scheduling_strategy = "round_robin"

    transactions {
      name = "Tr01 Validate search results behavior"

      steps {
        name         = "Go to search results URL, printed books, page ${local.start_page_number}"
        type         = "go_to_url"
        url          = local.search_print_books_with_startpage
        wait_for_nav = true
      }

      steps {
        name          = "Cookies permission popup appeared?"
        type          = "assert_element_present"
        selector_type = "xpath"
        selector      = "//button[@id='onetrust-reject-all-handler']"
      }

      steps {
        name          = "Reject unnecessary cookies"
        type          = "click_element"
        selector_type = "xpath"
        selector      = "//button[@id='onetrust-reject-all-handler']"
        wait_for_nav  = true
      }

      steps {
        name          = "Currently on page ${local.start_page_number}"
        type          = "assert_element_present"
        selector_type = "xpath"
        selector      = "//*[@data-testid='pagination-control-search-results']//button[contains(@class, 'Mui-selected')]/text()[.='${local.start_page_number}']/parent::button"
      }

      steps {
        name          = "At least one search result showing?"
        type          = "assert_element_present"
        selector_type = "xpath"
        selector      = "//*[starts-with(@data-testid, 'search-result-item-')]"
      }

      steps {
        name          = "Clear the book-format filter"
        type          = "click_element"
        selector_type = "xpath"
        selector      = "//button[@data-testid='facet-container-format-reset-button']"
        wait_for_nav  = true
      }

      steps {
        name          = "Bumped back to page 1?"
        type          = "assert_element_present"
        selector_type = "xpath"
        selector      = "//*[@data-testid='pagination-control-search-results']//button[contains(@class, 'Mui-selected')]/text()[.='1']/parent::button"
      }

      steps {
        name          = "At least one search result showing?"
        type          = "assert_element_present"
        selector_type = "xpath"
        selector      = "//*[starts-with(@data-testid, 'search-result-item-')]"
      }

    }

    advanced_settings {
      verify_certificates         = true
      collect_interactive_metrics = true
    }

  }
}
