Title: Manipulating Vim Registers
Date: 2014-10-23
Category: Vim
Tags: vim, registers, macros, programming
Author: Buck Ryan
Summary: Directly change contents of Vim registers for advanced macros.
Status: draft

Recently I came across PHP code that looked similar to this:

    const YEAR = 1;
    const QUARTER = 2;
    const MONTH = 3;
    const WEEK = 4;
    const DAY = 5;
    const HOUR = 6;
    const SECOND = 7;

I needed to write a switch with cases for each of these constants. The desired
outcome was:

    const YEAR:
    const QUARTER:
    const MONTH:
    const WEEK:
    const DAY:
    const HOUR:
    const SECOND:

An obvious way to do this would be to yank the whole text, paste it where you
want your switch statement to be, and then use a macro to modify each line
of text. [This article](http://blog.sanctum.geek.nz/advanced-vim-macros/) is
a great writeup of more advanced macro techniques. Definitely read it.

However, it's possible to be more succinct by directly manipulating registers
([:help registers](http://vimdoc.sourceforge.net/htmldoc/change.html#registers).
Only basic knowledge of how to do this is necessary to enable you to do some
cool stuff. Here are some examples to show the various ways to do that.

Clear out the contents of register `a`:

    :let @a = ""

Append the text `I'm a!` to register `a`:

    :let @a .= "I'm a!"

Set the contents of register `c` to be the text `b is: ` concatenated with the
contents of register `b`:

    :let @c = "b is: " . @b

Now to see what is in register `c` you use:

    :reg c

To replace register `d` with the current line:

    "dyy

If you'd rather not replace what's in register `d`, but instead append to it,
you do:

    "Dyy

Knowing just the above will get us far. Let's see how we can apply it toward
making our switch statement.

The first thing I'll do is show you how to get the contents of register `a`
to be

    
    YEAR
    QUARTER
    MONTH
    WEEK
    DAY
    HOUR
    SECOND

We will start by initializing register `a` to be a newline:

    :let @a = "\n"

Note that this makes register `a` linewise
([:help linewise](http://vimdoc.sourceforge.net/htmldoc/motion.html#linewise)).
I'll explain what that means below. For now, suffice it to say that when you
yank more text into `a`, Vim will keep a newline at the end of the register.

Move your cursor to the beginning of the word `YEAR` in the first line and do

    "Aye

As we saw above, `"A` tells vim that the next thing we yank should be appended
to register `a` and `ye` means to yank until the end of the word. Now if you
example register a (`:reg a`) you will see it is set to `^JYEAR^J` (`^J` just
stands for the newline character). You can now move down to the next line and
do the same thing, so that register `a` is `^JYEAR^JQUARTER^J`. Do this for
every line (or even better, record a macro to automate it) and now register
`a` will have the text we were going for.

That was a fun exercise, but if we now paste register `a` (`"ap`), we still
have to do some text manipulation to add `case ` to each line and end each
line with a colon. We can do better. This time, start by clearing out register
a:

    :let @a = ""

Once again, move to the beginning of the word `YEAR`

    /YEAR<CR>

set register `b` to be the word `YEAR`

    "bye

and now put it all together

    :let @a = "case " . @b . ":\n"

(Note that register `a` is not in linewise mode this time, so we have to append
the newline ourselves.)

If we do this for each line (once again - use a macro!), now register `a` will
be

    case YEAR:
    case QUARTER:
    case MONTH:
    case WEEK:
    case DAY:
    case HOUR:
    case SECOND:

This is perfect. We eliminated the need to do any work after we pasted the
results. Instead, we just built up register `a` to be exactly what we desired.

We can make one further improvement. Using register `b` was an interesting way
of showing how you can use different registers and concatenate them together
to make the finished product. It's unnecessary, however, since we can use
<C-R><C-W>
([:help <c_CTRL-R_CTRL-W>](http://vimdoc.sourceforge.net/htmldoc/cmdline.html#c_CTRL-R_CTRL-W))
to insert the word under the cursor when creating our `let` statement. Once
again, move to the beginning of `YEAR` and clear register `a`. This time, we
can modify register `a` with:

    :let @a = "case <C-R><C-W>:\n"

The result after applying this to each line will be the same as before, but we
saved a few keystrokes.

Linewise vs. characterwise registers
====================================

As I mentioned above, Vim will make a register `linewise` when your `:let @`
expression ends in a newline. In this case, Vim will keep a newline at the end
of the register whenever you append to the register by yanking, deleting, etc.,
but not when you directly modify the register using `:let @`.

If you want to get around this, you have a few options. The first is to not use
`:let @` to append a newline to your register. Instead, go into insert mode and
type `<C-V><C-M>`. This will insert a newline character which you can yank into
register a with `"ayl`. Register `a` will still be `characterwise` and Vim will
not append newlines automatically.

A second option, which is perhaps a bit hackier, is to not append just a
newline to your register, but a newline plus some other character. For example,
you could use

    :let @a = "\n|"

Here I have finished the register with the pipe character, but you could use a
space or anything else. Since your expression does not end in a newline, Vim
will keep it character-wise. In our example above, this technique could
have been useful if we wanted each line to begin with a tab character.