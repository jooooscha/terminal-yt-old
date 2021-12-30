use std::process::{Command, Output};

pub fn notify_link(msg: &str) -> Output {
    send(&String::from("Title"), msg)
}

pub fn notify_open(video_title: &str) -> Output {
    send(&String::from("Video Opening"), video_title)
}

fn send(title: &str, msg: &str) -> Output {
    // Command::new("notify-send").arg(title).arg(msg).output().expect("failed")
    Command::new("dunstify").arg(title).arg(msg).output().expect("failed")
}
    
