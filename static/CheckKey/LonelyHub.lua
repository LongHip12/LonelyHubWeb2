local LonelyHubLib = {}

  LonelyHubLib.BaseURL = "https://lonelyhubgetkey.onrender.com"
  LonelyHubLib.ServiceId = "24hours"
  LonelyHubLib.Version = "1.0.0"

  local HttpService = game:GetService("HttpService")
  local Players = game:GetService("Players")
  local LocalPlayer = Players.LocalPlayer

  local httpRequest = (syn and syn.request)
      or (http and http.request)
      or http_request
      or (fluxus and fluxus.request)
      or request

  function LonelyHubLib.getHWID()
      local id
      pcall(function()
          if gethwid then
              id = gethwid()
          end
      end)
      if not id or id == "" then
          pcall(function()
              id = game:GetService("RbxAnalyticsService"):GetClientId()
          end)
      end
      if not id or id == "" then
          id = tostring(LocalPlayer.UserId) .. "_" .. tostring(game.JobId or "lonely")
      end
      return tostring(id)
  end

  function LonelyHubLib._getBaseUrl()
      return LonelyHubLib.BaseURL
  end

  function LonelyHubLib.getKeyURL(serviceId)
      return LonelyHubLib.BaseURL .. "/getkey"
  end

  function LonelyHubLib.resetHwidURL(key)
      return LonelyHubLib.BaseURL .. "/resethwid?key=" .. tostring(key or "")
  end

  function LonelyHubLib.kickHwidMismatch(boundPreview)
      pcall(function()
          if LocalPlayer then
              local msg = "[Lonely Hub] Hwid not mismatch"
              if boundPreview and boundPreview ~= "" then
                  msg = msg .. " | Bound: " .. tostring(boundPreview)
              end
              msg = msg .. "\nReset at: " .. LonelyHubLib.BaseURL .. "/resethwid"
              LocalPlayer:Kick(msg)
          end
      end)
  end

  function LonelyHubLib.validate(key)
      if not key or key == "" then
          return { success = false, status = "missing_key" }
      end
      if not httpRequest then
          return { success = false, status = "no_http" }
      end
      local hwid = LonelyHubLib.getHWID()
      local payload = { key = key, hwid = hwid }
      pcall(function()
          if LocalPlayer then
              payload.userId = tostring(LocalPlayer.UserId or 0)
              payload.username = tostring(LocalPlayer.Name or "")
              payload.displayName = tostring(LocalPlayer.DisplayName or LocalPlayer.Name or "")
          end
      end)
      local body = HttpService:JSONEncode(payload)
      local ok, res = pcall(function()
          return httpRequest({
              Url = LonelyHubLib.BaseURL .. "/api/v1/auth/key/validate",
              Method = "POST",
              Headers = {
                  ["Content-Type"] = "application/json",
                  ["X-HWID"] = hwid,
                  ["User-Agent"] = "LonelyHub-Loader/" .. LonelyHubLib.Version,
              },
              Body = body,
          })
      end)
      if not ok or not res or not res.Body then
          return { success = false, status = "request_failed" }
      end
      local decoded
      pcall(function()
          decoded = HttpService:JSONDecode(res.Body)
      end)
      if not decoded then
          return { success = false, status = "bad_response" }
      end
      return decoded
  end

  _G.LonelyHubLib = LonelyHubLib
  getgenv().LonelyHubLib = LonelyHubLib
  getgenv()._getBaseUrl = LonelyHubLib._getBaseUrl
  getgenv().getHWID = LonelyHubLib.getHWID

  if not getgenv().CONFIG_SERVICE_ID then
      getgenv().CONFIG_SERVICE_ID = "24hours"
  end
  local CONFIG_SERVICE_ID = getgenv().CONFIG_SERVICE_ID
  LonelyHubLib.ServiceId = CONFIG_SERVICE_ID

  function LoadScript()
      print("Loaded!")
  end

  function GetKeyURL()
      return LonelyHubLib._getBaseUrl() .. "/getkey"
  end

  
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")
local request = syn and syn.request or request or http_request

local KeyFilePath = "Lonely Hub/keys.txt"

function SaveKeyToFile(key)
    if writefile then
        pcall(function()
            writefile(KeyFilePath, key)
        end)
    end
end

function LoadKeyFromFile()
    if readfile then
        local success, data = pcall(function()
            return readfile(KeyFilePath)
        end)
        if success and data ~= "" then
            return data
        end
    end
    return nil
end

function DeleteKeyFile()
    if writefile then
        pcall(function()
            writefile(KeyFilePath, "")
        end)
    end
end


local LonelyHub = Instance.new("ScreenGui")
LonelyHub.Name = "LonelyHub_KEY"
LonelyHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LonelyHub.ResetOnSpawn = false
LonelyHub.IgnoreGuiInset = true
LonelyHub.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local INTRO = Instance.new("CanvasGroup")
local Wallpaper = Instance.new("ImageLabel")
local TextHolder = Instance.new("Frame")
local Status = Instance.new("TextLabel")
local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
local Gradient = Instance.new("Frame")
local UIGradient = Instance.new("UIGradient")
local Pattern = Instance.new("ImageLabel")
local Logo = Instance.new("ImageLabel")
local Main = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local Loader = Instance.new("Frame")
local Content = Instance.new("Frame")
local UIStroke = Instance.new("UIStroke")
local ImageLabel = Instance.new("ImageLabel")
local UIAspectRatioConstraint_1 = Instance.new("UIAspectRatioConstraint")
local UICorner = Instance.new("UICorner")

INTRO.BorderSizePixel = 0
INTRO.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
INTRO.AnchorPoint = Vector2.new(0.5, 0.5)
INTRO.Size = UDim2.new(0.455271, 0, 0.46186, 0)
INTRO.ZIndex = 990
INTRO.Name = "INTRO"
INTRO.Position = UDim2.new(0.5, 0, 0.5, 0)
INTRO.BorderColor3 = Color3.fromRGB(0, 0, 0)
INTRO.Parent = LonelyHub

