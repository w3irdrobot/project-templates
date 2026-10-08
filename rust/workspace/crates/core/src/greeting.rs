use thiserror::Error;

#[derive(Debug, Error, PartialEq, Eq)]
pub enum GreetingError {
    #[error("name must not be empty")]
    EmptyName,
}

/// Create a greeting, rejecting empty or whitespace-only names.
pub fn greet(name: &str) -> Result<String, GreetingError> {
    let name = name.trim();
    if name.is_empty() {
        return Err(GreetingError::EmptyName);
    }

    Ok(format!("Hello, {name}!"))
}

#[cfg(test)]
mod tests {
    use super::{GreetingError, greet};

    #[test]
    fn rejects_blank_names() {
        for name in ["", " ", "\t\n", "\u{2003}"] {
            assert_eq!(greet(name), Err(GreetingError::EmptyName));
        }
    }
}
