local function parse_statement(line, lineno)
	if line == "left" or line == "turn left" 
			or line == "l" or line == "<" then 	--HJG
		return {
			command = "rotate",
			params  = "left"
		}
	elseif line == "right" or line == "turn right" 
			or line == "r" or line == ">" then 	--HJG
		return {
			command = "rotate",
			params  = "right"
		}
	elseif line == "forward" or line == "backward"
			or line == "f"  or line == "b"    	--HJG
			or line == "up" or line == "down"
			or line == "u"  or line == "d" then
		return {
			command = "move",
			params  = line
		}
	elseif line == "build" or line == "place front" then
		return {
			command = "build",
			params  = "front"
		}
	elseif line == "place below" then
		return {
			command = "build",
			params  = "below"
		}
	elseif line == "dig" or line == "dig front" then
		return {
			command = "dig",
			params  = "front"
		}
	elseif line == "dig below" then
		return {
			command = "dig",
			params  = "below"
		}
	elseif line == "dig above" then  --HJG
		return {
			command = "dig",
			params  = "above"
		}
	else
		return nil
	end
end

function turtleminer.build_script(owner, t_id, source)
	local lines = source:split("\n")
	local statements = {}
	local lineno = 1
	for _, line in pairs(lines) do
		line = line:trim()
		if string.sub(line,1,2) == "--" then line = "" end  -- ignore lines with comment
		if line ~= "" then
			local res = parse_statement(line, lineno)
			if res then
				statements[#statements + 1] = res
			else
				print("Error at line " .. lineno .. ": " .. line)
				return "Error at line " .. lineno .. ": " .. line
			end
		end
		lineno = lineno + 1
	end

	local errored = false
	local pointer = 1

	return {
		next_statement = function(self)
			if pointer <= #statements then
				local stmt = statements[pointer]
				pointer = pointer + 1
				return stmt
			end
		end,

		is_alive = function(self)
			return pointer <= #statements and not errored
		end,

		step = function(self)
			if errored then
				return
			end

			local stmt = self:next_statement()

			if stmt then
				local pos = turtleminer.turtles[t_id].pos
				local res = turtleminer.run_command(owner, pos, stmt.command, stmt.params)
				if not pos then
					errored = true
				end
			end
		end,
	}
end
