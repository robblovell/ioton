modules.exports = Class Typer
    constructor:() ->

    makeValue = (value, type) ->
        switch (type)
            when "string"
                return value.toString()
            when 'number', 'uint', 'int', 'float'
                return parseFloat(value)
            when "boolean"
                return value == 'true'
            else
                return value