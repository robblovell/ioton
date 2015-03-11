
    objectifyStr = (text) ->
        stack = new Stack()
        indexStack = new Stack()

        # helper functions.
        push = (value, type, index=null) ->
            stack.push([value, type])
            if (index?)
                indexStack.push(index)

        pop = () ->
            [value, na, na] = stack.pop()
            indexStack.pop()
            return value

        setObject = (value) ->
            index = indexStack.pop()
            [na, na, schema] = stack.peek()
            stack.peek()[0][index++] = value
            indexStack.push(index)

        setArray = (value) ->
            stack.peek()[0].push(value)

        set = (value) ->
            if (!stack.isEmpty())
                [na, type] = stack.peek()
                if (type is "object")
                    setObject(value)
                else
                    setArray(value)

        findEnd = (token, i) ->
            j = i
            while i < token.length and token[i] != '}' and token[i] != ']'
                i++
            return [j,i-1,i]

        # the main algorithm.
        objects = null
        tokens = text.split(',')
        j=0

        index = 0
        for token in tokens
            i = 0
            while i < token.length
                # arrays and objects.
                if (token[i] is '{') # new object
                    # push down new object
                    push({}, "object", 0)
                    i++
                else if token[i] is '}'
                    # pop out one object
                    objects = pop()
                    set(objects)
                    i++

                else if (token[i] is '[') # new array
                    # push down new array
                    push([], "array")
                    i++
                else if token[i] is ']'
                    # pop out one array
                    [objects, na] = stack.pop()
                    set(objects)
                    i++

                else # elements of the object or array.
                    [na, type] = stack.peek()
                    if (type is "object")
                        [start, end, i] = findEnd(token, i)
                        setObject(token[start..end])
                    else
                        # push into top array
                        [start, end, i] = findEnd(token, i)
                        setArray(token[start..end])

        return objects