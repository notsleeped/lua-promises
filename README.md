# Lua Promise Library

An asynchronous Promise implementation in Lua, inspired by JavaScript Promises. Suitable for use in Garry's Mod (GMod) and other Lua environments.

## 📦 Features

- Simple creation and handling of asynchronous tasks
- `:done()` method with support for `onResolve` and `onReject`
- `:next()` `onResolve`
- `:catch()` for error handling
- `:finally()` for final actions
- `promise.all()` for running multiple promises in parallel
- `promise.chain()` for running promises sequentially
- `promise.retry()` for retrying on failure

## 🚀 Installation

Copy `promise.lua` into your project and include it:

```lua
local promise = include("promise.lua")
```

## 🔧 Usage

### Creating a Promise

```lua
local p = promise.new(function(resolve, reject)
    resolve("Success!")
end)

p:done(function(result)
    print("Resolved with:", result)
end, function(err)
    print("Rejected with:", err)
end)
```

### `promise.all()`

```lua
promise.all({
    promise.new(function(r) r("a") end),
    promise.new(function(r) r("b") end),
}):done(function(results)
    PrintTable(results) -- { [1] = "a", [2] = "b" }
end)
```

### `promise.chain()`

```lua
promise.chain({
    function()
        return promise.new(function(r) r(1) end)
    end,
    function(last)
        return promise.new(function(r) r(last + 1) end)
    end
}):done(function(results)
    PrintTable(results) -- { [1] = {1}, [2] = {2} }
end)
```

## 🧪 Methods

| Method                        | Description |
|------------------------------|-------------|
| `promise.new(fn)`            | Create a new promise |
| `:done(onResolve, onReject?)`| Start the promise |
| `:next(fn)` / `:andThen(fn)` | Chain result |
| `:catch(fn)`                 | Handle errors |
| `:finally(fn)`               | Run regardless of result |
| `promise.all(list)`          | Wait for all promises |
| `promise.chain(list)`        | Execute promises sequentially |

## 📄 License

MIT — free to use, modify, and distribute. Please include attribution if redistributing or modifying.
