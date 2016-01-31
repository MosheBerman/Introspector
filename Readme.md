Introspector
---

Introspector is an app that lets you introspect the Objective-C runtime with an easy-to-use UI. If you're looking for more features, check out [Runtime Browser](https://github.com/nst/RuntimeBrowser). I didn't realize that Runtime Browser existed when I built this.

Features:
---
- See all classes that have been loaded into the runtime.
- Search including prefix and suffix matching. 
- View methods, property types, and subclasses.

How it Works:
---

Introspector uses a few Objective-C runtime methods to do its thing. Look inside the INTIntrospector class for details.

LICENSE: 
---
MIT