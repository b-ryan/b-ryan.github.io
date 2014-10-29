Title: Manipulating Vim Registers
Date: 2014-10-23
Category: Vim
Tags: vim, registers, macros, programming
Author: Buck Ryan
Summary: Directly change contents of Vim registers for advanced macros.
Status: draft

Recently I came across PHP code that looked similar to this:

    #!php
    const YEAR = 1;
    const QUARTER = 2;
    const MONTH = 3;
    const WEEK = 4;
    const DAY = 5;
    const HOUR = 6;
    const SECOND = 7;

I wanted to write a switch statement which handled each of those constants. I
thought a good way to get started would be to write

    #!php
    const self::YEAR:
    const self::QUARTER:
    const self::MONTH:
    const self::WEEK:
    const self::DAY:
    const self::HOUR:
    const self::SECOND:

An obvious way to do this would be to yank the whole text, paste it where the
code will live, and then use a macro to modify each line of text. [This
article](http://blog.sanctum.geek.nz/advanced-vim-macros/) is a great writeup
of more advanced macro techniques. Everything in there would work great for
accomplishing this.

However, it's possible to be more succinct by directly manipulating registers
([:help registers](http://vimdoc.sourceforge.net/htmldoc/change.html#registers).
This post will show a few ways to do that so that you can learn how to master
registers. We can start off by showing some examples.

Command                         | Explanation
------------------------------- | -----------
`:let @a = ""`                  | *Clear out the contents of register "a"*
`:let @a .= "I am register a!"` | *Append the text "I am register a!" to register "a"*
`:let @c = "b is: " . @b`       | *Set the contents of register "c" to be the text "b is: " concatenated with the contents of register "b"*
`:reg c`                        | *Check what's in register "c"*
`"dyy`                          | *Replace register "d" with the current line*
`"Dyy`                          | *If you'd rather not overwrite register "d", but instead append to it*

Knowing just the above will get us far, but for more details on the `:let @`
command, check out [:help
:let-@](http://vimdoc.sourceforge.net/htmldoc/eval.html#:let-@).

Let's see how we can apply it toward making our switch statement. Our first
exercise is pretty simple. We will get the contents of register `a` to be:

    #!php
    YEAR
    QUARTER
    MONTH
    WEEK
    DAY
    HOUR
    SECOND

*(note that there will actually be an empty first line)*

Start by moving your cursor to the word "YEAR" and initializing register `a` to
a newline:

    #!vim
    /YEAR<CR>
    :let @a = "\n"<CR>

Doing so will make register `a` linewise ([:help
linewise](http://vimdoc.sourceforge.net/htmldoc/motion.html#linewise)). I
explain below why this happens and what effect is has, but for now, suffice it
to say that when you yank more text into `a`, Vim will keep a newline at the
end of the register. Go ahead and yank the word "YEAR" onto the end of register
a to see it happen:

    #!vim
    "Aye

As we saw above, `"A` tells vim that the next thing we yank should be appended
to register `a` and `ye` means to yank until the end of the word. Examine
register `a` with `:reg a` to see it is set to`^JYEAR^J` (`^J` stands for the
newline character).

Move your cursor down so it is on `QUARTER` and again use `"Aye` to yank it
onto `a`. `a` is now `^JYEAR^JQUARTER^J`. Do this for every line (or even
better, record a macro to automate it) and register `a` will have the text we
were going for.

That was a fun exercise, but to finish writing each case statement, we would
need to edit each line in register `a`, which we wanted to avoid in the first
place. We can do better. As before, move your cursor to `YEAR`, but this time
clear out register `a` entirely:

    #!vim
    /YEAR<CR>
    :let @a = ""<CR>

We will use another register to help us. Yank `YEAR` into register `b` and use
it to append to register `a`:

    #!vim
    "bye
    :let @a .= "case self::" . @b . ":\n"<CR>

This concatenates the text `case self::` with the contents of register `b` and
the string `:\n`. Register `a` is not linewise this time, so we have to append
the newline ourselves. `a` will now be `case self::YEAR:^J`. If we repeat the
above for each line (once again - use a macro!), register `a` will be:

    #!php
    case self::YEAR:
    case self::QUARTER:
    case self::MONTH:
    case self::WEEK:
    case self::DAY:
    case self::HOUR:
    case self::SECOND:

This is perfect. We eliminated the need to do any work after we pasted the
results. Instead, we just incrementally built the desired text within register
`a`.

We can make one further improvement. Using register `b` was an interesting way
of showing how you can use different registers and concatenate them together to
make the finished product. It's unnecessary, however, since we can use
`<C-R><C-W>` ([:help
<c\_CTRL-R\_CTRL-W\>](http://vimdoc.sourceforge.net/htmldoc/cmdline.html#c_CTRL-R_CTRL-W))
to insert the word under the cursor each time we append to `a`. To demonstrate
this, again move to the beginning of `YEAR` and clear register `a`. This time,
skip yanking to register `b` and on each line do:

    #!vim
    :let @a .= "case self::<C-R><C-W>:\n"<CR>

Linewise vs. characterwise registers
====================================

As I mentioned above, Vim will make a register `linewise` when your `:let @...`
expression ends in a newline. Vim will keep a newline at the end of the
register whenever you append to it by yanking, deleting, etc., but not when you
directly modify the register using `:let @...`.

If you want to get around this, you have a few options. The first uses yanking
to get a newline at the end of your register. In insert mode, type
`<C-V><C-M>`. This inserts a newline character which you can yank into register
`a` with `"ayl`. Register `a` will still be `characterwise`, but `a` will have
a trailing newline character.

A second option, which is perhaps a bit hackier, is to not append just a
newline to your register, but a newline plus some other character. For example:

    #!vim
    :let @a = "\n|"<CR>

Here the register ends with the pipe character. You could use a space or tab or
any non-newline character. In our PHP example from the previous section, this
technique might have been useful if we wanted each line to begin with a tab
character, for example.
