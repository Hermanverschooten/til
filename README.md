# TIL - Today I Learned

A simple file-based BLOG engine.
It was amusing and I learned somethings new

## How to add articles

* Make sure the path in the runtime config points to the correct location.
* Add a dated folder, YYYY-MM-DD
* Create an <article>.md file, see below for its structure
* Add any assets in the same foler, images, downloads, ...
* visit /reload, to refresh the article list.

## File structure
The .md file MUST adhere to the following structure:
```
visible
-- TITLE --
Try an Image
-- TAGS --
elixir
ecto
-- TLDR --
How do I show an image
-- CONTENT --
# How do I show an image?
![logo](assets/logo.png|class=border p-2,style=width:200px)

[pdf](assets/document.pdf)

```
The first line should contain only the word `visible` for the article to be live.
The title is shown on the main page, in the overview and as the page title.
Tags are 1 per line.
TLDR is the summary that appears on the home page.
CONTENT contains the article in markdown format, with support for elixir syntax highlighting.

For images I have added the option to add extra attributes by appending a `|` to the url followed by the attributes seperated with a comma.
_Caution_ If adding Tailwind classes, make sure they exist in your css-file. These changes to the image tag are made at runtime.

