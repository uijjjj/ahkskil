end
end
end
local espConnection
function module:SetESPEnabled(state)ESPEnabled=state;if state then if espConnection then espConnection:Disconnect()end espConnection=RunService.RenderStepped:Connect(updateESP)else if espConnection then espConnection:Disconnect();espConnection=nil end clearDrawings()end end
function module:SetShowBox(v)ShowBox=v end
function module:SetShowName(v)ShowName=v end
function module:SetShowDistance(v)ShowDistance=v end
function module:SetShowHealth(v)ShowHealth=v end
function module:SetShowLine(v)ShowLine=v end
function module:SetBoxColor(c)BoxColor=c end
function module:SetTextColor(c)TextColor=c end
function module:SetLineColor(c)LineColor=c end
function module:SetShowAllPlayers(v)ShowAllPlayers=v end
function module:SetLineOrigin(v)LineOrigin=v end
return module
end)()
local M1Extender=(function()
local M={};local active=false;local maxRange=100
local Net=RS:WaitForChild("Modules"):WaitForChild("Net")
local RegisterHit=Net["RE/RegisterHit"];local RegisterAttack=Net["RE/RegisterAttack"]
local function getTarget()
local myChar=lp.Character;local myRoot=myChar and myChar:FindFirstChild("HumanoidRootPart")
if not myRoot then return nil end
local target,shortestDist=nil,maxRange
for _,folder in pairs({workspace:FindFirstChild("Enemies"),workspace:FindFirstChild("Characters")})do
if folder then for _,v in pairs(folder:GetChildren())do
local eRoot=v:FindFirstChild("HumanoidRootPart");local eHum=v:FindFirstChildOfClass("Humanoid")
if v~=myChar and eRoot and eHum and eHum.Health>0 then
local dist=(eRoot.Position-myRoot.Position).Magnitude
if dist<shortestDist then shortestDist=dist;target=v end
end
end end
end
return target
end
UserInputService.InputBegan:Connect(function(input,processed)
if processed or not active then return end
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
local target=getTarget()
local tool=lp.Character and lp.Character:FindFirstChildOfClass("Tool")
if target and tool then
local head=target:FindFirstChild("Head")or target:FindFirstChild("HumanoidRootPart")
if head then
local sessionId=tostring(lp.UserId):sub(2,4)..tostring(coroutine.running()):sub(11,15)
pcall(function()
RegisterAttack:FireServer()
local hitData={}
for _,part in pairs(target:GetChildren())do if part:IsA("BasePart")then table.insert(hitData,{target,part})end end
RegisterHit:FireServer(head,hitData,{},sessionId)
end)
end
end
end
end)
function M:Toggle(v)active=v end
function M:SetRange(v)maxRange=v end
return M
end)()
local GunClickSL=(function()
local enabled=false
local aimPos=nil
local hookInstalled=false
local function getClosestTarget()
local char=lp.Character
if not char then return nil end
local root=char:FindFirstChild("HumanoidRootPart")
if not root then return nil end
local closest,dist=nil,math.huge
local myPos=root.Position
for _,player in ipairs(Players:GetPlayers())do
if player~=lp and player.Character then
local entity=player.Character
local targetPart=entity:FindFirstChild("HumanoidRootPart")
if targetPart then
local hum=entity:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health>0 then
local d=(targetPart.Position-myPos).Magnitude
if d<dist then
dist=d
closest=targetPart
end
end
end
end
end
return closest
end
local function installHook()
if hookInstalled then return end
hookInstalled=true
local mt=getrawmetatable(game)
local oldNamecall=mt.__namecall
setreadonly(mt,false)
mt.__namecall=newcclosure(function(self,...)
local args={...}
local method=getnamecallmethod()
if enabled and aimPos and method=="FireServer"then
local remoteName=tostring(self.Name or self)
if remoteName:find("ShootGunEvent")then
if typeof(args[1])=="Vector3"then
args[1]=aimPos.Position
end
if typeof(args[2])=="table"then
args[2]={[1]=aimPos}
end
end
end
return oldNamecall(self,unpack(args))
end)
setreadonly(mt,true)
end
local function startLoop()
task.spawn(function()
while enabled do
aimPos=getClosestTarget()
task.wait(0.05)
end
end)
end
local M={}
function M:SetEnabled(state)
if state==enabled then return end
enabled=state
if state then
aimPos=nil
installHook()
startLoop()
else
aimPos=nil
end
end
return M
end)()
SilentAimModule=(function()
local module={}
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local CoreGui=game:GetService("CoreGui")
local camera=workspace.CurrentCamera
local RS=game:GetService("ReplicatedStorage")
local commE=RS:WaitForChild("Remotes"):WaitForChild("CommE")
local MouseModule=RS:FindFirstChild("Mouse")
local Mouse=nil
if MouseModule and typeof(MouseModule)=="Instance"then
local ok,res=pcall(require,MouseModule)
if ok and type(res)=="table"then Mouse=res end
end
local SilentAimPlayersEnabled=false
local SilentAimNPCsEnabled=false
local PredictionEnabled=true
local PredictionAmount=0.12
local ZSkillorM1=true
local ShowFOVCircle=false;local FOVRadius=100;local FOVMode="V1";local AimMode="360";local TargetPriority="Nearest"
local SoruAutoAimEnabled=false;local SoruAutoAimRange=300;local SoruTargetingMode="360";local SoruFOVType="V1";local SoruFOVRadius=100;local SoruTargetPriority="Nearest";local SoruShowFOVCircle=false;local SoruCurrentTarget=nil
local TracerEnabled=false;local TracerColor="Red";local tracerModel,tracerAttachment0,tracerAttachment1,tracerBeam=nil,nil,nil,nil
local renderConnection,heartbeatConnection=nil,nil
local currentTool,currentToolCategory=nil,"Melee"
local PlayersPosition,NPCPosition=nil,nil
local Selectedplayer=nil
local characterConnections={}
local Skills={"X"};local Booms={};local maxRange=1000
local BlacklistedKeys={
Melee={Z=false,X=false,C=false},
Sword={Z=false,X=false},
Fruit={Z=false,X=false,C=false,V=false,F=false,TAP=false},
Gun={Z=false,X=false}
}
local currentSkillKey=nil;local SKILL_KEYS={"Z","X","C","V","F","TAP"}
local lastSkillTime=0
local OverrideGodhumanSanguineEnabled=true
local function isOverrideTool(tool)
if not tool then return false end
local name=string.lower(tool.Name)
if name=="godhuman"or string.find(name,"sanguine")then
return true
end
if currentToolCategory=="Sword"then
return true
end
if string.find(name,"yama")then
return true
end
return false
end
local function faceTarget(targetPos)
if not targetPos then return end
local char=player.Character
if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local currentPos=hrp.Position
local lookVector=(Vector3.new(targetPos.X,currentPos.Y,targetPos.Z)-currentPos).Unit
if lookVector.Magnitude<0.001 then return end
local newCFrame=CFrame.lookAt(currentPos,currentPos+lookVector,Vector3.new(0,1,0))
hrp.CFrame=newCFrame
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum.AutoRotate=true end
end
local function setCurrentSkillKey(key)
currentSkillKey=key
lastSkillTime=os.clock()
if SilentAimPlayersEnabled or SilentAimNPCsEnabled then
local targetPos=PlayersPosition or NPCPosition
if targetPos then
task.spawn(function()faceTarget(targetPos)end)
end
end
task.spawn(function()
local myTime=lastSkillTime
task.wait(1.5)
if lastSkillTime==myTime and currentSkillKey==key then
currentSkillKey=nil
end
end)
end
local ScreenGui=Instance.new("ScreenGui");ScreenGui.Name="FOV_System_Linoria";ScreenGui.ResetOnSpawn=false;ScreenGui.IgnoreGuiInset=true
if syn and syn.protect_gui then syn.protect_gui(ScreenGui);ScreenGui.Parent=CoreGui elseif getgui then ScreenGui.Parent=getgui()else ScreenGui.Parent=CoreGui or player:WaitForChild("PlayerGui")end
local FOVFrame=Instance.new("Frame");FOVFrame.Name="FOVCircle";FOVFrame.AnchorPoint=Vector2.new(0.5,0.5);FOVFrame.BackgroundTransparency=1;FOVFrame.Visible=false;FOVFrame.Parent=ScreenGui
local UIStroke=Instance.new("UIStroke");UIStroke.Color=Color3.fromRGB(255,0,0);UIStroke.Thickness=2;UIStroke.Parent=FOVFrame
local FOVCorner=Instance.new("UICorner");FOVCorner.CornerRadius=UDim.new(1,0);FOVCorner.Parent=FOVFrame
local SoruFOVFrame=Instance.new("Frame");SoruFOVFrame.Name="SoruFOVCircle";SoruFOVFrame.AnchorPoint=Vector2.new(0.5,0.5);SoruFOVFrame.BackgroundTransparency=1;SoruFOVFrame.Visible=false;SoruFOVFrame.Parent=ScreenGui
local SoruUIStroke=Instance.new("UIStroke");SoruUIStroke.Color=Color3.fromRGB(0,255,0);SoruUIStroke.Thickness=2;SoruUIStroke.Parent=SoruFOVFrame
local SoruFOVCorner=Instance.new("UICorner");SoruFOVCorner.CornerRadius=UDim.new(1,0);SoruFOVCorner.Parent=SoruFOVFrame
module.ScreenGui=ScreenGui
local PingService=game:GetService("Stats").Network.ServerStatsItem
local function getToolCategory(tool)
if not tool then return"Melee"end
local name=string.lower(tool.Name)
local gunNames={"guitar","rifle","cannon","gun","slingshot","kabucha","serpent bow","bow"}
for _,g in ipairs(gunNames)do if string.find(name,g)then return"Gun"end end
local meleeNames={"claw","godhuman","superhuman","talon","step","karate","breath","kung fu","combat","fist","sanguine"}
for _,m in ipairs(meleeNames)do if string.find(name,m)then return"Melee"end end
if string.find(name,"fruit")or string.find(name,"-")then return"Fruit"end
return"Sword"
end
local function isKeyCurrentlyBlacklisted(key)
if not key then return false end
local cat=currentToolCategory
if BlacklistedKeys[cat]and BlacklistedKeys[cat][key]~=nil then return BlacklistedKeys[cat][key]end
return false
end
local function getHRP(model)if model and model:FindFirstChild("HumanoidRootPart")then return model.HumanoidRootPart end return nil end
local function clearConnections()for _,c in ipairs(characterConnections)do pcall(function()c:Disconnect()end)end characterConnections={}end
local lastVelocity=nil
local lastDirection=nil
local function predicted(hrp)
if not hrp then return nil end
local hum=hrp.Parent:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health<=0 then return hrp.Position end
if not PredictionEnabled then return hrp.Position end
local vel=hrp.Velocity
local speed=vel.Magnitude
if speed<5 then
lastVelocity=nil
lastDirection=nil
return hrp.Position
end
local currentDirection=vel.Unit
if lastDirection then
local dot=lastDirection:Dot(currentDirection)
if dot<0.7 then
lastVelocity=nil
lastDirection=nil
return hrp.Position
end
end
lastDirection=currentDirection
lastVelocity=vel
local ping=0
pcall(function()
if PingService then
ping=PingService:GetValue()/1000
end
end)
ping=math.clamp(ping,0,0.35)
local predictionFactor=PredictionAmount+ping
if speed>100 then
predictionFactor=math.min(predictionFactor,0.15)
end
return hrp.Position+(vel*predictionFactor)
end
local function isAllyWithMe(targetplayer)
local myGui=player:FindFirstChild("PlayerGui")
if not myGui then return false end
local scrolling=myGui:FindFirstChild("Main")and myGui.Main:FindFirstChild("Allies")and myGui.Main.Allies:FindFirstChild("Container")and myGui.Main.Allies.Container:FindFirstChild("Allies")and myGui.Main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
if scrolling then for _,frame in pairs(scrolling:GetDescendants())do if frame:IsA("ImageButton")and frame.Name==targetplayer.Name then return true end end end
return false
end
local function isTargetProtected(targetPlayer)
if not targetPlayer then return false end
local char=targetPlayer.Character;if not char then return false end
if char:GetAttribute("SafeZone")==true or char:GetAttribute("PvpDisabled")==true or char:GetAttribute("CombatProtected")==true or char:GetAttribute("PVP")==false then return true end
if targetPlayer:GetAttribute("SafeZone")==true or targetPlayer:GetAttribute("PvpDisabled")==true or targetPlayer:GetAttribute("CombatProtected")==true then return true end
if char:FindFirstChild("SafeZone")or char:FindFirstChild("CombatPD")or char:FindFirstChild("PvpDisabled")then return true end
if char:FindFirstChildWhichIsA("ForceField")then return true end
return false
end
local function isEnemy(targetplayer)
if not targetplayer or targetplayer==player then return false end
if isTargetProtected(targetplayer)then return false end
local myTeam=player.Team;local targetTeam=targetplayer.Team
if myTeam and targetTeam then
if myTeam.Name=="Pirates"and targetTeam.Name=="Marines"then return true
elseif myTeam.Name=="Marines"and targetTeam.Name=="Pirates"then return true end
if myTeam.Name=="Pirates"and targetTeam.Name=="Pirates"then return not isAllyWithMe(targetplayer)end
if myTeam.Name=="Marines"and targetTeam.Name=="Marines"then return false end
end
return true
end
local function getFOVCenter(mode)
if mode=="V2"then return UserInputService:GetMouseLocation()end
if not camera then camera=workspace.CurrentCamera end
return camera.ViewportSize/2
end
local function isTargetValid(hrp,lpHRP,aimMode,fovRadius,fovType)
if not hrp or not lpHRP then return false end
if aimMode=="180"then local dir=(hrp.Position-lpHRP.Position).Unit;if lpHRP.CFrame.LookVector:Dot(dir)<0 then return false end
elseif aimMode=="FOV"then
local screenPos,onScreen=camera:WorldToViewportPoint(hrp.Position)
if not onScreen then return false end
local center=getFOVCenter(fovType)
if(Vector2.new(screenPos.X,screenPos.Y)-center).Magnitude>fovRadius then return false end
end
return true
end
local function getClosestplayer(lpHRP)
if not lpHRP then return nil end
if TargetPriority=="Lock Player"then
if Selectedplayer and Selectedplayer.Character and Selectedplayer.Character.Parent then
if isTargetProtected(Selectedplayer)then return nil end
local hum=Selectedplayer.Character:FindFirstChildWhichIsA("Humanoid");local hrp=getHRP(Selectedplayer.Character)
if hum and hum.Health>0 and hrp then
if isTargetValid(hrp,lpHRP,AimMode,FOVRadius,FOVMode)and(hrp.Position-lpHRP.Position).Magnitude<=maxRange then return Selectedplayer end
end
end
return nil
end
local valid={}
for _,pl in ipairs(Players:GetPlayers())do
if pl~=player and isEnemy(pl)and pl.Character and pl.Character.Parent then
local hum=pl.Character:FindFirstChildWhichIsA("Humanoid");local hrp=getHRP(pl.Character)
if hum and hum.Health>0 and hrp and isTargetValid(hrp,lpHRP,AimMode,FOVRadius,FOVMode)then
local dist=(hrp.Position-lpHRP.Position).Magnitude
if dist<=maxRange then table.insert(valid,{Player=pl,Humanoid=hum,HRP=hrp,Distance=dist})end
end
end
end
if#valid==0 then return nil end
if AimMode=="360"or AimMode=="180"then
if TargetPriority=="Nearest"then table.sort(valid,function(a,b)return a.Distance<b.Distance end)
elseif TargetPriority=="Low HP"then table.sort(valid,function(a,b)return a.Humanoid.Health<b.Humanoid.Health end)
elseif TargetPriority=="Looking At Me"then table.sort(valid,function(a,b)local dirA=(lpHRP.Position-a.HRP.Position).Unit;local lookA=a.HRP.CFrame.LookVector;local dirB=(lpHRP.Position-b.HRP.Position).Unit;local lookB=b.HRP.CFrame.LookVector;return lookA:Dot(dirA)>lookB:Dot(dirB)end)end
else
local center=getFOVCenter(FOVMode)
table.sort(valid,function(a,b)
local pA=camera:WorldToViewportPoint(a.HRP.Position)
local pB=camera:WorldToViewportPoint(b.HRP.Position)
return(Vector2.new(pA.X,pA.Y)-center).Magnitude<(Vector2.new(pB.X,pB.Y)-center).Magnitude
end)
end
return valid[1].Player
end
local function getClosestNPC(lpHRP)
if not lpHRP then return nil end
local enemiesFolder=workspace:FindFirstChild("Enemies");if not enemiesFolder then return nil end
local closest,closestDist=nil,math.huge
for _,npc in ipairs(enemiesFolder:GetChildren())do
if npc:IsA("Model")then
local hum=npc:FindFirstChildWhichIsA("Humanoid");local hrp=getHRP(npc)
if hum and hum.Health>0 and hrp and isTargetValid(hrp,lpHRP,AimMode,FOVRadius,FOVMode)then
local dist=(hrp.Position-lpHRP.Position).Magnitude
if dist<=maxRange and dist<closestDist then closestDist=dist;closest=npc end
end
end
end
return closest
end
local SoruPredictedPosition=nil
local function getSoruTarget(lpHRP)
if not lpHRP then return nil end
local valid={}
for _,pl in ipairs(Players:GetPlayers())do
if pl~=player and pl.Character and pl.Character.Parent then
if not isEnemy(pl)then continue end
local hum=pl.Character:FindFirstChildWhichIsA("Humanoid");local hrp=getHRP(pl.Character)
if hum and hum.Health>0 and hrp then
if isTargetValid(hrp,lpHRP,SoruTargetingMode,SoruFOVRadius,SoruFOVType)then
local dist=(hrp.Position-lpHRP.Position).Magnitude
if dist<=SoruAutoAimRange then table.insert(valid,{HRP=hrp,Humanoid=hum,Distance=dist})end
end
end
end
end
if#valid==0 then return nil end
if SoruTargetingMode=="360"or SoruTargetingMode=="180"then
if SoruTargetPriority=="Nearest"then table.sort(valid,function(a,b)return a.Distance<b.Distance end)
elseif SoruTargetPriority=="Low HP"then table.sort(valid,function(a,b)return a.Humanoid.Health<b.Humanoid.Health end)
elseif SoruTargetPriority=="Looking At Me"then table.sort(valid,function(a,b)local dirA=(lpHRP.Position-a.HRP.Position).Unit;local lookA=a.HRP.CFrame.LookVector;local dirB=(lpHRP.Position-b.HRP.Position).Unit;local lookB=b.HRP.CFrame.LookVector;return lookA:Dot(dirA)>lookB:Dot(dirB)end)end
else
local center=getFOVCenter(SoruFOVType)
table.sort(valid,function(a,b)
local pA=camera:WorldToViewportPoint(a.HRP.Position)
local pB=camera:WorldToViewportPoint(b.HRP.Position)
return(Vector2.new(pA.X,pA.Y)-center).Magnitude<(Vector2.new(pB.X,pB.Y)-center).Magnitude
end)
end
return valid[1].HRP
end
task.spawn(function()
while true do
task.wait(0.2)
if SoruAutoAimEnabled then
local myHRP=getHRP(player.Character)
local targetHRP=myHRP and getSoruTarget(myHRP)
if targetHRP then
SoruPredictedPosition=targetHRP.Position
SoruCurrentTarget=targetHRP
else
SoruCurrentTarget=nil
SoruPredictedPosition=nil
end
else
SoruCurrentTarget=nil
SoruPredictedPosition=nil
end
end
end)
local function handleAttackRotation(key)
end
local function createTracer()
if tracerModel then return end
tracerModel=Instance.new("Model",workspace);tracerModel.Name="SilentAimTracer"
tracerAttachment0=Instance.new("Attachment",tracerModel);tracerAttachment1=Instance.new("Attachment",tracerModel)
tracerBeam=Instance.new("Beam",tracerModel)
tracerBeam.Attachment0=tracerAttachment0;tracerBeam.Attachment1=tracerAttachment1
tracerBeam.Width0=0.1;tracerBeam.Width1=0.1;tracerBeam.FaceCamera=true
updateTracerColor()
end
local function destroyTracer()if tracerModel then tracerModel:Destroy();tracerModel=nil;tracerAttachment0=nil;tracerAttachment1=nil;tracerBeam=nil end end
local function updateTracerColor()
if not tracerBeam then return end
local colorMap={Red=Color3.fromRGB(255,0,0),Green=Color3.fromRGB(0,255,0),Blue=Color3.fromRGB(0,0,255),Yellow=Color3.fromRGB(255,255,0),White=Color3.fromRGB(255,255,255)}
local col=colorMap[TracerColor]or Color3.fromRGB(255,0,0)
tracerBeam.Color=ColorSequence.new(col)
end
function module:SetTracerEnabled(state)TracerEnabled=state;if state then createTracer()else destroyTracer()end end
function module:SetTracerColor(color)TracerColor=color;updateTracerColor()end
local function installMouseOverride()
local MouseModuleInstance=RS:FindFirstChild("Mouse")
if not MouseModuleInstance then return end
local MouseModule=nil
pcall(function()MouseModule=require(MouseModuleInstance)end)
if not MouseModule or typeof(MouseModule)~="table"then return end
local realStore={Hit=rawget(MouseModule,"Hit"),Target=rawget(MouseModule,"Target")}
local mmt=getrawmetatable(MouseModule)
if mmt then setreadonly(mmt,false)else mmt={};setmetatable(MouseModule,mmt)end
rawset(MouseModule,"Hit",nil);rawset(MouseModule,"Target",nil)
mmt.__index=function(self,key)
if key=="Hit"then
if OverrideGodhumanSanguineEnabled and(SilentAimPlayersEnabled or SilentAimNPCsEnabled)and(PlayersPosition or NPCPosition)and isOverrideTool(currentTool)and currentSkillKey=="Z"and not isKeyCurrentlyBlacklisted(currentSkillKey)then
local pos=PlayersPosition or NPCPosition
if pos then return CFrame.new(pos)end
end
return realStore.Hit
elseif key=="Target"then
if OverrideGodhumanSanguineEnabled and(SilentAimPlayersEnabled or SilentAimNPCsEnabled)and(PlayersPosition or NPCPosition)and isOverrideTool(currentTool)and currentSkillKey=="Z"and not isKeyCurrentlyBlacklisted(currentSkillKey)then
return nil
end
return realStore.Target
end
return rawget(self,key)
end
mmt.__newindex=function(self,key,value)
if key=="Hit"or key=="Target"then realStore[key]=value else rawset(self,key,value)end
end
setreadonly(mmt,true)
end
installMouseOverride()
UserInputService.InputBegan:Connect(function(input,gp)
if gp then return end
local keyMap={[Enum.KeyCode.Z]="Z",[Enum.KeyCode.X]="X",[Enum.KeyCode.C]="C",[Enum.KeyCode.V]="V",[Enum.KeyCode.F]="F"}
local key=keyMap[input.KeyCode]
if key then setCurrentSkillKey(key)end
end)
local function hookMobileButton(btn)
if btn:GetAttribute("Hooked")then return end;btn:SetAttribute("Hooked",true)
local key=btn.Name
if table.find(SKILL_KEYS,key)then
btn.Activated:Connect(function()setCurrentSkillKey(key)end)
end
end
spawn(function()
while not player.PlayerGui do wait(0.5)end
local pg=player.PlayerGui;local main=pg:WaitForChild("Main",10)
if main then
local skills=main:WaitForChild("Skills",10)
if skills then
for _,wf in ipairs(skills:GetChildren())do if wf:IsA("GuiObject")then for _,b in ipairs(wf:GetChildren())do if b:IsA("ImageButton")or b:IsA("TextButton")then hookMobileButton(b)end end end end
skills.ChildAdded:Connect(function(wf)if wf:IsA("GuiObject")then for _,b in ipairs(wf:GetChildren())do if b:IsA("ImageButton")or b:IsA("TextButton")then hookMobileButton(b)end end end end)
end
end
end)
local function getSkillKeyFromArgs(args)
for _,arg in ipairs(args)do if type(arg)=="string"and table.find(SKILL_KEYS,arg)then return arg end end
return nil
end
local function startRenderLoop()
if not renderConnection then
renderConnection=RunService.RenderStepped:Connect(function()
if ShowFOVCircle then local center=getFOVCenter(FOVMode);FOVFrame.Position=UDim2.new(0,center.X,0,center.Y);FOVFrame.Size=UDim2.new(0,FOVRadius*2,0,FOVRadius*2);FOVFrame.Visible=true else FOVFrame.Visible=false end
if SoruShowFOVCircle then local center=getFOVCenter(SoruFOVType);SoruFOVFrame.Position=UDim2.new(0,center.X,0,center.Y);SoruFOVFrame.Size=UDim2.new(0,SoruFOVRadius*2,0,SoruFOVRadius*2);SoruFOVFrame.Visible=true else SoruFOVFrame.Visible=false end
pcall(function()
local lpChar=player.Character;if not lpChar then return end
local lpHRP=lpChar:FindFirstChild("HumanoidRootPart");if not lpHRP then return end
if not SilentAimPlayersEnabled and not SilentAimNPCsEnabled then
if TracerEnabled and tracerBeam then tracerBeam.Enabled=false end
PlayersPosition=nil;NPCPosition=nil
return
end
if SilentAimPlayersEnabled then
local targetplayer=getClosestplayer(lpHRP)
if targetplayer and targetplayer.Character then
PlayersPosition=predicted(getHRP(targetplayer.Character))
else PlayersPosition=nil end
end
if SilentAimNPCsEnabled then
local npc=getClosestNPC(lpHRP)
if npc then NPCPosition=predicted(getHRP(npc))
else NPCPosition=nil end
end
if TracerEnabled and tracerBeam and tracerAttachment0 and tracerAttachment1 then
local targetPos=PlayersPosition or NPCPosition
if lpHRP and targetPos then tracerAttachment0.WorldPosition=lpHRP.Position;tracerAttachment1.WorldPosition=targetPos;tracerBeam.Enabled=true
else tracerBeam.Enabled=false end
end
end)
end)
end
if not heartbeatConnection then
heartbeatConnection=RunService.Heartbeat:Connect(function()
if not ZSkillorM1 or(not SilentAimPlayersEnabled and not SilentAimNPCsEnabled)then return end
if currentSkillKey and isKeyCurrentlyBlacklisted(currentSkillKey)then return end
if currentTool and(string.find(string.lower(currentTool.Name),"portal")or string.find(string.lower(currentTool.Name),"lightning"))then return end
if not OverrideGodhumanSanguineEnabled then return end
if not isOverrideTool(currentTool)then return end
if currentSkillKey~="Z"then return end
local targetPos=PlayersPosition or NPCPosition
if targetPos and Mouse then
local targetCFrame=CFrame.new(targetPos)
pcall(function()Mouse.Hit=targetCFrame;Mouse.Target=nil end)
if MouseModule then pcall(function()local MouseData=require(MouseModule);MouseData.Hit=targetCFrame;MouseData.Target=nil end)end
end
end)
end
end
local function stopRenderLoop()
if renderConnection then renderConnection:Disconnect();renderConnection=nil end
if heartbeatConnection then heartbeatConnection:Disconnect();heartbeatConnection=nil end
FOVFrame.Visible=false;SoruFOVFrame.Visible=false;destroyTracer()
PlayersPosition=nil;NPCPosition=nil
if Mouse then pcall(function()Mouse.Hit=CFrame.new(0,0,0)end)end
end
local Mouse=player:GetMouse()
spawn(function()
local mt=getrawmetatable(game);if not mt then return end
local oldNamecall=mt.__namecall;local oldIndex=mt.__index
setreadonly(mt,false)
mt.__namecall=newcclosure(function(self,...)
local Method=getnamecallmethod();local args={...}
if args[1]=="TAP"then return oldNamecall(self,...)end
local skillKey=getSkillKeyFromArgs(args)
if skillKey then
if SilentAimPlayersEnabled or SilentAimNPCsEnabled then
local targetPos=PlayersPosition or NPCPosition
if targetPos then
task.spawn(function()faceTarget(targetPos)end)
end
end
setCurrentSkillKey(skillKey)
end
if SoruAutoAimEnabled and SoruPredictedPosition and skillKey=="C"then
for i,arg in ipairs(args)do
if typeof(arg)=="Vector3"then
args[i]=SoruPredictedPosition
end
end
end
local skip=false
if skillKey and isKeyCurrentlyBlacklisted(skillKey)then skip=true
elseif not skillKey and currentSkillKey and isKeyCurrentlyBlacklisted(currentSkillKey)then skip=true end
if not skip then
if Method=="FireServer"then
if typeof(args[1])=="Vector3"then
if SilentAimPlayersEnabled and PlayersPosition then args[1]=PlayersPosition
elseif SilentAimNPCsEnabled and NPCPosition then args[1]=NPCPosition end
end
elseif Method=="InvokeServer"and currentTool and currentTool.Name=="Buddy Sword"then
if type(args[1])=="string"and table.find(Skills,args[1])then
if SilentAimPlayersEnabled and PlayersPosition then args[2]=PlayersPosition
elseif SilentAimNPCsEnabled and NPCPosition then args[2]=NPCPosition end
end
end
end
return oldNamecall(self,unpack(args))
end)
mt.__index=newcclosure(function(t,k)
if SoruAutoAimEnabled and t==Mouse and SoruPredictedPosition then
if k=="Hit"then return CFrame.new(SoruPredictedPosition)end
if k=="Target"then return nil end
end
return oldIndex(t,k)
end)
setreadonly(mt,true)
end)
local function onCharacterAdded(char)
clearConnections()
local hum=char:WaitForChild("Humanoid",10)
if hum then
table.insert(characterConnections,hum.AnimationPlayed:Connect(function(track)
local anim=track.Animation
local id=anim and tostring(anim.AnimationId):match("%d+")
local animName=string.lower(anim and anim.Name or"")
if bunnyHopEnabled and(string.find(animName,"dash")or string.find(animName,"flashstep")or id=="17555632156"or id=="1846164274"or id=="1846163351")then
task.spawn(function()
task.wait(0.05)
if hum and hum.FloorMaterial~=Enum.Material.Air then
hum:ChangeState(Enum.HumanoidStateType.Jumping)
end
end)
end
end))
end
for _,child in ipairs(char:GetChildren())do
if child:IsA("Tool")then currentTool=child;currentToolCategory=getToolCategory(child);currentSkillKey=nil
table.insert(characterConnections,child.AncestryChanged:Connect(function(_,p)if not p then currentTool=nil end end))end
end
table.insert(characterConnections,char.ChildAdded:Connect(function(child)
if child:IsA("Tool")then currentTool=child;currentToolCategory=getToolCategory(child);currentSkillKey=nil
table.insert(characterConnections,child.AncestryChanged:Connect(function(_,p)if not p then currentTool=nil end end))end
end))
table.insert(characterConnections,char.ChildRemoved:Connect(function(child)if child==currentTool then currentTool=nil end end))
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character)end
local UserWantsplayerAim,UserWantsNPCAim=false,false
function module:SetZSkillorM1(state)ZSkillorM1=state end
function module:SetPrediction(state)PredictionEnabled=state end
function module:SetPredictionAmount(amt)PredictionAmount=amt end
function module:SetDistanceLimit(num)if type(num)=="number"then maxRange=num end end
function module:SetSelectedPlayer(playerName)if not playerName or playerName==""then Selectedplayer=nil return end;Selectedplayer=Players:FindFirstChild(playerName)end
function module:SetPlayerSilentAim(state)UserWantsplayerAim=state;SilentAimPlayersEnabled=state;if state then startRenderLoop()elseif not SilentAimNPCsEnabled then stopRenderLoop()end end
function module:SetNPCSilentAim(state)UserWantsNPCAim=state;SilentAimNPCsEnabled=state;if state then startRenderLoop()elseif not SilentAimPlayersEnabled then stopRenderLoop()end end
function module:SetBlacklistKey(cat,key,state)if BlacklistedKeys[cat]and BlacklistedKeys[cat][key]~=nil then BlacklistedKeys[cat][key]=state end end
function module:IsKeyBlacklisted(cat,key)return BlacklistedKeys[cat]and BlacklistedKeys[cat][key]or false end
function module:SetAimMode(mode)AimMode=mode end
function module:SetTargetPriority(prio)TargetPriority=prio end
function module:SetShowFOVCircle(state)ShowFOVCircle=state end
function module:SetFOVRadius(num)FOVRadius=num end
function module:SetFOVMode(mode)FOVMode=mode end
function module:SetSoruAutoAim(state)SoruAutoAimEnabled=state;if not state then SoruCurrentTarget=nil;SoruPredictedPosition=nil end end
function module:SetSoruRange(r)SoruAutoAimRange=r end
function module:SetSoruAimMode(mode)SoruTargetingMode=mode end
function module:SetSoruFOVType(mode)SoruFOVType=mode end
function module:SetSoruFOVRadius(r)SoruFOVRadius=r end
function module:SetSoruPriority(p)SoruTargetPriority=p end
function module:SetSoruShowFOVCircle(state)SoruShowFOVCircle=state end
function module:GetTargetPos()return PlayersPosition or NPCPosition end
return module
end)()
local MacroTab=Tabs.Macro
local MacroLeft=MacroTab:AddLeftGroupbox("Automation")
MacroLeft:AddToggle("AHKSoru",{Text="Enable AHK Soru",Default=false,Callback=function(v)if v then LoadAHKsoru()else UnloadAHKsoru()end end})
MacroLeft:AddToggle("AHKCombo",{Text="Enable AHK Combo",Default=false,Callback=function(v)if v then LoadAHKComboScript()else UnloadAHKComboScript()end end})
local SoruGroup=MacroTab:AddRightGroupbox("Soru Auto Aim")
SoruGroup:AddToggle("SoruToggle",{Text="Enable Soru Auto Aim",Default=false,Callback=function(v)SilentAimModule:SetSoruAutoAim(v)end})
SoruGroup:AddDropdown("SoruAimMode",{Values={"360","180","FOV"},Default="360",Text="Aim Mode",Callback=function(v)SilentAimModule:SetSoruAimMode(v)end})
SoruGroup:AddDropdown("SoruFOVType",{Values={"V1","V2"},Default="V1",Text="FOV Type",Callback=function(v)SilentAimModule:SetSoruFOVType(v)end})
SoruGroup:AddDropdown("SoruPriority",{Values={"Nearest","Low HP","Looking At Me"},Default="Nearest",Text="Target Priority",Callback=function(v)SilentAimModule:SetSoruPriority(v)end})
SoruGroup:AddSlider("SoruFOVRadius",{Text="FOV Radius",Default=100,Min=10,Max=800,Rounding=0,Callback=function(v)SilentAimModule:SetSoruFOVRadius(v)end})
SoruGroup:AddSlider("SoruRange",{Text="Max Range",Default=300,Min=50,Max=500,Rounding=0,Suffix=" studs",Callback=function(v)SilentAimModule:SetSoruRange(v)end})
SoruGroup:AddToggle("SoruShowFOV",{Text="Show FOV Circle",Default=false,Callback=function(v)SilentAimModule:SetSoruShowFOVCircle(v)end})
local GlitchTab=Tabs.Glitch
local SanguineGroup=GlitchTab:AddLeftGroupbox("Sanguine Z Boost")
SanguineGroup:AddToggle("SanguineToggle",{Text="Enable Sanguine",Default=false,Callback=function(v)multiEnabled=v;if not v then multiCharging=false;multiChargeStart=0 end end})
SanguineGroup:AddSlider("SanguinePower",{Text="Power",Default=400,Min=100,Max=5000,Rounding=0,Suffix=" force",Callback=function(v)multiPower=v end})
SanguineGroup:AddSlider("SanguineDuration",{Text="Duration (cs)",Default=90,Min=10,Max=200,Rounding=0,Suffix=" cs",Callback=function(v)multiDuration=v/100 end})
SanguineGroup:AddSlider("SanguineCharge",{Text="Min Charge",Default=10,Min=1,Max=50,Rounding=0,Suffix="",Callback=function(v)multiRequiredCharge=v/10 end})
local DTalonGroup=GlitchTab:AddLeftGroupbox("DTalon Z Boost")
DTalonGroup:AddToggle("DTalonToggle",{Text="Enable DTalon",Default=false,Callback=function(v)dtalonEnabled=v;if not v then dtalonCharging=false;dtalonChargeStart=0 end end})
DTalonGroup:AddSlider("DTalonPower",{Text="Power",Default=400,Min=100,Max=5000,Rounding=0,Suffix=" force",Callback=function(v)dtalonPower=v end})
DTalonGroup:AddSlider("DTalonDuration",{Text="Duration (cs)",Default=90,Min=10,Max=200,Rounding=0,Suffix=" cs",Callback=function(v)dtalonDuration=v/100 end})
DTalonGroup:AddSlider("DTalonCharge",{Text="Min Charge",Default=10,Min=1,Max=50,Rounding=0,Suffix="",Callback=function(v)dtalonRequiredCharge=v/10 end})
local BigSkinGroup=GlitchTab:AddLeftGroupbox("Big Skin Bug")
BigSkinGroup:AddToggle("BigSkinToggle",{Text="Enable Big Skin Bug",Default=false,Callback=function(v)
if v then enableBigSkin()else disableBigSkin()end
end})
local DiamondGroup=GlitchTab:AddRightGroupbox("Diamond Boost")
DiamondGroup:AddToggle("DiamondToggle",{Text="Enable Diamond",Default=false,Callback=function(v)diamondEnabled=v;if not v then diamondCharging=false;diamondChargeStart=0 end end})
DiamondGroup:AddSlider("DiamondPower",{Text="Power",Default=250,Min=100,Max=5000,Rounding=0,Suffix=" force",Callback=function(v)diamondPower=v end})
DiamondGroup:AddSlider("DiamondDuration",{Text="Duration (cs)",Default=30,Min=10,Max=200,Rounding=0,Suffix=" cs",Callback=function(v)diamondDuration=v/100 end})
DiamondGroup:AddSlider("DiamondCharge",{Text="Min Charge",Default=10,Min=1,Max=50,Rounding=0,Suffix="",Callback=function(v)diamondRequiredCharge=v/10 end})
local EClawGroup=GlitchTab:AddRightGroupbox("EClaw X Boost")
EClawGroup:AddToggle("EClawToggle",{Text="Enable EClaw Boost",Default=false,Callback=function(v)EClawBoost:Toggle(v)end})
EClawGroup:AddSlider("EClawPower",{Text="Power",Default=400,Min=100,Max=5000,Rounding=0,Suffix=" force",Callback=function(v)EClawBoost:SetPower(v)end})
EClawGroup:AddSlider("EClawDuration",{Text="Duration (cs)",Default=170,Min=10,Max=200,Rounding=0,Suffix=" cs",Callback=function(v)EClawBoost:SetDuration(v/100)end})
EClawGroup:AddSlider("EClawCharge",{Text="Min Charge",Default=0,Min=0,Max=50,Rounding=0,Suffix="",Callback=function(v)EClawBoost:SetRequiredCharge(v/10)end})
local MoveTab=Tabs.Movement
local MoveGroup=MoveTab:AddLeftGroupbox("Player Movement")
MoveGroup:AddToggle("BunnyHopToggle",{Text="Bunny Hop",Default=false,Callback=function(v)bunnyHopEnabled=v end})
local SuperJumpGroup=MoveTab:AddLeftGroupbox("Super Jump")
SuperJumpGroup:AddToggle("SuperJumpToggle",{Text="Enable Super Jump",Default=false,Callback=function(v)superJumpEnabled=v;updateSuperJumpState();if not v then resetSuperJumpToNormal();if superJumpButton then destroySuperJumpButton()end end end})
SuperJumpGroup:AddDropdown("SuperJumpMode",{Values={"V1","V2","V3"},Default="V1",Text="",Callback=function(v)superJumpMode=v;updateSuperJumpState()end})
SuperJumpGroup:AddSlider("SuperJumpPower",{Text="Jump Power",Default=150,Min=50,Max=500,Rounding=0,Callback=function(v)superJumpPower=v;if superJumpEnabled and superJumpMode=="V1"then applySuperJumpV1()end end})
local DashLengthGroup=MoveTab:AddRightGroupbox("Dash Length")
DashLengthGroup:AddToggle("DashToggle",{Text="Enable Dash Length",Default=false,Callback=function(v)
dashLengthEnabled=v
if v then
if dashLengthConnection then task.cancel(dashLengthConnection)end
dashLengthConnection=task.spawn(function()
while dashLengthEnabled do task.wait(0.1)
local character=lp.Character
if character then
local cv=character:GetAttribute("DashLength")
if cv~=dashLengthValue then character:SetAttribute("DashLength",dashLengthValue);character:SetAttribute("DashLengthAir",dashLengthValue)end
end
end
end)
else
if dashLengthConnection then task.cancel(dashLengthConnection);dashLengthConnection=nil end
if lp.Character then lp.Character:SetAttribute("DashLength",1);lp.Character:SetAttribute("DashLengthAir",1)end
end
end})
DashLengthGroup:AddSlider("DashLengthValue",{Text="Dash Distance",Default=1,Min=1,Max=300,Rounding=0,Callback=function(v)dashLengthValue=v end})
local SpeedGroup=MoveTab:AddLeftGroupbox("Speed Hack")
SpeedGroup:AddToggle("SpeedHackToggle",{Text="Enable Speed Hack",Default=false,Callback=function(v)if v then StartSpeedHack();CreateSpeedMiniToggle()else StopSpeedHack();DestroySpeedMiniToggle()end end})
SpeedGroup:AddDropdown("SpeedMode",{Values={"WalkSpeed","CFrame","Velocity","TP-Flash","AnimSpeed"},Default="WalkSpeed",Text="Mode",Callback=function(v)speedSettings.mode=v end})
SpeedGroup:AddSlider("SpeedHackValue",{Text="Speed Value",Default=50,Min=16,Max=500,Rounding=0,Callback=function(v)speedSettings.speedValue=v end})
local FlyGroup=MoveTab:AddRightGroupbox("Fly")
FlyGroup:AddToggle("FlyToggle",{Text="Toggle Fly",Default=false,Callback=function(v)if v then StartFly();CreateFlyMiniToggle()else StopFly();DestroyFlyMiniToggle()end;flySettings.flyActive=v end})
FlyGroup:AddDropdown("FlyMode",{Values={"CFrame","Velocity","Swim","TP-Fast","Float","Tween"},Default="CFrame",Text="Mode",Callback=function(v)flySettings.mode=v;if flySettings.flyActive then StopFly();StartFly()end end})
FlyGroup:AddSlider("FlySpeed",{Text="Speed",Default=50,Min=10,Max=500,Rounding=0,Callback=function(v)flySettings.speed=v end})
FlyGroup:AddToggle("NoClipToggle",{Text="NoClip",Default=false,Callback=function(v)flySettings.noclipActive=v;if v then StartNoClip()else StopNoClip()end end})
local DashGlitchGroup=MoveTab:AddRightGroupbox("Skull Guitar Dash")
DashGlitchGroup:AddToggle("DashGlitchToggle",{Text="Enable Dash Glitch",Default=false,Callback=function(v)DashGlitch:SetEnabled(v)end})
DashGlitchGroup:AddDropdown("DashGlitchVersion",{Values={"V1 (Auto)","V2 (Manual Tap)"},Default="V1 (Auto)",Text="Version",Callback=function(v)
local ver=v:match("^(%w+)")
DashGlitch:SetVersion(ver)
end})
DashGlitchGroup:AddSlider("DashGlitchCooldown",{Text="Cooldown",Default=1.5,Min=0.2,Max=5,Rounding=1,Suffix="s",Callback=function(v)DashGlitch:SetCooldown(v)end})
DashGlitchGroup:AddSlider("DashGlitchDashLength",{Text="Dash Length",Default=190,Min=10,Max=500,Rounding=0,Callback=function(v)DashGlitch:SetDashLength(v)end})
DashGlitchGroup:AddSlider("DashGlitchSpeedBoost",{Text="Propulsion",Default=350,Min=50,Max=1000,Rounding=0,Callback=function(v)DashGlitch:SetSpeedBoost(v)end})
DashGlitchGroup:AddSlider("DashGlitchAirSpeed",{Text="Air Speed",Default=400,Min=50,Max=1000,Rounding=0,Callback=function(v)DashGlitch:SetAirWalkSpeed(v)end})
lp.CharacterAdded:Connect(function(char)if dashLengthEnabled then task.wait(0.1);char:SetAttribute("DashLength",dashLengthValue);char:SetAttribute("DashLengthAir",dashLengthValue)end end)
local ApparenceTab=Tabs.Apparence
local HeadlessGroup=ApparenceTab:AddLeftGroupbox("Fake Headless")
HeadlessGroup:AddDropdown("HeadlessVersion",{Values={"V1","V2"},Default="V1",Text="Version",Callback=function(v)fakeHeadlessVersion=v;if fakeHeadlessEnabled then removeFakeHeadless();applyFakeHeadless()end end})
HeadlessGroup:AddToggle("HeadlessToggle",{Text="Enable Fake Headless",Default=false,Callback=function(v)fakeHeadlessEnabled=v;if v then applyFakeHeadless()else removeFakeHeadless()end end})
local KorbloxGroup=ApparenceTab:AddRightGroupbox("Fake Korblox")
KorbloxGroup:AddDropdown("KorbloxVersion",{Values={"V1","V2"},Default="V1",Text="Version",Callback=function(v)fakeKorbloxVersion=v;if fakeKorbloxEnabled then removeFakeKorblox();applyFakeKorblox()end end})
KorbloxGroup:AddToggle("KorbloxToggle",{Text="Enable Fake Korblox",Default=false,Callback=function(v)fakeKorbloxEnabled=v;if v then applyFakeKorblox()else removeFakeKorblox()end end})
local MiscTab=Tabs.Misc
local FontChangerGroup=MiscTab:AddLeftGroupbox("Font Changer")
local fontList={}
for _,v in Enum.Font:GetEnumItems()do table.insert(fontList,tostring(v):split(".")[3])end
local function getCustomFonts()
local list={"None"}
if listfiles and isfolder and isfolder("NamelessConfigs/Fonts")then
for _,v in ipairs(listfiles("NamelessConfigs/Fonts"))do
local filename=v:match("([^/\\]+)$")
if filename:lower():find("%.ttf")or filename:lower():find("%.otf")then table.insert(list,filename)end
end
end
return list
end
FontChangerGroup:AddDropdown("FontStyle",{Values=fontList,Default="GothamSsm",Text="Font Style",Callback=function(v)fontPreset=v;if fontChangerEnabled then disableFonts();enableFonts()end end})
FontChangerGroup:AddDropdown("CustomFontFile",{Values=getCustomFonts(),Default="None",Text="Custom Font (.ttf)",Callback=function(val)loadCustomFont(val);if fontChangerEnabled then disableFonts();enableFonts()end end})
FontChangerGroup:AddToggle("FontChangerToggle",{Text="Enable Font Changer",Default=false,Callback=function(v)fontChangerEnabled=v;if v then enableFonts()else disableFonts()end end})
local AntiMoverGroup=MiscTab:AddRightGroupbox("Anti Mover")
AntiMoverGroup:AddToggle("AntiMoverToggle",{Text="Enable Anti Mover",Default=false,Callback=function(v)
antiMoverEnabled=v
if v then
local function add(char)if not char:FindFirstChild("AntiMover")then Instance.new("Folder",char).Name="AntiMover"end end
if lp.Character then add(lp.Character)end
antiMoverConnection=lp.CharacterAdded:Connect(add)
else
if antiMoverConnection then antiMoverConnection:Disconnect();antiMoverConnection=nil end
if lp.Character and lp.Character:FindFirstChild("AntiMover")then lp.Character.AntiMover:Destroy()end
end
end})
local UnbreakableGroup=MiscTab:AddRightGroupbox("Unbreakable")
UnbreakableGroup:AddToggle("UnbreakableToggle",{Text="Enable Unbreakable",Default=false,Callback=function(v)
unbreakableEnabled=v
if v then
if unbreakableConnection then task.cancel(unbreakableConnection)end
unbreakableConnection=task.spawn(function()
while unbreakableEnabled do task.wait(0.1);if lp.Character and lp.Character:GetAttribute("UnbreakableAll")~=true then lp.Character:SetAttribute("UnbreakableAll",true)end end
end)
else
if unbreakableConnection then task.cancel(unbreakableConnection);unbreakableConnection=nil end
if lp.Character then lp.Character:SetAttribute("UnbreakableAll",false)end
end
end})
local NoGFXGroup=MiscTab:AddRightGroupbox("No GFX")
NoGFXGroup:AddDropdown("NoGFXMode",{Values={"Off","V1","V2"},Default="Off",Text="No GFX Mode",Callback=function(v)setNoGfxMode(v)end})
local DeleteShipGroup=MiscTab:AddLeftGroupbox("Delete Ship")
DeleteShipGroup:AddToggle("DeleteShipToggle",{Text="Enable Delete Ship",Default=false,Callback=function(v)
deleteShipActive=v
if v then startDeleteShipLoop()end
end})
local WalkOnWaterGroup=MiscTab:AddLeftGroupbox("Walk on Water")
WalkOnWaterGroup:AddToggle("WalkOnWaterToggle",{Text="Enable Walk on Water",Default=false,Callback=function(v)WalkOnWaterEnabled=v end})
local AntiLavaGroup=MiscTab:AddLeftGroupbox("Anti Lava")
AntiLavaGroup:AddToggle("AntiLavaToggle",{Text="Enable Anti Lava",Default=false,Callback=function(v)
antiLavaActive=v
if v then startAntiLava()else stopAntiLava()end
end})
local ESPTab=Tabs.ESP
local ESPGroup=ESPTab:AddLeftGroupbox("ESP Settings")
local ESPVisualGroup=ESPTab:AddRightGroupbox("ESP Appearance")
ESPGroup:AddToggle("ESPToggle",{Text="Enable ESP",Default=false,Callback=function(v)ESPModule:SetESPEnabled(v)end})
ESPGroup:AddToggle("ShowBox",{Text="Show Box",Default=true,Callback=function(v)ESPModule:SetShowBox(v)end})
ESPGroup:AddToggle("ShowName",{Text="Show Name",Default=true,Callback=function(v)ESPModule:SetShowName(v)end})
ESPGroup:AddToggle("ShowDistance",{Text="Show Distance",Default=true,Callback=function(v)ESPModule:SetShowDistance(v)end})
ESPGroup:AddToggle("ShowHealth",{Text="Show Health Bar",Default=true,Callback=function(v)ESPModule:SetShowHealth(v)end})
ESPGroup:AddToggle("ShowAllPlayers",{Text="Show All Players",Default=false,Callback=function(v)ESPModule:SetShowAllPlayers(v)end})
ESPGroup:AddDropdown("LineOrigin",{Values={"Player","Center","Top"},Default="Player",Text="Line Origin",Callback=function(v)ESPModule:SetLineOrigin(v)end})
ESPVisualGroup:AddToggle("ShowLine",{Text="Show Tracers (Lines)",Default=true,Callback=function(v)ESPModule:SetShowLine(v)end})
ESPVisualGroup:AddDropdown("BoxColor",{Values={"Red","Green","Blue","Yellow","White","Cyan","Magenta"},Default="Red",Text="Box Color",Callback=function(v)ESPModule:SetBoxColor(v)end})
ESPVisualGroup:AddDropdown("TextColor",{Values={"Red","Green","Blue","Yellow","White","Cyan","Magenta"},Default="White",Text="Text Color",Callback=function(v)ESPModule:SetTextColor(v)end})
ESPVisualGroup:AddDropdown("LineColor",{Values={"Red","Green","Blue","Yellow","White","Cyan","Magenta"},Default="Red",Text="Line Color",Callback=function(v)ESPModule:SetLineColor(v)end})
local SA=Tabs.SilentAim
local MainGroup=SA:AddLeftGroupbox("Main")
MainGroup:AddToggle("EnablePlayerAim",{Text="Player Silent Aim",Default=false,Callback=function(v)SilentAimModule:SetPlayerSilentAim(v)end})
MainGroup:AddToggle("EnableNPCAim",{Text="NPC Silent Aim",Default=false,Callback=function(v)SilentAimModule:SetNPCSilentAim(v)end})
local TargetGroup=SA:AddLeftGroupbox("Target Settings")
TargetGroup:AddDropdown("AimModeSelection",{Values={"360","180","FOV"},Default="360",Text="Aim Angle Mode",Callback=function(v)SilentAimModule:SetAimMode(v)end})
TargetGroup:AddDropdown("PrioritySelection",{Values={"Nearest","Low HP","Looking At Me","Lock Player"},Default="Nearest",Text="Target Priority",Callback=function(v)SilentAimModule:SetTargetPriority(v)end})
local FOVGroup=SA:AddLeftGroupbox("FOV Settings")
FOVGroup:AddToggle("ShowFOVCircle",{Text="Show FOV Circle",Default=false,Callback=function(v)SilentAimModule:SetShowFOVCircle(v)end})
FOVGroup:AddDropdown("FOVModeSelection",{Values={"V1","V2"},Default="V1",Text="FOV Mode",Callback=function(v)SilentAimModule:SetFOVMode(v)end})
FOVGroup:AddSlider("FOVRadiusSize",{Text="FOV Radius Size",Default=100,Min=10,Max=800,Rounding=0,Callback=function(v)SilentAimModule:SetFOVRadius(v)end})
local M1ExtGroup=SA:AddRightGroupbox("M1 Extender")
M1ExtGroup:AddToggle("M1ExtenderToggle",{Text="Enable M1 Extender",Default=false,Callback=function(v)M1Extender:Toggle(v)end})
M1ExtGroup:AddSlider("M1ExtenderRange",{Text="Extender Range",Default=50,Min=10,Max=100,Rounding=0,Callback=function(v)M1Extender:SetRange(v)end})
local GunGroup=SA:AddRightGroupbox("Gun Click SL")
GunGroup:AddToggle("GunClickSLToggle",{Text="Enable Gun Click SL",Default=false,Callback=function(v)GunClickSL:SetEnabled(v)end})
local OptionsGroup=SA:AddRightGroupbox("Options")
local PlayerDropdown=OptionsGroup:AddDropdown("LockPlayerSelect",{Values={"None"},Default="None",Text="Target Player List",Callback=function(v)SilentAimModule:SetSelectedPlayer(v)end})
local function refreshPlayerList()
local list={"None"}
for _,p in ipairs(Players:GetPlayers())do if p~=lp then table.insert(list,p.Name)end end
PlayerDropdown:SetValues(list)
end
task.spawn(function()while true do refreshPlayerList();task.wait(5)end end)
OptionsGroup:AddButton("Refresh Player List",refreshPlayerList)
OptionsGroup:AddSlider("MaxRange",{Text="Max Range",Default=1000,Min=100,Max=3000,Rounding=0,Suffix="m",Callback=function(v)SilentAimModule:SetDistanceLimit(v)end})
OptionsGroup:AddToggle("EnableTracer",{Text="Enable Tracer",Default=false,Callback=function(v)SilentAimModule:SetTracerEnabled(v)end})
OptionsGroup:AddDropdown("TracerColor",{Values={"Red","Green","Blue","Yellow","White"},Default="Red",Text="Tracer Color",Callback=function(v)SilentAimModule:SetTracerColor(v)end})
local BLTab=Tabs.SABlacklist
local BlacklistLeft=BLTab:AddLeftGroupbox("Blacklist Melee & Fruit")
local BlacklistRight=BLTab:AddRightGroupbox("Blacklist Swords & Guns")
BlacklistLeft:AddLabel("--- MELEES ---")
for _,key in ipairs({"Z","X","C"})do
BlacklistLeft:AddToggle("B_Melee_"..key,{Text="Melee: Blacklist "..key,Default=false,Callback=function(v)SilentAimModule:SetBlacklistKey("Melee",key,v)end})
end
BlacklistLeft:AddLabel("--- FRUITS ---")
for _,key in ipairs({"Z","X","C","V","F","TAP"})do
BlacklistLeft:AddToggle("B_Fruit_"..key,{Text="Fruit: Blacklist "..key,Default=false,Callback=function(v)SilentAimModule:SetBlacklistKey("Fruit",key,v)end})
end
BlacklistRight:AddLabel("--- SWORDS ---")
for _,key in ipairs({"Z","X"})do
BlacklistRight:AddToggle("B_Sword_"..key,{Text="Sword: Blacklist "..key,Default=false,Callback=function(v)SilentAimModule:SetBlacklistKey("Sword",key,v)end})
end
BlacklistRight:AddLabel("--- GUNS ---")
for _,key in ipairs({"Z","X"})do
BlacklistRight:AddToggle("B_Gun_"..key,{Text="Gun: Blacklist "..key,Default=false,Callback=function(v)SilentAimModule:SetBlacklistKey("Gun",key,v)end})
end
local function closeTheScript()
_G.NamelessLoaded=false
_G.NamelessAuthToken=nil
_G.NamelessScriptBasiqueRunning=nil
_G.NamelessAHKRunning=nil
_G.NamelessComboRunning=nil
pcall(UnloadAHKsoru)
pcall(UnloadAHKComboScript)
pcall(function()Library:Unload()end)
pcall(function()
local containers={lp:FindFirstChild("PlayerGui"),game:GetService("CoreGui")}
if get_hidden_gui then table.insert(containers,get_hidden_gui())end
for _,parent in ipairs(containers)do
if parent then
for _,g in pairs(parent:GetChildren())do
if g:IsA("ScreenGui")and(g.Name:find("Nameless")or g.Name:find("nameless")or g.Name:find("AHK")or g.Name:find("NM_Notify")or g.Name:find("Obsidian")or g.Name:find("Linoria"))then
g:Destroy()
end
end
end
end
end)
end
local MenuGroup=Tabs.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload",function()Library:Unload()end)
MenuGroup:AddButton("Close The Script",closeTheScript)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind",{Default="End",NoUI=true,Text="Menu keybind"})
Library.ToggleKeybind=Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("LinoriaMobile")
SaveManager:SetFolder("LinoriaMobile/game")
ThemeManager:ApplyToGroupbox(MenuGroup)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
task.wait(0.5)
for _,cat in ipairs({"Melee","Sword","Fruit","Gun"})do
local keys={}
if cat=="Melee"then keys={"Z","X","C"}elseif cat=="Sword"then keys={"Z","X"}elseif cat=="Fruit"then keys={"Z","X","C","V","F","TAP"}elseif cat=="Gun"then keys={"Z","X"}end
for _,key in ipairs(keys)do
local toggleName="B_"..cat.."_"..key
if Options[toggleName]then SilentAimModule:SetBlacklistKey(cat,key,Options[toggleName].Value)end
end
end
local function onChatted(msg)
local msgLower=msg:lower()
if not msgLower:match("^/e%s+")then return end
local command=msgLower:gsub("^/e%s+",""):gsub("%s+"," "):gsub("^%s*(.-)%s*$","%1")
if command=="hide"then
if Library.ScreenGui then
Library.ScreenGui.Enabled=false
end
elseif command=="unhide"or command=="show"then
if Library.ScreenGui then
Library.ScreenGui.Enabled=true
end
end
end
lp.Chatted:Connect(onChatted)