Wallpaper.BorderSizePixel = 0
Wallpaper.ScaleType = Enum.ScaleType.Fit
Wallpaper.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Wallpaper.Position = UDim2.new(-0.0361702, 0, -0.158876, 0)
Wallpaper.Name = "Wallpaper"
Wallpaper.Image = "rbxassetid://129512322120437"
Wallpaper.Size = UDim2.new(1.11064, 0, 1.59989, 0)
Wallpaper.BorderColor3 = Color3.fromRGB(0, 0, 0)
Wallpaper.Parent = INTRO

TextHolder.BorderSizePixel = 0
TextHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TextHolder.Size = UDim2.new(1, 0, 0.284847, 0)
TextHolder.BorderColor3 = Color3.fromRGB(30, 30, 30)
TextHolder.Name = "TextHolder"
TextHolder.Position = UDim2.new(0, 0, 0.753631, 0)
TextHolder.Parent = INTRO

Status.TextWrapped = true
Status.BorderSizePixel = 0
Status.TextScaled = true
Status.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Status.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Italic)
Status.Position = UDim2.new(0.120042, 0, 0.254529, 0)
Status.Name = "Status"
Status.TextSize = 20
Status.Size = UDim2.new(0.79993, 0, 0.464041, 0)
Status.ZIndex = 2
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.BorderColor3 = Color3.fromRGB(0, 0, 0)
Status.Text = "Preparing your HUB for an amazing experience."
Status.BackgroundTransparency = 1
Status.Parent = TextHolder
Status:SetAttribute("EngText",Status.Text)

UITextSizeConstraint.MaxTextSize = 20
UITextSizeConstraint.Parent = Status

Gradient.BorderSizePixel = 0
Gradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Gradient.Size = UDim2.new(1, 0, 1, 0)
Gradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
Gradient.Name = "Gradient"
Gradient.Position = UDim2.new(0, 0, 2.11993e-08, 0)
Gradient.Parent = TextHolder

UIGradient.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0.9) }
UIGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(157, 2, 31)), ColorSequenceKeypoint.new(0.466321, Color3.fromRGB(139.758, 6.07549, 31.0759)), ColorSequenceKeypoint.new(0.797927, Color3.fromRGB(46.7098, 28.0691, 31.4853)), ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30)) }
UIGradient.Rotation = -90
UIGradient.Parent = Gradient

Pattern.SliceCenter = Rect.new(0, 256, 0, 256)
Pattern.ScaleType = Enum.ScaleType.Tile
Pattern.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Pattern.ImageTransparency = 0.6
Pattern.Position = UDim2.new(6.64996e-05, 0, 0.00124399, 0)
Pattern.Name = "Pattern"
Pattern.Image = "rbxassetid://2151741365"
Pattern.TileSize = UDim2.new(0, 250, 0, 250)
Pattern.Size = UDim2.new(1, 0, 1, 0)
Pattern.ZIndex = 0
Pattern.BackgroundTransparency = 1
Pattern.Parent = Gradient

Logo.ImageColor3 = Color3.fromRGB(0, 0, 0)
Logo.BorderSizePixel = 0
Logo.ScaleType = Enum.ScaleType.Fit
Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Logo.ImageTransparency = 0.5
Logo.Position = UDim2.new(0.271609, 0, 0.122057, 0)
Logo.Name = "Logo"
Logo.Image = ""
Logo.Size = UDim2.new(0.453191, 0, 0.550704, 0)
Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
Logo.ZIndex = 2
Logo.BackgroundTransparency = 1
Logo.Parent = INTRO

Main.BorderSizePixel = 0
Main.ScaleType = Enum.ScaleType.Fit
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Image = ""
Main.Size = UDim2.new(0.95, 0, 0.95, 0)
Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
Main.BackgroundTransparency = 1
Main.Parent = Logo

UIAspectRatioConstraint.AspectRatio = 2.08357
UIAspectRatioConstraint.Parent = INTRO

Loader.BorderSizePixel = 0
Loader.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
Loader.Size = UDim2.new(0.999948, 0, 0.0285966, 0)
Loader.BorderColor3 = Color3.fromRGB(0, 0, 0)
Loader.Name = "Loader"
Loader.Position = UDim2.new(0, 0, 0.751682, 0)
Loader.ZIndex = 2
Loader.Parent = INTRO

Content.BorderSizePixel = 0
Content.BackgroundColor3 = Color3.fromRGB(255, 51, 51)
Content.Size = UDim2.new(0, 0, 1, 0)
Content.BorderColor3 = Color3.fromRGB(0, 0, 0)
Content.Name = "Content"
Content.Parent = Loader

UIStroke.Transparency = 0.5
UIStroke.Parent = Content

ImageLabel.ImageColor3 = Color3.fromRGB(255, 46, 46)
ImageLabel.BorderSizePixel = 0
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.Position = UDim2.new(1, 0, .5, 0)
ImageLabel.AnchorPoint = Vector2.new(.5,.5)
ImageLabel.Image = "rbxassetid://16073652319"
ImageLabel.Size = UDim2.new(0.671884, 0, 15.1201, 0)
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Parent = Content

UIAspectRatioConstraint_1.AspectRatio = 1.49814
UIAspectRatioConstraint_1.Parent = ImageLabel

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = INTRO


local GET_KEY19 = Instance.new("CanvasGroup")
GET_KEY19.Name = "GET_KEY"
GET_KEY19.Size = UDim2.new(0.359117,0,0.665296,0)
GET_KEY19.Position = UDim2.new(0.500000,0,0.500000,0)
GET_KEY19.AnchorPoint = Vector2.new(0.500000,0.500000)
GET_KEY19.BackgroundColor3 = Color3.fromRGB(30,30,30)
GET_KEY19.BackgroundTransparency = 0.000000
GET_KEY19.BorderSizePixel = 0.000000
GET_KEY19.Visible = false
GET_KEY19.AutomaticSize = Enum.AutomaticSize.None
GET_KEY19.ClipsDescendants = true
GET_KEY19.LayoutOrder = 0.000000
GET_KEY19.GroupTransparency = 0.000000
GET_KEY19.GroupColor3 = Color3.fromRGB(255,255,255)
GET_KEY19.Parent = LonelyHub

