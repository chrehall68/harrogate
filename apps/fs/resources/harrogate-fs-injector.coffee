﻿exports.name = 'harrogate_fs_injector'

exports.inject = (app) ->
  # inject fs angular modules
  require('./fs-view-controller.coffee').inject app
  return

# view controller
exports.controller = require('./fs-view-controller.coffee').controller