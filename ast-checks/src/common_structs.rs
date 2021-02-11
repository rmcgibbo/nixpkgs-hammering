use codespan::{ByteIndex, FileId, Files};
use serde::{Deserialize, Serialize};
use std::error::Error;

#[derive(Serialize, Deserialize, Debug)]
pub struct SourceLocation {
    pub column: usize,
    pub line: usize,
    pub file: String,
}

impl SourceLocation {
    pub fn from_byte_index(
        files: &Files<String>,
        file_id: FileId,
        byte_index: impl Into<ByteIndex>,
    ) -> Result<SourceLocation, Box<dyn Error>> {
        let loc = files.location(file_id, byte_index)?;

        Ok(SourceLocation {
            file: files
                .name(file_id)
                .to_str()
                .ok_or("encoding error")?
                .to_string(),
            // Convert 0-based indexing to 1-based.
            column: loc.column.to_usize() + 1,
            line: loc.line.to_usize() + 1,
        })
    }
}

#[derive(Serialize, Deserialize, Debug)]
pub struct NixpkgsHammerMessage {
    name: String,
    msg: String,
    locations: Vec<SourceLocation>,
    link: bool,
}

impl NixpkgsHammerMessage {
    pub fn new<S>(name: S, msg: S, locations: Vec<SourceLocation>) -> NixpkgsHammerMessage
    where
        S: Into<String>,
    {
        NixpkgsHammerMessage {
            name: name.into(),
            msg: msg.into(),
            locations: locations,
            link: true,
        }
    }

    /// Add an argument to pass to the program.
    pub fn with_link(&mut self, link: bool) -> &mut NixpkgsHammerMessage {
        self.link = link;
        self
    }
}