local UICorner20 = Instance.new("UICorner")
UICorner20.CornerRadius = UDim.new(0.075000,0)
UICorner20.Parent = GET_KEY19

local url = "https://raw.githubusercontent.com/LongHip12/LonelyHub/refs/heads/main/1775396168046-019d5dda-a645-745b-84a8-830794cde06a-removebg-preview.png"

if not request then warn("[wl bye longhip] exec not support request") return end

local res = request({ Url = url, Method = "GET" })

if not res or not res.Body then warn("[wl bye longhip] download failed") return end

if not writefile then warn("[wl bye longhip] exec not support writefile") return end

writefile("Lonely Hub/logo.png", res.Body)

local asset
if getsynasset then
    asset = getsynasset("Lonely Hub/logo.png")
elseif getcustomasset then
    asset = getcustomasset("Lonely Hub/logo.png")
else
    warn("[wl bye longhip] exec not suppoet getcustomasset / getsynasset") return
end

local Logo21 = Instance.new("ImageLabel")
Logo21.Name = "Logo"
Logo21.Size = UDim2.new(0.5,0,0.5,0)
Logo21.Position = UDim2.new(0.279999822, 0, -0.100000024, 0)
Logo21.AnchorPoint = Vector2.new(0.000000,0.000000)
Logo21.BackgroundColor3 = Color3.fromRGB(255,255,255)
Logo21.BackgroundTransparency = 1.000000
Logo21.BorderSizePixel = 0.000000
Logo21.Image = asset
Logo21.ImageColor3 = Color3.fromRGB(255,255,255)
Logo21.ImageTransparency = 0.000000
Logo21.ScaleType = Enum.ScaleType.Fit
Logo21.SliceCenter = Rect.new(0,0,0,0)
Logo21.Visible = true
Logo21.ZIndex = 2.000000
Logo21.Parent = GET_KEY19

local UIAspectRatioConstraint22 = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint22.AspectRatio = 1.140960
UIAspectRatioConstraint22.DominantAxis = Enum.DominantAxis.Width
UIAspectRatioConstraint22.Parent = GET_KEY19

local Get23 = Instance.new("TextButton")
Get23.Name = "Get"
Get23.Size = UDim2.new(0.510000,0,0.095000,0)
Get23.Position = UDim2.new(0.336000,0,0.453770,0)
Get23.AnchorPoint = Vector2.new(0.500000,0.500000)
Get23.BackgroundColor3 = Color3.fromRGB(200,50,50)
Get23.BackgroundTransparency = 0.000000
Get23.BorderSizePixel = 0.000000
Get23.Text = ""
Get23.TextColor3 = Color3.fromRGB(255,255,255)
Get23.TextSize = 20.000000
Get23.ZIndex = 2.000000
Get23.Font = Enum.Font.SourceSansBold
Get23.TextScaled = true
Get23.TextWrapped = true
Get23.RichText = false
Get23.Visible = true
Get23.AutoButtonColor = false
Get23.Parent = GET_KEY19

local Hover24 = Instance.new("ImageLabel")
Hover24.Name = "Hover"
Hover24.Size = UDim2.new(1.055000,0,1.450000,0)
Hover24.Position = UDim2.new(0.500000,0,0.500000,0)
Hover24.AnchorPoint = Vector2.new(0.500000,0.500000)
Hover24.BackgroundColor3 = Color3.fromRGB(255,255,255)
Hover24.BackgroundTransparency = 1.000000
Hover24.BorderSizePixel = 0.000000
Hover24.Image = "rbxassetid://16261022724"
Hover24.ImageColor3 = Color3.fromRGB(250,80,80)
Hover24.ImageTransparency = 1.000000
Hover24.ScaleType = Enum.ScaleType.Slice
Hover24.SliceCenter = Rect.new(205,197,828,828)
Hover24.Visible = true
Hover24.ZIndex = 1.000000
Hover24.Parent = Get23

local UICorner25 = Instance.new("UICorner")
UICorner25.CornerRadius = UDim.new(0.000000,7)
UICorner25.Parent = Get23

local UIStroke26 = Instance.new("UIStroke")
UIStroke26.Color = Color3.fromRGB(250,80,80)
UIStroke26.Thickness = 1.000000
UIStroke26.Transparency = 0.500000
UIStroke26.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke26.Parent = Get23

local Title27 = Instance.new("TextLabel")
Title27.Name = "Title"
Title27.Size = UDim2.new(1.000000,0,0.546077,0)
Title27.Position = UDim2.new(0.500000,0,0.500000,0)
Title27.AnchorPoint = Vector2.new(0.500000,0.500000)
Title27.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title27.BackgroundTransparency = 1.000000
Title27.BorderSizePixel = 0.000000
Title27.Visible = true
Title27.AutomaticSize = Enum.AutomaticSize.None
Title27.ClipsDescendants = false
Title27.LayoutOrder = 0.000000
Title27.Active = false
Title27.Selectable = false
Title27.SizeConstraint = Enum.SizeConstraint.RelativeXY
Title27.ZIndex = 1.000000
Title27.Rotation = 0.000000
Title27.Transparency = 1.000000
Title27.Text = "GET KEY"
Title27.TextColor3 = Color3.fromRGB(255,255,255)
Title27.TextSize = 8.000000
Title27.Font = Enum.Font.SourceSansBold
Title27.TextScaled = true
Title27.TextWrapped = true
Title27.RichText = false
Title27.LineHeight = 1.000000
Title27.MaxVisibleGraphemes = -1.000000
Title27.TextTransparency = 0.000000
Title27.TextStrokeColor3 = Color3.fromRGB(0,0,0)
Title27.TextStrokeTransparency = 1.000000
Title27.TextTruncate = Enum.TextTruncate.None
Title27.ZIndex = 1.000000
Title27.TextXAlignment = Enum.TextXAlignment.Center
Title27.TextYAlignment = Enum.TextYAlignment.Center
Title27.Parent = Get23

