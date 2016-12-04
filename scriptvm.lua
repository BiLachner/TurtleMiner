local function parse_statement(line)
	if line == "left" or line == "turn left" then
		return {
			command = "rotate",
			params = "left"
		}
	elseif line == "right" or line == "turn right" then
		return {
			command = "rotate",
			params = "right"
		}
	elseif line == "forward" or line == "backward"
			or line == "up" or line == "down" then
		return {
			command = "move",
			params = line
		}
	end
end

function turtleminer.build_script(owner, source)
	local lines = source:split("\n")
	local statements = {}
	for _, line in pairs(lines) do
		line = line:trim()
		if line ~= "" then
			local res = parse_statement(line)
			if res then
				statements[#statements + 1] = res
			end
		end
	end

	return {
		owner = owner,
		statements = statements,

		next_statement = function(self)
			if self.pointer <= #statements then
				local stmt = statements[self.pointer]
				self.pointer = self.pointer + 1
				return stmt
			end
		end,

		step = function(self)
			local stmt = self:next_statement()

			if stmt then
				local pos = turtleminer.run_command(self.owner, self.pos)
			end
		end,
	}
end
