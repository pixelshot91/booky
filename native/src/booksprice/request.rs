//! Requires chromedriver running on port 9515:
//!
//!     chromedriver --port=9515

use thirtyfour::prelude::*;
use tokio;

// mod selenium_common;

// use crate::common;

#[tokio::main]
async fn selenium_fn() -> color_eyre::Result<()> {
    // The use of color_eyre gives much nicer error reports, including making
    // it much easier to locate where the error occurred.
    color_eyre::install()?;

    // thirtyfour::resolve!();
    // crate::local_tester!();

    let caps = DesiredCapabilities::chrome();
    let driver = WebDriver::new("http://localhost:9515", caps).await?;
    driver.goto("https://www.booksprice.com/comparePrice.do?l=y&searchType=compare&inputData=9782266071529").await?;
    let elem_form = driver.find(By::Id("search-form")).await?;

    // Find element from element.
    let elem_text = elem_form.find(By::Id("searchInput")).await?;

    // Type in the search terms.
    elem_text.send_keys("selenium").await?;

    // Click the search button.
    let elem_button = elem_form.find(By::Css("button[type='submit']")).await?;
    elem_button.click().await?;

    // Look for header to implicitly wait for the page to load.
    driver.find(By::ClassName("firstHeading")).await?;
    assert_eq!(driver.title().await?, "Selenium - Wikipedia");

    // Always explicitly close the browser. There are no async destructors.
    driver.quit().await?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::booksprice::selenium_common;
    use crate::booksprice::selenium_common::handle_test_error;
    use crate::booksprice::selenium_common::make_capabilities;
    use crate::booksprice::selenium_common::make_url;
    use crate::booksprice::selenium_common::setup_server;

    use crate::{local_tester, tester_inner};

    use super::*;

    async fn parse_booksprices(c: WebDriver, port: u16) -> Result<(), WebDriverError> {
        let url = selenium_common::url_from_path(port, "9782884747974.html");

        c.goto(&url).await?;
        let entries = c
            .find_all(By::XPath("//*[@id='chart']/tbody/tr[position()>1]"))
            .await?;
        assert_eq!(entries.len(), 6);

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
                r.get(1).unwrap().as_str().parse::<f64>().unwrap()
            })
        }))
        .await
        .unwrap();

        assert_eq!(prices, vec![16.55, 21.85, 23.75, 27.17, 28.15, 43.20]);

        c.close_window().await
    }

    #[test]
    fn test_selenium() {
        local_tester!(parse_booksprices, "chrome");
    }
}
