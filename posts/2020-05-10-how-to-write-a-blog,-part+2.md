So, you are here. Hello and welcome. I will describe here how to write a blog.
It will be a somewhat technical description so please be ready. But it will also
be partly philosophical musings and for this you might also want to get ready.

Please read [part 1](2020-04-25-how-to-write-a-blog,-part+1.html) for a gentle
introduction to the topic with a less technical background required.

## "Do one thing and do it well"&#169;

This is a famous phrase in [UNIX] world. In UNIX-like systems
([Linux], [MacOS], [*BSD]) there exists a set of small standard programs
that do one thing and that are able to communicate with each other using pipes
`|`. A short example would be most useful:

```shell
$ ls posts/ | cut -d - -f 1-3 | sort | xargs -I {} date -d {} +%A
```

and it produces the following output which lists all the days of the week
on which I wrote the blog posts in chronological order:

```
Sunday
Saturday
Sunday
```

[UNIX]: https://en.wikipedia.org/wiki/Unix
[Linux]: https://en.wikipedia.org/wiki/Linux
[MacOS]: https://en.wikipedia.org/wiki/MacOS
[*BSD]: https://en.wikipedia.org/wiki/Berkeley_Software_Distribution

<details>
  <summary>Explanation of the command</summary>

1. `$` - this is not a part of a command, don't write it, no one writes it.
   This is just a convention which means that the following command
   should be written in the [terminal].

2. `ls posts/` - `ls` means list files, `posts/` points to the directory,
   where we want to list files. Currently typing just `ls posts/` has the
   following output:
   ```
   2020-04-19-pixel-clouds.md
   2020-04-25-how-to-write-a-blog,-part+1.md
   2020-05-10-how-to-write-a-blog,-part+2.md
   ```
   These are the posts that I have written so far.

3. `cut -d - -f 1-3` - this command splits the input by dashes
   `-` (using `-d -` flag) and chooses only columns
   from 1 to 3 (using `-f 1-3` flag). `ls posts/ | cut -d - -f 1-3` outputs:
   ```
   2020-04-19
   2020-04-25
   2020-05-10
   ```
   Here the `cut` command by itself is not as useful as with the
   flags `-d` and `-f`. Flag `-d` allows to specify the delimiter which
   is a dash in our case and the flag `-f` allows to choose certain columns.
   One more important thing to realize is the use of `|` which takes output from
   `ls` and passes it over as input to `cut` command. This is how commands
   communicate with each other.

4. `sort` - this command just does what it says it does, it sorts the input.
   This ensures that all the posts are listed in chronological order.

5. `date -d 2020-04-19 +%A` - this command takes a date as input with the flag
   `-d` and applies a formatting to it using `+%A` syntax, in this case this
   formatting just outputs the day of the week. So the output of this command
   is just "Sunday".

6. `xargs -I {} date -d {} +%A` - the problem with the command `date` is that
   it doesn't fully support the pipe `|` communication and here `xargs` comes
   to the rescue, it first says: `-I {}` - whatever I get from input, please
   use double braces `{}` pattern instead of an input line in the next command;
   and then comes the command `date -d {} +%A` which transforms into
   `date -d 2020-04-19 +%A` and so on for all the other input lines
   (of which there are 3 lines from the `cut` command, see point 3).
   Basically `xargs` helped to use pipe `|` communication with a command
   which does not play with it very well by default.

[terminal]: https://en.wikipedia.org/wiki/Virtual_console

</details>

This is an example which uses a total of 5 different commands which all do
just one thing but with the help of communication we can build powerful
constructions using these simple commands.

This is the essence of the quote "Do one thing and do it well".
And it often implies that these programs should be able to communicate
with each other, otherwise they are useless. But I would argue that
even if the command does just one thing, it is still useful for this 1
specific use case. And even if it does not communicate well, it is easier
to extend it to suit your needs.

## Static site generator which does one thing

You might have guessed which thing it should do well - create a blog.

