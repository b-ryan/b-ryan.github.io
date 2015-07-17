Title: Om, Clojurescript, and Testing
Date: 2015-07-16
Category:
Tags:
Author: Buck Ryan
Summary:
Status: draft

This past week I started learning React, Om, and Clojurescript all at once.
When beginning to use [cemerick's
.clojurescript.test](https://github.com/cemerick/clojurescript.test), I kept
running into this error:

    #!text
    Error: cemerick is undefined

    ERROR: cemerick.cljs.test was not required.

    You can resolve this issue by ensuring [cemerick.cljs.test] appears
    in the :require clause of your test suite namespaces.
    Also make sure that your build has actually included any test files.

But I clearly had included it in my test! I googled and grumbled, but could not
figure out what was wrong. Finally I discovered that
[slimerjs](https://slimerjs.org/) has the `-jsconsole` flag, which, as the docs
say, will

    #!text
    Open a window to view all javascript errors during the execution

Great, using that I finally found the actual problem:

    #!text
    Script Error: Error: Assert failed: No target specified to om.core/root
    (not (nil? target))
           Stack:
             -> file:///tmp/runner6386761518784950059.js.html: 55456

This makes much more sense. The issue is that my `core.cljs` namespace was
running `om/root` when the page loads. The code looked like:

    #!clojure
    (om/root main-view
             app-state
             {:target (. js/document (getElementById "app"))}))

But since the tests are not loading the index.html page (as they shouldn't),
there is no element with ID app. Ultimately the problem is with running code
at the namespace level. What would be preferred would be if there were some
way to specify a main function to initialize the app. This would be run for
the actual application, but not the tests.

Solution
========

It took awhile of searching, but I finally found some inspiration from
[this project](https://github.com/jalehman/react-tutorial-om) and specifically
[this line of code](https://github.com/jalehman/react-tutorial-om/blob/60867fb0efcb48a3f20bc94361c2f981e6c96f44/resources/public/index.html#L15):

    <script type="text/javascript">goog.require("react_tutorial_om.app");</script>

I realized I could just wrap by `om/root` call in a main function and then call
this from the index.html page. Here is what the code in `core.cljs` looks like
now:

    #!clojure
    (defn app []
      (om/root main-view
               app-state
               {:target (. js/document (getElementById "app"))}))

and the corresponding code in `index.html`:

    #!html
    <script type="text/javascript">
    goog.require("my.namespace.core");
    my.namespace.core.app();
    </script>

Now running the tests no longer had any problem. However, I realized that
lein figwheel was not reloading the page properly when I made changes to the
code. This is because the javascript would be reloaded, which previously was
running `om/root` every time. To solve this I added to the `on-js-reload`
function so that the app was reinitialized:

    #!clojure
    (defn on-js-reload []
      (app))

Alternative Approach
====================

An entirely different approach to all of this (and perhaps a lot simpler)
would be to simply check if your target element exists. Your code could then
look like

    #!clojure
    (if-let [target (. js/document (getElementById "app"))]
      (om/root main-view
               app-state
               {:target target}))

You might prefer this approach. The reason I tend to not like this is that you
still have functionality that executes when you require the namespace. It also
introduces a silent failure. If you change the main element to have a different
id, your app would just show up blank with no errors printed.

I was pretty surprised to not be able to find anything about this. Maybe I'm
missing something obvious. I am new to Clojurescript and Om, so it could just
be a newbie mistake. If so let me know!
