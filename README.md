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

`MS_TRANSLATOR_ACCESS_TOKEN=YOUR_ACCESS_TOKEN`

## Sample Interaction

```
user> hubot translate me bienvenu
hubot> " bienvenu" is Turkish for " Bienvenu "
user> hubot translate me from french into english bienvenu
hubot> The French " bienvenu" translates as " Welcome " in English
```
