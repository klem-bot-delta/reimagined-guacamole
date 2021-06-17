#region Imports
import path from 'path'
import fs from 'fs'
import markdown from 'markdown-it'
import cli from 'cli'
import chokidar from 'chokidar'
import logSymbols from 'log-symbols'
import clc from 'cli-color'
import hljs from 'highlight.js'
import markDownItSub from 'markdown-it-sub'
import markDownItSup from 'markdown-it-sup'
import markDownItInclude from 'markdown-it-include'
import markdownItTextualUml from 'markdown-it-textual-uml'

import markdownItMath from 'markdown-it-math'
import texzilla from 'texzilla'

import markdownItFrontMatter from '../node_modules/@gerhobbelt/markdown-it-front-matter/dist/markdownitFrontMatter.js'
import YAML from 'yaml'

import { pugTemplate } from './template.js';
#endregion

mathConf =
  inlineOpen: '$'
  inlineClose: '$'
  blockOpen: '$$'
  blockClose: '$$'
  inlineRenderer: (str) ->
    texzilla.toMathMLString str
  blockRenderer: (str) ->
    texzilla.toMathMLString str, true

md = new markdown {
  highlight: (str, lang) ->
    if lang and hljs.getLanguage(lang)
      try
        return hljs.highlight(str, language: lang).value
      catch __
    ''
  
  typographer: false
  
  html: true
}

template = pugTemplate


fm = {}

run = ->
  text = fs.readFileSync( path.resolve options.entry ).toString()
  result = md.render text
  htmlOut = template(
    title: if fm.title then fm.title else options.title
    bodyMarkDown: result)
  fs.writeFileSync path.resolve(options.output), htmlOut
  return

md.use markdownItMath, mathConf
    .use markDownItSub
    .use markDownItSup
    .use markDownItInclude
    .use markdownItTextualUml
    .use markdownItFrontMatter, callback: (str) -> fm = YAML.parse str


options = cli.parse {
  entry: [
    'e'
    'Entry file.'
    'file'
    'main.md'
  ]
  output: [
    'o'
    'Output file.'
    'file'
    'out.html'
  ]
  watch: [
    'w'
    'Watch file for changes.'
    'boolean'
    false
  ]
  title: [
    't'
    'Set title of the emitted html.'
    'string'
    'MarkDown'
  ]
}


watcher = chokidar.watch options.entry, persistent: true


if options.watch == true
  process.stdout.write clc.reset

  run()
  
  console.log 'Settings:'
  
  process.stdout.write clc.columns [
    [
      clc.bold '  Input'
      options.entry
    ]
    [
      clc.bold ' Output'
      options.output
    ]
  ]

  console.log "\nWatching for file changes..."
  
  watcher.on "change", (path) ->
    process.stdout.write clc.move.up 1
    process.stdout.write clc.erase.line
    
    console.log "Recompiling #{path}..."

    process.stdout.write clc.move.up 1
    process.stdout.write clc.erase.line

    run()

    console.log "Recompiling #{clc.yellow path}... #{logSymbols.success}"
    
    return
else
  run()

  console.log "Compiled file #{clc.yellow options.entry} to #{clc.yellow options.output}"

  watcher.close()
