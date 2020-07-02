import os
import strutils except replace
from times import cpuTime, parse, format
from algorithm import sort, sorted

import regex
from rainbow import rfTurquoise2, rfCyan3
import markdown

include "layout.html"
include "index.html"
include "post.html"

import types

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

func parseMetadata(s: string): Metadata =
  var
    index: int
    colonPos = s.find(':', index)
  while (colonPos) != -1:
    let key = s[index..<colonPos].strip
    let valueEnd = s.find('\n', colonPos)
    if valueEnd == -1:
      raise newException(ParseMetadataError, "Ending newline not found for "&key)
    let value = s[colonPos + 1 ..< valueEnd].strip
    case key
    of "tags":
      result.tags = value.split(", ").sorted
    else:
      raise newException(ParseMetadataError, "Unknown metadata key: "&key)
    index = valueEnd
    colonPos = s.find(':', index)

# Benchmarking #

# Reference:
# plain reading and writing to a single file - 300 us

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
    echo "Generating ", dest.rfCyan3()
    let fileInfo = splitFile(path)
    let markdown = markdown(readFile(path), config=initGfmConfig())
    let content = genLayoutHtml(fileInfo.name.humanize(), markdown)
    writeFile(dest, content)

  var posts: seq[Post]

  for kind, path in walkDir("posts", checkDir = true):
    if kind != pcFile: continue
    let
      fileInfo = splitFile(path)
      name = fileInfo.name & ".html"
      dest = "docs"/name
    echo "Generating ", dest.rfTurquoise2()
    var
      match: RegexMatch
    assert(fileInfo.name.find(datePattern, match), "Date must exist in file name")
    let parsedDate = match
      .groupFirstCapture("date", fileInfo.name)
      .parse("yyyy-MM-dd")
    let day = addOrdinalSuffix(parseInt(parsedDate.format("dd")))
    let formattedDate = day & parsedDate.format("' of 'MMMM', 'yyyy")
    let fileContent = readFile(path)
    var
      metadata: Metadata
      metadataEnd: int
    if fileContent.len > 3 and fileContent[0..2] == "---":
      metadataEnd = fileContent.find("---", 3)
      if metadataEnd == -1:
        raise newException(ParseMetadataError, "Closing --- not found for"&dest)
      metadata = parseMetadata(fileContent[3..<metadataEnd])
    if metadataEnd != 0: metadataEnd += 3 # move after ---
    # following operation takes 15-100 ms (!)
    let markdown = markdown(
      fileContent[metadataEnd ..< fileContent.len],
      config=initGfmConfig()
    )
    let post = Post(
      path: name,
      title: fileInfo.name.humanize(),
      date: formattedDate,
      content: markdown,
      metadata: metadata,
    )
    let postHtml = genPostHtml(post)
    writeFile(dest, genLayoutHtml(post.title, postHtml))
    posts.add post

  posts.sort do (x, y: Post) -> int:
    cmp(y.path, x.path) # Descending order, lexicographic sorting.

  echo "Generating ", "docs/index.html".rfCyan3()
  writeFile(
    "docs"/"index.html",
    genLayoutHtml("Home", genIndexHtml(posts))
  )

  echo "Finished in ", $(cpuTime() - t0), " seconds"

main()
