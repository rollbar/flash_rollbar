# Upgrading from flash_ratchet

Download and install the latest SWF/SWC into your project, (e.g. replace `RatchetNotifier.swc` with `RollbarNotifier.swc`)

## Update references in code

Change your initialization call from `Ratchet.init(...)` to `Rollbar.init(...)`.

Search your app for all references to `ratchet`/`Ratchet` and replace them with `rollbar`/`Rollbar`.

Update all references to the `io.ratchet.*` package to the new one, `com.rollbar.*`.
