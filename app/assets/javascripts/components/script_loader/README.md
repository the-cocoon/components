### Simple Async Script Loader

If you are looking for simple tool for Async Script Loading, this can be useful for you

**features**

- avoid duplication URL loading
- callbacks queue

```javascript
<script type="text/javascript" src='scriptLoader.js'></script>
```

```javascript
  <script>
    lodash_url = "https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.4.0/lodash.js" + '?' + Math.random();
    jq_url     = "https://code.jquery.com/jquery-2.2.0.js" + '?' + Math.random();

    // Just loading - no callback
    ScriptLoader.load(jq_url);

    // Loading with callbacks
    ScriptLoader.load(lodash_url, function(){
      console.log("Script Loaded 1")
      console.log( _.map([1, 2, 3], function(n) { return n * 3; }) )
    })

    ScriptLoader.load(lodash_url, function(){
      console.log("Script Loaded 2")
      console.log( _.map([1, 2, 3], function(n) { return n * 3; }) )

      ScriptLoader.load(jq_url, function(){
        console.log("Script Loaded 4 :: Jquery ");
        console.log( $.fn.jquery );

        ScriptLoader.load(lodash_url, function(){
          console.log("Script Loaded 5")
          console.log( _.map([1, 2, 3], function(n) { return n * 3; }) )
        })
      })
    })

    ScriptLoader.load(lodash_url, function(){
      console.log("Script Loaded 3")
      console.log( _.map([1, 2, 3], function(n) { return n * 3; }) )
    })
  </script>
```

### Install

```
npm install script_loader --save
```

### MIT License, 2016
