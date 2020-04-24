import os, times, algorithm
import strutils except replace
import regex
import rainbow

import markdown

include "layout.html"
include "index.html"

type
  Post = tuple[path, title, date: string]

const datePattern = re"(?P<date>\d\d\d\d-\d\d-\d\d)"

func humanize(str: string): string =
  str
    .replace(datePattern, "")
    .strip(chars = Whitespace + { '_', '-' })
    .multiReplace(("_", " "), ("-", " "))
    .capitalizeAscii()

proc genPageHtml(path: string): string =
  let fileInfo = splitFile(path)
  genLayoutHtml(fileInfo.name.humanize, readFile(path))

proc genPostHtml(path: string): string =
  let fileInfo = splitFile(path)
  genLayoutHtml(fileInfo.name.humanize, markdown(readFile(path)))

proc main =
  ## Requires the following structure in the current folder:
  ## * pages/
  ##   * page1.html
  ##   * page2.html
  ## * posts/
  ##   * yyyy-mm-dd-post1.md
  ##   * yyyy-mm-dd-post2.md
  ##
  ## There will be an index.html page generated with all the posts and any
  ## additional pages in the pages/ directory.

  var t0 = cpuTime()

  for kind, path in walkDir("pages", checkDir = true):
    if kind != pcFile: continue
    let filename = extractFilename(path)
    let dest = "docs"/filename
    writeFile(dest, genPageHtml(path))
    echo "Generated ", dest.rfCyan3

  var posts: seq[Post]

  for kind, path in walkDir("posts", checkDir = true):
    if kind != pcFile: continue
    let
      fileInfo = splitFile(path)
      name = fileInfo.name & ".html"
      dest = "docs"/name
    var
      match: RegexMatch
    assert(fileInfo.name.find(datePattern, match), "Date must exist in file name")
    writeFile(dest, genPostHtml(path))
    posts.add(
      (name,
       fileInfo.name.humanize,
       match.groupFirstCapture("date", fileInfo.name)
      )
    )
    echo "Generated ", dest.rfTurquoise2

  posts.sort do (x, y: Post) -> int:
    cmp(y.date, x.date) # Descending order.

  writeFile(
    "docs"/"index.html",
    genLayoutHtml("Home", genIndexHtml(posts))
  )

  echo "Finished in ", $(cpuTime() - t0), " seconds"

main()
