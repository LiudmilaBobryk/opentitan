// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use anyhow::{Context, Result};
use clap::{Args, Subcommand, ValueEnum};
use serde_annotate::Annotate;
use std::any::Any;
use std::fs;
use std::path::PathBuf;

use opentitanlib::app::command::CommandDispatch;
use opentitanlib::app::TransportWrapper;
use ot_certs::{template, x509};

/// Commands for interacting with certificates.
#[derive(Debug, Subcommand, CommandDispatch)]
pub enum CertificateCommand {
    /// Generate a certificate template.
    GenTemplate(GenTplCommand),
}

/// Generate a certificate template.
#[derive(Clone, Debug, ValueEnum)]
pub enum CertFormat {
    X509,
}

/// Generate a certificate template.
#[derive(Debug, Args)]
pub struct GenTplCommand {
    /// Filename of the template.
    template: PathBuf,
    /// Certificate format
    #[arg(long, value_enum, default_value_t = CertFormat::X509)]
    cert_format: CertFormat,
    /// Output directory path.
    output_dir: PathBuf,
}

impl CommandDispatch for GenTplCommand {
    fn run(
        &self,
        _context: &dyn Any,
        _transport: &TransportWrapper,
    ) -> Result<Option<Box<dyn Annotate>>> {
        let template_content = fs::read_to_string(&self.template).with_context(|| {
            format!(
                "Could not load the template file {}",
                self.template.display()
            )
        })?;
        let template =
            template::Template::from_hjson_str(&template_content).with_context(|| {
                format!("Failed to parse template file {}", self.template.display())
            })?;
        // NOTE for now do not clear the fields as this prevents openssl from parsing
        // the certificate which is useful for debugging.
        let x509 = x509::generate_certificate(&template, false)?;
        // Warn about unused variables.
        for var in &x509.variables {
            if var.offsets.is_empty() {
                log::warn!("Variable '{}' is not used by the certificate", var.name);
            }
        }
        let output_x509 = self.output_dir.join(format!("{}.pem", &template.name));
        /* Generate pem certificate for debugging and inspection */
        fs::write(output_x509, &x509.cert)?;
        Ok(Some(Box::new(x509)))
    }
}