Here is a list of features comparing different static site generators for
blogs taken from [zola](https://github.com/getzola/zola):

<div class="pure-table-wrapper pure-table-striped-wrapper">

| Static site generator           | Zola   | Cobalt | Hugo   | Pelican |
|:--------------------------------|:------:|:------:|:------:|:-------:|
| Language                        | Rust   | Rust   | Go     | Python  |
| Single binary                   | yes    | yes    | yes    | no      |
| Syntax highlighting             | yes    | yes    | yes    | yes     |
| Sass compilation                | yes    | yes    | yes    | yes     |
| Assets co-location              | yes    | yes    | yes    | yes     |
| Multilingual site               | ehh    | no     | yes    | yes     |
| Image processing                | yes    | no     | yes    | yes     |
| Sane & powerful template engine | yes    | yes    | ehh    | yes     |
| Themes                          | yes    | no     | yes    | yes     |
| Shortcodes                      | yes    | no     | yes    | yes     |
| Internal links                  | yes    | no     | yes    | yes     |
| Link checker                    | yes    | no     | no     | yes     |
| Table of contents               | yes    | no     | yes    | yes     |
| Automatic header anchors        | yes    | no     | yes    | yes     |
| Aliases                         | yes    | no     | yes    | yes     |
| Pagination                      | yes    | no     | yes    | yes     |
| Custom taxonomies               | yes    | no     | yes    | no      |
| Search                          | yes    | no     | no     | yes     |
| Data files                      | yes    | yes    | yes    | no      |
| LiveReload                      | yes    | no     | yes    | yes     |
| Netlify support                 | yes    | no     | yes    | no      |
| ZEIT Now support                | yes    | no     | yes    | yes     |
| Breadcrumbs                     | yes    | no     | no     | yes     |
| Custom output formats           | no     | no     | yes    | no      |

</div>

There are a lot of features.
Do you need all of them? A half of them? A quarter? Answers vary but
for an average user I would say a quarter is going to be enough. I believe
this is the idea behind the Cobalt, it has roughly a quarter.

This might not exactly reflect your needs, you could need all of them.
But the abundance of features also has its implications.

What if you need an additional feature? Here I will try to list 5 reasons
why you might not get this feature:

1. It is too specific, there's no one who would want to implement this feature.
2. The codebase is not very well adapted to implement this feature, it is
   postponed until better times.
3. You are not a `<insert language>` programmer and you don't feel like
   learning a new language to implement it yourself.
4. The codebase is too large and even with your knowledge of programming
   it requires too much commitment.
5. You know you can make the code to work exactly how you want but you are
   unable to convince the repository maintainer that this feature should be
   added. And it doesn't sound appealing to maintain your own fork.

Any of these might be false for you and it's fine. If this is the case, I
don't believe my knowledge will have much of a practical use for you but you
might still want to follow because of sheer interest. Please be my guest.

## Let's create a static site generator in Nim

[Nim] is a statically typed compiled systems programming language.
It combines successful concepts from mature languages like Python,
Ada and Modula. I will use this language because I believe it can provide
all the necessary tools with the minimal friction.

If you are an absolute beginner, you might want to check out the
beginner-friendly [Nim tutorial] to get the basic programming concepts
and make the most of the following content.

If you are not a beginner, the code will be pretty easy, especially
if you are familiar with Python.

[Nim]: https://nim-lang.org/
[Nim tutorial]: https://narimiran.github.io/nim-basics/

What do we need in order to create a static site generator? We need 3 things:

1. Design
2. Templates
3. Markdown parser

Firstly, design. It mainly boils down to [learning CSS][learn CSS]
and practicing your
skills of creating beautiful layouts. But you don't need to be exceptionally
good at it, look at this blog, you can definitely do better even without
tryharding.

Secondly, templates. They will allow us to reduce html duplication to the
minimum. Nim has a language feature called [Source Code Filters] which
creates compiled templates and they are perfectly fit for our case - they
are fast and easy to use.

[Source Code Filters]: https://nim-lang.org/docs/filters.html

Thirdly, we need a markdown parser. You might want to use a different format:
Asciidoc, Org-mode, reStructuredText - but I will use markdown here. It's
good enough. Every popular language has a library for that and
Nim is not an exception, I will use [nim-markdown].

[nim-markdown]: https://github.com/soasme/nim-markdown

So, all the pieces of the puzzle are in place, let's put them together.

### Design

Let's throw some css for the beautiful design:

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
  padding-top: 5%;
  padding-bottom: 10%;
  padding-left: 5%;
  padding-right: 5%;
}
ul li, ol li {
  margin-bottom: 0.9rem;
}
```

This code is not really hard and I won't fully explain what it does,
but just trust me, this is very easy, you can quickly pick up the
idea along the way if you want to [learn CSS].

[learn CSS]: https://developer.mozilla.org/en-US/docs/Learn/CSS/First_steps

The general idea behind this code is that it allows us to use headers, links,
lists and it keeps the text in the center. All the basic things.

### Templates

Then goes the the code for a general template:

```html
# This is in file `layout.html`

