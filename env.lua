-- turtleminer/env.lua

-- ENVIRONMENT --
-----------------

-- [function] create environment
function turtleminer.create_env(pos, name)
  local meta = minetest.get_meta(pos) -- get meta
  -- CUSTOM SAFE FUNCTIONS --

  local function safe_print(param)
  	print(dump(param))
  end

  local function safe_date()
  	return(os.date("*t",os.time()))
  end

  -- string.rep(str, n) with a high value for n can be used to DoS
  -- the server. Therefore, limit max. length of generated string.
  local function safe_string_rep(str, n)
  	if #str * n > 6400 then
  		debug.sethook() -- Clear hook
  		error("string.rep: string length overflow", 2)
  	end

  	return string.rep(str, n)
  end

  -- string.find with a pattern can be used to DoS the server.
  -- Therefore, limit string.find to patternless matching.
  local function safe_string_find(...)
  	if (select(4, ...)) ~= true then
  		debug.sethook() -- Clear hook
  		error("string.find: 'plain' (fourth parameter) must always be true for turtleminerrs.")
  	end

  	return string.find(...)
  end


  -- [function] move
  local function move(direction)
    turtleminer.move(pos, direction, name)
  end

  -- [function] dig
  local function dig(where)
    turtleminer.dig(pos, where, name)
  end

  -- [function] rotate
  local function rotate(direction)
    turtleminer.rotate(pos, direction, name)
  end

  -- ENVIRONMENT TABLE --

  local env = {
    turtle = {
      move = move,
      dig = dig,
      turn = rotate,
    },
    string = {
      byte = string.byte,
      char = string.char,
      format = string.format,
      len = string.len,
      lower = string.lower,
      upper = string.upper,
      rep = safe_string_rep,
      reverse = string.reverse,
      sub = string.sub,
      find = safe_string_find,
    },
    math = {
      abs = math.abs,
      acos = math.acos,
      asin = math.asin,
      atan = math.atan,
      atan2 = math.atan2,
      ceil = math.ceil,
      cos = math.cos,
      cosh = math.cosh,
      deg = math.deg,
      exp = math.exp,
      floor = math.floor,
      fmod = math.fmod,
      frexp = math.frexp,
      huge = math.huge,
      ldexp = math.ldexp,
      log = math.log,
      log10 = math.log10,
      max = math.max,
      min = math.min,
      modf = math.modf,
      pi = math.pi,
      pow = math.pow,
      rad = math.rad,
      random = math.random,
      sin = math.sin,
      sinh = math.sinh,
      sqrt = math.sqrt,
      tan = math.tan,
      tanh = math.tanh,
    },
    table = {
      concat = table.concat,
      insert = table.insert,
      maxn = table.maxn,
      remove = table.remove,
      sort = table.sort,
    },
    os = {
      clock = os.clock,
      difftime = os.difftime,
      time = os.time,
      datetable = safe_date,
    },
  }
  return env -- return table
end

-- [function] run code (in sandbox env)
function turtleminer.run(f, env)
  setfenv(f, env)
  local e, msg = pcall(f)
  if e == false then return msg end
end

-- [function] run file under env
function turtleminer.run_string(pos, name, string)
  local meta = minetest.get_meta(pos)
  local env = turtleminer.create_env(pos, name) -- environment
  local f = loadstring(string) -- load func
  local e = turtleminer.run(f, env) -- run function
  -- if error, return
  if e then return e end
end
