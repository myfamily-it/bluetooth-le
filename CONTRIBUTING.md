# Contributing

This guide provides instructions for contributing to this Capacitor plugin.

## Developing

### Local Setup

1. Fork and clone the repo.
1. Install the dependencies.

   ```shell
   npm install
   ```

1. Install SwiftLint if you're on macOS.

   ```shell
   brew install swiftlint
   ```

### Scripts

#### `npm run build`

Build the plugin web assets and generate plugin API documentation using [`@capacitor/docgen`](https://github.com/ionic-team/capacitor-docgen).

It will compile the TypeScript code from `src/` into ESM JavaScript in `dist/esm/`. These files are used in apps with bundlers when your plugin is imported.

Then, Rollup will bundle the code into a single file at `dist/plugin.js`. This file is used in apps without bundlers by including it as a script in `index.html`.

#### `npm run verify`

Build and validate the web and native projects.

This is useful to run in CI to verify that the plugin builds for all platforms.

#### `npm run lint` / `npm run fmt`

Check formatting and code quality, autoformat/autofix if possible.

This template is integrated with ESLint, Prettier, and SwiftLint. Using these tools is completely optional, but the [Capacitor Community](https://github.com/capacitor-community/) strives to have consistent code style and structure for easier cooperation.

## Publishing

1. Run `linting`
   ```bash
   npm run lint
   # if there are linting errors
   npm run fmt
   ```
1. Update `usage` in README if necessary
1. Merge to main
1. Create a new version
   ```bash
   npm run release
   # or
   npm run release:minor
   # or
   npm run release:major
   # add -- -p to any for a prerelease

   # or for a development release
   npm run version:dev
   ```
1. Check `CHANGELOG.md` (which is auto-generated)
1. Publish

   There is a `prepublishOnly` hook in `package.json` which prepares the plugin before publishing, so all you need to do is run:

   ```bash
   npm publish
   # or for a prerelease
   npm publish --tag next
   # or for a development release
   npm run publish:dev
   ```
1. Push git tag
   ```
   git push --follow-tags origin main
   ```

> **Note**: The [`files`](https://docs.npmjs.com/cli/v7/configuring-npm/package-json#files) array in `package.json` specifies which files get published. If you rename files/directories or add files elsewhere, you may need to update it.
