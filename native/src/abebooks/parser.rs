pub fn extract_prices(isbn_search_result: &str) -> Vec<f32> {
    let doc = scraper::Html::parse_document(isbn_search_result);

    let prices = (1..)
        .map_while(|index| {
            let selector =
                scraper::Selector::parse(&format!("#add-to-basket-link-{}", index)).unwrap();
            let mut res = doc.select(&selector);

            match res.next() {
                None => None,
                Some(e) => {
                    let raw_book_price: f32 =
                        e.value().attr("data-csa-c-cost").unwrap().parse().unwrap();
                    let shipping_cost: f32 = e
                        .value()
                        .attr("data-csa-c-shipping-cost")
                        .unwrap()
                        .parse()
                        .unwrap();

                    Some(raw_book_price + shipping_cost)
                }
            }
        })
        .collect();

    return prices;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_prices() {
        let html =
            std::fs::read_to_string("src/abebooks/test/search_isbn_9782703304180.html").unwrap();
        let prices = extract_prices(&html);
        assert_eq!(prices, vec![15.34, 17.06, 17.59, 27.7, 42.0, 44.9]);
    }
}
