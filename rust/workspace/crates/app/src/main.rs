use std::io::{self, Write};

use anyhow::{Context, Result};
use clap::Parser;
use tracing::debug;
use tracing_subscriber::EnvFilter;
use {{crate_name}}_core::greet;

mod cli;

use crate::cli::Args;

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
    let greeting = greet(&args.name).context("could not create greeting")?;
    writeln!(io::stdout().lock(), "{greeting}").context("could not write greeting")?;

    Ok(())
}
