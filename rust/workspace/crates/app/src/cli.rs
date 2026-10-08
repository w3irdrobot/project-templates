use clap::Parser;

#[derive(Debug, Parser)]
#[command(version, about)]
pub(crate) struct Args {
    /// Name to greet.
    #[arg(default_value = "world")]
    pub(crate) name: String,
}
