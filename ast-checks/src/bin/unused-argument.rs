use codespan::{FileId, Files};
use nixpkgs_hammering_ast_checks::analysis::*;
use nixpkgs_hammering_ast_checks::common_structs::*;
use nixpkgs_hammering_ast_checks::tree_utils::walk_kind;
use rnix::types::*;
use rnix::SyntaxKind::*;
use std::{env, error::Error};

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().skip(1).collect();
    println!("{}", analyze_files(args, analyze_single_file)?);
    Ok(())
}

fn analyze_single_file(files: &Files<String>, file_id: FileId) -> Result<Report, Box<dyn Error>> {
    let root = find_root(files, file_id)?;
    let mut report: Report = vec![];

    for lambda_elem in walk_kind(&root, NODE_LAMBDA) {
        let lambda = lambda_elem.into_node().and_then(Lambda::cast);

        let body = lambda
            .clone()
            .and_then(|l| l.body())
            .ok_or("Unable to extract function body")?;
        let identifiers_in_body: Vec<Ident> = walk_kind(&body, NODE_IDENT)
            .filter_map(|elem| elem.into_node())
            .filter_map(Ident::cast)
            .collect();

        // Extract the formal parameters from pattern-type functions, and don't
        // extract anything from single-argument functions because they often
        // need to have unused arguments for overlay-type constructs.
        let pattern = lambda.and_then(|l| l.arg()).and_then(Pattern::cast);
        let formal_parameter_pattern_args = match pattern {
            Some(pattern) => pattern.entries().filter_map(|entry| entry.name()).collect(),
            None => vec![],
        };

        let unused_formal_parameters = formal_parameter_pattern_args
            .iter()            
            // Don't consider parameters that appear as identifiers in the function
            // body
            .filter(|formal| {
                !identifiers_in_body
                    .iter()
                    .any(|ident| ident.as_str() == formal.as_str())
            });

        for unused in unused_formal_parameters {
            let start = unused.node().text_range().start().to_usize() as u32;
            report.push(NixpkgsHammerMessage {
                msg: format!("Unused argument: `{}`.", unused.node()),
                name: "unused-argument",
                locations: vec![SourceLocation::from_byte_index(files, file_id, start)?],
                link: false,
            });
        }
    }

    Ok(report)
}
