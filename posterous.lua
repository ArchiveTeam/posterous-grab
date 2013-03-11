local url_count = 0

wget.callbacks.get_urls = function(file, url, is_css, iri)
  -- progress message
  url_count = url_count + 1
  if url_count % 20 == 0 then
    io.stdout:write("\r - Downloaded "..url_count.." URLs")
    io.stdout:flush()
  end

  return {}
end

local gateway_error_delay = -3

wget.callbacks.httploop_result = function(url, err, http_stat)
  if http_stat.statcode == 502 and string.match(url["host"], "%.posterous%.com$") then
    -- try again
    delay = math.pow(2, math.max(0, gateway_error_delay))

    if gateway_error_delay >= 0 then
      io.stdout:write("\nServer returned error 502. Waiting for "..delay.." seconds...\n")
      io.stdout:flush()
    end

    os.execute("sleep "..delay)
    gateway_error_delay = math.min(5, gateway_error_delay + 1)
    return wget.actions.CONTINUE

  else
    if http_stat.statcode == 200 then
      gateway_error_delay = -3
    end
    return wget.actions.NOTHING
  end
end