local Submit28 = Instance.new("TextButton")
Submit28.Name = "Submit"
Submit28.Size = UDim2.new(0.838618,0,0.095000,0)
Submit28.Position = UDim2.new(0.500630,0,0.578448,0)
Submit28.AnchorPoint = Vector2.new(0.500000,0.500000)
Submit28.BackgroundColor3 = Color3.fromRGB(200,50,50)
Submit28.BackgroundTransparency = 0.000000
Submit28.BorderSizePixel = 0.000000
Submit28.Text = ""
Submit28.TextColor3 = Color3.fromRGB(255,255,255)
Submit28.TextSize = 20.000000
Submit28.ZIndex = 2.000000
Submit28.Font = Enum.Font.SourceSansBold
Submit28.TextScaled = true
Submit28.TextWrapped = true
Submit28.RichText = false
Submit28.Visible = true
Submit28.AutoButtonColor = false
Submit28.Parent = GET_KEY19

local Hover29 = Instance.new("ImageLabel")
Hover29.Name = "Hover"
Hover29.Size = UDim2.new(1.055000,0,1.450000,0)
Hover29.Position = UDim2.new(0.500000,0,0.500000,0)
Hover29.AnchorPoint = Vector2.new(0.500000,0.500000)
Hover29.BackgroundColor3 = Color3.fromRGB(255,255,255)
Hover29.BackgroundTransparency = 1.000000
Hover29.BorderSizePixel = 0.000000
Hover29.Image = "rbxassetid://16261022724"
Hover29.ImageColor3 = Color3.fromRGB(250,80,80)
Hover29.ImageTransparency = 1.000000
Hover29.ScaleType = Enum.ScaleType.Slice
Hover29.SliceCenter = Rect.new(205,197,828,828)
Hover29.Visible = true
Hover29.ZIndex = 1.000000
Hover29.Parent = Submit28

local UICorner30 = Instance.new("UICorner")
UICorner30.CornerRadius = UDim.new(0.000000,7)
UICorner30.Parent = Submit28

local UIStroke31 = Instance.new("UIStroke")
UIStroke31.Color = Color3.fromRGB(250,80,80)
UIStroke31.Thickness = 1.000000
UIStroke31.Transparency = 0.500000
UIStroke31.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke31.Parent = Submit28

local Title32 = Instance.new("TextLabel")
Title32.Name = "Title"
Title32.Size = UDim2.new(1.000000,0,0.546000,0)
Title32.Position = UDim2.new(0.500000,0,0.480000,0)
Title32.AnchorPoint = Vector2.new(0.500000,0.500000)
Title32.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title32.BackgroundTransparency = 1.000000
Title32.BorderSizePixel = 0.000000
Title32.Visible = true
Title32.AutomaticSize = Enum.AutomaticSize.None
Title32.ClipsDescendants = false
Title32.LayoutOrder = 0.000000
Title32.Active = false
Title32.Selectable = false
Title32.SizeConstraint = Enum.SizeConstraint.RelativeXY
Title32.ZIndex = 1.000000
Title32.Rotation = 0.000000
Title32.Transparency = 1.000000
Title32.Text = "SUBMIT KEY"
Title32.TextColor3 = Color3.fromRGB(255,255,255)
Title32.TextSize = 8.000000
Title32.Font = Enum.Font.SourceSansBold
Title32.TextScaled = true
Title32.TextWrapped = true
Title32.RichText = false
Title32.LineHeight = 1.000000
Title32.MaxVisibleGraphemes = -1.000000
Title32.TextTransparency = 0.000000
Title32.TextStrokeColor3 = Color3.fromRGB(0,0,0)
Title32.TextStrokeTransparency = 1.000000
Title32.TextTruncate = Enum.TextTruncate.None
Title32.ZIndex = 1.000000
Title32.TextXAlignment = Enum.TextXAlignment.Center
Title32.TextYAlignment = Enum.TextYAlignment.Center
Title32.Parent = Submit28

local Get233 = Instance.new("TextButton")
Get233.Name = "Get2"
Get233.Size = UDim2.new(0.312000,0,0.095000,0)
Get233.Position = UDim2.new(0.764000,0,0.453770,0)
Get233.AnchorPoint = Vector2.new(0.500000,0.500000)
Get233.BackgroundColor3 = Color3.fromRGB(200,50,50)
Get233.BackgroundTransparency = 0.000000
Get233.BorderSizePixel = 0.000000
Get233.Text = ""
Get233.TextColor3 = Color3.fromRGB(255,255,255)
Get233.TextSize = 20.000000
Get233.ZIndex = 2.000000
Get233.Font = Enum.Font.SourceSansBold
Get233.TextScaled = true
Get233.TextWrapped = true
Get233.RichText = false
Get233.Visible = true
Get233.AutoButtonColor = false
Get233.Parent = GET_KEY19

local Hover34 = Instance.new("ImageLabel")
Hover34.Name = "Hover"
Hover34.Size = UDim2.new(1.055000,0,1.450000,0)
Hover34.Position = UDim2.new(0.500000,0,0.500000,0)
Hover34.AnchorPoint = Vector2.new(0.500000,0.500000)
Hover34.BackgroundColor3 = Color3.fromRGB(255,255,255)
Hover34.BackgroundTransparency = 1.000000
Hover34.BorderSizePixel = 0.000000
Hover34.Image = "rbxassetid://16261022724"
Hover34.ImageColor3 = Color3.fromRGB(250,80,80)
Hover34.ImageTransparency = 1.000000
Hover34.ScaleType = Enum.ScaleType.Slice
Hover34.SliceCenter = Rect.new(205,197,828,828)
Hover34.Visible = true
Hover34.ZIndex = 1.000000
Hover34.Parent = Get233

local UICorner35 = Instance.new("UICorner")
UICorner35.CornerRadius = UDim.new(0.000000,7)
UICorner35.Parent = Get233

local UIStroke36 = Instance.new("UIStroke")
UIStroke36.Color = Color3.fromRGB(250,80,80)
UIStroke36.Thickness = 1.000000
UIStroke36.Transparency = 0.500000
UIStroke36.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke36.Parent = Get233

