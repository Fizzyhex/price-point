export type StartConfig = {
    systemContainers: {Instance},
    componentContainers: {Instance}
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Baseline = require(ReplicatedStorage.Packages.Baseline)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local MODULE_FILTER = Baseline.Filters.IsA("ModuleScript")
local logger = CreateLogger(script)

local function LoudRequire(message: string)
    return function(module: ModuleScript)
        logger.print(string.format(message, module:GetFullName()))
        return require(module)
    end
end

local observerLoadRequire = LoudRequire("Loading observer %s")

local function LoudLoadObserver(observer)
    return observerLoadRequire(observer)()
end

local function LoadSystems(container)
    local systems = {}

    for _, systemContainer in container do
        local moduleScripts = Baseline.Filter(
            systemContainer:GetDescendants(),
            MODULE_FILTER
        )
        local modules = Baseline.CallFor(moduleScripts, LoudRequire("Loading system %s..."))
        systems = Baseline.Extend(systems, modules)
    end

    Baseline.CallMethods(systems, "OnInit")
    Baseline.SpawnMethods(systems, "OnStart")
end

local function LoadComponents(container)
    for _, componentContainer in container do
        local moduleScripts = Baseline.Filter(
            componentContainer:GetDescendants(),
            MODULE_FILTER
        )
        Baseline.CallFor(moduleScripts, LoudRequire("Loading component %s..."))
    end
end

local function LoadObservers(container)
    for _, observerContainer in container do
        local moduleScripts = Baseline.Filter(
            observerContainer:GetDescendants(),
            MODULE_FILTER
        )
        Baseline.CallFor(moduleScripts, LoudLoadObserver)
    end
end

local function Start(startConfig: StartConfig)
    local systemPaths = startConfig.systemPaths or {}
    local componentPaths = startConfig.componentPaths or {}
    local observerPaths = startConfig.observerPaths or {}

    LoadSystems(systemPaths)
    logger.print("All systems loaded!")
    LoadComponents(componentPaths)
    logger.print("All components loaded!")
    LoadObservers(observerPaths)
    logger.print("All observers loaded!")
end

return Start