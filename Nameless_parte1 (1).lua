local repo="https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library=loadstring(game:HttpGet(repo.."Library.lua"))()
local ThemeManager=loadstring(game:HttpGet(repo.."addons/ThemeManager.lua"))()
local SaveManager=loadstring(game:HttpGet(repo.."addons/SaveManager.lua"))()
local Options=Library.Options
local Toggles=Library.Toggles
if not isfolder("NamelessConfigs")then makefolder("NamelessConfigs")end
if not isfolder("NamelessConfigs/Fonts")then makefolder("NamelessConfigs/Fonts")end
local Window=Library:CreateWindow({
Title="NamelessWare",
Footer="lumexa on top",
ShowCustomCursor=true,
NotifySide="Right",
Size=UDim2.new(0,600,0,460),
})
task.delay(0.2,function()
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local lp=Players.LocalPlayer
local function applyLogo()
local titleLabel=nil
local containers={CoreGui,lp:FindFirstChild("PlayerGui")}
for _,parent in ipairs(containers)do
if parent then
for _,descendant in ipairs(parent:GetDescendants())do
if descendant:IsA("TextLabel")and(descendant.Text=="NamelessWare"or descendant.Text:find("Nameless"))then
if descendant.Parent and descendant.Parent:FindFirstChild("NamelessLogoIcon")then
return true
end
titleLabel=descendant
break
end
end
end
if titleLabel then break end
end
if titleLabel then
titleLabel.RichText=true
titleLabel.Text='<font color="#ffffff">Nameless</font><font color="#a050ff">Ware</font>'
local titleParent=titleLabel.Parent
if titleParent then
local existingLogo=titleParent:FindFirstChild("NamelessLogoIcon")
if existingLogo then existingLogo:Destroy()end
local logoImg=Instance.new("ImageButton")
logoImg.Name="NamelessLogoIcon"
logoImg.BackgroundTransparency=1
logoImg.Size=UDim2.new(0,22,0,22)
logoImg.Image="rbxassetid://105243902490842"
logoImg.ScaleType=Enum.ScaleType.Fit
logoImg.AutoButtonColor=false
local UICornerLogo=Instance.new("UICorner")
UICornerLogo.CornerRadius=UDim.new(0,4)
UICornerLogo.Parent=logoImg
local listLayout=titleParent:FindFirstChildOfClass("UIListLayout")
if listLayout then
logoImg.LayoutOrder=0
titleLabel.LayoutOrder=1
else
logoImg.Position=UDim2.new(0,8,0,(titleLabel.Position.Y.Offset>0 and titleLabel.Position.Y.Offset or 6))
titleLabel.Position=UDim2.new(0,36,0,titleLabel.Position.Y.Offset)
end
logoImg.Parent=titleParent
local windowFrame=titleParent
while windowFrame and windowFrame.Parent and not windowFrame.Parent:IsA("ScreenGui")do
windowFrame=windowFrame.Parent
end
local screenGui=windowFrame and windowFrame.Parent
local toggleBtn=nil
if screenGui then
toggleBtn=screenGui:FindFirstChild("NamelessToggleIcon")
if not toggleBtn then
toggleBtn=Instance.new("ImageButton")
toggleBtn.Name="NamelessToggleIcon"
toggleBtn.Size=UDim2.new(0,42,0,42)
toggleBtn.Position=UDim2.new(0.05,0,0.15,0)
toggleBtn.BackgroundColor3=Color3.fromRGB(15,15,20)
toggleBtn.BackgroundTransparency=0.1
toggleBtn.Image="rbxassetid://105243902490842"
toggleBtn.ScaleType=Enum.ScaleType.Fit
toggleBtn.Visible=false
toggleBtn.Active=true
toggleBtn.Draggable=true
toggleBtn.Parent=screenGui
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,10)
corner.Parent=toggleBtn
local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(160,80,255)
stroke.Thickness=2
stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
stroke.Parent=toggleBtn
toggleBtn.MouseButton1Click:Connect(function()
toggleBtn.Visible=false
if windowFrame then windowFrame.Visible=true end
end)
end
end
logoImg.MouseButton1Click:Connect(function()
if windowFrame then
if toggleBtn then
toggleBtn.Position=UDim2.new(
windowFrame.Position.X.Scale,
windowFrame.Position.X.Offset+10,
windowFrame.Position.Y.Scale,
windowFrame.Position.Y.Offset+10
)
toggleBtn.Visible=true
end
windowFrame.Visible=false
end
end)
return true
end
end
return false
end
for i=1,5 do
if applyLogo()then break end
task.wait(0.3)
end
end)
local Tabs={
Macro=Window:AddTab("Macro","keyboard"),
SilentAim=Window:AddTab("Silent Aim","crosshair"),
SABlacklist=Window:AddTab("SA Blacklist","ban"),
Glitch=Window:AddTab("Glitch","zap"),
Movement=Window:AddTab("Movement","move"),
Apparence=Window:AddTab("Appearance","user"),
Misc=Window:AddTab("Misc","box"),
ESP=Window:AddTab("ESP","eye"),
Settings=Window:AddTab("Settings","settings"),
}
local Players=game:GetService("Players")
local lp=Players.LocalPlayer
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local camera=workspace.CurrentCamera
local RS=game:GetService("ReplicatedStorage")
local SilentAimModule
local sharkZActive,vActive,cursedZActive=false,false,false
local rightTouchActive=false
local damageDetected=false
local isBunnyHopping=false
local ahk_soru_loaded=false
local function UnloadAHKsoru()
ahk_soru_loaded=false
_G.NamelessAHKRunning=nil
pcall(function()
local containers={lp:FindFirstChild("PlayerGui"),game:GetService("CoreGui")}
for _,parent in ipairs(containers)do
if parent then
for _,child in pairs(parent:GetChildren())do
if child.Name:find("AHK_Soru")or child.Name:find("namelessWare_AHK_Soru")then
child:Destroy()
end
end
end
end
end)
Library:Notify({Title="AHK Soru",Description="Script disabled!",Time=3})
end
local function LoadAHKsoru()
_G.NamelessAHKRunning=nil
ahk_soru_loaded=false
local success,err=pcall(function()
local script_code=game:HttpGet("https://raw.githubusercontent.com/sykq0/Namelesssoru/refs/heads/main/ahk.lua")
loadstring(script_code)()
end)
if success then
ahk_soru_loaded=true
Library:Notify({Title="AHK Soru",Description="Script loaded!",Time=3})
else
Library:Notify({Title="AHK Soru",Description="Loading error.",Time=3})
end
end
local ahk_combo_script_loaded=false
local function UnloadAHKComboScript()
ahk_combo_script_loaded=false
_G.NamelessComboRunning=nil
pcall(function()
local containers={lp:FindFirstChild("PlayerGui"),game:GetService("CoreGui")}
for _,parent in ipairs(containers)do
if parent then
for _,child in pairs(parent:GetChildren())do
if child.Name:find("AHK_Combo")or child.Name:find("namelessWare_AHK_Combo")then
child:Destroy()
end
end
end
end
end)
Library:Notify({Title="AHK Combo",Description="Script disabled!",Time=3})
end
local function LoadAHKComboScript()
_G.NamelessComboRunning=nil
ahk_combo_script_loaded=false
local success,err=pcall(function()
local script_code=game:HttpGet("https://raw.githubusercontent.com/sykq0/Namelesssoru/refs/heads/main/fetched-1.lua")
loadstring(script_code)()
end)
if success then
ahk_combo_script_loaded=true
Library:Notify({Title="AHK Combo",Description="Script loaded!",Time=3})
else
Library:Notify({Title="AHK Combo",Description="Loading error.",Time=3})
end
end
local function watchDamageCounter()
task.spawn(function()
while true do
local gui=lp:FindFirstChild("PlayerGui")and lp.PlayerGui:FindFirstChild("Main")
local dmgCounter=gui and gui:FindFirstChild("DmgCounter")
local dmgTextLabel=dmgCounter and dmgCounter:FindFirstChild("Text")
if dmgTextLabel then
dmgTextLabel:GetPropertyChangedSignal("Text"):Connect(function()
local dmgText=tonumber(dmgTextLabel.Text)or 0
damageDetected=(dmgText>0)
end)
break
end
task.wait(1)
end
end)
end
watchDamageCounter()
local function isValidStopCondition()
local tool=lp.Character and lp.Character:FindFirstChildOfClass("Tool")
return(tool and tool.Name=="Shark Anchor"and sharkZActive)
or(vActive)
or(tool and tool.Name=="Cursed Dual Katana"and cursedZActive)
end
local multiEnabled=false;local multiPower=400;local multiDuration=0.9
local multiCharging=false;local multiChargeStart=0;local multiRequiredCharge=1.0
local diamondEnabled=false;local diamondPower=250;local diamondDuration=0.3
local diamondCharging=false;local diamondChargeStart=0;local diamondRequiredCharge=1.0
local dtalonEnabled=false;local dtalonPower=400;local dtalonDuration=0.9
local dtalonCharging=false;local dtalonChargeStart=0;local dtalonRequiredCharge=1.0
local EClawBoost
local function MegaBoost()
local char=lp.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChild("Humanoid")
if not hrp or not hum then return end
local dir=camera.CFrame.LookVector
hum.PlatformStand=true
local att=Instance.new("Attachment",hrp);local lv=Instance.new("LinearVelocity",hrp)
lv.MaxForce=9999999;lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector;lv.VectorVelocity=dir*multiPower;lv.Attachment0=att
local boostActive=true;local boostEndTime=tick()+multiDuration;local dmgConn
local function stopPropulsion()
if not boostActive then return end;boostActive=false
if lv then lv:Destroy()end;if att then att:Destroy()end;if hum then hum.PlatformStand=false end;if dmgConn then dmgConn:Disconnect()end
end
local dmgLabel=lp:FindFirstChild("PlayerGui")and lp.PlayerGui:FindFirstChild("Main")and lp.PlayerGui.Main:FindFirstChild("DmgCounter")and lp.PlayerGui.Main.DmgCounter:FindFirstChild("Text")
local startText=dmgLabel and dmgLabel.Text or""
if dmgLabel then
dmgConn=dmgLabel:GetPropertyChangedSignal("Text"):Connect(function()
local currentText=dmgLabel.Text
if(currentText~=startText and currentText~=""and currentText~="0")or(rightTouchActive and isValidStopCondition())then
stopPropulsion()
end
end)
end
while boostActive and tick()<boostEndTime do task.wait()end;stopPropulsion()
end
RunService.Heartbeat:Connect(function()
if not multiEnabled then return end
local char=lp.Character;local hum=char and char:FindFirstChild("Humanoid");if not hum then return end
local isGC=false
for _,a in pairs(hum:GetPlayingAnimationTracks())do
if a.Animation.AnimationId:find("14418367908")or a.Name=="GhoulZCharge"then isGC=true;break end
end
if isGC then if not multiCharging then multiCharging=true;multiChargeStart=tick()end
else if multiCharging then if(tick()-multiChargeStart)>=multiRequiredCharge then task.spawn(MegaBoost)end;multiCharging=false;multiChargeStart=0 end end
end)
local function DiamondBoost()
local char=lp.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChild("Humanoid")
if not hrp or not hum then return end
local dir=camera.CFrame.LookVector
hum.PlatformStand=true
local att=Instance.new("Attachment",hrp);local lv=Instance.new("LinearVelocity",hrp)
lv.MaxForce=9999999;lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector;lv.VectorVelocity=dir*diamondPower;lv.Attachment0=att
local boostActive=true;local boostEndTime=tick()+diamondDuration;local dmgConn
local function stopPropulsion()
if not boostActive then return end;boostActive=false
if lv then lv:Destroy()end;if att then att:Destroy()end;if hum then hum.PlatformStand=false end;if dmgConn then dmgConn:Disconnect()end
end
local dmgLabel=lp:FindFirstChild("PlayerGui")and lp.PlayerGui:FindFirstChild("Main")and lp.PlayerGui.Main:FindFirstChild("DmgCounter")and lp.PlayerGui.Main.DmgCounter:FindFirstChild("Text")
local startText=dmgLabel and dmgLabel.Text or""
if dmgLabel then
dmgConn=dmgLabel:GetPropertyChangedSignal("Text"):Connect(function()
local currentText=dmgLabel.Text
if(currentText~=startText and currentText~=""and currentText~="0")or(rightTouchActive and isValidStopCondition())then
stopPropulsion()
end
end)
end
while boostActive and tick()<boostEndTime do task.wait()end;stopPropulsion()
end
RunService.Heartbeat:Connect(function()
if not diamondEnabled then return end
local char=lp.Character;local hum=char and char:FindFirstChild("Humanoid");if not hum then return end
local isC=false
for _,a in pairs(hum:GetPlayingAnimationTracks())do
if a.Animation.AnimationId:find("14414815375")then isC=true;break end
end
if isC then if not diamondCharging then diamondCharging=true;diamondChargeStart=tick()end
else if diamondCharging then if(tick()-diamondChargeStart)>=diamondRequiredCharge then task.spawn(DiamondBoost)end;diamondCharging=false;diamondChargeStart=0 end end
end)
local function DTalonBoost()
local char=lp.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChild("Humanoid")
if not hrp or not hum then return end
local dir=camera.CFrame.LookVector
hum.PlatformStand=true
local att=Instance.new("Attachment",hrp);local lv=Instance.new("LinearVelocity",hrp)
lv.MaxForce=9999999;lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector;lv.VectorVelocity=dir*dtalonPower;lv.Attachment0=att
local boostActive=true;local boostEndTime=tick()+dtalonDuration;local dmgConn
local function stopPropulsion()
if not boostActive then return end;boostActive=false
if lv then lv:Destroy()end;if att then att:Destroy()end;if hum then hum.PlatformStand=false end;if dmgConn then dmgConn:Disconnect()end
end
local dmgLabel=lp:FindFirstChild("PlayerGui")and lp.PlayerGui:FindFirstChild("Main")and lp.PlayerGui.Main:FindFirstChild("DmgCounter")and lp.PlayerGui.Main.DmgCounter:FindFirstChild("Text")
local startText=dmgLabel and dmgLabel.Text or""
if dmgLabel then
dmgConn=dmgLabel:GetPropertyChangedSignal("Text"):Connect(function()
local currentText=dmgLabel.Text
if(currentText~=startText and currentText~=""and currentText~="0")or(rightTouchActive and isValidStopCondition())then
stopPropulsion()
end
end)
end
while boostActive and tick()<boostEndTime do task.wait()end;stopPropulsion()
end
RunService.Heartbeat:Connect(function()
if not dtalonEnabled then return end
local char=lp.Character;local hum=char and char:FindFirstChild("Humanoid");if not hum then return end
local isC=false
for _,a in pairs(hum:GetPlayingAnimationTracks())do
if a.Animation.AnimationId:find("18839089313")or a.Name=="DTalon_ZCharge"then isC=true;break end
end
if isC then if not dtalonCharging then dtalonCharging=true;dtalonChargeStart=tick()end
else if dtalonCharging then if(tick()-dtalonChargeStart)>=dtalonRequiredCharge then task.spawn(DTalonBoost)end;dtalonCharging=false;dtalonChargeStart=0 end end
end)
EClawBoost=(function()
local M={};local enabled=false;local power=400;local duration=1.7;local requiredCharge=0.0;local boosted=false
local function boost()
local char=lp.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
if not hrp or not hum then return end;local mouse=lp:GetMouse();local dir=(mouse.Hit.p-hrp.Position).Unit
hum.PlatformStand=true;local att=Instance.new("Attachment",hrp);local lv=Instance.new("LinearVelocity",hrp)
lv.MaxForce=9999999;lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector;lv.VectorVelocity=dir*power;lv.Attachment0=att
local boostActive=true;local boostEndTime=tick()+duration;local dmgConn
local function stopPropulsion()
if not boostActive then return end;boostActive=false
if lv then lv:Destroy()end;if att then att:Destroy()end;if hum then hum.PlatformStand=false end;if dmgConn then dmgConn:Disconnect()end
end
local dmgLabel=lp:FindFirstChild("PlayerGui")and lp.PlayerGui:FindFirstChild("Main")and lp.PlayerGui.Main:FindFirstChild("DmgCounter")and lp.PlayerGui.Main.DmgCounter:FindFirstChild("Text")
local startText=dmgLabel and dmgLabel.Text or""
if dmgLabel then
dmgConn=dmgLabel:GetPropertyChangedSignal("Text"):Connect(function()
local currentText=dmgLabel.Text
if(currentText~=startText and currentText~=""and currentText~="0")or(rightTouchActive and isValidStopCondition())then
stopPropulsion()
end
end)
end
while boostActive and tick()<boostEndTime do task.wait()end;stopPropulsion()
end
local function hookAnimations(hum)
hum.AnimationPlayed:Connect(function(track)
if not enabled then return end
if track.Animation.AnimationId:find("6875496851")or track.Name=="ElectroClawXImpact"then
boosted=false;local chargeStart=tick()
track.Stopped:Connect(function()
if not enabled and not boosted then return end
if(tick()-chargeStart)>=requiredCharge then boosted=true;task.spawn(boost)end
end)
end
end)
end
function M:Toggle(v)enabled=v;if not v then boosted=false end end
function M:SetPower(v)power=v end
function M:SetDuration(v)duration=v end
function M:SetRequiredCharge(v)requiredCharge=v end
function M:Init(char)local hum=char:WaitForChild("Humanoid");hookAnimations(hum)end
return M
end)()
lp.CharacterAdded:Connect(function(char)EClawBoost:Init(char)end)
if lp.Character then EClawBoost:Init(lp.Character)end
local fakeHeadlessEnabled=false
local fakeHeadlessVersion="V1"
local fakeKorbloxEnabled=false
local fakeKorbloxVersion="V1"
local korbloxMeshes={}
function applyFakeKorblox()
local char=lp.Character if not char then return end
local rl=char:FindFirstChild("RightUpperLeg")
local rl2=char:FindFirstChild("RightLowerLeg")
local rf=char:FindFirstChild("RightFoot")
if rl then
rl.Transparency=1
for _,c in pairs(rl:GetChildren())do if c:IsA("SpecialMesh")then c:Destroy()end end
local mesh=Instance.new("SpecialMesh")
mesh.MeshId="rbxassetid://139607718"
mesh.TextureId="rbxassetid://139607673"
mesh.Scale=Vector3.new(1,1,1)mesh.Parent=rl
table.insert(korbloxMeshes,mesh)
end
if rl2 then rl2.Transparency=1 end
if rf then rf.Transparency=1 end
if fakeKorbloxVersion=="V2"then
for _,n in pairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot"})do
local p=char:FindFirstChild(n)if p then p.Transparency=1 end
end
end
end
function removeFakeKorblox()
for _,m in pairs(korbloxMeshes)do pcall(function()m:Destroy()end)end
korbloxMeshes={}
local char=lp.Character if not char then return end
for _,n in pairs({"RightUpperLeg","RightLowerLeg","RightFoot","LeftUpperLeg","LeftLowerLeg","LeftFoot"})do
local p=char:FindFirstChild(n)if p then p.Transparency=0 end
end
end
function applyFakeHeadless()
local char=lp.Character if not char then return end
local head=char:FindFirstChild("Head")
if head then
head.Transparency=1
local face=head:FindFirstChild("face")
if face then face.Transparency=1 end
end
if fakeHeadlessVersion=="V2"then
for _,obj in pairs(char:GetChildren())do
if obj:IsA("Accessory")then
local handle=obj:FindFirstChild("Handle")
if handle then handle.Transparency=1 end
end
end
end
end
function removeFakeHeadless()
local char=lp.Character if not char then return end
local head=char:FindFirstChild("Head")
if head then
head.Transparency=0
local face=head:FindFirstChild("face")
if face then face.Transparency=0 end
end
for _,obj in pairs(char:GetChildren())do
if obj:IsA("Accessory")then
local handle=obj:FindFirstChild("Handle")
if handle then handle.Transparency=0 end
end
end
end
local function onCharacterAddedApparence(char)
task.spawn(function()
task.wait(0.3)
if fakeHeadlessEnabled then applyFakeHeadless()end
if fakeKorbloxEnabled then applyFakeKorblox()end
end)
end
lp.CharacterAdded:Connect(onCharacterAddedApparence)
if lp.Character then onCharacterAddedApparence(lp.Character)end
local bunnyHopEnabled=false
local superJumpEnabled=false
local superJumpMode="V1"
local superJumpPower=150
local normalJumpPower=50
local superJumpButton=nil
local dashLengthEnabled=false
local dashLengthValue=1
local dashLengthConnection=nil
local flySettings={flyActive=false,noclipActive=false,mode="CFrame",speed=50,incore=nil,nocore=nil}
local flyMiniGui=nil;local flyMiniButton=nil;local flyDragConn,flyEndConn=nil,nil
local speedSettings={speedActive=false,mode="WalkSpeed",speedValue=50,incore=nil}
local speedMiniGui=nil;local speedMiniButton=nil;local speedDragConn,speedEndConn=nil,nil
local function StartFly()
if flySettings.incore then flySettings.incore:Disconnect()end
flySettings.flyActive=true
flySettings.incore=RunService.Stepped:Connect(function()
local char=lp.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
if not flySettings.flyActive or not hrp or not hum then return end
local moveDir=hum.MoveDirection
local camCF=camera.CFrame
local direction=Vector3.new(0,0,0)
if moveDir.Magnitude>0 then
local relativeMove=camCF:VectorToObjectSpace(moveDir)
direction=((camCF.RightVector*relativeMove.X)+(camCF.LookVector*-relativeMove.Z)).Unit
end
if flySettings.mode=="CFrame"then
hum.PlatformStand=true
hrp.CFrame=hrp.CFrame+(direction*(flySettings.speed/10))
hrp.Velocity=Vector3.zero
elseif flySettings.mode=="Velocity"then
hrp.Velocity=(direction*flySettings.speed)+Vector3.new(0,2,0)
end
if UserInputService:IsKeyDown(Enum.KeyCode.Space)then hrp.CFrame=hrp.CFrame+Vector3.new(0,flySettings.speed/15,0)end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)then hrp.CFrame=hrp.CFrame+Vector3.new(0,-flySettings.speed/15,0)end
end)
end
local function StopFly()
flySettings.flyActive=false;if flySettings.incore then flySettings.incore:Disconnect();flySettings.incore=nil end
if lp.Character and lp.Character:FindFirstChild("Humanoid")then lp.Character.Humanoid.PlatformStand=false end
end
local function StartNoClip()
if flySettings.nocore then flySettings.nocore:Disconnect()end
flySettings.nocore=RunService.Stepped:Connect(function()
if lp.Character then for _,p in pairs(lp.Character:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end end
end)
end
local function StopNoClip()
if flySettings.nocore then flySettings.nocore:Disconnect();flySettings.nocore=nil end
end
local function applySpeedHack()
local char=lp.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
if not hrp or not hum then return end
local moveDir=hum.MoveDirection
if speedSettings.mode=="WalkSpeed"then
hum.WalkSpeed=speedSettings.speedValue
elseif speedSettings.mode=="CFrame"and moveDir.Magnitude>0 then
hrp.CFrame=hrp.CFrame+(moveDir*(speedSettings.speedValue/100))
elseif speedSettings.mode=="Velocity"and moveDir.Magnitude>0 then
hrp.Velocity=Vector3.new(moveDir.X*speedSettings.speedValue,hrp.Velocity.Y,moveDir.Z*speedSettings.speedValue)
elseif speedSettings.mode=="TP-Flash"and moveDir.Magnitude>0 then
hrp.CFrame=hrp.CFrame*CFrame.new(0,0,-speedSettings.speedValue/50)
elseif speedSettings.mode=="AnimSpeed"then
hum.WalkSpeed=speedSettings.speedValue
for _,track in pairs(hum:GetPlayingAnimationTracks())do track:AdjustSpeed(speedSettings.speedValue/16)end
end
end
local function StartSpeedHack()
speedSettings.speedActive=true
end
local function StopSpeedHack()
speedSettings.speedActive=false
if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")then lp.Character.Humanoid.WalkSpeed=16 end
end
RunService.Heartbeat:Connect(function()
if not speedSettings.speedActive then return end
applySpeedHack()
end)
local function applySuperJumpV1()
local char=lp.Character
if not char then return end
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then
hum.UseJumpPower=true
hum.JumpPower=superJumpPower
end
end
local function resetSuperJumpToNormal()
local char=lp.Character
if not char then return end
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then
hum.JumpPower=normalJumpPower
end
end
local function createSuperJumpButton()
if superJumpButton then return end
local gui=Instance.new("ScreenGui",game:GetService("CoreGui"))
gui.Name="SuperJumpBtn"
local btn=Instance.new("TextButton",gui)
btn.Size=UDim2.new(0,120,0,50)
btn.Position=UDim2.new(0.05,0,0.8,0)
btn.BackgroundColor3=Color3.fromRGB(200,70,30)
btn.TextColor3=Color3.new(1,1,1)
btn.Font=Enum.Font.GothamBold
btn.TextSize=15
btn.Text="🚀 SUPER JUMP"
btn.BorderSizePixel=0
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
btn.MouseButton1Click:Connect(function()
local char=lp.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if hrp then
if damageDetected then return end
hrp.Velocity=Vector3.new(hrp.Velocity.X,superJumpPower,hrp.Velocity.Z)
end
end)
local dragging,dragStart,startPos
btn.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
dragging=true;dragStart=i.Position;startPos=btn.AbsolutePosition
end
end)
UserInputService.InputChanged:Connect(function(i)
if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
local delta=i.Position-dragStart
local vp=workspace.CurrentCamera.ViewportSize
btn.Position=UDim2.new(0,math.clamp(startPos.X+delta.X,0,vp.X-btn.AbsoluteSize.X),0,math.clamp(startPos.Y+delta.Y,0,vp.Y-btn.AbsoluteSize.Y))
end
end)
UserInputService.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
superJumpButton=gui
end
local function destroySuperJumpButton()
if superJumpButton then superJumpButton:Destroy();superJumpButton=nil end
end
local function updateSuperJumpState()
if not superJumpEnabled then
resetSuperJumpToNormal()
if superJumpButton then destroySuperJumpButton()end
return
end
if superJumpMode=="V1"then
if superJumpButton then destroySuperJumpButton()end
applySuperJumpV1()
elseif superJumpMode=="V2"then
resetSuperJumpToNormal()
createSuperJumpButton()
elseif superJumpMode=="V3"then
resetSuperJumpToNormal()
if superJumpButton then destroySuperJumpButton()end
end
end
RunService.Heartbeat:Connect(function()
if superJumpEnabled and superJumpMode=="V1"and lp.Character then
local hum=lp.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.JumpPower=(damageDetected or isBunnyHopping)and normalJumpPower or superJumpPower end
end
end)
UserInputService.InputBegan:Connect(function(input,gameProcessed)
if gameProcessed then return end
if superJumpEnabled and superJumpMode=="V3"and input.KeyCode==Enum.KeyCode.Space then
local char=lp.Character
if not char then return end
local hum=char:FindFirstChildOfClass("Humanoid")
local hrp=char:FindFirstChild("HumanoidRootPart")
if not hum or not hrp then return end
local onGround=false
if hum.FloorMaterial~=Enum.Material.Air then
onGround=true
else
local raycastParams=RaycastParams.new()
raycastParams.FilterDescendantsInstances={char}
raycastParams.FilterType=Enum.RaycastFilterType.Exclude
local ray=workspace:Raycast(hrp.Position,Vector3.new(0,-4.5,0),raycastParams)
if ray then
onGround=true
end
end
if not onGround then return end
if damageDetected then return end
local originalJumpPower=hum.JumpPower
hum.JumpPower=superJumpPower
hum:Jump()
task.delay(0.1,function()
if hum then hum.JumpPower=originalJumpPower end
end)
end
end)
local function CreateFlyMiniToggle()
if flyMiniGui then return end
local screenGui=Instance.new("ScreenGui");screenGui.Name="FlyMiniToggle";screenGui.ResetOnSpawn=false;screenGui.Parent=game:GetService("CoreGui")
flyMiniGui=screenGui
local button=Instance.new("TextButton",screenGui)
button.Size=UDim2.new(0,80,0,40);button.Position=UDim2.new(0,10,0.5,-20);button.Text="FLY: ON";button.TextScaled=true
button.BackgroundColor3=Color3.fromRGB(30,30,30);button.TextColor3=Color3.fromRGB(255,255,255);button.BorderSizePixel=0
Instance.new("UICorner",button).CornerRadius=UDim.new(0,8)
local gradient=Instance.new("UIGradient",button);gradient.Rotation=45
local function updateButton(state)
button.Text="FLY: "..(state and"ON"or"OFF")
gradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,state and Color3.fromRGB(50,200,50)or Color3.fromRGB(80,80,80)),
ColorSequenceKeypoint.new(1,state and Color3.fromRGB(50,255,50)or Color3.fromRGB(50,50,50))
}
end
local function onButtonClick()
local newState=not flySettings.flyActive
if newState then StartFly()else StopFly()end
updateButton(newState)
local toggle=Library.Options and Library.Options.FlyToggle
if toggle then toggle:SetValue(newState)end
end
button.MouseButton1Click:Connect(onButtonClick)
flyMiniButton=button
local dragging,dragStart,startPos
button.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=true;dragStart=input.Position;startPos=button.AbsolutePosition
end
end)
flyDragConn=UserInputService.InputChanged:Connect(function(input)
if dragging and(input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement)then
local delta=input.Position-dragStart;local vp=camera.ViewportSize
button.Position=UDim2.new(0,math.clamp(startPos.X+delta.X,0,vp.X-button.AbsoluteSize.X),0,math.clamp(startPos.Y+delta.Y,0,vp.Y-button.AbsoluteSize.Y))
end
end)
flyEndConn=UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=false
end
end)
end
local function DestroyFlyMiniToggle()
if flyDragConn then flyDragConn:Disconnect();flyDragConn=nil end
if flyEndConn then flyEndConn:Disconnect();flyEndConn=nil end
if flyMiniGui then flyMiniGui:Destroy();flyMiniGui=nil;flyMiniButton=nil end
end
local function CreateSpeedMiniToggle()
if speedMiniGui then return end
local screenGui=Instance.new("ScreenGui");screenGui.Name="SpeedMiniToggle";screenGui.ResetOnSpawn=false;screenGui.Parent=game:GetService("CoreGui")
speedMiniGui=screenGui
local button=Instance.new("TextButton",screenGui)
button.Size=UDim2.new(0,80,0,40);button.Position=UDim2.new(0,10,0.5,30);button.Text="SPEED: ON";button.TextScaled=true
button.BackgroundColor3=Color3.fromRGB(30,30,30);button.TextColor3=Color3.fromRGB(255,255,255);button.BorderSizePixel=0
Instance.new("UICorner",button).CornerRadius=UDim.new(0,8)
local gradient=Instance.new("UIGradient",button);gradient.Rotation=45
local function updateButton(state)
button.Text="SPEED: "..(state and"ON"or"OFF")
gradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,state and Color3.fromRGB(50,200,50)or Color3.fromRGB(80,80,80)),
ColorSequenceKeypoint.new(1,state and Color3.fromRGB(50,255,50)or Color3.fromRGB(50,50,50))
}
end
local function onButtonClick()
local newState=not speedSettings.speedActive
if newState then StartSpeedHack()else StopSpeedHack()end
updateButton(newState)
local toggle=Library.Options and Library.Options.SpeedHackToggle
if toggle then toggle:SetValue(newState)end
end
button.MouseButton1Click:Connect(onButtonClick)
speedMiniButton=button
local dragging,dragStart,startPos
button.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=true;dragStart=input.Position;startPos=button.AbsolutePosition
end
end)
speedDragConn=UserInputService.InputChanged:Connect(function(input)
if dragging and(input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement)then
local delta=input.Position-dragStart;local vp=camera.ViewportSize
button.Position=UDim2.new(0,math.clamp(startPos.X+delta.X,0,vp.X-button.AbsoluteSize.X),0,math.clamp(startPos.Y+delta.Y,0,vp.Y-button.AbsoluteSize.Y))
end
end)
speedEndConn=UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=false
end
end)
end
local function DestroySpeedMiniToggle()
if speedDragConn then speedDragConn:Disconnect();speedDragConn=nil end
if speedEndConn then speedEndConn:Disconnect();speedEndConn=nil end
if speedMiniGui then speedMiniGui:Destroy();speedMiniGui=nil;speedMiniButton=nil end
end
local DashGlitch=(function()
local module={}
local enabled=false
local version="V1"
local cooldown=1.5
local dashLength=190
local speedBoost=350
local airWalkSpeed=400
local tapButton=nil
local tapGui=nil
local v1Active=false
local v2Trigger=false
local autoLoop=nil
local args={
"TAP",
Vector3.new(-1221.487548828125,69.36107635498047,-566.5001220703125)
}
local function createTapButton()
if tapGui then return end
local gui=Instance.new("ScreenGui")
gui.Name="DashGlitchTap"
gui.ResetOnSpawn=false
gui.Parent=game:GetService("CoreGui")
tapGui=gui
local btn=Instance.new("TextButton",gui)
btn.Size=UDim2.new(0,50,0,30)
btn.Position=UDim2.new(0.02,0,0.45,0)
btn.BackgroundColor3=Color3.fromRGB(50,100,200)
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Text=(version=="V1")and"DASH: OFF"or"TAP"
btn.Font=Enum.Font.GothamBold
btn.TextSize=9
btn.BorderSizePixel=0
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
local dragging,dragStart,startPos
btn.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
dragging=true;dragStart=i.Position;startPos=btn.AbsolutePosition
end
end)
UserInputService.InputChanged:Connect(function(i)
if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
local delta=i.Position-dragStart
local vp=camera.ViewportSize
btn.Position=UDim2.new(0,math.clamp(startPos.X+delta.X,0,vp.X-btn.AbsoluteSize.X),0,math.clamp(startPos.Y+delta.Y,0,vp.Y-btn.AbsoluteSize.Y))
end
end)
UserInputService.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
dragging=false
end
end)
btn.MouseButton1Click:Connect(function()
if version=="V2"then
v2Trigger=true
elseif version=="V1"then
v1Active=not v1Active
btn.Text="DASH: "..(v1Active and"ON"or"OFF")
btn.BackgroundColor3=v1Active and Color3.fromRGB(0,200,100)or Color3.fromRGB(200,70,30)
end
end)
tapButton=btn
end
local function destroyTapButton()
if tapGui then tapGui:Destroy();tapGui=nil;tapButton=nil end
end
local function doDashCombo()
local char=lp.Character
if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
local hum=char:FindFirstChildOfClass("Humanoid")
local tool=char:FindFirstChildOfClass("Tool")
if not tool or tool.Name~="Skull Guitar"or not hrp or not hum then return end
local remote=tool:FindFirstChild("RemoteEvent")
if not remote then return end
hum.PlatformStand=true
hum:ChangeState(Enum.HumanoidStateType.Physics)
remote:FireServer(unpack(args))
char:SetAttribute("DashLength",dashLength)
char:SetAttribute("DashLengthAir",dashLength)
hrp.AssemblyLinearVelocity=hrp.CFrame.LookVector*speedBoost
task.delay(0.2,function()
if char then
char:SetAttribute("DashLength",1)
char:SetAttribute("DashLengthAir",1)
end
end)
task.wait(0.25)
hum.PlatformStand=false
hum:ChangeState(Enum.HumanoidStateType.GettingUp)
end
local function startAuto()
if autoLoop then return end
autoLoop=task.spawn(function()
while enabled and(version=="V1")do
if v1Active then
local char=lp.Character
local tool=char and char:FindFirstChildOfClass("Tool")
if tool and tool.Name=="Skull Guitar"then
doDashCombo()
end
end
task.wait(cooldown)
end
end)
end
local function stopAuto()
if autoLoop then task.cancel(autoLoop);autoLoop=nil end
local char=lp.Character
if char then
char:SetAttribute("DashLength",1)
char:SetAttribute("DashLengthAir",1)
local hum=char:FindFirstChildOfClass("Humanoid")
if hum then hum.PlatformStand=false;hum.WalkSpeed=16 end
end
end
local function v2Watch()
task.spawn(function()
while enabled and version=="V2"do
if v2Trigger then
v2Trigger=false
doDashCombo()
end
task.wait(0.05)
end
end)
end
function module:SetEnabled(state)
if state==enabled then return end
enabled=state
if state then
if version=="V1"then
v1Active=false
createTapButton()
startAuto()
elseif version=="V2"then
createTapButton()
v2Watch()
end
else
stopAuto()
destroyTapButton()
v2Trigger=false
v1Active=false
end
end
function module:SetVersion(v)
if v==version then return end
local wasEnabled=enabled
if wasEnabled then module:SetEnabled(false)end
version=v
if wasEnabled then module:SetEnabled(true)end
end
function module:SetCooldown(v)cooldown=v end
function module:SetDashLength(v)dashLength=v end
function module:SetSpeedBoost(v)speedBoost=v end
function module:SetAirWalkSpeed(v)airWalkSpeed=v end
RunService.Stepped:Connect(function()
if not enabled or version~="V1"then return end
local char=lp.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
local tool=char and char:FindFirstChildOfClass("Tool")
if hum and tool and tool.Name=="Skull Guitar"then
if hum.FloorMaterial==Enum.Material.Air then
hum.WalkSpeed=airWalkSpeed
else
hum.WalkSpeed=16
hum.PlatformStand=false
end
elseif hum then
hum.WalkSpeed=16
hum.PlatformStand=false
end
end)
return module
end)()
local fontChangerEnabled=false
local fontPreset="GothamSsm"
local updatedFonts={}
local fontConn=nil
local antiMoverEnabled=false
local antiMoverConnection=nil
local unbreakableEnabled=false
local unbreakableConnection=nil
local function enableFonts()
if fontConn then fontConn:Disconnect()end
fontConn=RunService.Heartbeat:Connect(function()
local guiList={lp:FindFirstChild("PlayerGui"),game:GetService("CoreGui")}
for _,gui in pairs(guiList)do
if gui then
for _,obj in pairs(gui:GetDescendants())do
if obj:IsA("TextLabel")or obj:IsA("TextButton")or obj:IsA("TextBox")then
if obj.Font~=Enum.Font[fontPreset]then
obj.Font=Enum.Font[fontPreset]
table.insert(updatedFonts,obj)
end
end
end
end
end
end)
end
local function disableFonts()
if fontConn then fontConn:Disconnect();fontConn=nil end
for _,obj in pairs(updatedFonts)do pcall(function()obj.Font=Enum.Font.SourceSans end)end
updatedFonts={}
end
local function loadCustomFont(fileName)
if fileName=="None"then return end
end
local noGfxMode="Off"
local noGfxConnections={}
local noGfxModifiedObjects={}
local hotbarIconsOriginals={}
local function restoreNoGfx()
for obj,data in pairs(noGfxModifiedObjects)do
pcall(function()
if data.Texture~=nil then obj.Texture=data.Texture end
if data.Enabled~=nil then obj.Enabled=data.Enabled end
end)
end
noGfxModifiedObjects={}
for iconLabel,oldImage in pairs(hotbarIconsOriginals)do
pcall(function()iconLabel.Image=oldImage or""end)
end
hotbarIconsOriginals={}
if noGfxConnections.DescendantAdded then noGfxConnections.DescendantAdded:Disconnect();noGfxConnections.DescendantAdded=nil end
if noGfxConnections.HotbarChildAdded then noGfxConnections.HotbarChildAdded:Disconnect();noGfxConnections.HotbarChildAdded=nil end
end
local function processObject(inst)
local className=inst.ClassName
if className=="Beam"or className=="Trail"then
if not noGfxModifiedObjects[inst]then
noGfxModifiedObjects[inst]={Texture=inst.Texture}
inst.Texture="rbxassetid://84308155859778"
end
elseif className=="ParticleEmitter"then
if not noGfxModifiedObjects[inst]then
noGfxModifiedObjects[inst]={Texture=inst.Texture,Enabled=inst.Enabled}
inst.Texture=""
inst.Enabled=false
end
end
end
local function startNoGfxV1()
restoreNoGfx()
task.spawn(function()
local descendants=workspace:GetDescendants()
for i=1,#descendants do
local inst=descendants[i]
if not inst:IsA("Terrain")and not inst:IsA("Camera")then processObject(inst)end
if i%100==0 then RunService.Heartbeat:Wait()end
end
end)
noGfxConnections.DescendantAdded=workspace.DescendantAdded:Connect(processObject)
end
local function startNoGfxV2()
restoreNoGfx()
task.spawn(function()
local descendants=workspace:GetDescendants()
for i=1,#descendants do
local inst=descendants[i]
if not inst:IsA("Terrain")and not inst:IsA("Camera")then processObject(inst)end
if i%100==0 then RunService.Heartbeat:Wait()end
end
end)
noGfxConnections.DescendantAdded=workspace.DescendantAdded:Connect(processObject)
task.spawn(function()
local PlayerGui=lp:WaitForChild("PlayerGui")
local Backpack=PlayerGui:WaitForChild("Backpack")
local HotbarContainer=Backpack:WaitForChild("Hotbar"):WaitForChild("Container")
local function updateHotbarIconSilent()
for _,slot in ipairs(HotbarContainer:GetChildren())do
local iconLabel=slot:FindFirstChild("Icon")or slot:FindFirstChild("Image")or slot:FindFirstChildOfClass("ImageLabel")
if iconLabel and iconLabel:IsA("ImageLabel")then
if not hotbarIconsOriginals[iconLabel]then hotbarIconsOriginals[iconLabel]=iconLabel.Image end
iconLabel.Image="rbxassetid://84308155859778"
iconLabel.ImageColor3=Color3.fromRGB(255,255,255)
end
end
end
updateHotbarIconSilent()
noGfxConnections.HotbarChildAdded=HotbarContainer.ChildAdded:Connect(function()task.defer(updateHotbarIconSilent)end)
end)
end
local function stopNoGfx()restoreNoGfx()end
local function setNoGfxMode(mode)
if mode==noGfxMode then return end
noGfxMode=mode
stopNoGfx()
if mode=="V1"then startNoGfxV1()elseif mode=="V2"then startNoGfxV2()end
end
local deleteShipActive=false
local deleteShipRunning=false
local function deleteShipStructure()
if not deleteShipActive then return end
task.spawn(function()
local shipNames={"CursedShip","Cursed Ship","Ship"}
local exteriorNames={"Wall","Floor","Ceiling","Base","Hull","Window","DoorFrame"}
for _,obj in pairs(workspace:GetDescendants())do
for _,sName in ipairs(shipNames)do
if obj.Name:find(sName)and(obj:IsA("Model")or obj:IsA("Folder"))then
for _,child in pairs(obj:GetDescendants())do
if child:IsA("BasePart")and not child.Parent:FindFirstChild("Humanoid")then
local isExterior=false
for _,ext in ipairs(exteriorNames)do
if child.Name:find(ext)then
isExterior=true
break
end
end
if not isExterior then
child:Destroy()
end
end
end
end
end
end
end)
end
local function startDeleteShipLoop()
if deleteShipRunning then return end
deleteShipRunning=true
task.spawn(function()
while deleteShipActive do
deleteShipStructure()
task.wait(3)
end
deleteShipRunning=false
end)
end
local WalkOnWaterEnabled=false
local waterPart=nil
task.spawn(function()
local function getWaterPart()
if not waterPart or not waterPart.Parent then
waterPart=Instance.new("Part")
waterPart.Size=Vector3.new(200,1,200)
waterPart.Transparency=1
waterPart.Anchored=true
waterPart.CanCollide=false
waterPart.Name="SacredWaterPlatform"
waterPart.Parent=workspace
end
return waterPart
end
while true do
task.wait(0.15)
if WalkOnWaterEnabled then
local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
local wp=getWaterPart()
if hrp and hrp.Position.Y>=9.5 then
wp.Position=Vector3.new(hrp.Position.X,9.2,hrp.Position.Z)
wp.CanCollide=true
else
wp.CanCollide=false
end
elseif waterPart and waterPart.Parent then
waterPart.CanCollide=false
end
end
end)
local antiLavaActive=false
local antiLavaConnection=nil
local function startAntiLava()
if antiLavaConnection then antiLavaConnection:Disconnect()end
local antiLavaTimer=0
antiLavaConnection=RunService.Stepped:Connect(function(_,dt)
antiLavaTimer=antiLavaTimer+dt
if antiLavaTimer<0.2 then return end
antiLavaTimer=0
local char=lp.Character
if not(char and antiLavaActive)then return end
for _,part in pairs(char:GetDescendants())do
if part:IsA("BasePart")and part.Name~="HumanoidRootPart"
and part.Name~="Torso"and part.Name~="UpperTorso"
and part.Name~="LowerTorso"and part.Name~="Head"then
part.CanTouch=false
end
end
end)
end
local function stopAntiLava()
if antiLavaConnection then
antiLavaConnection:Disconnect()
antiLavaConnection=nil
end
end
local bigSkinBugEnabled=false
local bigSkinBugOriginal={}
local bigSkinBugConnections={}
local function applyBigSkin(char)
local data=bigSkinBugOriginal[char]
if not data then return end
for item,saved in pairs(data.accessories)do
item.Parent=nil
end
for part,saved in pairs(data.parts)do
part.Color=Color3.fromRGB(128,128,128)
part.Material=Enum.Material.SmoothPlastic
part.CanCollide=true
if part:IsA("MeshPart")then part.TextureID=""end
local nameLower=part.Name:lower()
if nameLower:match("torso")then
part.Size=Vector3.new(5.6,4.4,3.4)
elseif nameLower:match("leg")or nameLower:match("arm")then
part.Size=Vector3.new(2.6,4.8,2.6)
elseif nameLower=="head"then
part.Size=Vector3.new(2.2,2.2,2.2)
local mesh=part:FindFirstChildOfClass("SpecialMesh")
if mesh then mesh.Parent=nil end
end
end
for joint,saved in pairs(data.joints)do
local jName=joint.Name:lower()
local c0=saved.C0
if jName:match("rightshoulder")or jName:match("right shoulder")then
joint.C0=c0*CFrame.new(2.4,0.6,0)
elseif jName:match("leftshoulder")or jName:match("left shoulder")then
joint.C0=c0*CFrame.new(-2.4,0.6,0)
elseif jName:match("righthip")or jName:match("right hip")then
joint.C0=c0*CFrame.new(0.9,-0.6,0)
elseif jName:match("lefthip")or jName:match("left hip")then
joint.C0=c0*CFrame.new(-0.9,-0.6,0)
elseif jName:match("neck")then
joint.C0=c0*CFrame.new(0,0.8,0)
end
end
end
local function saveBigSkinOriginal(char)
local data={parts={},accessories={},joints={}}
for _,item in pairs(char:GetDescendants())do
if item:IsA("Accessory")or item:IsA("Clothing")or item:IsA("ShirtGraphic")or item:IsA("Decal")then
data.accessories[item]={Parent=item.Parent}
elseif item:IsA("BasePart")and item.Name~="HumanoidRootPart"then
local saved={Size=item.Size,Color=item.Color,Material=item.Material,TextureID=item:IsA("MeshPart")and item.TextureID or nil}
if item.Name=="Head"then
local mesh=item:FindFirstChildOfClass("SpecialMesh")
if mesh then saved.MeshParent=mesh.Parent end
end
data.parts[item]=saved
elseif item:IsA("Motor6D")and item.Part0 and item.Part1 then
data.joints[item]={C0=item.C0,C1=item.C1}
end
end
bigSkinBugOriginal[char]=data
end
local function restoreBigSkin(char)
local data=bigSkinBugOriginal[char]
if not data then return end
for item,saved in pairs(data.accessories)do
if saved.Parent then item.Parent=saved.Parent end
end
for part,saved in pairs(data.parts)do
part.Size=saved.Size
part.Color=saved.Color
part.Material=saved.Material
if saved.TextureID and part:IsA("MeshPart")then part.TextureID=saved.TextureID end
if saved.MeshParent and part.Name=="Head"then
local mesh=part:FindFirstChildOfClass("SpecialMesh")
if not mesh and saved.MeshParent~=part then
local oldMesh=saved.MeshParent:FindFirstChildOfClass("SpecialMesh")
if oldMesh then oldMesh.Parent=part end
end
end
end
for joint,saved in pairs(data.joints)do
joint.C0=saved.C0
joint.C1=saved.C1
end
bigSkinBugOriginal[char]=nil
end
local function onCharAddedBigSkin(char)
if not bigSkinBugEnabled then return end
task.wait(0.4)
saveBigSkinOriginal(char)
applyBigSkin(char)
end
local function enableBigSkin()
if bigSkinBugEnabled then return end
bigSkinBugEnabled=true
if lp.Character then
saveBigSkinOriginal(lp.Character)
applyBigSkin(lp.Character)
end
bigSkinBugConnections.CharAdded=lp.CharacterAdded:Connect(onCharAddedBigSkin)
end
local function disableBigSkin()
bigSkinBugEnabled=false
if bigSkinBugConnections.CharAdded then
bigSkinBugConnections.CharAdded:Disconnect()
bigSkinBugConnections.CharAdded=nil
end
if lp.Character then
restoreBigSkin(lp.Character)
end
end
local ESPModule=(function()
local module={}
local ESPEnabled=false
local ShowBox,ShowName,ShowDistance,ShowHealth,ShowLine=true,true,true,true,true
local BoxColor,TextColor,LineColor="Red","White","Red"
local ShowAllPlayers=false
local LineOrigin="Player"
local drawings={}
local function clearDrawings()for _,d in pairs(drawings)do pcall(function()d:Remove()end)end drawings={}end
local function getColor(name)
local colors={Red=Color3.new(1,0,0),Green=Color3.new(0,1,0),Blue=Color3.new(0,0,1),Yellow=Color3.new(1,1,0),White=Color3.new(1,1,1),Black=Color3.new(0,0,0),Cyan=Color3.new(0,1,1),Magenta=Color3.new(1,0,1)}
return colors[name]or Color3.new(1,1,1)
end
local function isEnemy(plr)
if plr==lp then return false end
if ShowAllPlayers then return true end
local myTeam=lp.Team;local targetTeam=plr.Team
if myTeam and targetTeam then
if myTeam.Name=="Pirates"and targetTeam.Name=="Marines"then return true
elseif myTeam.Name=="Marines"and targetTeam.Name=="Pirates"then return true end
if myTeam.Name=="Pirates"and targetTeam.Name=="Pirates"then return true end
if myTeam.Name=="Marines"and targetTeam.Name=="Marines"then return false end
end
return true
end
local function updateESP()
clearDrawings()
if not ESPEnabled then return end
local myHrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
local vp=camera.ViewportSize
for _,plr in pairs(Players:GetPlayers())do
if plr==lp or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart")then continue end
if not isEnemy(plr)then continue end
local hrp=plr.Character.HumanoidRootPart
local hum=plr.Character:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health<=0 then continue end
local pos,onScreen=camera:WorldToViewportPoint(hrp.Position)
local screenPos=Vector2.new(pos.X,pos.Y)
local isVisible=onScreen
local lineEnd=screenPos
if pos.Z<0 then
local center=Vector2.new(vp.X/2,vp.Y/2)
local dirToTarget=(center-screenPos).Unit
local maxX,maxY=(vp.X/2)-5,(vp.Y/2)-5
local t=1
if math.abs(dirToTarget.X)>0.001 and math.abs(dirToTarget.Y)>0.001 then t=math.min(math.abs(maxX/dirToTarget.X),math.abs(maxY/dirToTarget.Y))
elseif math.abs(dirToTarget.X)>0.001 then t=math.abs(maxX/dirToTarget.X)
elseif math.abs(dirToTarget.Y)>0.001 then t=math.abs(maxY/dirToTarget.Y)end
lineEnd=center+dirToTarget*t
end
local boxCol=getColor(BoxColor)
local txtCol=getColor(TextColor)
local lineCol=getColor(LineColor)
if ShowBox and isVisible then
local size=Vector2.new(2000/(camera.CFrame.Position-hrp.Position).Magnitude,4000/(camera.CFrame.Position-hrp.Position).Magnitude)
local topLeft=Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
local topRight=Vector2.new(pos.X+size.X/2,pos.Y-size.Y/2)
local bottomLeft=Vector2.new(pos.X-size.X/2,pos.Y+size.Y/2)
local bottomRight=Vector2.new(pos.X+size.X/2,pos.Y+size.Y/2)
local function addLine(p1,p2)local l=Drawing.new("Line");l.Visible=true;l.Color=boxCol;l.Thickness=1;l.From=p1;l.To=p2;table.insert(drawings,l)end
addLine(topLeft,topRight);addLine(topRight,bottomRight);addLine(bottomRight,bottomLeft);addLine(bottomLeft,topLeft)
end
if ShowName and isVisible then
local size=Vector2.new(2000/(camera.CFrame.Position-hrp.Position).Magnitude,4000/(camera.CFrame.Position-hrp.Position).Magnitude)
local t=Drawing.new("Text");t.Visible=true;t.Text=plr.Name;t.Color=txtCol;t.Size=13;t.Center=true;t.Position=Vector2.new(pos.X,pos.Y-size.Y/2-15);t.Font=2;table.insert(drawings,t)
end
if ShowDistance and isVisible then
local dist=math.floor((hrp.Position-(myHrp and myHrp.Position or Vector3.zero)).Magnitude)
local t=Drawing.new("Text");t.Visible=true;t.Text=dist.."m";t.Color=txtCol;t.Size=13;t.Center=true;t.Position=Vector2.new(pos.X,pos.Y+size.Y/2+2);t.Font=2;table.insert(drawings,t)
end
if ShowHealth and isVisible then
local size=Vector2.new(2000/(camera.CFrame.Position-hrp.Position).Magnitude,4000/(camera.CFrame.Position-hrp.Position).Magnitude)
local hpRatio=math.clamp(hum.Health/hum.MaxHealth,0,1)
local barW,barH=size.X,4
local barPos=Vector2.new(pos.X-barW/2,pos.Y+size.Y/2+12)
local bg=Drawing.new("Square");bg.Visible=true;bg.Color=Color3.new(0,0,0);bg.Filled=true;bg.Size=Vector2.new(barW,barH);bg.Position=barPos;table.insert(drawings,bg)
local fg=Drawing.new("Square");fg.Visible=true;fg.Color=Color3.new(1-hpRatio,hpRatio,0);fg.Filled=true;fg.Size=Vector2.new(barW*hpRatio,barH);fg.Position=barPos;table.insert(drawings,fg)
end
if ShowLine then
local lineStart=nil
if LineOrigin=="Player"then
if myHrp then
local myPos,onScr=camera:WorldToViewportPoint(myHrp.Position)
if onScr then lineStart=Vector2.new(myPos.X,myPos.Y)else lineStart=Vector2.new(vp.X/2,vp.Y/2)end
else lineStart=Vector2.new(vp.X/2,vp.Y/2)end
elseif LineOrigin=="Center"then lineStart=Vector2.new(vp.X/2,vp.Y/2)
elseif LineOrigin=="Top"then lineStart=Vector2.new(vp.X/2,0)end
if lineStart then
local l=Drawing.new("Line");l.Visible=true;l.Color=lineCol;l.Thickness=1;l.From=lineStart;l.To=lineEnd;table.insert(drawings,l)
end