local Title37 = Instance.new("TextLabel")
Title37.Name = "Title"
Title37.Size = UDim2.new(1.000000,0,0.546077,0)
Title37.Position = UDim2.new(0.500000,0,0.500000,0)
Title37.AnchorPoint = Vector2.new(0.500000,0.500000)
Title37.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title37.BackgroundTransparency = 1.000000
Title37.BorderSizePixel = 0.000000
Title37.Visible = true
Title37.AutomaticSize = Enum.AutomaticSize.None
Title37.ClipsDescendants = false
Title37.LayoutOrder = 0.000000
Title37.Active = false
Title37.Selectable = false
Title37.SizeConstraint = Enum.SizeConstraint.RelativeXY
Title37.ZIndex = 1.000000
Title37.Rotation = 0.000000
Title37.Transparency = 1.000000
Title37.Text = "Discord"
Title37.TextColor3 = Color3.fromRGB(255,255,255)
Title37.TextSize = 8.000000
Title37.Font = Enum.Font.SourceSansBold
Title37.TextScaled = true
Title37.TextWrapped = true
Title37.RichText = false
Title37.LineHeight = 1.000000
Title37.MaxVisibleGraphemes = -1.000000
Title37.TextTransparency = 0.000000
Title37.TextStrokeColor3 = Color3.fromRGB(0,0,0)
Title37.TextStrokeTransparency = 1.000000
Title37.TextTruncate = Enum.TextTruncate.None
Title37.ZIndex = 1.000000
Title37.TextXAlignment = Enum.TextXAlignment.Center
Title37.TextYAlignment = Enum.TextYAlignment.Center
Title37.Parent = Get233

local Pfp38 = Instance.new("ImageLabel")
Pfp38.Name = "Pfp"
Pfp38.Size = UDim2.new(0.229672,0,0.261163,0)
Pfp38.Position = UDim2.new(0.081014,0,0.652851,0)
Pfp38.AnchorPoint = Vector2.new(0.000000,0.000000)
Pfp38.BackgroundColor3 = Color3.fromRGB(255,255,255)
Pfp38.BackgroundTransparency = 1.000000
Pfp38.BorderSizePixel = 0.000000
Pfp38.Image = "rbxassetid://112485471724320"
Pfp38.ImageColor3 = Color3.fromRGB(255,255,255)
Pfp38.ImageTransparency = 0.000000
Pfp38.ScaleType = Enum.ScaleType.Fit
Pfp38.SliceCenter = Rect.new(0,0,0,0)
Pfp38.Visible = true
Pfp38.ZIndex = 2.000000
Pfp38.Parent = GET_KEY19

local UICorner39 = Instance.new("UICorner")
UICorner39.CornerRadius = UDim.new(0.075000,0)
UICorner39.Parent = Pfp38

local Support40 = Instance.new("TextButton")
Support40.Name = "Support"
Support40.Size = UDim2.new(0.581950,0,0.081186,0)
Support40.Position = UDim2.new(0.626422,0,0.765503,0)
Support40.AnchorPoint = Vector2.new(0.500000,0.500000)
Support40.BackgroundColor3 = Color3.fromRGB(250,80,80)
Support40.BackgroundTransparency = 1.000000
Support40.BorderSizePixel = 0.000000
Support40.Text = ""
Support40.TextColor3 = Color3.fromRGB(255,255,255)
Support40.TextSize = 20.000000
Support40.ZIndex = 2.000000
Support40.Font = Enum.Font.SourceSansBold
Support40.TextScaled = true
Support40.TextWrapped = true
Support40.RichText = false
Support40.Visible = true
Support40.AutoButtonColor = false
Support40.Parent = GET_KEY19

local UICorner41 = Instance.new("UICorner")
UICorner41.CornerRadius = UDim.new(0.000000,7)
UICorner41.Parent = Support40

local UIStroke42 = Instance.new("UIStroke")
UIStroke42.Color = Color3.fromRGB(250,80,80)
UIStroke42.Thickness = 1.250000
UIStroke42.Transparency = 0.250000
UIStroke42.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke42.Parent = Support40

local Title43 = Instance.new("TextLabel")
Title43.Name = "Title"
Title43.Size = UDim2.new(1.000000,0,0.600000,0)
Title43.Position = UDim2.new(0.500000,0,0.500000,0)
Title43.AnchorPoint = Vector2.new(0.500000,0.500000)
Title43.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title43.BackgroundTransparency = 1.000000
Title43.BorderSizePixel = 0.000000
Title43.Visible = true
Title43.AutomaticSize = Enum.AutomaticSize.None
Title43.ClipsDescendants = false
Title43.LayoutOrder = 0.000000
Title43.Active = false
Title43.Selectable = false
Title43.SizeConstraint = Enum.SizeConstraint.RelativeXY
Title43.ZIndex = 1.000000
Title43.Rotation = 0.000000
Title43.Transparency = 1.000000
Title43.Text = "SUPPORT US"
Title43.TextColor3 = Color3.fromRGB(250,80,80)
Title43.TextSize = 8.000000
Title43.Font = Enum.Font.SourceSansSemibold
Title43.TextScaled = true
Title43.TextWrapped = true
Title43.RichText = false
Title43.LineHeight = 1.000000
Title43.MaxVisibleGraphemes = -1.000000
Title43.TextTransparency = 0.000000
Title43.TextStrokeColor3 = Color3.fromRGB(0,0,0)
Title43.TextStrokeTransparency = 1.000000
Title43.TextTruncate = Enum.TextTruncate.None
Title43.ZIndex = 1.000000
Title43.TextXAlignment = Enum.TextXAlignment.Center
Title43.TextYAlignment = Enum.TextYAlignment.Center
Title43.Parent = Support40

