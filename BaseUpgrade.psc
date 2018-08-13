Scriptname SimSettlementsHQ:BaseUpgrade extends ObjectReference Const
;{This will be extended for each type of BaseUpgrade, so this is very basic as a result.}

struct UpgradeCosts
	Int WorkshopRatingScavengeBuildingAmount
	Int WorkshopRatingScavengeGeneralAmount
	Int WorkshopRatingScavengePartsAmount
	Int WorkshopRatingScavengeRareAmount
endstruct

Message Property UpgradeInfo Auto Const Mandatory
{the message that will display for this base upgrade explaining costs and benefits.}

Message Property UpgradeStarted Auto Const Mandatory
{the message that appears when the upgrade starts.  Use the default if the upgrad doesn't have it's own.}

Message Property UpgradeRequirementsNotMet Auto Const Mandatory
{the message that appears if the player tries to build this upgrade but doesn't have the required materials.}

;Should the upgrade appear in the list of available upgrades.
Bool Function AvailableToBuild()
	return true
EndFunction

;Does the player have all of the requirements to actually build the upgrade.
Bool Function MeetsUpgradeRequirements()
		return true
EndFunction

Function BuildUpgrade()
	;does the actual Build of the upgrade.  I suspect the first and most common type of upgrade will be a PlotBasedBaseUpgrade which will take a marker and place a "plot" like structure on that X-marker for location and facing.
	;having said that this base script does nothing on this front and it's only implimented in the final classes.  ToDo: determine if papyrus has an "Abstract" class concept to avoid issues with this script type.
EndFunction





