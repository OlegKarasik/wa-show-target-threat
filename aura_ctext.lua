function ()
    local function ScaleThreat(own, tank)
        local c = 0.3
        
        -- Determining melee range
        if WeakAuras.CheckRange('target', 10, "<=") then
            c = 0.1
        end
        
        local scaled = tank - own + (tank * c)
        if aura_env.helpers.AuraIsDebug() then
            print(string.format('DEBUG: Scaling %.1f to %.1f', tank - own, scaled))
        end
        
        return scaled
    end
    local function FormatThreat(value)
        -- Fix value to match addons output
        
        local formatted = value / 100
        if formatted > 1000 then
            -- Format thousands
            
            formatted = formatted / 1000
            
            if aura_env.helpers.AuraIsDebug() then
                print(string.format('DEBUG: Formatting %.1f to %.1fK', value, formatted))
            end
            
            return string.format('%.1fK', formatted)
        end
        
        if aura_env.helpers.AuraIsDebug() then
            print(string.format('DEBUG: Formatting %.1f to %.1f', value, formatted))
        end
        return string.format('%.1f', formatted)
    end
    local function FormatOutput(threat_code, threat)
        return string.format("|cfff8fa3a%s: %s", threat_code, threat)
    end
    
    if aura_env.state and aura_env.state.threatvalue then
        if aura_env.state.aggro then
            if aura_env.helpers.AuraIsDebug() then
                print('DEBUG: Tanking')
            end
            return FormatOutput('T', FormatThreat(aura_env.state.threatvalue))
        end
        
        local is_tank, _, _, _, threat = UnitDetailedThreatSituation('targettarget', 'target')
        if is_tank then
            if aura_env.helpers.AuraIsDebug() then
                print('DEBUG: Determining threat between "target" and "targettarget"')
            end
            
            local scaled = ScaleThreat(aura_env.state.threatvalue, threat)
            return FormatOutput('G', FormatThreat(scaled))
        else
            if IsInGroup() or IsInRaid() then
                for member in WA_IterateGroupMembers() do
                    local is_tank, _, _, _, threat = UnitDetailedThreatSituation(member, 'target')
                    if is_tank then
                        if aura_env.helpers.AuraIsDebug() then
                            print(string.format('DEBUG: Determining threat between "target" and "%s"', member))
                        end
                        
                        local scaled = ScaleThreat(aura_env.state.threatvalue, threat)
                        return FormatOutput('FG', FormatThreat(scaled))
                    end
                end
            end
            if aura_env.helpers.AuraIsDebug() then
                print('DEBUG: Unable to determine threat')
            end
            return FormatOutput('G', 'U')    
        end
    end
end