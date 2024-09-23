function newAccess(module, user, value) {
	return xo.xml.createNode(`<access xmlns:state="http://panax.io/state" state:new="true" state:dirty="true" module="${module}" user="${user}" level="${value}" />`)
}

xo.listener.on(['change::access/@level', 'append::access'], function ({ element, attribute, old, value }) {
	event.stopPropagation()
	attribute = attribute || element.getAttributeNodeOrMock("level");
	let initial_value = element.getAttributeNodeNS('http://panax.io/state/initial', attribute.localName);
	let new_line = element.getAttributeNodeNS('http://panax.io/state', "new");
	if (new_line && attribute.value == value) {
		element.remove()
	} else if (value !== null && !initial_value) {
		element.set(`initial:${attribute.localName}`, old);
	}/* else if (initial_value.value == value) {
		initial_value.remove();
	}*/
	element.set(`prev:${attribute.localName}`, old);
})