local Credit44 = Instance.new("TextLabel")
Credit44.Name = "Credit"
Credit44.Size = UDim2.new(0.584491,0,0.053618,0)
Credit44.Position = UDim2.new(0.627693,0,0.679660,0)
Credit44.AnchorPoint = Vector2.new(0.500000,0.500000)
Credit44.BackgroundColor3 = Color3.fromRGB(255,255,255)
Credit44.BackgroundTransparency = 1.000000
Credit44.BorderSizePixel = 0.000000
Credit44.Visible = true
Credit44.AutomaticSize = Enum.AutomaticSize.None
Credit44.ClipsDescendants = false
Credit44.LayoutOrder = 0.000000
Credit44.Active = false
Credit44.Selectable = false
Credit44.SizeConstraint = Enum.SizeConstraint.RelativeXY
Credit44.ZIndex = 2.000000
Credit44.Rotation = 0.000000
Credit44.Transparency = 1.000000
Credit44.Text = "<font color=\"#fa5050\">Tiktok</font> @longhip2012 | <font color=\"#c83232\">DISCORD</font> dsc.gg/lonelyhub"
Credit44.TextColor3 = Color3.fromRGB(255,255,255)
Credit44.TextSize = 8.000000
Credit44.Font = Enum.Font.SourceSansSemibold
Credit44.TextScaled = true
Credit44.TextWrapped = true
Credit44.RichText = true
Credit44.LineHeight = 1.000000
Credit44.MaxVisibleGraphemes = -1.000000
Credit44.TextTransparency = 0.000000
Credit44.TextStrokeColor3 = Color3.fromRGB(0,0,0)
Credit44.TextStrokeTransparency = 1.000000
Credit44.TextTruncate = Enum.TextTruncate.None
Credit44.ZIndex = 2.000000
Credit44.TextXAlignment = Enum.TextXAlignment.Center
Credit44.TextYAlignment = Enum.TextYAlignment.Center
Credit44.Parent = GET_KEY19

local Close45 = Instance.new("TextButton")
Close45.Name = "Close"
Close45.Size = UDim2.new(0.582000,0,0.081000,0)
Close45.Position = UDim2.new(0.626422,0,0.871296,0)
Close45.AnchorPoint = Vector2.new(0.500000,0.500000)
Close45.BackgroundColor3 = Color3.fromRGB(250,80,80)
Close45.BackgroundTransparency = 1.000000
Close45.BorderSizePixel = 0.000000
Close45.Text = ""
Close45.TextColor3 = Color3.fromRGB(255,255,255)
Close45.TextSize = 20.000000
Close45.ZIndex = 2.000000
Close45.Font = Enum.Font.SourceSansBold
Close45.TextScaled = true
Close45.TextWrapped = true
Close45.RichText = false
Close45.Visible = true
Close45.AutoButtonColor = false
Close45.Parent = GET_KEY19

local Title46 = Instance.new("TextLabel")
Title46.Name = "Title"
Title46.Size = UDim2.new(1.000000,0,0.600000,0)
Title46.Position = UDim2.new(0.500000,0,0.500000,0)
Title46.AnchorPoint = Vector2.new(0.500000,0.500000)
Title46.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title46.BackgroundTransparency = 1.000000
Title46.BorderSizePixel = 0.000000
Title46.Visible = true
Title46.AutomaticSize = Enum.AutomaticSize.None
Title46.ClipsDescendants = false
Title46.LayoutOrder = 0.000000
Title46.Active = false
Title46.Selectable = false
Title46.SizeConstraint = Enum.SizeConstraint.RelativeXY
Title46.ZIndex = 1.000000
Title46.Rotation = 0.000000
Title46.Transparency = 1.000000
Title46.Text = "CLOSE UI"
Title46.TextColor3 = Color3.fromRGB(250,80,80)
Title46.TextSize = 8.000000
Title46.Font = Enum.Font.SourceSansSemibold
Title46.TextScaled = true
Title46.TextWrapped = true
Title46.RichText = false
Title46.LineHeight = 1.000000
Title46.MaxVisibleGraphemes = -1.000000
Title46.TextTransparency = 0.000000
Title46.TextStrokeColor3 = Color3.fromRGB(0,0,0)
Title46.TextStrokeTransparency = 1.000000
Title46.TextTruncate = Enum.TextTruncate.None
Title46.ZIndex = 1.000000
Title46.TextXAlignment = Enum.TextXAlignment.Center
Title46.TextYAlignment = Enum.TextYAlignment.Center
Title46.Parent = Close45

local UIStroke47 = Instance.new("UIStroke")
UIStroke47.Color = Color3.fromRGB(250,80,80)
UIStroke47.Thickness = 1.250000
UIStroke47.Transparency = 0.250000
UIStroke47.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke47.Parent = Close45

local UICorner48 = Instance.new("UICorner")
UICorner48.CornerRadius = UDim.new(0.000000,7)
UICorner48.Parent = Close45

local Frame49 = Instance.new("Frame")
Frame49.Name = "Frame"
Frame49.Size = UDim2.new(0.850000,0,0.140000,0)
Frame49.Position = UDim2.new(0.500000,0,0.310000,0)
Frame49.AnchorPoint = Vector2.new(0.500000,0.500000)
Frame49.BackgroundColor3 = Color3.fromRGB(24,24,24)
Frame49.BackgroundTransparency = 0.000000
Frame49.BorderSizePixel = 0.000000
Frame49.Visible = true
Frame49.ZIndex = 2.000000
Frame49.AutomaticSize = Enum.AutomaticSize.None
Frame49.ClipsDescendants = false
Frame49.LayoutOrder = 0.000000
Frame49.Parent = GET_KEY19

local UIStroke50 = Instance.new("UIStroke")
UIStroke50.Color = Color3.fromRGB(255,255,255)
UIStroke50.Thickness = 2.000000
UIStroke50.Transparency = 0.500000
UIStroke50.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
UIStroke50.Parent = Frame49

local UIGradient51 = Instance.new("UIGradient")
UIGradient51.Color = ColorSequence.new({ColorSequenceKeypoint.new(0.000000, Color3.fromRGB(250,80,80)), ColorSequenceKeypoint.new(1.000000, Color3.fromRGB(250,80,80))})
UIGradient51.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0.000000, 0.000000, 0.000000), NumberSequenceKeypoint.new(0.900000, 0.995000, 0.000000), NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)})
UIGradient51.Rotation = -90.000000
UIGradient51.Offset = Vector2.new(0.000000,0.000000)
UIGradient51.Parent = UIStroke50

