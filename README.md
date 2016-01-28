# hubot-microsoft-translator

Allows Hubot to know many languages using Microsoft Translator

See [`src/microsoft-translator.coffee`](src/microsoft-translator.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-microsoft-translator --save`

Then add **hubot-microsoft-translator** to your `external-scripts.json`:

```json
[
  "hubot-microsoft-translator"
]
```

set the environment variable:

```
HUBOT_MICROSOFT_TRANSLATOR_CLIENT_ID=YOUR_MICROSOFT_TRANSLATOR_CLIENT_ID
HUBOT_MICROSOFT_TRANSLATOR_CLIENT_SECRET=YOUR_MICROSOFT_TRANSLATOR_SECRET
```

Visit this to find out how to get the CLIENT_ID and SECRET
- http://blogs.msdn.com/b/translation/p/gettingstarted1.aspx

## Sample Interaction

```
user> hubot translate me bienvenu
hubot> " bienvenu" is Turkish for " Bienvenu "
user> hubot translate me from french into english bienvenu
hubot> The French " bienvenu" translates as " Welcome " in English
```