#? strip(startswith = "<") | stdtmpl
#proc genLayoutHtml(title, content: string): string =
<!DOCTYPE html>
<html>
  <head>
    <title>$title · Greensky</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet" href="https://unpkg.com/purecss@1.0.1/build/pure-min.css" integrity="sha384-oAOxQR6DkCoMliIh8yFnu25d7Eq/PHS21PClpwjOTeU2jRSq11vu66rf90/cZr47" crossorigin="anonymous">
    <!--[if lte IE 8]>
        <link rel="stylesheet" href="https://unpkg.com/purecss@1.0.1/build/grids-responsive-old-ie-min.css">
    <![endif]-->
    <!--[if gt IE 8]><!-->
        <link rel="stylesheet" href="https://unpkg.com/purecss@1.0.1/build/grids-responsive-min.css">
    <!--<![endif]-->

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/styles/lightfair.min.css">

    <link rel="stylesheet" href="assets/greensky_style.css">
  </head>
  <body>
    <div class="container">
      $content
    </div>

    <script src="assets/highlight/highlight.pack.js"></script>
    <script>hljs.initHighlightingOnLoad();</script>
  </body>
</html>
```

and a template for a specific blog post:

```html
# This is in file `post.html`

#? stdtmpl
#proc genPostHtml(post: tuple[path, title, date, content: string]): string =
<div class="post">
  <h1>${post.title}</h1>
  <h2 class="subtitle-date">${post.date}</h2>
  ${post.content}
</div>
```

Again, html is easy, you can [learn HTML] if you want. All Nim does is that
it adds these directives to make the magic happen:
```
#? stdtmpl
#proc genPostHtml(post: tuple[path, title, date, content: string]): string =
```

[learn HTML]: https://www.w3schools.com/html/

These 2 code snippets give us 2 functions: `genLayoutHtml` and `genPostHtml`
and this is all we need from a template really. We do it like this:

```nim
include "layout.html"
include "post.html"
let post = (
  path: "/path/to/file",
  title: "Creative Title",
  date: "2020-05-10",
  content: "<h2>My html content</h2><p>Hej-hej!</p>",
)
let postHtml = genPostHtml(post)
let pageHtml = genLayoutHtml(post.title, postHtml)
```

and now we have a variable `pageHtml` which has all the html we want on
our page.

### Markdown

This is the easiest part because we already have a [library][nim-markdown]
which does all the heavy lifting for us.

```nim
import markdown
let markdown = markdown(readFile("/path/to/file"), config=initGfmConfig())
```

Here `"/path/to/file"` should be a path to a file with your markdown text.
You can have a look at this exact post in [raw markdown].
Now, the variable `markdown` has all the html we need. Cool.

[raw markdown]: https://raw.githubusercontent.com/greenfork/greensky/master/posts/2020-05-10-how-to-write-a-blog%2C-part%2B2.md

## Done!

So many words and so little code. But this is all we need.

Let's wrap up by listing the reasons why you might want to create
and use your own static site generator:

1. It is easy, you don't have to be an exceptional programmer, average will do.
2. You know the code, you can easily modify it.
3. The codebase is simple enough to add new features, new features can
   be tailored to your specific needs.

Aaaaaand... it's fun! Beautiful.

The main parts are here but we still need some glue to make it all work
together. And we might want to add a couple of additional features as well.
This is a good topic for the next part. See you!
