return function(context)
    local Logs = context.Logs

    function context.mergeNestedTables(target, source)
        if type(target) ~= "table" or type(source) ~= "table" then
            return source
        end

        for key, value in pairs(source) do
            local existing = target[key]
            if type(existing) == "table" and type(value) == "table" and not existing[1] and not value[1] then
                context.mergeNestedTables(existing, value)
            else
                target[key] = value
            end
        end

        return target
    end

    function context.getLogDefinition(eventID)
        return DynamicTrading.GameplayLogDefinitions[tostring(eventID or "")]
    end

    function context.getEntryData(entry)
        local data = entry and (entry.tokens or entry.p or entry.d)
        if type(data) == "table" then
            return data
        end
        return {}
    end

    function context.getTemplateForLanguage(definition)
        local templates = definition and definition.tpl or nil
        if type(templates) ~= "table" then
            return nil
        end

        local lang = DynamicTrading.GetLanguage and DynamicTrading.GetLanguage() or context.DEFAULT_LANG
        return templates[lang] or templates[context.DEFAULT_LANG] or templates.EN
    end

    function context.formatEntryText(template, data)
        local text = tostring(template or "")

        if type(data) == "table" and DynamicTrading.FormatInteractionString then
            text = DynamicTrading.FormatInteractionString(text, data)
        end

        if type(data) == "table" then
            for index, value in ipairs(data) do
                text = string.gsub(text, "{" .. tostring(index) .. "}", tostring(value))
            end
        end

        return text
    end

    function context.upsertDefinition(eventID, definition)
        if not eventID or type(definition) ~= "table" then
            return nil
        end

        local key = tostring(eventID)
        local registry = DynamicTrading.GameplayLogDefinitions
        registry[key] = registry[key] or { cat = "event", tpl = {} }

        local target = registry[key]
        if definition.category then
            target.cat = tostring(definition.category)
        end

        local templates = definition.templates or definition.tpl or definition.text or definition.translations
        if type(templates) == "table" then
            context.mergeNestedTables(target.tpl, templates)
        end

        return target
    end

    function DynamicTrading.RegisterGameplayLogEvent(eventID, definition)
        return context.upsertDefinition(eventID, definition)
    end

    function DynamicTrading.RegisterLogTemplate(eventID, data, category)
        if not eventID or type(data) ~= "table" then
            return nil
        end

        return context.upsertDefinition(eventID, {
            category = category or "event",
            templates = data
        })
    end

    function Logs.ResolveText(entry)
        if not entry or not entry.e then
            return "Invalid Entry", "event"
        end

        local definition = context.getLogDefinition(entry.e)
        if not definition then
            return "Unknown Event (" .. tostring(entry.e) .. ")", "event"
        end

        local template = context.getTemplateForLanguage(definition)
        if not template then
            return "Missing Translation (" .. tostring(entry.e) .. ")", definition.cat or "event"
        end

        return context.formatEntryText(template, context.getEntryData(entry)), definition.cat or "event"
    end
end
