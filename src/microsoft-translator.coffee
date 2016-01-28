# Description:
#   Allows Hubot to know many languages.
#
# Commands:
#   hubot translate me <phrase> - Searches for a translation for the <phrase> and then prints that bad boy out.
#   hubot translate me from <source> into <target> <phrase> - Translates <phrase> from <source> into <target>. Both <source> and <target> are optional

xml2js = require('xml2js')

CLIENT_ID = process.env.HUBOT_MICROSOFT_TRANSLATOR_CLIENT_ID
CLIENT_SECRET = process.env.HUBOT_MICROSOFT_TRANSLATOR_CLIENT_SECRET
TRANSLATOR_URL = "http://api.microsofttranslator.com/v2/Http.svc"

languages =
  "ar": "Arabic"
  "bs-Latn": "Bosnian"
  "bg": "Bulgarian"
  "ca": "Catalan"
  "zh-CHS": "Simplified Chinese"
  "zh-CHT": "Traditional Chinese"
  "hr": "Croatian"
  "cs": "Czech"
  "da": "Danish"
  "nl": "Dutch"
  "en": "English"
  "et": "Estonian"
  "fi": "Finnish"
  "fr": "French"
  "de": "German"
  "el": "Greek"
  "ht": "Haitian Creole"
  "he": "Hebrew"
  "hi": "Hindi"
  "mww": "Hmong Daw"
  "hu": "Hungarian"
  "id": "Indonesian"
  "it": "Italian"
  "ja": "Japanese"
  "sw": "Kiswahili"
  "tlh": "Klingon"
  "tlh-Qaak": "Klingon"
  "ko": "Korean"
  "lv": "Latvian"
  "lt": "Lithuanian"
  "ms": "Malay"
  "mt": "Maltese"
  "no": "Norwegian"
  "fa": "Persian"
  "pl": "Polish"
  "pt": "Portuguese"
  "otq": "Querétaro Otomi"
  "ro": "Romanian"
  "ru": "Russian"
  "sr-Cyrl": "Serbian Cyrillic"
  "sr-Latn": "Serbian Latin"
  "sk": "Slovak"
  "sl": "Slovenian"
  "es": "Spanish"
  "sv": "Swedish"
  "th": "Thai"
  "tr": "Turkish"
  "uk": "Ukrainian"
  "ur": "Urdu"
  "vi": "Vietnamese"
  "cy": "Welsh"
  "yua": "Yucatec Maya"

xmlParser = new xml2js.Parser()


GetAccessToken = (client, id, secret) ->
  return (callback) ->
    client.http('https://datamarket.accesscontrol.windows.net/v2/OAuth2-13')
      .header('Content-Type', 'application/x-www-form-urlencoded')
      .post(
        "grant_type=client_credentials&" +
        "client_id=#{encodeURIComponent(CLIENT_ID)}&" +
        "client_secret=#{encodeURIComponent(CLIENT_SECRET)}&" +
        "scope=http://api.microsofttranslator.com"
      ) (err, res, body) ->
        if err
          callback "Failed to get access token from Microsoft"
          return
  
        try
          authInfo = JSON.parse(body)
          callback null, authInfo.access_token

        catch err
          callback err


Detect = (client, auth, text) ->
  return (callback) ->
    client.http("#{TRANSLATOR_URL}/Detect")
      .query({
        text: text
      })
      .headers(Authorization: auth)
      .get() (err, res, body) ->
        if err
          callback "Failed to detect source language: " + err
          return

        try
          xmlParser.parseString body, (err, result) ->
            langCode = result['string']['_']
            callback null, langCode

        catch err
          callback "Failed to parse Detect result: #{body}, error: #{err}"


Translate = (client, auth, text, from, to) ->
  return (callback) ->
    doTrans = (params, callback) ->
      client.http("#{TRANSLATOR_URL}/Translate")
        .query(params)
        .headers(Authorization: auth)
        .get() (err, res, body) ->
          if err
            callback "Failed to translate: " + err
            return

          try
            xmlParser.parseString body, (err, result) ->
              translated = result['string']['_']
              callback null, translated, params.from, params.to

          catch err
            callback "Failed to parse translate result: #{body}, error: #{err}"

    params = {
      text: text
      to: to
    }
    if from != 'auto'
      params.from = from
      doTrans(params, callback)
    else
      Detect(client, auth, text) (err, langCode) ->
        params.from = langCode
        doTrans(params, callback)

getCode = (language,languages) ->
  for code, lang of languages
    return code if lang.toLowerCase() is language.toLowerCase()


module.exports = (robot) ->
  language_choices = (language for _, language of languages).sort().join('|')
  pattern = new RegExp('translate(?: me)?' +
                       "(?: from (#{language_choices}))?" +
                       "(?: (?:in)?to (#{language_choices}))?" +
                       '(.*)', 'i')
  robot.respond pattern, (msg) ->
    term   = "\"#{msg.match[3]?.trim()}\""
    source = if msg.match[1] isnt undefined then getCode(msg.match[1], languages) else 'auto'
    target = if msg.match[2] isnt undefined then getCode(msg.match[2], languages) else 'en'

    GetAccessToken(robot, CLIENT_ID, CLIENT_SECRET) (err, accessToken) ->
      if err
        msg.send "Failed to get access token from Microsoft"
        robot.emit 'error', err
        return

      authHeader = "Bearer #{accessToken}"

      Translate(msg, authHeader, term, source, target) (err, trans, from, to) ->
        if err
          msg.send err
          robot.emit 'error', err
          return

        msg.send "#{term} in #{languages[from]}" +
          " is translated to #{languages[to]}: #{trans}"
