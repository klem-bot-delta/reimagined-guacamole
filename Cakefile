fs = require 'fs'
path = require 'path'
pug = require 'pug'
esbuild = require 'esbuild'
coffee = require 'coffeescript'
uglifycss = require 'uglifycss'


task 'compile',
    'Compile CoffeeScript source.',
    -> 
    coffeeStr = fs.readFileSync('src/index.coffee').toString()
    jsStr = coffee.compile coffeeStr
    fs.writeFileSync 'src/index.js', jsStr


task 'templates',
    'Compile Pug templates to JavaScript functions.',
    -> 
    fs.writeFileSync 'src/template.js',
        "#{pug.compileFileClient 'src/template.pug', name: 'pugTemplate'} export {pugTemplate}"


task 'styles',
    'Wrap stylesheets in JS.',
    ->
    stylesheets =
        github: uglifycss.processFiles ['./node_modules/github-markdown-css/github-markdown.css']
        modest: uglifycss.processFiles ['src/styles/modest.css']
    
    jsStr = "export const stylesheets = #{JSON.stringify stylesheets};"
    fs.writeFileSync 'src/styles.js', jsStr


task 'pack',
    'Run esbuild bundler.',
    -> 
    invoke 'compile'
    invoke 'templates'
    esbuild.build(
        entryPoints: ['src/index.js']
        bundle: yes
        outdir: 'dist'
        platform: 'node'
        minify: yes
    ).catch(=> process.exit 1)