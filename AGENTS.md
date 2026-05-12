# AGENTS.md

## Repository Type

Personal configuration backup repository (Atom editor settings). Not a typical software project.

## Key Directories

- `sync-settings-backup/` - Atom packages and settings backup
- `modvim-code/` - Various code example projects (each with own package.json)
- `tools/` - Node utilities with axios, cheerio dependencies
- `backup/` - Additional backup docs

## Code Projects

Each `modvim-code/*/` subdirectory is an independent Node/TypeScript project with its own `package.json`. Common patterns:
- TypeScript projects use `tsc` to build, `tslint` to lint
- `npm install` required before `npm run` in each project

## Notes

- Most markdown files are personal notes (学习日志.md, 魂游之哲学/, books/)
- `.un~` and `.un~` suffixed files appear to be backup/swap files
