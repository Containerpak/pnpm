# pnpm (cpak)

pnpm 11.21.0 with a selectable Node.js runtime and a persistent content-addressable store.

```sh
cpak install github.com/containerpak/pnpm
```

The package exports `pnpm`, `node`, `npm`, `npx`, and `corepack`. Node.js 24.19.0 is available immediately. A different release can be selected with pnpm:

```sh
pnpm runtime set node lts -g
node --version
```

Selected runtimes and downloaded packages remain under `~/.local/share/cpak/pnpm`. The optional Native SDK add-on supplies compilers and build tools for packages with native modules.
