xover.listener.on('changeFilter', function (position, value) {
	xover.state['filterBy_' + position] = value;
})

navbar = {};

navbar.requests = function (document, request) {
	let source = document?.source || request?.source;
	return [
		request,
		document?.request,
		...(source?.requests || [])
	].filter(Boolean).distinct();
}

navbar.findRequest = function (document, request) {
	return navbar.requests(document, request).find(candidate => candidate.contract?.exists);
}

navbar.parameter = function (contract, name) {
	name = '' + (name || '');
	let bare = name.replace(/^@/, '');
	return contract?.parameters?.find(parameter => !parameter.output && parameter.name.replace(/^@/, '') === bare) || null;
}

navbar.setParameter = function (source, request, parameter, value) {
	if (!parameter) return;
	let sourceUrl = source?.url;
	let requestUrl = request?.url;
	let bare = parameter.name.replace(/^@/, '');
	let sourceName = sourceUrl?.searchParams.has(bare) && !sourceUrl.searchParams.has(parameter.name) ? bare : parameter.name;
	for (let [url, name] of [[sourceUrl, sourceName], [requestUrl, parameter.name]]) {
		if (!url) continue;
		if (value == null || value === '') {
			url.searchParams.delete(name);
		} else {
			url.searchParams.set(name, value);
		}
	}
}

navbar.sync = async function (document, request) {
	let source = document?.source || request?.source;
	if (source && source.contract == null && xover.manifest.getSettings(source, 'contract').pop()) await source.getContract();
	request = navbar.findRequest(document, request) || request;
	if (!request) return null;
	if (request && !request.contract) request.contract = source?.contract || null;
	let contract = request?.contract;
	if (!contract?.exists) return null;
	source = document?.source || request.source;
	for (let field of [...top.document.querySelectorAll('form fieldset > [name]')]) {
		let scope = await field.scope;
		let parameter = navbar.parameter(contract, field.getAttribute('name') || scope.closest('*')?.localName);
		if (!parameter) continue;
		let value = field.value;
		if (!value && source?.url?.searchParams.has(parameter.name)) value = source.url.searchParams.get(parameter.name);
		if (!value && source?.url?.searchParams.has(parameter.name.replace(/^@/, ''))) value = source.url.searchParams.get(parameter.name.replace(/^@/, ''));
		if (field.closest('.mutually-exclusive') && field.matches('[type=hidden]')) value = null;
		navbar.setParameter(source, request, parameter, value);
	}
	return request;
}

xover.listener.on('beforeFetch', async function ({ document, request }) {
	request = await navbar.sync(document, request);
	return request;
})

xover.listener.on('change::@state:selected', async function ({ document, value, request }) {
	request = await navbar.sync(document, request);
	if (!request || !instanceOf.call(this, Attr)) return;
	let parameter = navbar.parameter(request.contract, this.parentNode.name);
	if (!parameter) return;
	let source = document?.source || request.source;
	navbar.setParameter(source, request, parameter, value);
	request.source = source;
	request.target = document;
	await request.fetch();
})

function beforeTransform({ document }) {
	for (let catalog of document.select('//*[@navbar:*][not(*) and @navbar:control="combobox" and not(@xsi:nil) or * and @xsi:nil]')) {
		if (catalog.childElementCount) continue;
		catalog.setAttribute("xsi:nil", true)
	}
	document.select('/*[.//@navbar:*]/*[not(@navbar:*)]').remove();
	document.documentElement.sortChildrenByAttr("navbar:position");
}

xover.listener.on('beforeTransform?stylesheet.href*=page_navbar.xslt', beforeTransform)
