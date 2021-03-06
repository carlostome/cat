Description
===========
This project aims to formalize some parts of category theory using cubical agda
&mdash; an extension to agda permitting univalence.  To learn more about this
[read the docs](https://agda.readthedocs.io/en/latest/language/cubical.html).

This project draws a lot of inspiration from [the
HoTT-book](https://homotopytypetheory.org/book/).

If you want more information about this project, then you're in luck.
This is my masters thesis.  Go ahead and read it
[here](http://web.student.chalmers.se/~hanghj/papers/univalent-categories.pdf)
or alternative like so:

    cd doc/
    make

Dependencies
============
To successfully compile the following is needed:

* The master branch of Agda.
* [Agda Standard Library](https://github.com/agda/agda-stdlib)
* [Cubical](https://github.com/Saizan/cubical-demo/)

Has been tested with:

  * Agda version 2.6.0-d3efe64

Building
========
You can build the library with

    git submodule update --init
    make

The Makefile takes care of using the right dependencies.
Unfortunately I have not found a way to automatically inform
`agda-mode` that it should use these dependencies.  So what you can do
in stead is to copy these libraries to a global location and then add
them system wide:

    mkdir -p ~/.agda/libs
    cd ~/.agda/libs
    git clone $CAT/libs/std-lib
    git clone $CAT/libs/cubical
    echo << EOF | tee -a ~/.agda/libraries
    $HOME/.agda/libs/agda-stdlib/standard-library.agda-lib
    $HOME/.agda/libs/cubical/cubical.agda-lib
    EOF

Or you could symlink them as well if you want.
