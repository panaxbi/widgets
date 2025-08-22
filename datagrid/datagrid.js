xo.listener.on('mousemove::table.datagrid thead th', function () {
    const table = this.closest('table')
    let self = this;
    window.document.dragged_el = window.document.dragged_el || undefined;
    let draggedCol, draggedColIndex, targetCol, targetColIndex, target;
    let arrow;

    function createArrow() {
        arrow = document.body.querySelector('.arrow') || document.createElement('div');
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

    for (let tbody of [...table.querySelectorAll('tbody')]) {
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
            this.dispatch('dropped', { target: this, srcElement: window.document.dragged_el });
        }
        tbody.removeEventListener('drop', tbody.drop_handler);
        tbody.addEventListener('drop', tbody.drop_handler);
    }

    table.querySelectorAll('[draggable="true"]').forEach((th, index) => {
        th.dragstart_handler = th.dragstart_handler || function (e) {
            window.document.dragged_el = this;
            //console.log('dragstart', window.document.dragged_el)
            draggedColIndex = this.cellIndex || [...this.parentNode.children].indexOf(this);
            draggedCol = this.closest('[xo-slot]');
            createArrow();
        }
        th.removeEventListener('dragstart', th.dragstart_handler);
        th.addEventListener('dragstart', th.dragstart_handler);

        th.dragover_handler = th.dragover_handler || function (e) {
            e.dataTransfer.dropEffect = 'move';
            e.preventDefault();
            targetColIndex = this.cellIndex || [...this.parentNode.children].indexOf(this);
            const bounding = th.getBoundingClientRect();
            const offset = bounding.x + bounding.width / 2;
            targetCol = th;
            if (e.clientX > offset) {
                targetColIndex += 1;
                targetCol = targetCol.nextElementSibling;
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
                moveColumn({ draggedColIndex, draggedCol }, { targetColIndex, targetCol });
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

        for (let el of document.querySelectorAll('.trash-zone')) {
            el.dragtrash_dragover_handler = el.dragtrash_dragover_handler || function (e) {
                el = this;
                e.preventDefault();
            }
            el.removeEventListener('dragover', el.dragtrash_dragover_handler);
            el.addEventListener('dragover', el.dragtrash_dragover_handler);

            el.dragtrash_drop_handler = el.dragtrash_drop_handler || function (e) {
                //debugger
                if (!window.document.dragged_el) return;
                let scope = window.document.dragged_el.scope;
                let parent_table = window.document.dragged_el.closest('table');
                if (scope && parent_table && !parent_table.contains(this)) {
                    scope.parentNode.setAttributeNS("http://panax.io/state/hidden", scope.localName, true);
                    //scope.remove();
                }
            }
            el.removeEventListener('drop', el.dragtrash_drop_handler);
            el.addEventListener('drop', el.dragtrash_drop_handler);
        }
    });

    function moveColumn({ draggedColIndex: fromIndex, draggedCol: from }, { targetColIndex: toIndex, targetCol: to }, ) {
        const rows = table.rows;
        if (!from || from.nextElementSibling === to) return;
        for (let row of rows) {
            if (row.classList.contains("header")) continue;
            const cells = row.cells;
            const fromCell = from && row.querySelector(`td[xo-slot="${from.getAttribute("xo-slot")}"],td[xo-slot="group:${from.getAttribute("xo-slot")}"],th[xo-slot="${from.getAttribute("xo-slot")}"],th[xo-slot="group:${from.getAttribute("xo-slot")}"]`) || null;//cells[fromIndex];
            const toCell = to && row.querySelector(`td[xo-slot="${to.getAttribute("xo-slot")}"],td[xo-slot="group:${to.getAttribute("xo-slot")}"],th[xo-slot="${to.getAttribute("xo-slot")}"],th[xo-slot="group:${to.getAttribute("xo-slot")}"]`) || null;//cells[toIndex];
            try {
                fromCell.parentNode.insertBefore(fromCell, toCell)
            } catch (e) { }
        }
    }
})

xover.listener.on('transform', function ({ result }) {
    result.select(`//table//text()[starts-with(.,'-$')]`).forEach(text => text.parentNode.style.color = 'red');
    for (let caption of result.querySelectorAll(`.datagrid caption`)) {
        let textContent = ((caption.textContent || '').match(/\d{4}-\d{2}-\d{2}T?\d{2}:\d{2}:\d{2}.\d+/g) || []).pop();
        if (!isValidDate(textContent)) continue;
        if (datediff('minute', new Date(textContent)) > 90) {
            caption.style.color = 'red'
        } else if (datediff('minute', new Date(textContent)) > 30) {
            caption.style.color = 'orange'
        } else {
            caption.style.color = 'green'
        }
    }
})

xover.listener.on('ungroup', function () {
    let scope = this.scope;
    let group = scope.selectFirst('(.)[not(self::*)][namespace-uri()="http://panax.io/state/group"]|ancestor-or-self::*[namespace-uri()="http://panax.io/state/group"]');
    let store = scope.ownerDocument;
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
        let root_node = attr.single('ancestor::*[not(self::row)][1]');
        for (let value of root_node.select(`.//row/@${attr.localName}`).distinct()) {
            value = xover.string.htmlDecode(value);
            let row = xover.xml.createElement("row");
            row.setAttribute("desc", value);
            group_node.append(row);
        }
        //for (let row of root_node.select(`.//row[not(@${attr.localName})]]`)) {
        //    debugger
        //    let values = row.single(`ancestor::*/@${attr.localName}]`);
        //    let distinct = values.distinct();
        //    if (distinct.length) {
        //        row.setAttributeNS(attr.namespaceURI, attr.localName, attr.value)
        //    }
        //}
        document.documentElement.prepend(group_node);
    }
})

xo.listener.on(`beforeTransform::model[//@datatype:*]`, function ({ document, stylesheet }) {
    for (let attr of this.select(`//@datatype:*`)) {
        stylesheet.documentElement.prepend(xover.xml.createNode(`<key xmlns="${xover.spaces.xsl}" name="data_type" match="${attr.parentNode.nodeName}//@${attr.localName}" use="'${attr.value}'"/>`));
    }
})

xo.listener.on(`beforeTransform?stylesheet.selectFirst("//comment()[starts-with(.,'ack:imported-from')][contains(.,'datagrid.xslt')]")::model[//@hidden:*]`, function ({ document, stylesheet }) {
    for (let attr of this.select(`//@hidden:*[not(.='false')]`)) {
        stylesheet.documentElement.prepend(xover.xml.createNode(`<key xmlns="${xover.spaces.xsl}" name="state" match="${attr.parentNode.nodeName}/@${attr.localName}" use="'hidden'"/>`));
    }
})

xo.listener.on(`beforeTransform?stylesheet.selectFirst("//comment()[starts-with(.,'ack:imported-from')][contains(.,'datagrid.xslt')]")::model[*/@group:*]`, function ({ document, stylesheet }) {
    for (let target of this.select(`//*[@group:*]`)) {
        let attributes = target.attributes;
        let show_attributes = attributes.filterNS("http://panax.io/datatype", "http://panax.io/state/group", "http://panax.io/state/hidden").map(attr => attr.localName);
        if (document.single("*/@state:hide_suggested[.='true']")) {
            for (let attr of attributes.filterNS("").filter(attr => !show_attributes.includes(attr.localName) && !target.hasAttributeNS("http://panax.io/state/hidden", `hidden:${attr.localName}`))) {
                target.setAttributeNS("http://panax.io/state/hidden", `hidden:${attr.localName}`, "auto")
            }
        }
    }
})

xo.listener.on(`change::@filter:*`, function ({ document, srcElement }) {
    this.inert = true;
    srcElement.closest('table').dispatch('datagrid:filter');
})

xo.listener.on(`datagrid:filter::html:table`, async function ({ document }) {
    let table = this
    let scope = this.scope;
    let filters = scope.select(`@filter:*`);
    table.querySelectorAll('td.filtered').forEach(el => el.classList.remove('filtered'));
    if (table.original) {
        table.replaceWith(table.original);
        table = table.original;
    }
    if (filters.length) {
        table.original = table.original || !table.querySelector('.filtered') && table.cloneNode(true) || undefined;
        for (let attr of filters) {
            let values = attr.value.split("|");
            let cells = table.select(`tbody/tr/td[@xo-slot="${attr.localName}" and (${values.map(value => `@cell-value="${value}"`).join(" or ")})]`);
            if (!cells.length) {
                continue;
            }
            cells.forEach(cell => cell.classList.add('filtered'));
            table.select(`tbody/tr[not(td[@xo-slot="${attr.localName}" and (${values.map(value => `@cell-value="${value}"`).join(" or ")})])]`).filter(el => !el.matches(`.header`)).remove();
            table.querySelectorAll(`tbody.filtered`).forEach(tbody => tbody.classList.remove('filtered'))
            for (let tbody of [...table.querySelectorAll(`tbody:has(.filtered)`)]) {
                let level = [...(tbody.querySelector('tr.header') || {}).classList || []].filter(class_name => class_name.indexOf('group-level-') == 0).join(',').replace('group-level-', '');
                let preceding = tbody.previousElementSibling;
                while (level >= 1 && preceding && preceding.querySelector(`tr.header.group-level-${level},tr.header.group-level-${level - 1}`)) {
                    if (preceding.querySelector(`tr.header.group-level-${level - 1}`)) {
                        preceding.classList.add('filtered')
                        --level;
                    }
                    preceding = preceding.previousElementSibling;
                }
            }
            [...table.querySelectorAll(`tbody:not(.filtered):not(:has(.filtered))`)].remove();
        }
        table.querySelectorAll('.selected').forEach(cell => cell.classList.remove('selected', 'selection-begin', 'selection-end'))

    }
    table.querySelectorAll('tfoot [xo-stylesheet]').forEach(section => section.render())
})

xo.listener.on(`datagrid:filter`, function ({ document }) {
    for (let attr of this.select(`//@filter:*`)) {
        let rows_to_remove = attr.parentNode.select(`row[${attr.value.split("|").map(value => `not(@${attr.localName}="${value}")`).join(" and ")}]`)
        if (rows_to_remove.length == attr.parentNode.select(`row`).length) {
            attr.remove()
        } else {
            rows_to_remove.remove()
        }
    }
})

xover.listener.on('click::.datagrid .filterable', function () {
    if (!selection.cells.length || selection.cells.concat(this).includes(this.closest('td,.cell'))) {
        let filters = selection.cells.concat(this).map(cell => cell.scope).reduce((result, scope) => { result[scope.localName] = (result[scope.localName] || []); result[scope.localName].push(scope.value); return result }, {});
        let scope = this.scope;
        let model = scope.closest("model");
        let target = scope.selectSingleNode(`ancestor::*[parent::model]`);
        if (target.hasAttributeNS('http://panax.io/state/filter', `${scope.localName}`)) {
            target.removeAttributeNS('http://panax.io/state/filter', `${scope.localName}`)
            delete filters[scope.localName]
        }

        for (let key of Object.keys(filters)) {
            target.setAttributeNS('http://panax.io/state/filter', `filter:${key}`, filters[key].distinct().join("|"))
        }
    }
})

xo.listener.on(`transform::*[.//@filter:*]`, function ({ result }) {
    let table = result.querySelector('table');
    if (!table) return;
    table.dispatch('datagrid:filter');
}, { priority: 998 })

xo.listener.on(`beforeTransform::model[*/@filter:*]`, function () {
    this.dispatch('datagrid:filter')
}, { priority: 998 })

xo.listener.on(`beforeTransform?stylesheet.href*=datagrid-footer.xslt`, function () {
    this.dispatch('datagrid:filter')
})

xo.listener.on(`beforeTransform::model[*/@group:*]`, function ({ document }) {
    for (let group of this.select(`//@group:*`)) {
        for (let attr of group.parentNode.select(`.//row[*[not(@${group.localName})]]/@${group.localName}`)) {
            for (let row of attr.select(`..//*[not(@${group.localName})]`)) {
                row.setAttribute(attr.localName, attr.value)
            }
        }
    }
}, { priority: 998 })

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

collapse_or_expand = function (action = 'collapse') {
    let store = this.store;
    let scope = this.closest('td,th').scope;
    let groups = store.select(`//@group:*`);
    let ix = groups.findIndex(attr => attr.nodeName == `group:${scope.localName}`);
    groups.splice(ix + 1);
    let parent_groups = this.closest("td,th").select("preceding-sibling::*[contains(@class,'parent-group')]").map(el => el.scope).concat(scope);
    let group_node = store.selectFirst(`//${action}:groups`);
    if (!group_node) {
        store.documentElement.prepend(xover.xml.createElement(`${action}:groups`));
        group_node = store.selectFirst(`//${action}:groups`);
        if (!group_node instanceof Element) {
            throw (`Couln't ${action} group`)
        }
    }
    let row = xover.xml.createElement("row");
    for (let attr of parent_groups) {
        row.setAttribute(attr.nodeName, attr.value || attr.parentNode.single(`ancestor-or-self::*[@${attr.nodeName}][1]/@${attr.nodeName}`)); //sometimes the value is empty because the attribute is set on the parent node
    }
    let predicate = [...row.attributes].map((attr) => `[@${attr.nodeName}="${attr.value}"]`).join('');
    let matches = group_node.select(`row${predicate}`).filter(el => row.attributes.length == [...el.attributes].filter(a => !(a.namespaceURI)).length);
    return { matches, group_node, row };
}

xo.listener.on('collapse', 'datagrid:collapse', function () {
    event.stopPropagation()
    let { matches, group_node, row } = collapse_or_expand.call(this, 'collapse');
    if (!matches.length) {
        group_node.prepend(row);
    }
})

xo.listener.on('expand', 'datagrid:expand', function () {
    event.stopPropagation()
    let { matches } = collapse_or_expand.call(this, 'collapse');
    for (let match of matches) {
        match.remove()
    }
    if (xo.state.collapse_all) {
        let { matches, group_node, row } = collapse_or_expand.call(this, 'expand');
        if (!matches.length) {
            group_node.prepend(row);
        }
    }
})

xo.listener.on(`change::state:collapse_all`, function () {
    xover.stores.active.select(`//collapse:groups/row`).remove()
    xover.stores.active.select(`//expand:groups/row`).remove()
})

async function generateExcelFile(table, name) {
    let progress = await xo.sources["loading.xslt"].render();
    await xover.delay(500);
    //if (this.Interval) window.clearInterval(this.Interval);
    let _progress = 0;
    let progress_bar = progress[0].querySelector('progress');
    progress_bar.style.display = 'inline';

    //this.Interval = setInterval(function () {
    //    if (progress_bar) {
    //        progress_bar.value = _progress;
    //        console.log(_progress);
    //    }
    //}, 500);
    table = table.cloneNode(true);
    table.querySelectorAll('del,.hidden,.non-printable').toArray().remove();
    const hidden = [...document.querySelectorAll("colgroup col")].map(col => col.matches(".hidden"));
    /*debugger*/
    for (a of table.querySelectorAll('a')) {
        a.replaceWith(a.createTextNode(a.selectFirst("text()[1]")))
    }
    let set_computed_background = function (cell) {
        let border = cell.style.border;
        let backgroundColor = cell.style.backgroundColor;
        let color = cell.style.color;
        let styleSheets = document.styleSheets;
        for (let styleSheet of [...styleSheets]) {
            try {
                for (let rule of [...styleSheet.rules].filter(rule => rule.selectorText && (rule.style.border || rule.style.backgroundColor || rule.style.color) && cell.matches(rule.selectorText))) {
                    if (!border && rule.style.border) {
                        cell.style.border = rule.style.border;
                    }
                    if (!backgroundColor && rule.style.backgroundColor) {
                        cell.style.backgroundColor = rule.style.backgroundColor;
                    }
                    if (!color && rule.style.color) {
                        cell.style.color = rule.style.color;
                    }
                }
            } catch (e) {
                console.warn(e)
            }
        }
    }
    let rows = table.getElementsByTagName("tr");
    let r = 0;
    for (let row of rows) {
        ++r;
        _progress = r / rows.length * 100;
        for (let [ix, el] of Object.entries(row.querySelectorAll("td,th"))) {
            if (hidden[ix]) {
                el.remove();
                continue;
            }
            el => set_computed_background(el);
        }
        if (r % (rows.length / 10) == 0) {
            progress_bar.value = _progress;
            await xover.delay(500);
        }
    }
    xo.dom.toExcel(table, name.split("?")[0])
    progress.remove();
    if (this.Interval) window.clearInterval(this.Interval);
}

xover.listener.on('click::.datagrid .sortable', function () {
    sortRows.call(this, this.closest('td,th'))
})

xo.listener.on(`change?srcElement.matches('[type=checkbox]')::@hidden:*`, function ({ value: checked, srcElement }) {
    this.inert = true;
    checked = !eval(checked);
    let col = srcElement.closest('table').querySelector(`colgroup col[xo-slot="${this.localName}"]`);
    if (checked) {
        col.classList.remove('hidden')
    } else {
        col.classList.add('hidden')
    }
})

function sortRows(header) {
    let index = header.$$("preceding-sibling::*").reduce((index, el) => { index += el.colSpan || 0; return index }, 0);
    let direction = 1;
    let getValue = (el) => {
        let val = el.cells[index].getAttribute("value") || el.cells[index].textContent;
        let parsed_value = +val.replace(/\$|^#|,/g, '');
        return isNaN(parsed_value) ? val : parsed_value;
    };
    let compare = (next, curr) => {
        if (curr.classList.contains("header") || next.classList.contains("header")) {
            return 0;
        }
        let valueCurr = getValue(curr);
        let valueNext = getValue(next);
        if (typeof (valueNext.localeCompare) == 'function') {
            return direction * valueNext.localeCompare(valueCurr, undefined, { sensitivity: 'accent', caseFirst: 'upper' });
        } else {
            return direction * (valueNext - valueCurr);
        }
    }
    [...header.parentNode.querySelectorAll('.sorted')].filter(th => th != header).forEach(th => th.classList.remove('sorted-desc', 'sorted-asc', 'sorted'));
    for (let tbody of header.closest('table').select('tbody')) {
        let rows = [...tbody.querySelectorAll("tr")];
        if (header.classList.contains("sorted-desc")) {
            index = 0;
            rows.sort(compare);
        } else if (header.classList.contains("sorted")) {
            direction = -1;
            rows.sort(compare);
        } else {
            rows.sort(compare);
        }
        tbody.replaceChildren(...rows);
    }
    if (header.classList.contains("sorted-desc")) {
        header.classList.remove("sorted", "sorted-desc");
    } else if (header.classList.contains("sorted")) {
        header.classList.remove("sorted-asc");
        header.classList.add("sorted", "sorted-desc");
    } else {
        header.classList.add("sorted", "sorted-asc");
    }
}