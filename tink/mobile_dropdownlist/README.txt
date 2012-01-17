On desktop the item is selected on mouse down and the drop down closed. This doesn't work on mobile as the user may be scrolling the list, and therefore the committing of the selected index doesn't happen until mouse up.

I propose that in the override item_mouseDownHandler and we check the interactionMode. If it's "touch" we don't set  userProposedSelectedIndex and we DON'T CLOSE the dropDown, not not touch it carries on as normal, hopefully not introducing any new bugs.

We add an override for,  setSelectedIndex call super then check the interactionMode. If it's touch, set userProposedSelectedIndex and we CLOSE the dropDown.