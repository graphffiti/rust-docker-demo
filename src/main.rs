use actix_files::NamedFile;
use actix_web::{get, App, HttpServer, Responder};
use std::env;

#[get("/")]
async fn index() -> impl Responder {
    NamedFile::open_async("resources/static/index.html").await
}

#[actix_web::main] // or #[tokio::main]
async fn main() -> std::io::Result<()> {
    let port = env::var("PORT")
        .unwrap_or_else(|_| "3000".to_string())
        .parse()
        .expect("PORT must be a number");

    println!("Port: {}", port);

    HttpServer::new(|| App::new().service(index))
        .bind(("0.0.0.0", port))?
        .run()
        .await
}
