use crate::{cached_client::CachedClient, common};
mod parser;
mod request;

pub struct Babelio;

impl common::Provider for Babelio {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaData> {
        let client = reqwest::blocking::Client::builder().build().unwrap();
        let cached_client = CachedClient {
            http_client: client,
        };
        let book_url = request::get_book_url(&cached_client, isbn)?;
        let book_page = request::get_book_page(&cached_client, book_url);
        let blurb_res = parser::extract_blurb(&book_page);

        let raw_blurb = match blurb_res {
            parser::BlurbRes::SmallBlurb(blurb) => blurb,
            parser::BlurbRes::BigBlurb(id_obj) => {
                request::get_book_blurb_see_more(&cached_client, &id_obj)
            }
        };

        let mut res = parser::extract_title_author_keywords(&book_page);
        res.blurb = parser::parse_blurb(&raw_blurb);
        Some(res)
    }
}

#[cfg(test)]
mod tests {
    use crate::common::{Author, BookMetaData, Provider};

    use super::*;

    #[test]
    fn get_metadata_from_normal_book() {
        let isbn = "9782266071529";
        let md = Babelio {}.get_book_metadata_from_isbn(isbn);
        assert_eq!(md, Some(BookMetaData {
            title: "Le nom de la bête".to_string(),
            authors: vec![Author{first_name:"Daniel".to_string(), last_name: "Easterman".to_string()}],
            blurb: Some("Janvier 1999. Peu à peu, les pays arabes ont sombré dans l'intégrisme. Les attentats terroristes se multiplient en Europe attisant la haine et le racisme. Au Caire, un coup d'état fomenté par les fondamentalistes permet à leur chef Al-Kourtoubi de s'installer au pouvoir et d'instaurer la terreur. Le réseau des agents secrets britanniques en Égypte ayant été anéanti, Michael Hunt est obligé de reprendre du service pour enquêter sur place. Aidé par son frère Paul, prêtre catholique et agent du Vatican, il apprend que le Pape doit se rendre à Jérusalem pour participer à une conférence œcuménique. Au courant de ce projet, le chef des fondamentalistes a prévu d'enlever le saint père.Dans ce récit efficace et à l'action soutenue, le héros lutte presque seul contre des groupes fanatiques puissants et sans grand espoir de réussir. Comme dans tous ses autres livres, Daniel Easterman, spécialiste de l'islam, part du constat que le Mal est puissant et il dénonce l'intolérance et les nationalismes qui engendrent violence et chaos.--Claude Mesplède\n".to_string()),
            keywords:
                [
                    "roman",
                    "fantastique",
                    "policier historique",
                    "romans policiers et polars",
                    "thriller",
                    "terreur",
                    "action",
                    "démocratie",
                    "mystique",
                    "islam",
                    "intégrisme religieux",
                    "catholicisme",
                    "religion",
                    "terrorisme",
                    "extrémisme",
                    "egypte",
                    "médias",
                    "thriller religieux",
                    "littérature irlandaise",
                    "irlande"
                ]
                .map(|s| s.to_string())
                .to_vec(),
        }));
    }

    #[test]
    fn get_metadata_from_book_with_see_more_bug() {
        let isbn = "9782070541898";
        let md = Babelio {}.get_book_metadata_from_isbn(isbn);
        assert_eq!(md, Some(BookMetaData {
            title: "À la croisée des mondes, tome 2 : La tour des anges".to_string(),
            authors: vec![Author{first_name:"Philip".to_string(), last_name: "Pullman".to_string()}],
            blurb: Some(r#"Le jeune Will, à la recherche de son père disparu depuis de longues années, est persuadé d’avoir tué un homme. Dans sa fuite, il franchit une brèche presque invisible qui lui permet de passer dans un monde parallèle. 
Là, à Cittàgazze, la ville au-delà de l’Aurore, il rencontre Lyra, l’héroïne des "Royaumes du Nord". Elle aussi cherche à rejoindre son père, elle aussi est investie d’une mission dont elle ne connaît pas encore toute l’importance. 
Ensemble, les deux enfants devront lutter contre les forces obscures du mal et, pour accomplir leur quête, pénétrer dans la mystérieuse tour des Anges…
"#.to_string()),
            keywords:
                [
                    "aventure", "saga", "roman", "fantasy", "fantastique", "littérature jeunesse", "jeunesse", "steampunk", "littérature pour adolescents", "enfants", "magie", "amitié", "enfance", "science-fiction", "univers parallèles", "religion", "adolescence", "littérature anglaise", "littérature britannique", "20ème siècle",
                ]
                .map(|s| s.to_string())
                .to_vec(),
        }));
    }
}
