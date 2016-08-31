# Rollbar notifier for Flash (AS3)

<!-- RemoveNext -->
Flash (ActionScript 3) library for reporting exceptions, errors, and log messages to [Rollbar](https://rollbar.com).

<!-- Sub:[TOC] -->

## Quick start

1. Download the [flash_rollbar](https://github.com/rollbar/flash_rollbar/tree/master/src) code or just the [Rollbar.swc](https://github.com/rollbar/flash_rollbar/blob/master/build/swc/Rollbar.swc) file.
2. Place the ```flash_rollbar/src``` directory in your source path or place the ```Rollbar.swc``` file in your project's library path.
3. Call ```Rollbar.init(this, accessToken, environment);``` from your top-level ```DisplayObject```.

```actionscript
package {
  import com.rollbar.notifier.Rollbar;

  public class MyApp extends Sprite {

    public static const ROLLBAR_ACCESS_TOKEN:String = "POST_CLIENT_ITEM_ACCESS_TOKEN";

    public function MyApp() {
      var environment:String = isDebug() ? "development" : "production";
      var person:Object = {id: getUserId(), email: getEmail(), name: getName()};  // optional
      Rollbar.init(this, ROLLBAR_ACCESS_TOKEN, environment, person);
    }
  }
}
```


```Rollbar.init()``` installed a global error handler, so you don't need to do anything else.

<!-- RemoveNextIfProject -->
Be sure to replace ```POST_CLIENT_ITEM_ACCESS_TOKEN``` with your project's ```post_client_item``` access token, which you can find in the Rollbar.com interface.


## Requirements

- Flash Player 10.1+
  - May work on 9, but not tested.
- mxmlc/compc if you plan on building from the command-line
- A [Rollbar](http://rollbar.com) account

## Reporting caught errors

If you want to instrument specific parts of your code, call ```Rollbar.handleError(err)```:

```actionscript
private function onEnterFrame(event:Event) {
    try {
      gameLoop(event);
    } catch (err:Error) {
      Rollbar.handleError(err);
    }
}
```

**Advanced:** to override parts of the payload before it is sent to the Rollbar API, pass them in the second argument to `handleError()`. For example, to control how your data will be grouped, you can pass a custom `fingerprint`:

```actionscript
Rollbar.handleError(err, {fingerprint: "a string to uniquely identify this error"});
```

The second argument, `extraData`, should be an object. Each key in `extraData` will overwrite the previous contents of the payload. For all options, see the [API documentation](http://rollbar.com/docs/api_items/).


## Configuration

At the topmost level of your display list, instantiate the Rollbar singleton.

```actionscript
Rollbar.init(this, accessToken, environment);
```

Here's the full list of constructor parameters (in order):

  <dl>
<dt>parent
</dt>
<dd>The parent display object container; should usually be ```this```. The notifier will report all errors for SWFs that are loaded with ```parent.loaderInfo```.
</dd>
<dt>accessToken
</dt>
<dd>Access token from your Rollbar project
</dd>
<dt>environment
</dt>
<dd>Environment name. Any string up to 255 chars is OK. For best results, use ```"production"``` for your production environment.

Default: ``"production"``

</dd>
<dt>person
</dt>
<dd>Optional but can be one of:

  - A string identifier for the current person/user.
  - An object describing the current person/user, containing
    - Required - id, userId, user_id, user
    - Optional - email, userEmail, user_email, emailAddress, email_address
    - Optional - username, userName, user_name, name
  - A function returning an object like the one described above

</dd>
<dt>rootPath
</dt>
<dd>If you compiled the SWC/SWF using the debug or verbose stack trace flags, you'll want this to be the absolute path to the root of your Actionscript source code, not including the final ```/```.

Otherwise, set this to the source path relative to your repository's root.
e.g. if your source tree looks like this:
```
/myApp/src/com/myApp
```

Set this to ```"src"```

</dd>
<dt>codeBranch
</dt>
<dd>Name of the branch used to compile your Flash movie.

Default: ```"master"```

</dd>
<dt>serverData
</dt>
<dd>An Object containing any data you would like to pass along with this item to store.
</dd>
<dt>maxItemCount
</dt>
<dd>The maximum number of items to send to Rollbar for the lifetime of the notifier instance. This is useful for rate-limiting the number of items sent to Rollbar.
</dd>
<dt>endpointUrl
</dt>
<dd>URL items are posted to.

Default: ```"https://api.rollbar.com/api/1/item/"```
</dd>
</dl>
