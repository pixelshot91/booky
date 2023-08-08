use crate::client::Client;

pub fn isbn_search(client: &dyn Client, isbn: &str) -> String {
    let raw_search_results = client.request(
      format!("get_book_url_{}", isbn).as_str(),
      &|http_client|
          http_client.get(format!("http://www.abebooks.fr/servlet/SearchResults?bx=off&sts=t&ds=30&bi=0&isbn={}&sortby=2", &isbn)).send()
  );
    raw_search_results.body_if_success().unwrap()
}
