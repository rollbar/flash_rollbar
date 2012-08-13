flash_ratchet
===============

flash_ratchet is an Actionscript client for reporting errors to Ratchet.io_.


Requirements
------------
flash_ratchet requires:

- Flash Player 9+
- mxmlc/compc if you plan on building from source
- a Ratchet.io `error reporting`_ account


Installation
------------
SWC
    Download the RatchetNotifier.swc file and add to your project's library path
    
Source
    Download the full source and add to your project's source path

Configuration
-------------
At the topmost level of your display list, instantiate and the notifier to your stage.
    
    notifier = new RatchetNotifier(ACCESS_TOKEN, environment, userIp);

Here's the full list of constructor parameters:

access_token
    Access token from your Ratchet.io project
environment
    Environment name. Any string up to 255 chars is OK. For best results, use "production" for your production environment.

    **default:** ``production``
userIp
    The IP address of the user playing the flash movie. You should rely on the IP your server recognizes for the user in case the user is behind a firewall or NAT gateway.
rootPath
    If you compiled the SWC/SWF using the debug or verbose stack trace flags, you'll want this to be the absolute path to the root of your Actionscript source code, not including the final ``/``.

    Otherwise, set this to the source path relative to your repository's root.
    e.g. if your source tree looks like this:
        /myApp/src/com/myApp

    Set this to "src"
codeBranch
    Name of the branch used to compile your Flash movie.

    **default:** ``master``
serverData
    An Object containing any data you would like to pass along with this item to store.
maxItemCount
    The maximum number of items to send to Ratchet.io_ for the lifetime of the notifier instance. This is useful for rate-limiting the number of items sent to Ratchet.io_.
submitUrl
    URL items are posted to.
    
    **default:** ``https://submit.ratchet.io/api/1/item/``


Contributing
------------

Contributions are welcome. The project is hosted on github at http://github.com/ratchetio/flash_ratchet


Additional Help
---------------
If you have any questions, feedback, etc., drop me a line at cory@ratchet.io


.. _Ratchet.io: http://ratchet.io/
.. _error reporting: http://ratchet.io/
.. _flash_ratchet: http://github.com/ratchetio/flash_ratchet
