import path from 'path';
import fs from 'fs';
import markdown from 'markdown-it';
import cli from 'cli';
import chokidar from 'chokidar';
import logSymbols from 'log-symbols';
import clc from 'cli-color';
import hljs from 'highlight.js';
import markDownItSub from 'markdown-it-sub';
import markDownItSup from 'markdown-it-sup';
import markDownItInclude from 'markdown-it-include';
import markdownItTextualUml from 'markdown-it-textual-uml';
import pug from 'pug';

import markdownItMath from 'markdown-it-math';
import texzilla from 'texzilla';

import markdownItFrontMatter from '@gerhobbelt/markdown-it-front-matter';
import YAML from 'yaml';

const mathConf = {
    inlineOpen: '$',
    inlineClose: '$',
    blockOpen: '$$',
    blockClose: '$$',
    inlineRenderer: str => texzilla.toMathMLString(str),
    blockRenderer: str => texzilla.toMathMLString(str, true),
};

const md = new markdown({
    highlight: (str, lang) => {
        if (lang && hljs.getLanguage(lang)) {
            try {
                return hljs.highlight(str, { language: lang }).value;
            } catch (__) {}
        }

        return '';
    },
    typographer: false,
    html: true,
});

const template = pug.compileFile(
    path.resolve(path.dirname('index.js'), 'src/template.pug')
);

let fm = {};

md.use(markdownItMath, mathConf)
    .use(markDownItSub)
    .use(markDownItSup)
    .use(markDownItInclude)
    .use(markdownItTextualUml)
    .use(markdownItFrontMatter, {
        callback: str => {
            fm = YAML.parse(str);
        },
    });

let options = cli.parse({
    entry: ['e', 'Entry file.', 'file', 'markdown/main.md'],
    output: ['o', 'Output file.', 'file', 'markdown/out.html'],
    watch: ['w', 'Watch file for changes.', 'boolean'],
    title: ['t', 'Set title of the emitted html.', 'string', 'MarkDown'],
});

const watcher = chokidar.watch(options.entry, {
    persistent: true,
});

const run = () => {
    let text = fs.readFileSync(path.resolve(options.entry)).toString();

    let result = md.render(text);

    let htmlOut = template({
        title: fm.title ? fm.title : options.title,
        bodyMarkDown: result,
    });

    fs.writeFileSync(path.resolve(options.output), htmlOut);
};

if (options.watch === true) {
    process.stdout.write(clc.reset);

    run();

    console.log('Settings:');

    process.stdout.write(
        clc.columns([
            [clc.bold('  Input'), options.entry],
            [clc.bold(' Output'), options.output],
        ])
    );

    console.log('\nWatching for file changes...');

    watcher.on('change', path => {
        process.stdout.write(clc.move.up(1));
        process.stdout.write(clc.erase.line);

        console.log(`Recompiling ${path}...`);

        process.stdout.write(clc.move.up(1));
        process.stdout.write(clc.erase.line);
        run();

        console.log(`Recompiling ${clc.yellow(path)}... ${logSymbols.success}`);
    });
} else {
    run();
    console.log(
        `Compiled file ${clc.yellow(options.entry)} to ${clc.yellow(
            options.output
        )}`
    );
    watcher.close();
}
