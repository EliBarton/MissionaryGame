extends VBoxContainer


var a = "Not Invited"
var b = "Invited"
var c = "Keeping"
var d = "Not Keeping"


func update_invitations(pamInvite, BoMInvite, ChurchInvite, BapInvite):
	#Pamphlet Invitation
	if pamInvite == 3:
		$ReadPamphlet/Status.set_text(d)
	elif pamInvite == 1:
		$ReadPamphlet/Status.set_text(b)
	elif pamInvite == 2:
		$ReadPamphlet/Status.set_text(c)
	else:
		$ReadPamphlet/Status.set_text(a)
	
	#Book of Mormon Invitation
	if BoMInvite == 3:
		$ReadBom/Status.set_text(d)
	elif BoMInvite == 1:
		$ReadBom/Status.set_text(b)
	elif BoMInvite == 2:
		$ReadBom/Status.set_text(c)
	else:
		$ReadBom/Status.set_text(a)
	
	#Church Invitation
	if ChurchInvite == 3:
		$AttendChurch/Status.set_text(d)
	elif ChurchInvite == 1:
		$AttendChurch/Status.set_text(b)
	elif ChurchInvite == 2:
		$AttendChurch/Status.set_text(c)
	else:
		$AttendChurch/Status.set_text(a)
	
	#Baptism Invitation
	if BapInvite == 3:
		$BeBaptized/Status.set_text(d)
	elif BapInvite == 1:
		$BeBaptized/Status.set_text(b)
	elif BapInvite == 2:
		$BeBaptized/Status.set_text(c)
	else:
		$BeBaptized/Status.set_text(a)
