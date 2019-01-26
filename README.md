# Custom Elements

[billstclair/elm-custom-element](http://package.elm-lang.org/packages/billstclair/elm-custom-element/latest) is a package to collect Html custom element implementations. 

Note that when you use the included modules in your project, they won't actually DO anything unless you follow the instructions below to load their JavaScript files.

Here are the custom element modules:

* `CustomElement.FileListener`

  Attach a `<file-listener>` to a `<file>` element, and when the user
  chooses a file, you'll get an event containing the file's content as
  both a string and a Data URL.
  
  JavaScript file: `site/js/file-listener.js`
  
  This was a kluge to enable uploading binary files before `elm/http`
  v2.x `elm/file`, and `elm/bytes`. If you still need to use
  `elm/http` 1.x, then using this makes sense. For new code, use
  `elm/file` with `elm/http` v2.x.
  
* `CustomElement.CodeEditor`

  A simple wrapper around the [CodeMirror](https://codemirror.net) code editor.
  Inspired by [Luke Westby](https://github.com/lukewestby)'s
  [Elm Europe talk](https://youtu.be/tyFe9Pw6TVE).
  
  JavaScript file: `site/js/code-editor.js`
  Support files: `site/lib/ codemirror.css, codemirror.js`

## Adding Custom Elements to Your Project

In order to use custom elements, you must start your project from a `.html` that includes your compiled Elm file and the custom element JavaScript files, and any port code you need. You can start this by copying the `site` directory from here to your project, then edit `site/index.html`. Remove the custom elements you don't need from its `<head>` section, and customize anything else that needs it. Only include in your application the files in the `site/js` directory for custom elements you use.

    $ git clone git@github.com:billstclair/elm-custom-element.git
    $ cd elm-custom-element
    $ cp -R site .../<your project directory>/
    $ cd .../<your project directory>
    $ <editor> index.html

The included `index.html` assumes your Elm code is in `elm.js`. You can make this so with something like the following:

    elm make src/Main.elm --output site/elm.js
    
I usually run my Elm projects during development using `elm reactor`, if only beacause some browsers aren't happy with `file:` URLs:

    $ cd .../<project-dir>
    $ elm reactor

Then aim your browser at http://localhost:8000/site/index.html

## Building and Running the Example

The file `src/Main.elm` is an example of using the included custom elements.

To build and run it:

    $ git clone git@github.com:billstclair/elm-custom-element.git
    $ cd elm-custom-element
    $ elm make src/Main.elm --output site/elm.js
    $ elm reactor
    
Then aim your web browser at http://localhost:8000/site/index.html

The example is live at [billstclair.github.io/elm-custom-element](https://billstclair.github.io/elm-custom-element/)

## Help to Expand the Library

I encourage pull requests, for custom elements that you think will be useful to the community. To add a custom element, do the following:

0. Fork [billstclair/elm-custom-element](https://github.com/billstclair/elm-custom-element) on GitHub.

1. Add your JavaScript file to the `site/js` directory.
   The file should be patterned after `file-listener.js`, defining NO
   top-level variables or functions. Add a `<script>` element to
   `site/index.html` to load your JavaScript file.
   
2. If your custom element requires JavaScript written by somebody else,
   put those files in the `site/lib` directory, and edit `site/lib/README.md`
   to include a description of those files and their license(s). Add `<script>`
   elements to `site/index.html` for those files, too.

3. Add your Elm interface file to the `src/CustomElement` directory.
   The file should be patterned after `FileListener.elm`, exposing a
   function to create your custom element(s), one of more functions
   returning an `Html.Attribute` to set properties of the element, one
   or more functions returning an `Html.Attribute` to handle an event
   from the element, and any convenience functions that make sense.

4. Add your new module to the `exposed-modules` in `elm.json`.

5. Add an example of using your element to `example/Main.elm`, expanding
   its `Model` and `Msg` as necessary, and adding display code to `view`
   and event handling code to `update`.
   
6. Test your example, using the instructions above.

7. Add your element to the list above in this `README.md` file.

8. Ensure your exposed interface is all documented with:

       elm make --docs docs.json
   
9. Review `README.md` and `docs.json` with https://elm-doc-preview.netlify.com

10. Submit a pull request. Don't worry about bumping the version number.
    I'll do that.

# Compatibility

The [Custom Elements Registry](https://developer.mozilla.org/en-US/docs/Web/API/CustomElementRegistry) is still a fairly new part of the web browser DOM. It isn't supported by all browsers, as outlined in the compatibility table on that page.

In particular, Microsoft Internet Explorer and Edge do not support custom elements. There's a polyfill, and I included that in `site/lib/custom-elements.min.js`, but it didn't make the example work in IE on my Windows machine, though it DID make it work in Firefox on my Mac desktop, without setting `dom.webcomponents.customelements.enabled` true in `about:config` (the polyfill isn't necessary, if you do that). I commented out the inclusion of the polyfill in `site/index.html`. Use it if you wish.

If you're motivated to make the code work for IE and/or Edge, or for other browsers that don't currently work, I'll gladly accept a pull request that does that.

Bill St. Clair, 9 October 2018
