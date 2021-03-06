Tower.Support.Callbacks =
  ClassMethods:
    before: ->
      @appendCallback "before", arguments...
      
    after: ->
      @appendCallback "after", arguments...
      
    callback: ->
      @appendCallback arguments...
      
    removeCallback: (action, phase, run) ->
      @
      
    appendCallback: (phase) ->
      args = Tower.Support.Array.args(arguments, 1)
      if typeof args[args.length - 1] != "object"
        method    = args.pop()
      if typeof args[args.length - 1] == "object"
        options   = args.pop()
      method    ||= args.pop()
      options   ||= {}
      
      callbacks   = @callbacks()
      
      for filter in args
        callback = callbacks[filter] ||= new Tower.Support.Callbacks.Chain
        callback.push phase, method, options
        
      @
      
    prependCallback: (action, phase, run, options = {}) ->
      @
      
    callbacks: ->
      @_callbacks ||= {}
      
  runCallbacks: (kind, block) ->
    chain = @constructor.callbacks()[kind]
    if chain
      chain.run(@, block)
    else
      block.call @
      
  _callback: (callbacks...) ->
    (error) =>
      for callback in callbacks
        callback.call(@, error) if callback
      
class Tower.Support.Callbacks.Chain
  constructor: (options = {}) ->
    @[key] = value for key, value of options

    @before ||= []
    @after  ||= []

  run: (binding, block) ->
    runner    = (callback, next) => callback.run(binding, next)
    
    Tower.async @before, runner, (error) =>
      unless error
        switch block.length
          when 0
            block.call(binding)
            Tower.async @after, runner, (error) =>
              binding
          else
            block.call binding, (error) =>
              unless error
                Tower.async @after, runner, (error) =>
                  binding
    
  push: (phase, method, filters, options) ->
    @[phase].push new Tower.Support.Callback(method, filters, options)
    
class Tower.Support.Callback
  constructor: (method, options = {}) ->
    @method   = method
    @options  = options
    
  run: (binding, next) ->
    method  = @method
    method  = binding[method] if typeof method == "string"
    
    switch method.length
      when 0
        result = method.call binding
        next(if !result then new Error("Callback did not pass") else null)
      else
        method.call binding, next

module.exports = Tower.Support.Callbacks
