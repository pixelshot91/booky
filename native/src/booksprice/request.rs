//! Requires chromedriver running on port 9515:
//!
//!     chromedriver --port=9515

use std::time::Duration;

use thirtyfour::prelude::*;
use tokio;

#[tokio::main]
pub async fn extract_price_from_isbn(
    isbn: &str,
) -> Result<Vec<f32>, thirtyfour::prelude::WebDriverError> {
    let caps = DesiredCapabilities::chrome();
    let driver = WebDriver::new("http://localhost:9515", caps).await?;

    let url = format!(
        "https://www.booksprice.com/comparePrice.do?l=y&searchType=compare&inputData={}",
        isbn
    );

    let cache_file_path = format!("{}/booksprice/{}.html", crate::config::CACHE_PATH, isbn);
    if std::path::Path::new(&cache_file_path).exists() {
        println!("Using cache");
        extract_price_from_url(driver, &format!("file://{}", cache_file_path), None).await
    } else {
        println!("using online selenium");
        extract_price_from_url(driver, &url, Some(cache_file_path)).await
    }
}

async fn extract_price_from_url(
    c: WebDriver,
    url: &str,
    cache_file_path: Option<String>,
) -> Result<Vec<f32>, WebDriverError> {
    c.goto(&url).await?;

    let chart_element_exists = c
        .query(By::XPath("//*[@id='chart']"))
        .wait(Duration::from_secs(10), Duration::from_secs(1))
        .exists()
        .await?;
    if chart_element_exists == false {
        return Ok(vec![]);
    }

    let source_file = c.source().await.unwrap();

    if let Some(cache_file_path) = cache_file_path {
        std::fs::create_dir_all(std::path::Path::new(&cache_file_path).parent().unwrap()).unwrap();
        let write_res = std::fs::write(&cache_file_path, &source_file);
        write_res.expect(format!("Can't write to file {}", cache_file_path).as_str());
    }

    let entries = c
        .find_all(By::XPath("//*[@id='chart']/tbody/tr[position()>1]"))
        .await?;

    let prices = futures::future::try_join_all(entries.iter().map(|e| async {
        let price_text = e
            .find(By::XPath("td[@title='Total']/a/em"))
            .await
            .unwrap()
            .text()
            .await;

        price_text.map(|price_text| {
            use regex::Regex;
            let re = Regex::new(r"\$ (\d+\.?\d+)").unwrap();
            let r = re.captures(&price_text).unwrap();
            r.get(1).unwrap().as_str().parse::<f32>().unwrap()
        })
    }))
    .await
    .unwrap();

    c.close_window().await?;

    Ok(prices)
}

#[cfg(test)]
mod tests {
    use crate::booksprice::selenium_common::handle_test_error;
    use crate::booksprice::selenium_common::make_capabilities;
    use crate::booksprice::selenium_common::make_url;
    use crate::booksprice::selenium_common::setup_server;

    use crate::{local_tester, tester_inner};

    use super::*;

    async fn parse_booksprices_from_9782884747974(
        c: WebDriver,
        port: u16,
    ) -> Result<(), WebDriverError> {
        use crate::booksprice::selenium_common;

        let prices = extract_price_from_url(
            c,
            &selenium_common::url_from_path(port, "9782884747974.html"),
            None,
        )
        .await
        .unwrap();

        assert_eq!(prices, vec![16.55, 21.85, 23.75, 27.17, 28.15, 43.20]);
        Ok(())
    }

    #[test]
    // Need to launch `chromedriver`
    #[ignore]
    fn test_selenium() {
        local_tester!(parse_booksprices_from_9782884747974, "chrome");
    }
}
