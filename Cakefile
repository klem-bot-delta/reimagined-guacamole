fs = require 'fs'
pug = require 'pug'
esbuild = require 'esbuild'
coffee = require 'coffeescript'

task 'compile',
    'Compile CoffeeScript source.',
    -> 
    coffeeStr = fs.readFileSync('src/index.coffee').toString()
    jsStr = coffee.compile coffeeStr
    fs.writeFileSync 'src/index.js', jsStr

task 'build',
    'Compile Pug templates to JavaScript functions.',
    -> 
    fs.writeFileSync 'src/template.js',
        "#{pug.compileFileClient 'src/template.pug', name: 'pugTemplate'} export {pugTemplate}"

task 'pack',
    'Run esbuild bundler.',
    -> 
    invoke 'compile'
    invoke 'build'
    esbuild.build(
        entryPoints: ['src/index.js']
        bundle: yes
        outdir: 'dist'
        platform: 'node'
        minify: yes
    ).catch(=> process.exit 1)