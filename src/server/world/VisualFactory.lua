--[[
	VisualFactory.lua
	Loads optional toolbox models from ReplicatedStorage and falls back safely.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("shared")
local AssetCatalog = require(shared.config.AssetCatalog)

local VisualFactory = {}
local warnedMissing = {}

local function getAssetsRoot()
	local rootName = (AssetCatalog.Models and AssetCatalog.Models.RootFolder) or "AuraAssets"
	return ReplicatedStorage:FindFirstChild(rootName)
end

local function findModelByName(modelName)
	if type(modelName) ~= "string" or modelName == "" then
		return nil
	end
	local root = getAssetsRoot()
	if not root then
		return nil
	end
	local found = root:FindFirstChild(modelName, true)
	if found and (found:IsA("Model") or found:IsA("BasePart")) then
		return found
	end
	return nil
end

local function setPivot(instance, cframe)
	if not cframe then
		return
	end
	if instance:IsA("Model") then
		instance:PivotTo(cframe)
	elseif instance:IsA("BasePart") then
		instance.CFrame = cframe
	end
end

local function parseDescriptor(modelOrDescriptor)
	if type(modelOrDescriptor) == "string" then
		return modelOrDescriptor, {}
	end
	if type(modelOrDescriptor) ~= "table" then
		return nil, {}
	end
	local modelName = modelOrDescriptor.name or modelOrDescriptor.model or modelOrDescriptor.model_name
	if type(modelName) ~= "string" or modelName == "" then
		return nil, {}
	end
	local out = {}
	if typeof(modelOrDescriptor.offset) == "Vector3" then
		out.offset = modelOrDescriptor.offset
	end
	if typeof(modelOrDescriptor.rotation_degrees) == "Vector3" then
		out.rotation_degrees = modelOrDescriptor.rotation_degrees
	elseif typeof(modelOrDescriptor.rotation) == "Vector3" then
		out.rotation_degrees = modelOrDescriptor.rotation
	end
	if type(modelOrDescriptor.scale) == "number" then
		out.scale = modelOrDescriptor.scale
	end
	if type(modelOrDescriptor.static) == "boolean" then
		out.static = modelOrDescriptor.static
	end
	return modelName, out
end

local function mergedOptions(descriptorOptions, callOptions)
	local out = {}
	for k, v in pairs(descriptorOptions or {}) do
		out[k] = v
	end
	for k, v in pairs(callOptions or {}) do
		out[k] = v
	end
	return out
end

local function transformedCFrame(base, options)
	if not base then
		return nil
	end
	local out = base
	if options and typeof(options.offset) == "Vector3" then
		out = out * CFrame.new(options.offset)
	end
	if options and typeof(options.rotation_degrees) == "Vector3" then
		local r = options.rotation_degrees
		out = out * CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z))
	end
	return out
end

local function applyScale(instance, scale)
	if type(scale) ~= "number" or scale == 1 then
		return
	end
	if instance:IsA("Model") then
		pcall(function()
			instance:ScaleTo(scale)
		end)
	end
end

local function prepareStatic(instance)
	local targets = {}
	if instance:IsA("BasePart") then
		table.insert(targets, instance)
	elseif instance:IsA("Model") then
		for _, d in ipairs(instance:GetDescendants()) do
			if d:IsA("BasePart") then
				table.insert(targets, d)
			end
		end
	end
	for _, part in ipairs(targets) do
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Massless = true
	end
end

local function stripEmbeddedScripts(instance)
	for _, d in ipairs(instance:GetDescendants()) do
		if d:IsA("LuaSourceContainer") then
			d:Destroy()
		end
	end
end

local function warnMissing(modelName)
	if not (AssetCatalog.Models and AssetCatalog.Models.WarnOnMissing ~= false) then
		return
	end
	if warnedMissing[modelName] == true then
		return
	end
	warnedMissing[modelName] = true
	local rootName = "AuraAssets"
	if AssetCatalog.Models and type(AssetCatalog.Models.RootFolder) == "string" and AssetCatalog.Models.RootFolder ~= "" then
		rootName = AssetCatalog.Models.RootFolder
	end
	warn(string.format("[AuraAssets] Missing model '%s' under ReplicatedStorage/%s", modelName, rootName))
end

function VisualFactory.TrySpawnModel(modelOrDescriptor, parent, cframe, overrideName, options)
	if not (AssetCatalog.Models and AssetCatalog.Models.Enabled == true) then
		return nil
	end
	local modelName, descriptorOptions = parseDescriptor(modelOrDescriptor)
	if not modelName then
		return nil
	end
	local merged = mergedOptions(descriptorOptions, options)
	local source = findModelByName(modelName)
	if not source then
		warnMissing(modelName)
		return nil
	end
	if type(overrideName) == "string" and overrideName ~= "" then
		local existing = parent and parent:FindFirstChild(overrideName)
		if existing then
			existing:Destroy()
		end
	end
	local clone = source:Clone()
	stripEmbeddedScripts(clone)
	if type(overrideName) == "string" and overrideName ~= "" then
		clone.Name = overrideName
	end
	applyScale(clone, merged.scale)
	if not (type(merged) == "table" and merged.static == false) then
		prepareStatic(clone)
	end
	clone.Parent = parent
	setPivot(clone, transformedCFrame(cframe, merged))
	return clone
end

function VisualFactory.GetEnemyModelName(enemyId)
	local map = AssetCatalog.Models and AssetCatalog.Models.Enemies or {}
	return map and map[enemyId] or nil
end

return VisualFactory
