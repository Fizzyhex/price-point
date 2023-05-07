local function StringCondition(match: string)
	return function(instance: Instance)
		return instance.Name == match
	end
end

local function ObserveChild(parent: Instance, condition: string | (instance: Instance) -> (boolean), callback)
	local parentConnections = {}
	local cleanupFns = {}
	local childAddedConnection: RBXScriptConnection

	if condition == nil then
		condition = function()
			return true
		end
	elseif typeof(condition) == "string" then
		condition = StringCondition(condition)
	end

	local function CheckChild(child: Instance)
		return condition(child)
	end

	local function OnChildAdded(child: Instance)
		if not CheckChild(child) then
			return
		end

		if not childAddedConnection.Connected then
			return
		end

		local cleanupFn = callback(child)

		if not cleanupFn then
			return
		end

		cleanupFns[child] = cleanupFn

		parentConnections[child] = child:GetPropertyChangedSignal("Parent"):Connect(function()
			if child.Parent ~= parent then
				parentConnections[child] = nil
				cleanupFns[child] = nil
				cleanupFn()
			end
		end)
	end

	childAddedConnection = parent.ChildAdded:Connect(OnChildAdded)

	for _, child in parent:GetChildren() do
		if CheckChild(child) then
			task.spawn(OnChildAdded, child)
		end
	end

	return function()
		childAddedConnection:Disconnect()

		for _, connection in parentConnections do
			connection:Disconnect()
		end

		for _, cleanupFn in cleanupFns do
			task.spawn(cleanupFn)
		end

		table.clear(parentConnections)
		table.clear(cleanupFns)
	end
end

return ObserveChild