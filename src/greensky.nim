import os
import strutils except replace
import regex

import markdown

include "layout.html"
include "index.html"

const datePattern = re"(?P<date>\d\d\d\d-\d\d-\d\d)"

func humanize(str: string): string =
  str
    .replace(datePattern, "")
    .strip(chars = Whitespace + { '_', '-' })
    .multiReplace(("_", " "), ("-", " "))
    .capitalizeAscii()

proc genPage(path: string): string =
  let fileInfo = splitFile(path)
  genLayoutHtml(fileInfo.name.humanize, readFile(path))

proc genPost(path: string): string =
  let fileInfo = splitFile(path)
  genLayoutHtml(fileInfo.name.humanize, markdown(readFile(path)))

proc main =
  ## Requires the following structure in the current folder:
  ## * pages/
  ##   * page1.html
  ##   * page2.html
  ## * posts/
  ##   * post1.md
  ##   * post2.md
  ##
  ## There will be an index.html page generated with all the posts and any
  ## additional pages in the pages/ directory.

  for kind, path in walkDir("pages", checkDir = true):
    if kind != pcFile: continue
    let filename = extractFilename(path)
    let dest = "docs"/filename
    writeFile(dest, genPage(path))
    echo "Generated ", dest

  var posts: seq[tuple[path, title, date: string]]
  for kind, path in walkDir("posts", checkDir = true):
    if kind != pcFile: continue
    let
      fileInfo = splitFile(path)
      name = fileInfo.name & ".html"
      dest = "docs"/name
    var
      match: RegexMatch
    assert(fileInfo.name.find(datePattern, match), "Date must exist in file name")
    writeFile(dest, genPost(path))
    posts.add(
      (name,
       fileInfo.name.humanize,
       match.groupFirstCapture("date", fileInfo.name)
      )
    )
    echo "Generated ", dest

  writeFile(
    "docs"/"index.html",
    genLayoutHtml("Home", genIndexHtml(posts))
  )

main()
