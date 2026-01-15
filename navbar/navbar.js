xover.listener.on(`beforeFetch?searchParams`, async function ({ request, searchParams }) {
	if (request.target?.source?.tag !== xover.site.seed) return;
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
	try {
		for (let field of [...window.document.querySelectorAll(`form fieldset > [name]`)]) {
			let scope = await field.scope;
			let field_name = scope.closest('*').localName;
			if (!field.value || field.closest(`.mutually-exclusive`) && field.matches(`[type=hidden]`)) {
				searchParams.delete(`@${field_name}`)
			} else {
				searchParams.set(`@${field_name}`, field.value)
			}
		}
	} catch (e) {
		console.log(e)
	}
	/*for (let param of document.querySelectorAll('nav fieldset [xo-slot^=state]')) {
		let scope = await param.scope;
		let value = getNodeValue(scope) || null;
		let param_name = '@' + getNodeName(scope);
		if (value) {
			searchParams.set(param_name, value)
		} else {
			searchParams.delete(param_name)
		}
	}*/
})

xover.listener.on('changeFilter', function (position, value) {
	xover.state[`filterBy_${position}`] = value;
})

navbar = {};
navbar.checkURL = function ({ url }) {
	return url.matches(`?FROM=^PanaxBI.#server:request`)
}

xover.listener.on([`change?navbar.checkURL::@state:selected`, "beforeFetch::?FROM=^PanaxBI.#server:request"], async function ({ document, value }) {
	let url = document.url;
	if (!url) return;
	for (let field of [...document.querySelectorAll(`form fieldset > [name]`)]) {
		let field_name = field.scope.closest('*').localName;
		if (!field.value || field.closest(`.mutually-exclusive`) && field.matches(`[type=hidden]`)) {
			url.searchParams.delete(`@${field_name}`)
		} else {
			url.searchParams.set(`@${field_name}`, field.value)
		}
	}
	if (instanceOf.call(this, Attr)) {
		let param_name = this.parentNode.name;
		if (url.searchParams.has(`@${param_name}`)) {
			url.searchParams.set(`@${param_name}`, value || null);
			document.fetch()
		}
	}
})

function beforeTransform({ document }) {
	for (let catalog of document.select(`//*[@navbar:*][not(*) and not(@xsi:nil) or * and @xsi:nil]`)) {
		if (catalog.childElementCount) continue;
		catalog.setAttribute("xsi:nil", true)
	}
	document.select('/*[.//@navbar:*]/*[not(@navbar:*)]').remove();
	document.documentElement.sortChildrenByAttr("navbar:position");
}

xover.listener.on('beforeTransform?stylesheet.href*=page_navbar.xslt', beforeTransform)