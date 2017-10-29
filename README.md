# Reddit clone in Elm

## Setup

Tested with node `v8.x.x`.

```
$ yarn
```

## Running in dev mode

```
$ yarn start
```

Visit `http://localhost:3000/` from your browser of choice.
Server is visible from the local network as well.

## Build (production)

Build will be placed in the `build` folder.

```
$ yarn run build
```

## Running in preview production mode

This command will start webpack dev server, but with `NODE_ENV` set to `production`.
Everything will be minified and served.
Hot reload will not work, so you need to refresh the page manually after changing the code.

```
yarn run preview
```

## Linting

For linting I'm using [eslint-config-airbnb](https://www.yarnjs.com/package/eslint-config-airbnb),
but some options are overridden to my personal preferences.

```
$ yarn run lint
```
