xover.listener.on(`beforeFetch?searchParams`, function ({ request, searchParams }) {
	if (request.url.hash !== xover.site.seed) return;
	let getNodeValue = function (node) {
		if (node.localName == 'selected' && node.namespaceURI == 'http://panax.io/state') {
			let selection = node.parentNode.single(`*[@id=${node.value}]`) || top.document.createElement('p');
			return selection.getAttributeNode("id") || selection.getAttributeNode("key") || selection.getAttributeNode("desc") || node.value
		} else {
			return node.value
		}
	}
	let getNodeName = function (node) {
		if (node.localName == 'selected' && node.namespaceURI == 'http://panax.io/state') {
			return node.parentNode.nodeName
		} else {
			return node.name.replace(/^state:/, '')
		}
	}
	for (let param of document.querySelectorAll('nav fieldset [xo-slot^=state]')) {
		let scope = param.scope;
		let value = getNodeValue(scope) || null;
		let param_name = '@' + getNodeName(scope);
		if (value) {
			searchParams.set(param_name, value)
		} else {
			searchParams.delete(param_name)
		}
	}
})