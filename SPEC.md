# AsciiDoc Syntax Spec

This document summarizes the AsciiDoc syntax demonstrated by the official
Asciidoctor Syntax Quick Reference:

https://docs.asciidoctor.org/asciidoc/latest/syntax-quick-reference/

The quick reference demonstrates HTML output, but the syntax below describes the
source language features a parser should recognize independently of output
format.

## Paragraphs

Plain text separated by one or more blank lines forms paragraphs.

```adoc
Paragraph text can span multiple source lines.
The rendered paragraph treats the line break as whitespace.

This starts a new paragraph.
```

A paragraph indented by at least one space is a literal paragraph. Literal
paragraphs preserve whitespace and line breaks and are rendered in a fixed-width
style.

```adoc
Normal paragraph.

 Literal paragraph.
 Preserved line breaks and spaces.
```

Hard line breaks are written with a trailing `+`, or by applying the
`%hardbreaks` option.

```adoc
first line +
second line

[%hardbreaks]
first line
second line
```

A lead paragraph is assigned with the `lead` role.

```adoc
[.lead]
Opening paragraph with lead styling.
```

## Text Formatting

Constrained formatting applies when markup characters are bounded by word
boundaries or punctuation.

```adoc
*bold*
_italic_
`monospace`
*_bold italic_*
`*_monospace bold italic_*`
```

Unconstrained formatting can occur inside a word or identifier.

```adoc
**B**old inside a word
word__italic__word
``code`` inside a token
```

Other inline formatting:

```adoc
#highlight#
##unconstrained highlight##
[.underline]#underline#
[.line-through]#strike#
[.role]#custom role#
^superscript^
~subscript~
```

Curved quote substitutions use backtick and apostrophe pairs.

```adoc
"`double quotes`"
'`single quotes`'
```

## Links, Anchors, and Cross References

URLs and email addresses may be autolinked. URL macros can also provide link
text and attributes.

```adoc
https://example.org
https://example.org[Example]
https://example.org[Example,role=external,window=_blank]
https://example.org[Example^]

name@example.org
mailto:name@example.org[Email me]
mailto:list@example.org[Subscribe,Subject,Body]
```

Use the `link:` macro when the target is not an ordinary URL, or when a target
needs passthrough escaping.

```adoc
link:index.html[Docs]
link:++https://example.org/?q=[a b]++[Special URL]
link:\\server\share\file.pdf[File]
```

Inline anchors create referenceable locations.

```adoc
[[id-a]]Text after an anchor.
[#id-b]#A phrase with an ID.#
anchor:id-c[]Text after an anchor macro.
[[id-d,Reference Text]]Text with explicit xref text.
```

Cross references point to IDs in the same document or another document.

```adoc
See <<id-a>>.
See <<id-a,custom text>>.
xref:other.adoc#section-id[Other section]
xref:other.adoc[Other document]
```

## Document Header

The document header is optional. When present, it has no blank lines and is
separated from the body by at least one blank line.

```adoc
= Document Title
Author Name <author@example.org>; Another Author <other@example.org>
v1.0, 2026-06-25
:toc:
:homepage: https://example.org

Document body starts here.
```

A revision line requires an author line.

## Section Titles

Article documents have one level 0 title, the document title. Section levels use
one to six leading `=` characters.

```adoc
= Document Title

== Level 1

=== Level 2

==== Level 3

===== Level 4

====== Level 5
```

Book documents may contain additional level 0 titles, where they represent
parts. A discrete heading looks like a section title but does not create a
section in the document hierarchy.

```adoc
[discrete]
=== Standalone heading
```

## Automatic Table of Contents

Set the `toc` document attribute to generate a table of contents. Related
attributes can control the title, depth, and position.

```adoc
= Document Title
:toc:
:toclevels: 3
:toc-title: Contents
```

## Includes

Include directives insert content from another file. Includes can select tagged
regions, line ranges, or remote URLs when URI reads are enabled and safe mode
allows it.

```adoc
include::chapter.adoc[]
include::file.txt[tag=definition]
include::file.txt[lines=5..10]
include::https://example.org/file.adoc[]
```

## Lists

Unordered lists use one or more `*` markers.

```adoc
* Item
** Nested item
*** Deeper item
```

Ordered lists use one or more `.` markers.

```adoc
. Step one
. Step two
.. Nested step
```

Checklists are unordered list items with a checkbox marker.

```adoc
* [*] checked
* [x] checked
* [ ] unchecked
* normal item
```

Description lists use `::`; question-and-answer lists use the same marker after
question text.

```adoc
Term:: Description

Question?::
Answer.
```

List items can contain compound content by using a list continuation line
containing only `+`.

```adoc
* First paragraph.
+
Second paragraph in the same item.
+
----
Block content in the same item.
----
```

Adjacent lists can be separated with an empty attribute list or a separating
comment.

```adoc
* First list

[]
* Second list
```

## Images and Media

Block images use `image::`; inline images use `image:`. Image attributes can
provide alt text, dimensions, titles, IDs, captions, and links. The `imagesdir`
attribute supplies a common base path for relative image targets.

```adoc
:imagesdir: images

image::diagram.png[Architecture]

.Architecture diagram
[#img-architecture,link=https://example.org]
image::diagram.png[Architecture,640,480]

Click image:play.png[Play] to continue.
```

Audio and video use block macros.

```adoc
audio::podcast.mp3[]
video::demo.mp4[width=640,start=10,end=60,options=autoplay]
video::dQw4w9WgXcQ[youtube]
video::300817511[vimeo]
```

## UI Macros

