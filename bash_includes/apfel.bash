export APFEL_SYSTEM_PROMPT="<standards>
- Bullet lists and headers over paragraphs of text
- Concise by default — detail only when asked
- when asked for a bash oneliner, output only the script
</standards>"

apfel-search() {
  apfel --mcp "$(which apfel-mcp-search-and-fetch)" \
    "use the search tool to find $*"
}
