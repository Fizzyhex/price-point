export type StartConfig = {
    componentPaths: {Instance},
    systemPaths: {Instance},
    observerPaths: {Instance},
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Baseline = require(ReplicatedStorage.Packages.Baseline)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local MODULE_FILTER = Baseline.Filters.IsA("ModuleScript")
local logger = CreateLogger(script)

local function LoudlyRequire(message: string)
    return function(module: ModuleScript)
        logger.print(string.format(message, module:GetFullName()))
        return require(module)
    end
end

local observerLoadRequire = LoudlyRequire("Loading observer %s")

local function LoudlyLoadObserver(observer)
    return observerLoadRequire(observer)()
end

local function LoadSystems(container)
    local functionalSystems = {}
    local lifecycleSystems = {}

    for _, systemContainer in container do
        local moduleScripts: {ModuleScript} = Baseline.Filter(
            systemContainer:GetDescendants(),
            MODULE_FILTER
        )

        for _, moduleScript in moduleScripts do
            logger.print(`Requiring {moduleScript:GetFullName()}...`)
            local module = require(moduleScript)

            if typeof(module) == "table" then
                lifecycleSystems[moduleScript] = module
            else
                functionalSystems[moduleScript] = module
            end
        end
    end

    Baseline.CallFor(functionalSystems, task.spawn)
    Baseline.CallMethods(lifecycleSystems, "OnInit")
    Baseline.SpawnMethods(lifecycleSystems, "OnStart")
end

local function LoadComponents(container)
    for _, componentContainer in container do
        local moduleScripts = Baseline.Filter(
            componentContainer:GetDescendants(),
            MODULE_FILTER
        )
        Baseline.CallFor(moduleScripts, LoudlyRequire("Loading component %s..."))
    end
end

local function LoadObservers(container)
    for _, observerContainer in container do
        local moduleScripts = Baseline.Filter(
            observerContainer:GetDescendants(),
            MODULE_FILTER
        )
        Baseline.CallFor(moduleScripts, LoudlyLoadObserver)
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