module.exports = class PrettyJSON
    replacer: (match, pIndent, pKey, pVal, pEnd) ->
        key = '<span class=json-key>'
        val = '<span class=json-value>'
        str = '<span class=json-string>'
        r = pIndent || ''
        if (pKey)
            r = r + key + pKey.replace(/[": ]/g, '') + '</span>: '
        if (pVal)
            r = r + (if (pVal[0] == '"') then str else val) + pVal + '</span>'
        return r + (pEnd || '')

    prettyPrint: (obj) ->
        jsonLine = /^( *)("[\w]+": )?("[^"]*"|[\w.+-]*)?([,[{])?$/mg
        return JSON.stringify(obj, null, 3)
            .replace(/&/g, '&amp;')
            .replace(/\\"/g, '&quot;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(jsonLine, @replacer)
