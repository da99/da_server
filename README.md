
da99's Crystal Server Helper
============================

This won't be of any use to you. It's my preferred
way of setting up a server in Crystal. You should
use [Kemal](https://kemalcr.com/) instead.


Install & Use
============

Install as a crystal shard. Use in place of HTTP::Server:

```crystal
s = DA_Server.new(
    host: "1.1.1.1",
    port: 123,
    user: "www-deployer",
    handlers: [HTTP::StaticFileHandler.new("Public", false)]
    )
s.host == "1.1.1.1"
s.listen
```

`#listen` raises an error if the port is being used.

HTTP handlers included in this shard:

- `File_Types`
- `No_Slash_Tail`
- `Public_Files`
- `Secure_Headers` (Hard-coded to be used as the first handler.)

You can read the [handler source code here](https://github.com/da99/da_server/blob/master/src/da_server).

The only other thing included in the shard are singleton methods:

- `.redirect_to(Int32, path, ctx)`
- `.mime(file.path.with.etc)`

