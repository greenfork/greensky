---
title: How to write a blog, part 3
tags: Nim, programming
---

Let's glue what we had in [part 2](2020-05-10-how-to-write-a-blog,-part+2.html)!
"Glueing" is generally "connecting" the core parts so they all work together.

So far we need to assemble together:
* HTML templates
* CSS styles
* Markdown files

It goes like this:
* Markdown `->` HTML via external library
* CSS styles go in HTML templates via `link` tag
* HTML template + HTML `->` Complete html page via the magic of programming

So what do we need to glue? Just one thing, really:
1. List all existing posts in a blog a.k.a. *Table of Content* or *Index*

As far as we are not too ambitious, we can get away with pretty basic
modifications and complexity.

## List all posts
So let's just list all of them. Below is a complete and minimal example
of all the necessary files.

`life-of-a-boomer.md`:

```md
## Day 1
*sip* Aaaghhh
```

***

`style.css`:

```css
body {
  color: #624B08;
  background-color: ghostwhite;
  font-family: sans-serif;
}
a {
  text-decoration: none;
  color: #bb8d02;
}
a:hover {
  color: #dfa800;
}
h1, h2, h3, h4, h5, h6, .header {
  font-family: sans-serif;
  color: #463605; /* a bit darker than the text in body */
  margin-bottom: 0.8rem;
  margin-top: 2rem;
}
.container {
  margin: 0 auto;
  max-width: 768px;
  padding-left: 5%;
  padding-right: 5%;
}
ul li, ol li {
  margin-bottom: 0.9rem;
}
```

***

`layout.html`:

```html
#? strip(startswith = "<") | stdtmpl
#proc genLayoutHtml(content: string): string =
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://unpkg.com/purecss@1.0.1/build/pure-min.css" integrity="sha384-oAOxQR6DkCoMliIh8yFnu25d7Eq/PHS21PClpwjOTeU2jRSq11vu66rf90/cZr47" crossorigin="anonymous">
    <link rel="stylesheet" href="assets/style.css">
  </head>
  <body>
    <div class="container">
      $content
    </div>
  </body>
</html>
```

***

`types.nim`:

```nim
type
  Post* = object of RootObj
    path*, title*, content*: string
```

***

`index.html`:

```html
#? stdtmpl
#import types
#proc genIndexHtml(posts: openArray[Post]): string =
<h2>Index</h2>
<ul>
  #for p in posts:
    <li>
      <a href="${p.path}">$p.title</a>
    </li>
  #end for
</ul>
```

***

`post.html`:

```html
#? stdtmpl
#import types
#proc genPostHtml(post: Post): string =
<div class="post">
  <h1>${post.title}</h1>
  ${post.content}
</div>
```

***

`main.nim`:

```nim
import os
import strutils
import markdown # this is an external library which should be installed

include "layout.html"
include "index.html"
include "post.html"

import types

proc main() =
  var posts: seq[Post]

  for kind, path in walkDir("posts", checkDir = true):
    if kind != pcFile: continue
    let
      fileInfo = splitFile(path)
      name = fileInfo.name & ".html"
      dest = "docs"/name
    let markdown = markdown(
      readFile(path),
      config=initGfmConfig()
    )
    let post = Post(
      path: name,
      title: fileInfo.name.replace('-', ' ').capitalizeAscii,
      content: markdown,
    )
    writeFile(
      dest,
      genLayoutHtml(genPostHtml(post))
    )
    posts.add post

  writeFile(
    "docs"/"index.html",
    genLayoutHtml(genIndexHtml(posts))
  )

main()
```

***

And with the following file structure:
```
- src/
  - main.nim
  - types.nim
  - layout.html
  - index.html
  - post.html
- posts/
  - life-of-a-boomer.md
- assets/
  - style.css
- docs/
```

all the resulting HTML files will be located in the `docs/` directory. Don't
worry if you've just copied the code and it doesn't work, just go through
the error messages, fix them and you'll be fine.

## But this all is just boring
Yes, it is. It also works.

But we can do something more interesting as well. Say, we want a juicy feature
like attaching metadata to each markdown post to use it later. A popular idiom
is to make it at the very start separated from the main text with `---` like so:

`mypost.md`:

```md
---
tags: programming, Nim
updatedAt: 2020-02-02
---

## Oh snap
Here we go again
```

How to do it:
1. Check if the file starts with `---`
2. Find closing `---`
3. Parse everything in between

Here is an example of "not stripped down for readability" code with
error handling, low-levelish parsing and types:

```nim
type
  Metadata* = object of RootObj
    tags*: seq[string]
    updatedAt*: string

  Post* = object of RootObj
    path*, title*, content*: string
    metadata*: Metadata

  ParseMetadataError* = object of ValueError

func parseMetadata(s: string): Metadata =
  var
    index: int
    colonPos = s.find(':', index)
  while (colonPos) != -1:
    let key = s[index..<colonPos].strip
    let valueEnd = s.find('\n', colonPos)
    if valueEnd == -1:
      raise newException(ParseMetadataError,
                         "Ending newline not found for "&key)
    let value = s[colonPos + 1 ..< valueEnd].strip
    case key
    of "tags":
      result.tags = value.split(", ").sorted
    of "updatedAt":
      result.updatedAt = value
    else:
      raise newException(ParseMetadataError,
                         "Unknown metadata key: "&key)
    index = valueEnd
    colonPos = s.find(':', index)

# some code before
let fileContent = readFile(path)
var
  metadata: Metadata
  metadataEnd: int
if fileContent.len > 3 and fileContent[0..2] == "---":
  metadataEnd = fileContent.find("---", 3)
  if metadataEnd == -1:
    raise newException(ParseMetadataError,
                       "Closing --- not found for "&dest)
  metadata = parseMetadata(fileContent[3..<metadataEnd])
if metadataEnd != 0: metadataEnd += 3 # move after ---
let markdown = markdown(
  fileContent[metadataEnd ..< fileContent.len],
  config=initGfmConfig()
)
```

## Conclusion

This series of blog posts aims to prove that it is possible to create a static
site generator with relatively low effort. Hopefully it does so. And now the
closing thought.

People say that average programmers write blog posts with bad code examples and
practices whereas really good programmers don't do it because they think
that this is easy and essential. I think this post's code is easy and essential.
Am I a good programmer then? I don't know, maybe I'm just an average programmer
doing an easy thing. But it is the best thing I can do right now
(almost best (tired (who's not? ()
\`(hidden ,(car '("lisp :(", "treasure"))))))) last one is unbalanced).

Thanks for reading, see you!
