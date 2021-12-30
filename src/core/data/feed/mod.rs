pub mod atom;
pub mod rss;
use quick_xml::de::from_str;

use crate::core::data::video::builder::VideoBuilder;

#[derive(Default)]
pub(crate) struct Feed {
    pub(crate) name: String,
    pub(crate) videos: Vec<VideoBuilder>,
}

impl Feed {
    pub fn parse_text(feed: String) -> Result<Self, String> {
        // try to parse as atom
        match from_str::<atom::Feed>(&feed) {
            Ok(feed) => return Ok(feed.into()),
            Err(_) => (),
        };

        // try to parse as rss
        match from_str::<rss::Feed>(&feed) {
            Ok(feed) => return Ok(feed.into()),
            Err(_) => (),
        }

        Err(String::from("Could not parse feed"))
    }

    pub fn add_videos(&mut self, videos: Vec<VideoBuilder>) {
        for video in videos.into_iter() {
            if !self.videos.iter().any(|v| v == &video) {
                self.videos.push(video);
            }
        }
    }

    pub fn set_name(&mut self, name: &String) {
        self.name = name.clone();
    }
}

impl From<rss::Feed> for Feed {
    fn from(rss_feed: rss::Feed) -> Self {
        let feed = rss_feed.channel;

        let name = feed.name;
        /* let id = feed.link; */

        let videos = feed
            .videos
            .into_iter()
            .map(|rss_vid| VideoBuilder::from(rss_vid))
            .collect();

        // Feed { name, id, videos }
        Feed { name, videos }
    }
}

impl From<atom::Feed> for Feed {
    fn from(feed: atom::Feed) -> Self {
        let name = feed.name;
        /* let id = format!("https://www.youtube.com/channel/{}", feed.channel_id); */

        let videos = feed
            .videos
            .into_iter()
            .map(|atom_vid| VideoBuilder::from(atom_vid))
            .collect();

        // Feed { name, id, videos }
        Feed { name, videos }
    }
}
