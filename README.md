# Reddit clone in Elm

## Setup

Tested with node `v8.x.x`.

Install build tool dependencies:

```
$ yarn
```

[Follow instructions on Elm documentation to install Elm tools.](https://guide.elm-lang.org/install.html)

Install Elm project dependencies:

```
$ elm-package install
```

## Running in dev mode

```
$ yarn start
```

Visit `http://localhost:8000/` from your browser of choice.
Server is visible from the local network as well.

## Build (production)

Build will be placed in the `build` folder.

```
$ yarn run build
```

## Running in preview production mode

This command will start webpack dev server, but with `NODE_ENV` set to `production`.
Everything will be minified and served.

```
yarn run preview
```
