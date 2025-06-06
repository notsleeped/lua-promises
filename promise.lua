---@enum promise.states
local STATES = {
	PENDING  = 1,
	RESOLVED = 2,
	REJECTED = 3,
}

---@class promise
---@field private callback fun(resolve: fun(...: any), reject: fun(...: any))|nil
---@field private onResolve fun(...: any)|nil
---@field private onReject fun(...: any)|nil
---@field private onFinally fun()|nil
---@field private state promise.states
local promise = {}
promise.__index = promise

---@param callback? fun(resolve: fun(...: any), reject: fun(...: any))
---@return promise
function promise.new(callback)
	local self = {
		callback = callback,
		state = STATES.PENDING
	}

	setmetatable(self, promise)

	return self
end

---@return promise
function promise:start()
	if not self.callback or self.state ~= STATES.PENDING then return self end

	self.callback(function(...)
		self:resolve(...)
	end, function(...)
		self:reject(...)
	end)

	return self
end

---@param ... any
function promise:resolve(...)
	if self.state ~= STATES.PENDING then return end
	self.state = STATES.RESOLVED

	if self.onResolve then self.onResolve(...) end
	if self.onFinally then self.onFinally() end
end

---@param ... any
function promise:reject(...)
	if self.state ~= STATES.PENDING then return end
	self.state = STATES.REJECTED

	if self.onReject then self.onReject(...) end
	if self.onFinally then self.onFinally() end
end

---@param onResolve fun(...: any)
---@param onReject? fun(...: any)
---@return promise
function promise:done(onResolve, onReject)
	self.onResolve = onResolve
	self.onReject = onReject

	return self:start()
end

---@param onReject fun(...: any)
---@return promise
function promise:catch(onReject)
	self.onReject = onReject

	return self:start()
end

---@param onResolve fun(...: any)
---@return promise
function promise:next(onResolve)
	self.onResolve = onResolve

	return self:start()
end

---@param onResolve fun(...: any)
---@return promise
function promise:andThen(onResolve)
	return self:next(onResolve)
end

---@param callback fun()
---@return promise
function promise:finally(callback)
	self.onFinally = callback

	return self
end

---@return boolean
function promise:isPending()
	return self.state == STATES.PENDING
end

do
	local function promiseHandler(list, resolve, reject)
		local results = {}
		local completed = 0
		local total = #list

		for id, p in ipairs(list) do
			p:next(function(result)
				results[id] = result
				completed = completed + 1

				if completed ~= total then return end

				resolve(results)
			end):catch(function(err)
				reject(err)
			end)
		end
	end

	---@param list promise[]
	---@return promise
	function promise.all(list)
		return promise.new(function(...) promiseHandler(list, ...) end)
	end
end

do
	---@param list fun(): promise[]
	---@return promise
	function promise.chain(list)
		return promise.new(function(resolve, reject)
			local results = {}
			local index = 1

			local function nextStep(...)
				if index > #list then
					resolve(results)
					return
				end

				local currentFunc = list[index]
				index = index + 1

				local p = currentFunc(...)
				if not p or type(p.done) ~= 'function' then
					reject('Element at index ' .. (index - 1) .. ' is not a promise')
					return
				end

				p:done(function(...)
					results[index - 1] = {...}
					nextStep(...)
				end):catch(function(err)
					reject(err)
				end)
			end

			nextStep()
		end)
	end
end

return promise
