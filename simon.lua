-- Connect to Redis
local redis = require 'redis'
local red = redis:new()
red:connect('127.0.0.1', 6379)

-- Get session ID from cookie and host from headers
local sid = ngx.var['cookie_connect.sid']
local headers = ngx.req.get_headers()
local host = headers['host']
host = string.gsub(host, "^www.", "")

if sid then

    -- Check for an assigned backend
    local backend, err = red:get('sess:' .. host .. ':' .. sid)

    -- Use the assigned backend if it exists
    if backend ~= ngx.null then
        ngx.var.proxy_to = backend
        return
    end

end

-- Choose a random backend based on the host
local backends = red:smembers('backends:' .. host)
local chosen = backends[math.random(#backends)]

if sid then red:set('sess:' .. host .. ':' .. sid, chosen) end

-- Set chosen proxy server
ngx.var.proxy_to = chosen

