use crate::cached_client::{CachedClient, Client};

pub fn isbn_search(client: &CachedClient, isbn: &str) -> String {
    let raw_search_results = client.make_request_as_text(
      format!("abebooks/get_book_url_{}.html", isbn).as_str(),
      &|http_client|
          http_client.get(format!("http://www.abebooks.fr/servlet/SearchResults?bx=off&sts=t&ds=30&bi=0&isbn={}&sortby=2", &isbn)).send()
  );
    raw_search_results
}
