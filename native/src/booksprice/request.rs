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

    extract_price_from_url(
        driver,
        &format!(
            "https://www.booksprice.com/comparePrice.do?l=y&searchType=compare&inputData={}",
            isbn
        ),
    )
    .await
}

async fn extract_price_from_url(c: WebDriver, url: &str) -> Result<Vec<f32>, WebDriverError> {
    c.goto(&url).await?;

    let wait_res = c
        .query(By::XPath("//*[@id='chart']"))
        .wait(Duration::from_secs(10), Duration::from_secs(1))
        .exists()
        .await;

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

    c.close_window().await;

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
        )
        .await
        .unwrap();

        assert_eq!(prices, vec![16.55, 21.85, 23.75, 27.17, 28.15, 43.20]);
        Ok(())
    }

    #[test]
    fn test_selenium() {
        local_tester!(parse_booksprices_from_9782884747974, "chrome");
    }
}
