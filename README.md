# A tool to compile MarkDown

Essentially just [markdown-it](https://github.com/markdown-it/markdown-it) with a few addons for maths and graphs.
___ 

## Building

```sh
yarn build
```

## Usage

```sh
node ./dist/index.js
```

___

<br>

**TODO:**

- [ ] Add `--js` option & by default remove JS from output.
- [ ] Add option for custom CSS stylesheet inclusion in file header.
- [ ] Setup preprocessing of file for later feature additions.
- [ ] Replace **TexZilla** with **MathJax** or add option to use the latter.
- [ ] Get the project to compile down to a binary.
- [ ] Add support for encoding images as base64.
- [ ] Fix project structure, license & attributions.
- [ ] Build out an API.
- [ ] Add support for config files *(for larger projects)*.
- [ ] Add the option to change code block themes.
- [ ] Write usage examples.
- [ ] Add linebreak macro.
- [ ] Add custom layout components.
