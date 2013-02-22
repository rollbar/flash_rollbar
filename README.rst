flash_rollbar
===============

flash_rollbar is an Actionscript client for reporting errors to Rollbar_.


Requirements
------------
flash_rollbar requires:

- Flash Player 10.1+
  - May work on 9 but it's untested
- mxmlc/compc if you plan on building from source
- a Rollbar `error reporting`_ account


Installation
------------
SWC
    Download the RollbarNotifier.swc file and add to your project's library path
    
Source
    Download the full source and add to your project's source path

Configuration
-------------
At the topmost level of your display list, instantiate the Rollbar singleton.
    
    Rollbar.init(this, accessToken, environment);

Here's the full list of constructor parameters (in order):

parent
    The parent display object container; should usually be "this". The notifier will report all errors for SWFs that are loaded with parent.loaderInfo.
accessToken
    Access token from your Rollbar project
environment
    Environment name. Any string up to 255 chars is OK. For best results, use "production" for your production environment.

    **default:** ``production``
person
    Optional but can be one of:

    * A string identifier for the current person/user.
    * An object describing the current person/user, containing

      - Required - id, userId, user_id, user
      - Optional - email, userEmail, user_email, emailAddress, email_address
      - Optional - username, userName, user_name, name
    * A function returning an object like the one described above
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
    The maximum number of items to send to Rollbar_ for the lifetime of the notifier instance. This is useful for rate-limiting the number of items sent to Rollbar_.
endpointUrl
    URL items are posted to.
    
    **default:** ``https://api.rollbar.com/api/1/item/``


Contributing
------------

Contributions are welcome. The project is hosted on github at http://github.com/rollbar/flash_rollbar


Additional Help
---------------
If you have any questions, feedback, etc., drop me a line at cory@rollbar.com


.. _Rollbar: http://rollbar.com/
.. _error reporting: http://rollbar.com/
.. _flash_rollbar: http://github.com/rollbar/flash_rollbar
