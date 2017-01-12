var ScriptLoader = (function(_this) {
  'use strict';

  return function() {
    var version = '1.4.0';

    var loaded    = [];
    var loading   = {};
    var callbacks = {};

    function isFunction(object) {
      var getType = {}
      return object && getType.toString.call(object) === '[object Function]'
    }

    var add_callback = function(url, callback) {
      if( !callback ){ return false }

      callbacks[url] ? null : callbacks[url] = [];
      callbacks[url].push( callback );
    }

    var exec_callbacks = function(url) {
      var fn, k;
      var set = callbacks[url];

      // Execute Callbacks for URL
      for (k in set) {
        fn = set[k];
        fn();
      }

      delete callbacks[url];
    }

    var add_loading = function(url, callback) {
      loading[url] = true;
      add_callback(url, callback);
    }

    var add_loaded = function(url) {
      loaded.push(url);
      delete loading[url];
    }

    var _delete = function(url) {
      // cleanup arrays
      delete loaded[ loaded.indexOf(url) ];
      delete loading[url];

      // cleanup DOM
      var scripts = document.querySelectorAll('[src="' + url + '"]');
      for(var i; i++; scripts.length){
        var script = scripts[i];
        script.parentNode.removeChild(script);
      }
    }

    var force_load = function( url, arg_1, arg_2 ) {
      _delete(url);
      load( url, arg_1, arg_2 );
    }

    // 1. load url, function(){ }
    // 2. load url, { ... }, function(){ }
    var load = function( url, arg_1, arg_2 ) {
      var callback, options;

      // if first arg presence
      // get callback function and options
      if( arg_1 ){
        if( isFunction(arg_1) ) {
          callback = arg_1;
        } else {
          options  = arg_1;
          callback = arg_2;
        }
      }

      // if URL found in `loaded` -> add callback & exec
      // and RETURN
      if ( loaded.indexOf(url) !== -1 ) {
        add_callback(url, callback);
        exec_callbacks(url);
        return false;
      }

      // if URL found in `loading` - add callback
      // and RETURN
      if ( loading[url] ) {
        add_callback(url, callback);
        return false;
      }

      // Add to `loading`
      add_loading(url, callback);

      // Create script tag and add basic properties
      var script = document.createElement("script");

      script.type    = 'text/javascript';
      script.charset = 'utf-8';
      script.defer   = true;
      script.async   = true;

      // set options to script tag
      if( options ){
        for(var key in options) {
          var attr = options[key];
          script.setAttribute(key, attr)
        }
      }

      if (script.readyState) {
        //IE
        script.onreadystatechange = function() {
          if (script.readyState === 'loaded' || script.readyState === 'complete') {
            script.onreadystatechange = null;

            add_loaded(url);
            exec_callbacks(url);
          }
        };
      } else {
        //Others
        script.onload = function() {
          add_loaded(url);
          exec_callbacks(url);
        };
      }

      script.src = url;
      document.getElementsByTagName('head')[0].appendChild(script);
    }

    return {
      load: load,
      delete: _delete,
      force_load: force_load,

      loaded:  loaded,
      version: version,
    };
  }
})(this)();

window.ScriptLoader = ScriptLoader;