local UICorner52 = Instance.new("UICorner")
UICorner52.CornerRadius = UDim.new(0.000000,7)
UICorner52.Parent = Frame49

local Title53 = Instance.new("TextLabel")
Title53.Name = "Title"
Title53.Size = UDim2.new(0.420000,0,0.650000,0)
Title53.Position = UDim2.new(0.240000,0,0.500000,0)
Title53.AnchorPoint = Vector2.new(0.500000,0.500000)
Title53.BackgroundColor3 = Color3.fromRGB(24,24,24)
Title53.BackgroundTransparency = 1.000000
Title53.BorderSizePixel = 0.000000
Title53.Visible = true
Title53.AutomaticSize = Enum.AutomaticSize.None
Title53.ClipsDescendants = false
Title53.LayoutOrder = 0.000000
Title53.Active = false
Title53.Selectable = false
Title53.SizeConstraint = Enum.SizeConstraint.RelativeXY
Title53.ZIndex = 1.000000
Title53.Rotation = 0.000000
Title53.Transparency = 1.000000
Title53.Text = "ENTER KEY HERE"
Title53.TextColor3 = Color3.fromRGB(255,255,255)
Title53.TextSize = 8.000000
Title53.Font = Enum.Font.SourceSansSemibold
Title53.TextScaled = true
Title53.TextWrapped = true
Title53.RichText = false
Title53.LineHeight = 1.000000
Title53.MaxVisibleGraphemes = -1.000000
Title53.TextTransparency = 0.000000
Title53.TextStrokeColor3 = Color3.fromRGB(0,0,0)
Title53.TextStrokeTransparency = 1.000000
Title53.TextTruncate = Enum.TextTruncate.None
Title53.ZIndex = 1.000000
Title53.TextXAlignment = Enum.TextXAlignment.Left
Title53.TextYAlignment = Enum.TextYAlignment.Center
Title53.Parent = Frame49

local Textbox54 = Instance.new("TextBox")
Textbox54.Name = "Textbox"
Textbox54.Size = UDim2.new(0.480000,0,0.750000,0)
Textbox54.Position = UDim2.new(0.730000,0,0.500000,0)
Textbox54.AnchorPoint = Vector2.new(0.500000,0.500000)
Textbox54.BackgroundColor3 = Color3.fromRGB(24,24,24)
Textbox54.BackgroundTransparency = 0.000000
Textbox54.BorderSizePixel = 0.000000
Textbox54.Text = ""
Textbox54.TextColor3 = Color3.fromRGB(255,255,255)
Textbox54.TextSize = 8.000000
Textbox54.Font = Enum.Font.SourceSans
Textbox54.ZIndex = 1.000000
Textbox54.TextScaled = true
Textbox54.TextWrapped = true
Textbox54.RichText = false
Textbox54.Visible = true
Textbox54.ClearTextOnFocus = true
Textbox54.MultiLine = false
Textbox54.PlaceholderText = "..."
Textbox54.PlaceholderColor3 = Color3.fromRGB(178,178,178)
Textbox54.CursorPosition = 1.000000
Textbox54.SelectionStart = -1.000000
Textbox54.ShowNativeInput = true
Textbox54.TextEditable = true
Textbox54.TextXAlignment = Enum.TextXAlignment.Center
Textbox54.TextYAlignment = Enum.TextYAlignment.Center
Textbox54.Parent = Frame49

local UIStroke55 = Instance.new("UIStroke")
UIStroke55.Color = Color3.fromRGB(250,80,80)
UIStroke55.Thickness = 1.250000
UIStroke55.Transparency = 0.500000
UIStroke55.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke55.Parent = Textbox54

local UIGradient56 = Instance.new("UIGradient")
UIGradient56.Color = ColorSequence.new({ColorSequenceKeypoint.new(0.000000, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1.000000, Color3.fromRGB(255,255,255))})
UIGradient56.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0.000000, 0.000000, 0.000000), NumberSequenceKeypoint.new(0.900000, 0.995000, 0.000000), NumberSequenceKeypoint.new(1.000000, 1.000000, 0.000000)})
UIGradient56.Rotation = -90.000000
UIGradient56.Offset = Vector2.new(0.000000,0.000000)
UIGradient56.Parent = UIStroke55

local UICorner57 = Instance.new("UICorner")
UICorner57.CornerRadius = UDim.new(0.000000,7)
UICorner57.Parent = Textbox54

local Gradient58 = Instance.new("Frame")
Gradient58.Name = "Gradient"
Gradient58.Size = UDim2.new(1.000000,0,1.000000,0)
Gradient58.Position = UDim2.new(0.000000,0,0.000000,0)
Gradient58.AnchorPoint = Vector2.new(0.000000,0.000000)
Gradient58.BackgroundColor3 = Color3.fromRGB(255,255,255)
Gradient58.BackgroundTransparency = 1.000000
Gradient58.BorderSizePixel = 0.000000
Gradient58.Visible = true
Gradient58.ZIndex = 0.000000
Gradient58.AutomaticSize = Enum.AutomaticSize.None
Gradient58.ClipsDescendants = false
Gradient58.LayoutOrder = 0.000000
Gradient58.Parent = Frame49

local UIGradient59 = Instance.new("UIGradient")
UIGradient59.Color = ColorSequence.new({ColorSequenceKeypoint.new(0.000000, Color3.fromRGB(160,30,30)), ColorSequenceKeypoint.new(0.531952, Color3.fromRGB(19,28,40)), ColorSequenceKeypoint.new(1.000000, Color3.fromRGB(18,21,24))})
UIGradient59.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0.000000, 0.000000, 0.000000), NumberSequenceKeypoint.new(1.000000, 0.000000, 0.000000)})
UIGradient59.Rotation = -90.000000
UIGradient59.Offset = Vector2.new(0.000000,0.000000)
UIGradient59.Parent = Gradient58

