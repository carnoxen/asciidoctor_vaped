document.querySelectorAll('pre.highlight > code[data-lang]').forEach((code) => {
  const callouts = [...code.querySelectorAll('.conum')].map((mark, index) => {
    const range = document.createRange()
    range.setStart(code, 0)
    range.setEndBefore(mark)
    const callout = { position: range.toString().length, value: mark.textContent, index }
    mark.remove()
    return callout
  })
  hljs.highlightElement(code)
  callouts.sort((left, right) => right.position - left.position || right.index - left.index).forEach((callout) => {
    const walker = document.createTreeWalker(code, NodeFilter.SHOW_TEXT)
    let node, position = 0
    while ((node = walker.nextNode())) {
      if (callout.position <= position + node.length) {
        const tail = node.splitText(callout.position - position)
        const mark = Object.assign(document.createElement('i'), { className: 'conum', textContent: callout.value })
        tail.before(mark)
        break
      }
      position += node.length
    }
  })
})
