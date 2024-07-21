xover.listener.on(`render?stylesheet.selectFirst("//comment()[starts-with(.,'ack:imported-from')][contains(.,'datagrid.xslt')]")`, function () {
	let self = this;
	self.dragged_el = self.dragged_el || undefined;
	let draggedColIndex, targetColIndex, target;
	let arrow;

	function createArrow() {
		arrow = document.createElement('div');
		arrow.classList.add('arrow');
		document.body.appendChild(arrow);
	}

	function moveArrow(target, x) {
		if (!arrow) return;
		const bounding = target.getBoundingClientRect();
		arrow.style.top = `${bounding.bottom + window.scrollY}px`;
		arrow.style.left = `${x}px`;
		arrow.style.display = 'block';
	}

	function removeArrow() {
		if (!arrow) return;
		arrow.style.display = 'none';
	}

	for (let tbody of [...document.querySelectorAll('table tbody')]) {
		tbody.dragover_handler = tbody.dragover_handler || function (e) {
			e.preventDefault();
			/*
			targetColIndex = this.cellIndex;
			const bounding = tbody.getBoundingClientRect();
			const offset = bounding.x + bounding.width / 2;
			if (e.clientX > offset) {
				targetColIndex += 1;
				moveArrow(tbody, bounding.right);
			} else {
				moveArrow(tbody, bounding.left);
			}*/
		}
		tbody.removeEventListener('dragover', tbody.dragover_handler);
		tbody.addEventListener('dragover', tbody.dragover_handler);

		tbody.drop_handler = tbody.drop_handler || function (e) {
			e.preventDefault();
			removeArrow();
			this.dispatch('dropped', { target: this, srcElement: self.dragged_el });
		}
		tbody.removeEventListener('drop', tbody.drop_handler);
		tbody.addEventListener('drop', tbody.drop_handler);
	}

	document.querySelectorAll('[draggable="true"]').forEach((th, index) => {
		th.dragstart_handler = th.dragstart_handler || function (e) {
			self.dragged_el = this;
			console.log('dragstart', self.dragged_el)
			draggedColIndex = this.cellIndex;
			createArrow();
		}
		th.removeEventListener('dragstart', th.dragstart_handler);
		th.addEventListener('dragstart', th.dragstart_handler);

		th.dragover_handler = th.dragover_handler || function (e) {
			e.dataTransfer.dropEffect = 'move';
			e.preventDefault();
			targetColIndex = this.cellIndex;
			const bounding = th.getBoundingClientRect();
			const offset = bounding.x + bounding.width / 2;
			if (e.clientX > offset) {
				targetColIndex += 1;
				moveArrow(th, bounding.right);
			} else {
				moveArrow(th, bounding.left);
			}
		}
		th.removeEventListener('dragover', th.dragover_handler);
		th.addEventListener('dragover', th.dragover_handler);

		th.drop_handler = th.drop_handler || function (e) {
			e.preventDefault();
			removeArrow();
			if (draggedColIndex !== targetColIndex) {
				moveColumn(draggedColIndex, targetColIndex);
			}
			this.dispatch('columnRearranged');
		}
		th.removeEventListener('drop', th.drop_handler);
		th.addEventListener('drop', th.drop_handler);

		th.dragleave_handler = th.dragleave_handler || function (e) {
			removeArrow();
		}
		th.removeEventListener('dragleave', th.dragleave_handler);
		th.addEventListener('dragleave', th.dragleave_handler);

		for (let el of [...document.querySelectorAll('.trash-zone')]) {
			el.dragtrash_dragover_handler = el.dragtrash_dragover_handler || function (e) {
				el = this;
				e.preventDefault();
			}
			el.removeEventListener('dragover', el.dragtrash_dragover_handler);
			el.addEventListener('dragover', el.dragtrash_dragover_handler);

			el.dragtrash_drop_handler = el.dragtrash_drop_handler || function (e) {
				//debugger
				if (!self.dragged_el) return;
				let scope = self.dragged_el.scope;
				let parent_table = self.dragged_el.closest('table');
				if (scope && parent_table && !parent_table.contains(this)) {
					scope.remove();
				}
			}
			el.removeEventListener('drop', el.dragtrash_drop_handler);
			el.addEventListener('drop', el.dragtrash_drop_handler);
		}
	});

	function moveColumn(fromIndex, toIndex) {
		const table = document.querySelector('table');
		const rows = table.rows;
		for (let row of rows) {
			if (row.classList.contains("header")) continue;
			const cells = row.cells;
			const fromCell = cells[fromIndex];
			const toCell = cells[toIndex];
			try {
				fromCell.parentNode.insertBefore(fromCell, toCell)
			} catch (e) { }
		}
	}
})

xover.listener.on('ungroup', function () {
	let scope = this.scope;
	let group = scope.selectFirst('(.)[not(self::*)][namespace-uri()="http://panax.io/state/group"]|ancestor-or-self::*[namespace-uri()="http://panax.io/state/group"]');
	let store = scope.ownerDocument.store;
	store.select(`//@group:${group.localName}`).remove()
})

xover.listener.on('dropped::tbody', function ({ srcElement }) {
	let scope = srcElement.scope;
	let target = scope.selectSingleNode(`ancestor::*[parent::model]`);
	if (target.hasAttributeNS('http://panax.io/state/group', `${scope.localName}`)) {
		target.removeAttributeNS('http://panax.io/state/group', `${scope.localName}`)
	}
	let key = scope.localName;
	target.setAttributeNS('http://panax.io/state/group', `group:${key}`, 1)
})

xo.listener.on(`beforeTransform?stylesheet.selectFirst("//comment()[starts-with(.,'ack:imported-from')][contains(.,'datagrid.xslt')]")::model[*/@group:*]`, function ({ document }) {
	for (let attr of this.select(`//@group:*`)) {
		let group_node = xover.xml.createElement(attr.name);
		for (let value of attr.parentNode.select(`row/@${attr.localName}`).distinct()) {
			let row = xover.xml.createElement("row");
			row.setAttribute("desc", value);
			group_node.append(row);
		}
		document.documentElement.prepend(group_node);
	}
})

xover.listener.on(`columnRearranged`, function () {
	let tr = this.closest('tr');
	let node = tr.scope;
	if (!(this.namespaceURI)) {
		node.ownerDocument.disconnect();
	}
	let attributes = [];
	for (let slot of tr.querySelectorAll(':scope > th').toArray().map(th => th.getAttributeNode("xo-slot")).filter(slot => slot)) {
		let scope = slot.scope;
		attributes.push(scope.cloneNode());
		if (scope.namespaceURI == "http://panax.io/state/group") {
			let plain_slot = scope.parentNode.getAttributeNode(scope.localName);
			if (plain_slot) {
				attributes.push(plain_slot.cloneNode());
			}
		}
	}
	[...node.attributes].filter(attr => !attr.namespaceURI || ["http://panax.io/state/group"].includes(attr.namespaceURI)).remove();
	attributes.forEach(attr => node.setAttributeNode(attr));
	tr.store.save();
})