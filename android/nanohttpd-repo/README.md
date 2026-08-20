# Local NanoHttpd Maven repo

Rebuilt from https://github.com/NanoHttpd/nanohttpd (packages under `org.nanohttpd.*`)
so FolioReader / r2-streamer-kotlin can load `org.nanohttpd.router.RouterNanoHTTPD`.

Maven Central `org.nanohttpd:nanohttpd:2.3.1` ships the older `fi.iki.elonen.*` packages,
which caused `NoClassDefFoundError: Lorg/readium/r2/streamer/server/Server` at runtime
(Server extends AbstractServer → RouterNanoHTTPD).

Artifacts: `org.nanohttpd:nanohttpd:2.3.2-ponomar` and `nanohttpd-nanolets:2.3.2-ponomar`.
