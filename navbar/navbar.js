xover.listener.on(`beforeFetch?searchParams`, async function ({ request, searchParams }) {
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

xover.listener.on([`change::@state:selected`, "beforeFetch::?FROM=^PanaxBI.#server:request"], async function ({ document, value }) {
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
        url.searchParams.set(`@${this.parentNode.localName}`, value || null);
        document.fetch()
    }
})