local UICorner60 = Instance.new("UICorner")
UICorner60.CornerRadius = UDim.new(0.000000,10)
UICorner60.Parent = Gradient58

local Gradient61 = Instance.new("Frame")
Gradient61.Name = "Gradient"
Gradient61.Size = UDim2.new(1.000000,0,1.000000,0)
Gradient61.Position = UDim2.new(0.000000,0,0.000000,0)
Gradient61.AnchorPoint = Vector2.new(0.000000,0.000000)
Gradient61.BackgroundColor3 = Color3.fromRGB(255,255,255)
Gradient61.BackgroundTransparency = 0.000000
Gradient61.BorderSizePixel = 0.000000
Gradient61.Visible = true
Gradient61.ZIndex = 1.000000
Gradient61.AutomaticSize = Enum.AutomaticSize.None
Gradient61.ClipsDescendants = false
Gradient61.LayoutOrder = 0.000000
Gradient61.Parent = GET_KEY19

local UIGradient62 = Instance.new("UIGradient")
UIGradient62.Color = ColorSequence.new({ColorSequenceKeypoint.new(0.000000, Color3.fromRGB(200,50,50)), ColorSequenceKeypoint.new(0.468048, Color3.fromRGB(28,38,47)), ColorSequenceKeypoint.new(1.000000, Color3.fromRGB(30,30,30))})
UIGradient62.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0.000000, 0.900000, 0.000000), NumberSequenceKeypoint.new(1.000000, 0.900000, 0.000000)})
UIGradient62.Rotation = -90.000000
UIGradient62.Offset = Vector2.new(0.000000,0.000000)
UIGradient62.Parent = Gradient61

local Pattern63 = Instance.new("ImageLabel")
Pattern63.Name = "Pattern"
Pattern63.Size = UDim2.new(1.000000,0,1.000000,0)
Pattern63.Position = UDim2.new(0.000066,0,0.001244,0)
Pattern63.AnchorPoint = Vector2.new(0.000000,0.000000)
Pattern63.BackgroundColor3 = Color3.fromRGB(255,255,255)
Pattern63.BackgroundTransparency = 1.000000
Pattern63.BorderSizePixel = 1.000000
Pattern63.Image = "rbxassetid://2151741365"
Pattern63.ImageColor3 = Color3.fromRGB(255,255,255)
Pattern63.ImageTransparency = 0.600000
Pattern63.ScaleType = Enum.ScaleType.Tile
Pattern63.SliceCenter = Rect.new(0,256,0,256)
Pattern63.Visible = true
Pattern63.ZIndex = 0.000000
Pattern63.Parent = Gradient61

game:GetService("TweenService"):Create(Content, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()

task.wait(5.1)

game:GetService("TweenService"):Create(INTRO, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()

task.wait(0.5)

INTRO.Visible = false
INTRO.GroupTransparency = 0

GET_KEY19.GroupTransparency = 1
GET_KEY19.Visible = true

game:GetService("TweenService"):Create(GET_KEY19, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
local savedKey = LoadKeyFromFile()
if savedKey then
    Textbox54.Text = savedKey
    task.wait(0.5)
    
    local key = savedKey:gsub("%s+", "")
    if key ~= "" then
        Submit28.Active = false
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Lonely Hub",
            Text = "Verifying Key...",
            Icon = "rbxassetid://112485471724320",
            Duration = 5
        })

        task.spawn(function()
            local result = LonelyHubLib.validate(key)
            if result and result.success and (not result.type or result.type == LonelyHubLib.ServiceId) then
                SaveKeyToFile(key)
                getgenv().SCRIPT_KEY = key
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Lonely Hub",
                    Text = "Key valid! Loading...",
                    Icon = "rbxassetid://112485471724320",
                    Duration = 5
                })
                task.wait(0.5)
                LonelyHub:Destroy()
                LoadScript()
            else
                SaveKeyToFile("")
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Lonely Hub",
                    Text = "Key Expired or Invalid!",
                    Icon = "rbxassetid://112485471724320",
                    Duration = 5
                })
                Submit28.Active = true
            end
        end)
    end
end

Close45.MouseButton1Click:Connect(function()
    LonelyHub:Destroy()
end)

Get23.MouseButton1Click:Connect(function()
    local link = GetKeyURL()
    if link and setclipboard then
        setclipboard(link)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Lonely Hub",
            Text = "Copied Link!",
            Icon = "rbxassetid://112485471724320",
            Duration = 5
        })
    end
end)

Get233.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("dsc.gg/lonelyhub")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Lonely Hub",
            Text = "Discord Link Copied!",
            Icon = "rbxassetid://112485471724320",
            Duration = 5
        })
    end
end)

Support40.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://link-center.net/1785243/7PeLEKmQgfmj")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Lonely Hub",
            Text = "Thanks U Very Much <3",
            Icon = "rbxassetid://112485471724320",
            Duration = 5
        })
    end
end)
Submit28.MouseButton1Click:Connect(function()
    local key = Textbox54.Text:gsub("%s+", "")
    if key == "" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Lonely Hub",
            Text = "Please Input Key!",
            Icon = "rbxassetid://112485471724320",
            Duration = 5
        })
        return
    end

    Submit28.Active = false
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Lonely Hub",
        Text = "Verifing Key...",
        Icon = "rbxassetid://112485471724320",
        Duration = 5
    })

    task.spawn(function()
        local result = LonelyHubLib.validate(key)
        if result and result.success and (not result.type or result.type == LonelyHubLib.ServiceId) then
            SaveKeyToFile(key)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Lonely Hub",
                Text = "Key valid! Loading...",
                Icon = "rbxassetid://112485471724320",
                Duration = 5
            })
            task.wait(0.5)
            LonelyHub:Destroy()
            LoadScript()
        else
            SaveKeyToFile("")
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Lonely Hub",
                Text = "Key Expired or Invalid!",
                Icon = "rbxassetid://112485471724320",
                Duration = 5
            })
            Submit28.Active = true
        end
    end)
end)