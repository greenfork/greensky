And by writing a blog I don't mean writing the text. I mean, how to make it
good-looking. And actually I'm not even going to talk about that, this is
a programming blog afterall (HTML and CSS is not programming). I will tell you
how to make it fast, simple and maintainable.

This part is an introductory material, feel free to skip to part 2
(which will be a bit later) for more technical details.


## Existing solutions

Nowadays if you want to write a blog, you generally have several options:

1. Software-as-a-Service (SaaS) - prominent examples are [WordPress] and
   [Joomla]. The easiest solution where you just register your account and
   the site is ready to go!
2. Do the same stuff as in 1 but use your own server for that. The code is
   open-source which means you can do that.
3. Use a static site generator - well-known options are [Jekyll], [Hugo] and
   [Gatsby]. "Static site generator" basically means that you will get only
   html pages with no user interaction whatsoever.
4. Write everything straight in html.

[WordPress]: https://wordpress.org/
[Joomla]: https://www.joomla.org/
[Jekyll]: https://jekyllrb.com/
[Hugo]: https://gohugo.io/
[Gatsby]: https://www.gatsbyjs.org/

Options 1 and 2 imply that there's going to be dynamic content on the page such
as forums, comments, contacts form. And even when there's no such content,
people are eager to use it because it is easy.

But I'm not concerned with options 1 and 2. Not to bash on any of these systems,
but they are way too complex (and written in [PHP]) which leaves a lot of
possibilities to all sorts of defects.

Options 3 and 4 are much simpler. Writing everything straight in html is the
simplest solution of all. You just write a bunch of tags: `<h1>Tags</h1>` - and
some more: `<ul><li>More</li><li>Is this <i>enough</i>?</li></ul>` - and more,
and as a result you get something like the following:

[PHP]: https://whydoesitsuck.com/why-does-php-suck/

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Stupid title · Greensky</title>
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
      <h1>Tags</h1>
      <ul>
        <li>More</li>
        <li>Is this <i>enough</i>?</li>
        <li><b>Please</b> make it <del>stop</del><ins>continue</ins></li>
      </ul>
    </div>
    <script src="assets/highlight/highlight.pack.js"></script>
    <!--
    <script>
      // This code shouldn't be commented but it gets eaten by a highlighter
      // otherwise.
      // https://github.com/highlightjs/highlight.js/issues/2504
      hljs.initHighlightingOnLoad();
    </script>
    -->
  </body>
</html>
```
which renders to something like this:

<blockquote>
  <h1>Tags</h1>
  <ul>
    <li>More</li>
    <li>Is this <i>enough</i>?</li>
    <li><b>Please</b> make it <del>stop</del><ins>continue</ins></li>
  </ul>
</blockquote>

After some time the eyes are trained enough to dismiss some of that
~~garbage~~tags. But it is never gone forever, it still stays there. Waiting for
you to watch at this disgrace.

And so the static site generators were born!


## Static site generators

The idea behind such a generator is to produce plain html files but with less
noise and less manual work. There are several improvements compared to plain
writing of html:

1. Templates - you *really* don't want to copy that bulk of text above every
   time you create a new blog post. You want to just concentrate on the
   actual content of your post.
2. Markup ~~languages~~ - [HTML] is abbreviated as Hyper-Text Markup Language
   which just introduces some special markup syntax like tags `<h1>` to make
   text content richer. But this is not the only one, there are also markup
   languages like [Markdown] or [reStructuredText] and they look a lot nicer.
   For example, the rendered with html text above can be written in Markdown
   as:
   ```md
   # Tags
   
   * More
   * Is this _enough_?
   * __Please__ make it ~~stop~~<ins>continue</ins>
   ```
   As you can see it is shorter and also allows to use html if needed
   (there's no option to underline the text in the variant of markdown I am
   using here).
3. Cool features like [SASS] compilation, themes, internal links, [pagination],
   [breadcrumbs] and everything you would ever want to see on your site.

[HTML]: https://en.wikipedia.org/wiki/HTML
[reStructuredText]: https://en.wikipedia.org/wiki/ReStructuredText
[Markdown]: https://en.wikipedia.org/wiki/Markdown
[SASS]: https://sass-lang.com/
[pagination]: https://en.wikipedia.org/wiki/Pagination
[breadcrumbs]: https://en.wikipedia.org/wiki/Breadcrumb_navigation

But remember when I said that WordPress and Joomla are too complex? The option 3
is what **I** would call complex. A _general_ static site generator tries to
appeal to _general_ public and it means it should include all the features so
that normies could use it as well as to claim that "ALL features are optional"
so that `hackers` could think of it "it's so cool, it's so minimal".

In my personal and correct opinion I think it's wrong. Would you call yourself
a hacker using some of this bloated software? Maybe yes and maybe you are right.
But is this the only option? No. And I will show you the path if you are
willing to follow. Please, wait for part 2 to come.
