require "DT/Common/Config"

DynamicTrading.RegisterDialogue("Player", "Buying", {
    EN = {
        Generic = {
            "I'm sending the {price} credits now. Gimme that {item}.",
            "That {item} looks decent. I'm wiring {price}. Copy?",
            "Alright, {price} sent. Don't lose that {item} before I get it.",
            "I really need that {item}. Transferring {price} now.",
            "I'm good for the {price}. Send the {item} over.",
            "Can you confirm the {price}? Okay, sending it now for the {item}.",
            "Price is a bit steep, but I'm paying {price}. Send the {item}.",
            "Done. {price} credits transferred. Hand over the {item}.",
            "I'm buying the {item}. Check your account for {price}.",
            "Just wired {price}. Pack up the {item} for me.",
            "Hope this {item} works. Sending {price}.",
            "Yeah, I'll take it. {price} inbound for the {item}.",
            "Mark the {item} as sold. {price} is on the way.",
            "I'm grabbing that {item} for {price}. Do you copy?",
            "Here's the {price}. Where can I pick up the {item}?"
        },
        LastStock = {
            "Is that the last {item}? I'm buying it for {price}.",
            "I'll take the last {item} off your hands. {price} sent.",
            "Don't sell that final {item} to anyone else. Here's {price}.",
            "I'm clearing you out. {price} for the rest of the {item}.",
            "Might as well grab the last {item}. Sending {price}.",
            "Just one left? Fine, I'll take the {item} for {price}.",
            "Scraping the barrel here. {price} for the last {item}.",
            "I'll save you the storage space. Buying the last {item} for {price}.",
            "Inventory is getting low, huh? I'm taking that {item} for {price}.",
            "Sold. {price} for the final unit of {item}."
        },
        NoCash = {
            "I'm a little short on credits... can you lower the price?",
            "Come on, I'm good for it. Can you put the {item} on my tab?",
            "That price is steep. Any wiggle room for a survivor?",
            "I don't have the cash right now... can you hold it for me?",
            "Credits are tight. Can we work something out for that {item}?",
            "I really need that {item}, but I'm broke. Help me out?",
            "Look, I'll pay you double next time. Just send it now.",
            "Any discount for a loyal customer? I'm short."
        }
    }
})
