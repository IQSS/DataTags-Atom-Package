{View ,TextEditorView} = require 'atom-space-pen-views'
path = require 'path'
{BufferedProcess, Point} = require 'atom'

module.exports =
class ConsoleView
  CLI= null

  constructor: (symbol_indexer) ->
    @SymbolIndexer= symbol_indexer
    @root = document.createElement('div')

    @console = document.createElement('textarea')
    @console.classList.add('console-view')
    @console.setAttribute('id','console')
    @console.readOnly=true
    @root.appendChild(@console)

    header = document.createElement('div')
    header.textContent = "Type your answer:"
    @root.appendChild(header)

    @CreateCLIProcess()
    @editor = document.createElement('atom-text-editor')
    @editor.setAttribute('mini',true)
    @root.appendChild(@editor)

    @editor.addEventListener 'keydown', @InsertTextToConsole

    @Panel=atom.workspace.addBottomPanel({item: @root , visible: true})

  CreateCLIProcess: ->
    command ="java"
    jar_path = path.resolve(__dirname, '..', 'cli', 'DataTagsLib.jar')
    args=['-jar',jar_path,@SymbolIndexer.TagSpacePath,@SymbolIndexer.DesicionGraphPath]


    stderr = (lines) -> console.log lines
    exit = (code) -> console.log("The process exited with code: #{code}")
    process = new BufferedProcess({command, args,stderr,exit})
    CLI = process.process
    CLI.stdin.setEncoding('utf8')
    CLI.stdout.on('data' , (data) ->
      console_element = document.getElementById('console')
      console_element.textContent+= data
      console_element.scrollTop = console_element.scrollHeight
    )

  InsertTextToConsole: (event) ->
    if event.keyCode == 13 #enter ==13
      text = event.target.model.getText()+'\n'
      event.target.model.setText("")
      console_element = document.getElementById('console')
      console_element.textContent  += text
      console_element.scrollTop = console_element.scrollHeight
      CLI.stdin.write(text)

  destroy: ->
    @Panel.hide()
    CLI.kill()
    @root.remove()
    @editor.remove()
    @console.remove()
    @Panel.destroy()