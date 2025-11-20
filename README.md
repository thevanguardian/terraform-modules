# terraform-modules

Shared Terraform modules for ephemeral infrastructure primitives.

## Pre-commit hooks

This repository expects contributors to run Terraform formatters and terraform-docs before committing. Install the hooks once and run them as needed:

```bash
pip install pre-commit
pre-commit install

# optional: run against entire repo to verify
pre-commit run --all-files
```

The hooks perform:
- `terraform fmt` on each directory that has staged `.tf` changes.
- `terraform-docs markdown --output-file README.md --output-mode inject --output-values .` for each module with staged Terraform or README updates.

If a hook rewrites files, re-add them (`git add ...`) and rerun until it passes.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->