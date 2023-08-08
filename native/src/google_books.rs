use crate::common;
mod parser;
mod request;
use crate::client::Client;
use itertools::Itertools;

pub struct GoogleBooks {
    pub client: Box<dyn Client>,
}

fn merge<T, F>(first: Option<T>, other: Option<T>, resolver: F) -> Option<T>
where
    F: FnOnce(T, T) -> T,
{
    if let None = first {
        return other;
    }
    if let None = other {
        return first;
    }
    Some(resolver(first.unwrap(), other.unwrap()))
}

fn longest_string_merger(first: Option<String>, other: Option<String>) -> Option<String> {
    merge(
        first,
        other,
        |s1, s2| if s1.len() > s2.len() { s1 } else { s2 },
    )
}

fn merge_vec<T: std::cmp::Eq + std::hash::Hash + std::clone::Clone>(
    v1: Vec<T>,
    v2: Vec<T>,
) -> Vec<T> {
    v1.iter()
        .chain(&v2)
        .unique()
        .map(|f| (*f).clone())
        .collect_vec()
}

fn merge_bmd(
    bmd1: common::BookMetaDataFromProvider,
    bmd2: common::BookMetaDataFromProvider,
) -> common::BookMetaDataFromProvider {
    common::BookMetaDataFromProvider {
        title: longest_string_merger(bmd1.title, bmd2.title),
        // Some authors are not display the same way in the first and second request. Sometimes GoogleBooks display the middle name, sometimes not
        // So a basic merge would result in duplicate authors
        // authors: merge_vec(bmd1.authors, bmd2.authors),
        authors: bmd1.authors,
        blurb: longest_string_merger(bmd1.blurb, bmd2.blurb),
        keywords: merge_vec(bmd1.keywords, bmd2.keywords),
        market_price: vec![],
    }
}

impl common::Provider for GoogleBooks {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaDataFromProvider> {
        // TODO: For some books (eg 9782703305033), the description is better on the first page than in the second
        // The number of authors can be different too !
        let isbn_search_response = request::search_by_isbn(&self.client, isbn);

        let metadata_from_isbn_search =
            parser::extract_metadata_from_isbn_response(&isbn_search_response);

        let self_link = parser::extract_self_link_from_isbn_response(&isbn_search_response)?;
        let book_page = request::get_volume(&self.client, &self_link);

        let metadata_from_self_link_response =
            parser::extract_metadata_from_self_link_response(&book_page);

        Some(merge_bmd(
            metadata_from_isbn_search,
            metadata_from_self_link_response,
        ))
    }
}

#[cfg(test)]
mod tests {
    use crate::client::mock_client::MockClient;
    use crate::common::BookMetaDataFromProvider;
    use crate::common::Provider;

    use super::*;

    #[test]
    fn get_book_metadata_from_isbn_9782266162777() {
        let g = GoogleBooks {
            client: Box::new(MockClient {
                dir: "mock/google_books/normal_book",
            }),
        };
        let md = g.get_book_metadata_from_isbn("9782266162777");
        assert_eq!(md, Some(BookMetaDataFromProvider {
            title: Some("L'essence du Tao".to_owned()),
            authors: vec![common::Author{first_name: "".to_owned(), last_name: "Pamela Ball".to_owned()}],
            blurb: Some("Le Tao est moins une religion qu'un principe de vie universel, une recherche de la sagesse. C'est la \" Voie\" telle que les grands philosophes chinois, Lao Tse, Chuang Tse surtout, l'ont définie il y a plus de deux mille ans : une façon d'être; un ensemble de clés pour une existence harmonieuse et paisible. Pamela Bali nous aide à trouver le chemin qui est le nôtre par le biais de pratiques et de préceptes simples propres au Tao. Après en avoir brossé un bref historique, l'auteur développe les pratiques du Tao, son principe libérateur, évoquant aussi bien la méditation que le Li Chi, le Chi Cung, le Feng Shui ou art du placement, et l'interprétation du I Ching ou Livre des mutations. Un ouvrage clair, accessible et lumineux.".to_string()),
            keywords: vec![],
            market_price: vec![],
        }))
    }
}