Icon, keyboard, button, and menu macros represent UI elements.

```adoc
icon:tags[]
icon:heart[role=red]
kbd:[Ctrl+T]
btn:[Save]
menu:File[New,Project]
```

## Blocks

A block may have a title, attributes, style, ID, role, and options.

```adoc
.Block title
[#block-id.role]
[style,options]
--
Block content.
--
```

Common delimited blocks:

```adoc
----
listing or source
----

....
literal
....

====
example
====

****
sidebar
****

____
quote
____

====
NOTE: admonition content
====

+++
passthrough content
+++
```

Open blocks use `--` and can act as anonymous containers or masquerade as other
block styles.

```adoc
[sidebar]
--
Sidebar content.
--
```

Collapsible blocks use the `%collapsible` option. They may also be open by
default with `%open`.

```adoc
[%collapsible]
====
Hidden until expanded.
====
```

## Source Blocks and Callouts

Source blocks are listing blocks with a source style and optional language.

```adoc
[source,ruby]
----
puts "hello" # <1>
----
<1> Callout explanation.
```

Callout marks may be hidden behind line comments for languages that support
comments.

```adoc
----
code // <1>
code # <2>
code ;; <3>
code <!--4-->
----
<1> C-style line comment.
<2> Ruby, Python, or shell style.
<3> Clojure style.
<4> XML or HTML style.
```

Source block content can be included from files, and `indent` can strip or add
leading indentation.

```adoc
[source,java]
----
include::{sourcedir}/Example.java[tag=main,indent=0]
----
```

## Admonitions

Admonition paragraphs start with a built-in label. Admonition blocks use the
label as the block style.

```adoc
NOTE: A note.
TIP: A tip.
IMPORTANT: Important information.
CAUTION: Be careful.
WARNING: A warning.

[NOTE]
====
Compound admonition content.
====
```

## Tables

Tables use `|===` delimiters. Cells begin with `|`. If `cols` is omitted, the
number of columns is inferred from the first non-empty row. A blank line after
the first row can promote that row to a header.

```adoc
.Table title
|===
|Name |Description

|First
|Description for first

|Second
|Description for second
|===
```

Table attributes can declare the number of columns, relative widths, headers,
footers, autowidth, stripes, borders, orientation, and roles.

```adoc
[%header,cols="1,2,1",width=75%,stripes=even]
|===
|Name |Description |Status

|Alpha |First item |Ready
|Beta |Second item |Pending
|===
```

Cell specifiers can align, format, span, duplicate, or style cells.

```adoc
|===
^|centered
>.>|right and middle
2+|spans two columns
.2+|spans two rows
a|AsciiDoc content in a cell
|===
```

AsciiDoc also supports CSV, TSV, and DSV table data by assigning the table
format.

```adoc
[format=csv]
|===
name,description
alpha,first
|===
```

## IDs, Roles, and Options

IDs and roles can be assigned with shorthand or named attributes.

```adoc
[#id.role1.role2]
Paragraph with ID and roles.

[id="id",role="role1 role2"]
Paragraph with explicit attributes.
```

Inline formatted text can also receive IDs and roles.

```adoc
[#id.role]`monospace text`
[#id.role]*bold text*
```

Options can be written with shorthand `%` markers or an `options`/`opts`
attribute.

```adoc
[%header%footer%autowidth]
|===
|Header A |Header B
|Footer A |Footer B
|===

[options="header,footer,autowidth"]
|===
|Header A |Header B
|Footer A |Footer B
|===
```

## Comments

Line comments start with `//`. Block comments use `////` delimiters.

```adoc
// Single-line comment

////
Block comment.
////
```

## Breaks

A thematic break is a line containing three apostrophes. A page break is a line
containing three less-than signs.

```adoc
'''

<<<
```

## Attributes and Substitutions

Attribute entries use `:name: value`. An attribute can be referenced with
`{name}`. A multiline attribute value can continue with a trailing backslash.

```adoc
:url-home: https://example.org
:summary: This value continues \
          on the next line.

Visit {url-home}[the site].
{summary}
```

Counters are attributes that increment as they are referenced.

```adoc
Part {counter:index}
Part {counter:index}
Reset {counter2:index:0}
```

Common substitution groups include special characters, quotes, attribute
references, character replacements, macros, and post replacements. Block and
inline substitutions can be customized with the `subs` attribute.

```adoc
:version: 1.0

[source,xml,subs=attributes+]
----
<version>{version}</version>
----
```

## Text Replacements

AsciiDoc replaces common textual symbols during substitutions. Examples include
copyright, registered trademark, trademark, arrows, ellipses, apostrophes,
typographic quotes, dashes, plus/minus, fractions, and HTML/XML entity
references.

```adoc
(C)
(R)
(TM)
...
->
=>
<-
<=
```

## Escaping and Passthroughs

Prefix syntax with a backslash to prevent interpretation. Attribute references
can be escaped with a backslash before the opening brace.

```adoc
\*not bold*
\{not-an-attribute}
```

Passthroughs preserve content from normal substitutions. Inline passthroughs can
use `pass:[...]`, triple plus, or quoted passthrough forms. Passthrough blocks
use `++++`.

```adoc
pass:[<u>raw</u>]
++<u>raw</u>++

++++
<p>Raw output.</p>
++++
```

## Markdown Compatibility

AsciiDoc accepts selected Markdown-style syntax, including ATX headings,
fenced code blocks, Markdown blockquotes, and horizontal rules.

````adoc
# Heading 1
## Heading 2

```ruby
puts "hello"
```

> quoted line

---
````
