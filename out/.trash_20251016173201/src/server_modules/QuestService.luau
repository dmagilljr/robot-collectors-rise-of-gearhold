--!strict
-- QuestService ModuleScript — quest state + unlock checks + collect tracking

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("shared")

local Quests = require(shared:WaitForChild("config"):WaitForChild("Quests"))
local Unlocks = require(shared:WaitForChild("config"):WaitForChild("Unlocks"))
local Progression = require(game:GetService("ServerScriptService"):WaitForChild("Modules"):WaitForChild("ProgressionService"))

type StepState = { id: string, progress: number, complete: boolean }
type QuestState = { id: string, stepIndex: number, steps: {StepState}, status: "active" | "complete" }

local state: {[number]: {[string]: QuestState}} = {}

local function ensurePlayer(p: Player)
  state[p.UserId] = state[p.UserId] or {}
  return state[p.UserId]
end

local function startQuest(p: Player, questId: string)
  local bag = ensurePlayer(p)
  if bag[questId] then
    return
  end
  local quest = Quests[questId]
  if not quest then
    return
  end
  local steps = {}
  for _, step in ipairs(quest.steps) do
    table.insert(steps, { id = step.id, progress = 0, complete = false })
  end
  bag[questId] = { id = questId, stepIndex = 1, steps = steps, status = "active" }
end

local function advanceIfReady(p: Player, questId: string)
  local bag = ensurePlayer(p)
  local qs = bag[questId]
  if not qs then
    return
  end
  local quest = Quests[questId]
  local idx = qs.stepIndex
  if idx > #quest.steps then
    return
  end
  if qs.steps[idx].complete then
    qs.stepIndex += 1
    if qs.stepIndex > #quest.steps then
      qs.status = "complete"
    end
  end
end

local function trackCollect(p: Player, resourceType: string, amount: number)
  local bag = ensurePlayer(p)
  for questId, qs in pairs(bag) do
    if qs.status ~= "active" then
      continue
    end
    local quest = Quests[questId]
    local idx = qs.stepIndex
    if idx > #quest.steps then
      continue
    end
    local stepDef = quest.steps[idx]
    if stepDef.type == "collect" and stepDef.resource == resourceType then
      local stepState = qs.steps[idx]
      stepState.progress += amount
      if stepState.progress >= (stepDef.amount or 1) then
        stepState.complete = true
      end
      advanceIfReady(p, questId)
    end
  end
end

local function isUnlocked(p: Player, resourceType: string): boolean
  local rule = Unlocks.resources[resourceType]
  if not rule then
    return false
  end
  local bag = ensurePlayer(p)
  if rule.quest then
    local qs = bag[rule.quest]
    if qs and (qs.status == "active" or qs.status == "complete") then
      return true
    end
  end
  return Progression:IsLevelUnlocked(p, resourceType)
end

local QuestModule = {}

function QuestModule:Start(p: Player, questId: string)
  startQuest(p, questId)
end

function QuestModule:TrackCollect(p: Player, resourceType: string, amount: number)
  trackCollect(p, resourceType, amount)
end

function QuestModule:IsUnlocked(p: Player, resourceType: string)
  return isUnlocked(p, resourceType)
end

Players.PlayerAdded:Connect(function(p)
  startQuest(p, "TUTORIAL_01")
end)

return QuestModule
