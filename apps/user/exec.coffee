Express = require 'express'
Url = require 'url'

ServerError = require_harrogate_module '/shared/scripts/server-error.coffee'
UserManager = require_harrogate_module '/shared/scripts/user-manager.coffee'
UserResource = require './rest-resources/user-resource.coffee'

AppManifest = require './manifest.json'

# the fs router
router = Express.Router()

# '/' is relative to <manifest>.web_api.user.uri
router.get '/current', (request, response, next) ->
  if request.logged_in_user?
    user_resource = new UserResource(request.logged_in_user)
    user_resource.get_representation()
    .then (representation) ->
      response.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
      response.setHeader 'Pragma', 'no-cache'
      response.setHeader 'Expires', '0'
      response.writeHead 200, { 'Content-Type': 'application/json' }
      return response.end "#{JSON.stringify(representation)}", 'utf8'
    .catch (e) ->
      if e instanceof ServerError
        response.writeHead e.code, { 'Content-Type': 'application/javascript' }
        return response.end "#{JSON.stringify(error: e.message)}", 'utf8'
      else
        next e
    .done()
  else
    response.writeHead 404, { 'Content-Type': 'application/json' }
    return response.end "#{JSON.stringify(error: 'No user is logged in')}", 'utf8'

router.get '/', (request, response, next) ->
  representation =
      links:
        self:
          href: AppManifest.web_api.users.uri

  if request.logged_in_user?
    representation.links.current = 
      login: request.logged_in_user.login
      href: request.logged_in_user.uri

  for user_name, user of UserManager.users
    if not representation.links.users?
      representation.links.users = []

    user_resource = new UserResource user
    representation.links.users.push { login: user_resource.user.login, href: user_resource.url }

  response.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
  response.setHeader 'Pragma', 'no-cache'
  response.setHeader 'Expires', '0'
  response.writeHead 200, { 'Content-Type': 'application/json' }
  return response.end "#{JSON.stringify(representation)}", 'utf8'

module.exports =
  init: (app) =>
    # add the router
    app.web_api.users['router'] = router
    return

  exec: ->