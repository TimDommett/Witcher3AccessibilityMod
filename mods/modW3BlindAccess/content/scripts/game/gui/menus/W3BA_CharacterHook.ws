// W3BlindAccess - Character Menu Hook
// Wraps CR4CharacterMenu to narrate skill tab changes and skill selection.

// ---------------------------------------------------------------
// Menu open with player stats summary
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnConfigUI()
{
    var level : Int32;
    var skillPoints : Int32;
    var text : String;

    wrappedMethod();

    level = thePlayer.GetLevel();
    skillPoints = thePlayer.GetAbilityManager().GetAvailableSkillPoints();

    text = "Character. Level " + level + ". ";
    if (skillPoints > 0)
    {
        text += skillPoints + " skill points available.";
    }

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Tab changes (Combat, Signs, Alchemy, General, Mutagens)
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnTabChanged(tabIndex : Int32)
{
    var tabName : String;

    wrappedMethod(tabIndex);

    switch (tabIndex)
    {
        case 0: tabName = "Combat Skills";  break;
        case 1: tabName = "Signs";          break;
        case 2: tabName = "Alchemy Skills"; break;
        case 3: tabName = "General Skills"; break;
        case 4: tabName = "Mutagens";       break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Skill selection - narrate skill name and level
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnSkillSelected(skillId : Int32)
{
    var abilityManager : W3AbilityManager;
    var skillName : String;
    var skillLevel : Int32;
    var maxLevel : Int32;
    var isEquipped : Bool;
    var text : String;

    wrappedMethod(skillId);

    abilityManager = thePlayer.GetAbilityManager();
    if (!abilityManager) { return; }

    // Get skill info
    skillName = W3BA_GetSkillName(skillId);
    skillLevel = abilityManager.GetSkillLevel(skillId);
    maxLevel = abilityManager.GetSkillMaxLevel(skillId);
    isEquipped = abilityManager.IsSkillEquipped(skillId);

    text = skillName;

    if (skillLevel > 0)
    {
        text += ". Level " + skillLevel + " of " + maxLevel;
    }
    else
    {
        text += ". Not learned";
    }

    if (isEquipped)
    {
        text += ". Equipped";
    }

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------
// Skill name lookup
// ---------------------------------------------------------------

function W3BA_GetSkillName(skillId : Int32) : String
{
    var skillName : String;

    // Try to get localized skill name
    skillName = GetLocStringByKeyExt("skill_name_" + skillId);
    if (skillName != "" && skillName != "skill_name_" + skillId)
    {
        return skillName;
    }

    // Fallback to skill type name based on common skill IDs
    return "Skill " + skillId;
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}
