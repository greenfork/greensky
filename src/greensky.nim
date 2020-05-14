import os
import strutils except replace
from times import cpuTime, parse, format
from algorithm import sort

import regex
from rainbow import rfTurquoise2, rfCyan3
import markdown

include "layout.html"
include "index.html"
include "post.html"

type
  Post = tuple[path, title, date, content: string]
    ## representation of markdown file

const datePattern = re"(?P<date>\d\d\d\d-\d\d-\d\d)"

func humanize(str: string): string =
  str
    .replace(datePattern, "")
    .strip(chars = Whitespace + { '_', '-' })
    .multiReplace(("_", " "), ("-", " "), ("+", "&nbsp;"))
    .capitalizeAscii()

func addOrdinalSuffix(n: int): string =
  let
    lastDigit = n mod 10
    lastTwoDigits = n mod 100
  if lastDigit == 1 and lastTwoDigits != 11: $n & "st"
  elif lastDigit == 2 and lastTwoDigits != 12: $n & "nd"
  elif lastDigit == 3 and lastTwoDigits != 13: $n & "rd"
  else: $n & "th"

# Benchmarking #

# References:
# plain reading and writing to a file - 300 us

# Testing with 1 file
# no markdown processing - 850 us
# with markdown processing - 16 ms

# Testing with 9k files
# with markdown with output - 216 s
# with markdown no output - 222 s
# no markdown no output - 1.45 s
# no markdown with output - 1.71 s

proc main() =
  ## Requires the following structure in the current folder:
  ## * pages/
  ##   * page1.html
  ##   * page2.html
  ## * posts/
  ##   * yyyy-mm-dd-my-interesting-title.md
  ##   * yyyy-mm-dd-my-title,-part+2.md
  ##
  ## There will be an index.html page generated with all the posts and any
  ## additional pages in the pages/ directory.
  ##
  ## Post date and title
  ##
  ## Title and date are both derived from the file name. Date is obviously
  ## in the yyyy-mm-dd format. Everything that follows is converted to title
  ## with the following rules:
  ##   - Dashes `-` are converted to spaces
  ##   - Plus signs `+` are converted to non-breakable spaces
  ##   - First letter of a title is capitalized

  let t0 = cpuTime()

  for kind, path in walkDir("pages", checkDir = true):
    if kind != pcFile: continue
    let filename = extractFilename(path)
    let dest = "docs"/filename
    let fileInfo = splitFile(path)
    let markdown = markdown(readFile(path), config=initGfmConfig())
    let content = genLayoutHtml(fileInfo.name.humanize(), markdown)
    writeFile(dest, content)
    echo "Generated ", dest.rfCyan3()

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
    let parsedDate = match
      .groupFirstCapture("date", fileInfo.name)
      .parse("yyyy-MM-dd")
    let day = addOrdinalSuffix(parseInt(parsedDate.format("dd")))
    let formattedDate = day & parsedDate.format("' of 'MMMM', 'yyyy")
    # following operation takes 15-100 ms (!)
    let markdown = markdown(readFile(path), config=initGfmConfig())
    let post = (
      path: name,
      title: fileInfo.name.humanize(),
      date: formattedDate,
      content: markdown,
    )
    let postHtml = genPostHtml(post)
    writeFile(dest, genLayoutHtml(post.title, postHtml))
    posts.add post
    echo "Generated ", dest.rfTurquoise2()

  posts.sort do (x, y: Post) -> int:
    cmp(y.path, x.path) # Descending order, lexicographic sorting.

  writeFile(
    "docs"/"index.html",
    genLayoutHtml("Home", genIndexHtml(posts))
  )
  echo "Generated ", "docs/index.html".rfCyan3()

  echo "Finished in ", $(cpuTime() - t0), " seconds"

main()
