# Liz Wine Studio Promotion Status

Last updated: 2026-05-12.

## Current Decision

`D:/Projects/liz-wine-studio` remains a staging project.

It is code-like because it has `package.json`, but the current copy is incomplete as a runtime app: `package.json` points to `server/src/app.js`, while this copy only contains docs and `server/db/schema.sql`.

## Completed

- Confirmed the project copy and legacy source copy match by relative SHA256 file hashes.
- Confirmed neither the project copy nor the legacy source copy has a recovered `.git` directory.
- Confirmed no runtime old path references are present; remaining old path mentions are documentation/migration notes.
- Added `.gitignore` to keep local `.env`, TLS/certificate material, dependencies, logs, and runtime DB files out of git.
- Added `.env.example` from documented placeholder values, without reading the real `.env`.

## Sensitive Local Files

The project contains local environment and TLS/certificate material. These files were not read and must not be committed:

- `.env`
- `ssl/`

Review and rotate certificate/private-key material outside this cleanup if this project is revived or deployed.

## Remaining Gates

- Decide whether this is an active app, a planning archive, or a superseded concept.
- Recover or rebuild missing runtime source files before any smoke test.
- Decide whether the local git snapshot should stay local-only or be connected to a remote.
- Keep the legacy source path until Robin approves retirement or junction protection.
