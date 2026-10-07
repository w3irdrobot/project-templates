use std::io::{self, Write};

use anyhow::Result;
use clap::Parser;
use tracing::debug;
use tracing_subscriber::EnvFilter;

#[derive(Debug, Parser)]
#[command(version, about)]
struct Args {
    /// Name to greet.
    #[arg(default_value = "world")]
    name: String,
}

{% if async %}#[tokio::main]
async {% endif %}fn main() -> Result<()> {
    let args = Args::parse();
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .with_writer(io::stderr)
        .init();

    debug!(?args, "parsed CLI arguments");
    writeln!(io::stdout().lock(), "Hello, {}!", args.name)?;

    Ok(())
}
