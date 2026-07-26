/*Tambien quiero que las columnas agrupadas queden al principio (pueden ser duplicados con el prefijo group en el xo-slot y las actuales pueden estar ocultas para que sean restauradas a su lugar original cuando se desagrupen), como en mi ejemplo datagrid.html.  */
// AGRUPADO DINÁMICO SOBRE HTML (sin retransformar)
// • Usa axis correcto: datagrid:group::html:table
// • Replica el header de grupos que genera XSLT (tab-space + íconos SVG +/-)
// • Mantiene compatibilidad con collapse/expand existentes (evento datagrid:collapse/expand)
(function () {
    const stackSVG = xover.xml.createNode(`
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor"
                 class="bi bi-stack ms-2 button" viewBox="0 0 16 16"
                 onclick="dispatch('ungroup')"
                 xo-swap="@xo-slot @xo-scope" xo-xsl-source="xsl_template_datagrid_group_icon">
                <path d="m14.12 10.163 1.715.858c.22.11.22.424 0 .534L8.267 15.34a.6.6 0 0 1-.534 0L.165 11.555a.299.299 0 0 1 0-.534l1.716-.858 5.317 2.659c.505.252 1.1.252 1.604 0l5.317-2.66zM7.733.063a.6.6 0 0 1 .534 0l7.568 3.784a.3.3 0 0 1 0 .535L8.267 8.165a.6.6 0 0 1-.534 0L.165 4.382a.299.299 0 0 1 0-.535z"></path>
                <path d="m14.12 6.576 1.715.858c.22.11.22.424 0 .534l-7.568 3.784a.6.6 0 0 1-.534 0L.165 7.968a.299.299 0 0 1 0-.534l1.716-.858 5.317 2.659c.505.252 1.1.252 1.604 0z"></path>
            </svg>`);
    // --- SVG para badge de agrupación en headers (stack) ---
    function makeStackSVG(field, target) {
        // Puedes crear directamente con xover.xml.createNode
        const svg = stackSVG.cloneNode(true);
        svg.setAttribute("xo-slot", `group:${field}`)
        if (target?.id) svg.setAttribute("xo-scope", target.id);
        return svg;
    }

    // Pinta/actualiza badges en thead y habilita ungroup al click (estilo datagrid.html)
    function decorateGroupHeaders(table = this) {
        const target = this.scope;
        const fields = getGroupFields(this);
        if (!table.tHead) return table;

        // limpia badges previos
        table.tHead.querySelectorAll('svg.bi.bi-stack.button').forEach(n => n.remove());
        table.tHead.querySelectorAll('th[xo-slot].drag-group-dim').forEach(th => th.classList.remove('drag-group-dim', 'drag-group-headers'));

        for (const field of fields) {
            const th = table.tHead.querySelector(`th[xo-slot="${field}"], th[xo-slot="group:${field}"]`);
            if (!th) continue;
            th.classList.add('drag-group-headers', 'drag-group-dim');

            const container = th.querySelector('.d-flex.flex-nowrap') || th;
            const icon = makeStackSVG(field, target);

            // Scope de atributo para que el listener ungroup quite @group:<field>
            try {
                const attrNode = target?.selectFirst(`@group:${field}`);
                if (attrNode) icon.scope = attrNode;
            } catch (e) { }

            container.append(icon);
        }
        return table;
    }

    // Utils de cadena para identificar grupos
    const encode = s => encodeURIComponent(s ?? '').replace(/%20/g, '+');
    const decode = s => decodeURIComponent(String(s || '').replace(/\+/g, '%20'));
    const chainToKey = chain => chain.map(({ field, value }) => `${encode(field)}=${encode(value)}`).join('|');
    const keyToChain = key => (key ? key.split('|').map(p => { const [f, v] = p.split('='); return { field: decode(f), value: decode(v) }; }) : []);

    function getGroupFields(table) {
        // Respeta el orden EXACTO en que están definidos los atributos @group:*
        const scope = table.scope;
        if (!scope) return [];
        return [...scope.attributes]
            .filter(attr => attr.namespaceURI === 'http://panax.io/state/group')
            .map(attr => attr.localName);
    }

    function snapshotRows(table) {
        // Toma un snapshot plano de filas de datos (sin headers) para reagrupar sin retransformar
        const originals = [...table.querySelectorAll('tbody > tr:not(.header)')];
        table._flatRows = originals.map(tr => tr.cloneNode(true));
    }

    function resetTbody(table) {
        table.querySelectorAll('tbody').forEach(tb => tb.remove());
    }

    function colCountOf(table) {
        const lastHead = table.tHead?.rows?.[table.tHead.rows.length - 1];
        if (lastHead) return [...lastHead.cells].reduce((n, c) => n + (c.colSpan || 1), 0);
        const anyRow = table._flatRows?.[0] || table.querySelector('tbody tr:not(.header)');
        return anyRow ? anyRow.cells.length : 1;
    }

    // Obtiene el valor del grupo desde la celda (preferir cell-value → data-value → value → text)
    function getGroupValue(row, field) {
        const td = row.querySelector(`td[xo-slot="${field}"],th[xo-slot="${field}"]`);
        if (!td) return '';
        const v = td.getAttribute('cell-value')
            || td.getAttribute('data-value')
            || td.getAttribute('value')
            || td.textContent;
        return (v || '').trim();
    }

    // ==== SORT helpers (compatible con agrupado) ====
    function getSortSpec(table) {
        const ths = [...(table.tHead?.querySelectorAll('th[xo-slot]') || [])];
        const spec = new Map();
        ths.forEach(th => {
            const slot = th.getAttribute('xo-slot') || '';
            const field = slot.startsWith('group:') ? slot.slice(6) : slot;
            const dir = th.dataset.sort || (th.classList.contains('sorted-asc') ? 'asc' : (th.classList.contains('sorted-desc') ? 'desc' : ''));
            spec.set(field, dir);
        });
        return spec; // Map(field -> 'asc'|'desc'|'')
    }
    function cmpAsc(a, b) { return a < b ? -1 : a > b ? 1 : 0; }
    function cmpDesc(a, b) { return -cmpAsc(a, b); }
    function groupKeyComparator(field, spec) {
        const direction = (spec.get(field) || 'asc').toLowerCase();
        const cmp = direction === 'desc' ? cmpDesc : cmpAsc;
        return (a, b) => cmp(a[0], b[0]); // a,b son [value, entry]
    }
    function rowComparator(spec) {
        const orderedFields = [...spec.entries()].filter(([, dir]) => !!dir).map(([f]) => f);
        return (ra, rb) => {
            for (const field of orderedFields) {
                const va = getGroupValue(ra, field);
                const vb = getGroupValue(rb, field);
                const dir = (spec.get(field) || 'asc').toLowerCase();
                const cmp = dir === 'desc' ? cmpDesc : cmpAsc;
                const c = cmp(va, vb);
                if (c) return c;
            }
            return 0;
        };
    }

    const dashSVGBase = xover.xml.createNode(`
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-dash-square icon-btn" viewBox="0 0 16 16" style="cursor:pointer;" onclick="dispatch('collapse')">
			<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"></path>
			<path d="M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8z"></path>
		</svg>
    `);
    const plusSVGBase = xover.xml.createNode(`
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-plus-square icon-btn" viewBox="0 0 16 16" style="cursor:pointer;" onclick="dispatch('expand')">
			<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"></path>
			<path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"></path>
		</svg>
    `);

    function makeDashSVG() { return dashSVGBase.cloneNode(true); }
    function makePlusSVG() { return plusSVGBase.cloneNode(true); }

    function isCollapsed(table, chain) {
        try {
            const store = table.store || xover.stores.active;
            const predicate = chain.map(({ field, value }) => `@${field}="${xover.string?.htmlEncode ? xover.string.htmlEncode(value) : value}"`).join(' and ');
            // 1) Expandidos forzados tienen prioridad
            const expanded = store.select(`//expand:groups/row[${predicate}]`);
            if (expanded.length) return false;
            // 2) Colapsados específicos
            const collapsed = store.select(`//collapse:groups/row[${predicate}]`);
            if (collapsed.length) return true;
            // 3) collapse_all por defecto (si no está en expand)
            if (xo?.state?.collapse_all) return true;
        } catch (e) { }
        return false;
    }

    function makeHeaderRow(table, level, parents, field, value, totalCols, chainKey) {
        const tr = document.createElement('tr');
        tr.className = `header sticky group-level-${level + 1}`; // igual que XSLT

        // Primera celda vacía (alineación como plantilla)
        const thFirst = document.createElement('th');
        thFirst.style.textAlign = 'center';
        thFirst.innerHTML = '&nbsp;';
        tr.appendChild(thFirst);

        // Celdas parent-group con <tab-space/>
        parents.forEach(p => {
            const th = document.createElement('th');
            th.className = 'parent-group';
            th.setAttribute('xo-slot', p.field);
            th.scope = { localName: p.field, nodeName: p.field, value: p.value };
            const tab = document.createElement('tab-space');
            tab.setAttribute('style', 'padding-right: 4rem; margin-left: -10px;');
            th.appendChild(tab);
            tr.appendChild(th);
        });

        // Celda del grupo actual (con ícono +/- y texto)
        const thGroup = document.createElement('th');
        thGroup.classList.add('group');
        thGroup.setAttribute('scope', 'row');
        thGroup.style.whiteSpace = 'nowrap';
        thGroup.setAttribute('xo-slot', field);
        thGroup.scope = { localName: field, nodeName: field, value: value };

        const chain = parents.concat([{ field, value }]);
        const collapsed = isCollapsed(table, chain);
        const icon = collapsed ? makePlusSVG() : makeDashSVG();
        thGroup.append(icon);
        thGroup.append(document.createTextNode(` ${field}: ${value}`));

        // El resto de columnas hasta completar ancho
        const used = 1 /*thFirst*/ + parents.length + 1 /*thGroup*/;
        if (used < totalCols) thGroup.colSpan = totalCols - (1 + parents.length);

        // Guarda la key del grupo en el header para toggles
        thGroup.dataset.chain = chainKey;

        tr.appendChild(thGroup);
        return tr;
    }

    function groupTable() {
        const scope = this.scope;
        const fields = getGroupFields(this).filter(Boolean);
        let table = this.cloneNode(true)
        table.original = this.original;
        // Si no hay grupos activos: dejar DOM plano
        if (!fields.length) {
            snapshotRows(table);
            resetTbody(table);
            const tb = document.createElement('tbody');
            const sortSpec = getSortSpec(table);
            const rows = (table._flatRows || []).slice();
            const hasSort = [...sortSpec.values()].some(Boolean);
            if (hasSort) rows.sort(rowComparator(sortSpec));
            rows.forEach(r => tb.append(r.cloneNode(true)));
            table.append(tb);
            decorateGroupHeaders.call(this, table);
            return applyCollapsedVisibility(table);
        }

        snapshotRows(table);
        resetTbody(table);
        const totalCols = colCountOf(table);

        // 1) Construir ÍNDICE jerárquico primero (no pintamos aún)
        const root = new Map(); // value -> entry
        (table._flatRows || []).forEach(row => {
            const keyParts = fields.map(f => getGroupValue(row, f));
            let cursor = root;
            fields.forEach((field, ix) => {
                const value = keyParts[ix] || '';
                if (!cursor.has(value)) cursor.set(value, { map: new Map(), rows: [], field, level: ix + 1 });
                const entry = cursor.get(value);
                if (ix === fields.length - 1) {
                    const clone = row.cloneNode(true);
                    try {
                        fields.forEach((f, j) => clone.setAttribute(`group:${f}`, keyParts[j] || ''));
                        const chainForRow = fields.map((f, j) => ({ field: f, value: keyParts[j] || '' }));
                        clone.dataset.groupChain = chainToKey(chainForRow);
                    } catch (e) { }
                    entry.rows.push(clone);
                } else {
                    cursor = entry.map;
                }
            });
        });

        // 2) Renderizar en orden jerárquico para garantizar contigüidad de grupos
        const renderLevel = (map, parents, depth) => {
            const field = fields[depth];
            const entries = Array.from(map.entries());
            const sortSpecLevel = getSortSpec(table);
            entries.sort(groupKeyComparator(field, sortSpecLevel));
            for (const [value, entry] of entries) {
                const chain = parents.concat([{ field, value }]);
                const ck = chainToKey(chain);
                const tb = document.createElement('tbody');
                tb.dataset.chain = ck;
                tb.dataset.level = String(depth + 1);
                tb.setAttribute(`group:${field}`, value);

                const header = makeHeaderRow(table, depth, parents, field, value, totalCols, ck);
                tb.append(header);

                if (depth === fields.length - 1) {
                    // Ordenar filas hoja según el sort activo (si lo hay)
                    const sortSpecRows = getSortSpec(table);
                    const hasRowSort = [...sortSpecRows.values()].some(Boolean);
                    const rows = entry.rows.slice();
                    if (hasRowSort) rows.sort(rowComparator(sortSpecRows));
                    rows.forEach(r => tb.append(r));
                    table.append(tb);
                } else {
                    // Padre intermedio: primero el header, luego recursión de hijos, todo contiguo
                    table.append(tb);
                    renderLevel(entry.map, chain, depth + 1);
                }
            }
        };

        renderLevel(root, [], 0);

        // Decora headers (badges de agrupación)
        decorateGroupHeaders.call(this, table);

        // Re-render tfoot si existe
        this.querySelectorAll('tfoot [xo-stylesheet]')?.forEach(section => section.render && section.render());

        applyCollapsedVisibility(table);
        this.replaceWith(table)
        return this;
    }

    function applyCollapsedVisibility(table) {
        const bodies = [...table.querySelectorAll('tbody[data-chain]')];
        // Ordenar por nivel (asc), para decidir desde padres a hijos
        bodies.sort((a, b) => (parseInt(a.dataset.level) || 0) - (parseInt(b.dataset.level) || 0));

        const keyIndex = new Map(bodies.map(tb => [tb.dataset.chain, tb]));

        const isDescendantOf = (childKey, parentKey) => childKey !== parentKey && childKey.startsWith(parentKey + '|');

        // Primero determina estado y setea iconos + filas propias
        const states = new Map();
        for (const tb of bodies) {
            const chain = keyToChain(tb.dataset.chain);
            const collapsed = isCollapsed(table, chain);
            states.set(tb.dataset.chain, collapsed);

            // Icono del header
            const th = tb.querySelector('tr.header th.group');
            if (th) {
                const current = th.querySelector('svg.icon-btn');
                const desired = collapsed ? makePlusSVG() : makeDashSVG();
                if (current) current.replaceWith(desired); else th.prepend(desired);
            }

            // Filas propias (no-header) del group actual
            tb.querySelectorAll('tr:not(.header)').forEach(tr => {
                tr.style.display = collapsed ? 'none' : '';
            });
        }

        // Luego aplica visibilidad a descendientes según estados (soporta expand forzado)
        for (const tb of bodies) {
            const parentKey = tb.dataset.chain;
            const collapsedParent = states.get(parentKey);
            if (!collapsedParent) continue; // si está expandido, los hijos deciden por sí mismos

            for (const child of bodies) {
                const ck = child.dataset.chain;
                if (isDescendantOf(ck, parentKey)) {
                    const childCollapsed = states.get(ck);
                    // Si el hijo no está colapsado (p.ej., expand forzado), se muestra; de lo contrario se oculta completo
                    child.style.display = childCollapsed ? 'none' : '';
                }
            }
        }

        return table;
    }

    const handler = function () { return groupTable.call(this); };

    xo.listener.on('group::html:table', handler);
    xo.listener.on('datagrid:group::html:table', handler);
    // Sólo recalcula visibilidad (sin reagrupar) – útil tras collapse/expand
    xo.listener.on('datagrid:group-visibility::html:table', function () { decorateGroupHeaders.call(this); return applyCollapsedVisibility(this); });
})();

(function () {
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
                window.document.dragged_el = this.closest('[xo-slot]');
                //console.log('dragstart', window.document.dragged_el)
                draggedColIndex = this.cellIndex || [...this.parentNode.children].indexOf(this);
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
                    moveColumn({ draggedColIndex, draggedCol: window.document.dragged_el }, { targetColIndex, targetCol });
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

        function moveColumn({ draggedColIndex: fromIndex, draggedCol: from }, { targetColIndex: toIndex, targetCol: to },) {
            if (!from || from.nextElementSibling === to) return;
            const rows = table.rows;
            let [from_name, from_schema = null] = from.getAttribute("xo-slot").split(":").reverse();
            let [to_name, to_schema = null] = to.getAttribute("xo-slot").split(":").reverse();
            for (let row of rows) {
                if (row.classList.contains("header")) continue;
                const cells = row.cells;
                const fromCell = from && row.querySelector(`td[xo-slot="${from.getAttribute("xo-slot")}"],td[xo-slot="${from_schema}:${from_name}"],th[xo-slot="${from_name}"],th[xo-slot="${from_schema}:${from_name}"]`) || null;//cells[fromIndex];
                const toCell = to && row.querySelector(`td[xo-slot="${to_name}"],td[xo-slot="${to_schema}:${to_name}"],th[xo-slot="${to_name}"],th[xo-slot="${to_schema}:${to_name}"]`) || null;//cells[toIndex];
                try {
                    fromCell.parentNode.insertBefore(fromCell, toCell)
                } catch (e) { }
            }
            if (from_schema && !to_schema && to.closest('thead')) {
                from.dispatch('ungroup')
                from.setAttribute("xo-slot", from_name)
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
    let originalClones = new WeakMap()
    const filterTable = async function ({ document }) {
        let scope = this.scope;
        let filters = scope.select(`@filter:*`);
        let table = (this.original || this).cloneNode(true);
        table.original = this.original || !this.querySelector('.filtered') && this || undefined;
        table.querySelectorAll('td.filtered').forEach(el => el.classList.remove('filtered'));
        if (!table.original && window.document.contains(this)) {
            return this.section.render();
        }
        if (filters.length) {
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
        this.replaceWith(table)
        return table;
    }
    xo.listener.on(`datagrid:filter::html:table`, filterTable)

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

    xo.listener.on(`transform::*[.//@filter:*]`, function ({ result }) {
        let table = result.querySelector('table');
        if (!table) return;
        table.dispatch('datagrid:filter');
    }, { priority: -1 })

    xo.listener.on(`beforeTransform::model[*/@filter:*]`, function () {
        this.dispatch('datagrid:filter')
    }, { priority: -1 })

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
    }, { priority: -1 })

    const columnRearranged = function () {
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
        [...node.attributes].filter(attr => !attr.namespaceURI || ["http://panax.io/state/group"].includes(attr.namespaceURI)).remove({ silent: true });
        attributes.forEach(attr => node.setAttributeNode(attr));
        tr.store.save();
    }
    xover.listener.on(`columnRearranged`, columnRearranged)

    collapse_or_expand = function (action = 'collapse') {
        let store = this.store;
        let scope = this.closest('td,th').scope;
        let table = this.closest('table');
        let targetNode = table && table.scope; // nodo con los @group:* activos
        let groups = targetNode
            ? [...targetNode.attributes].filter(a => a.namespaceURI === 'http://panax.io/state/group')
            : store.select(`//@group:*`);
        let ix = groups.findIndex(attr => (attr.localName || attr.name || String(attr.nodeName).replace(/^[^:]*:/, '')) === scope.localName);
        if (ix >= 0) groups.splice(ix + 1);
        let parent_groups = this.closest("td,th").select("preceding-sibling::*[contains(@class,'parent-group')]").map(el => el.scope).concat(scope);
        let group_node = store.selectFirst(`//${action}:groups`);
        if (!group_node) {
            store.documentElement.prepend(xover.xml.createElement(`${action}:groups`));
            group_node = store.selectFirst(`//${action}:groups`);
            group_node.inert = true;
            if (!group_node instanceof Element) {
                throw (`Couln't ${action} group`)
            }
        }
        let row = xover.xml.createElement("row");
        row.inert = true;
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
        const table = this.closest('table');
        if (table) table.dispatch('datagrid:group-visibility');
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
        const table = this.closest('table');
        if (table) table.dispatch('datagrid:group-visibility');
    })

    xo.listener.on(`change::state:collapse_all`, function () {
        xover.stores.active.select(`//collapse:groups/row`).remove({ silent: true })
        xover.stores.active.select(`//expand:groups/row`).remove({ silent: true })
    })

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
        debugger
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
        for (let tbody of header.closest('table').querySelectorAll('tbody')) {
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
})();

xo.listener.on(`change::@filter:*`, async function ({ document, srcElement }) {//`change::@group:*`, 
    this.inert = true;
    let tables = srcElement.closest('table') || srcElement.findAll(`table`);
    for (let table of [tables].flat()) {
        table = table && await table.dispatch('datagrid:filter');
        //table = table && await table.dispatch('datagrid:group');
    }
});

// beforeTransform: consolidate totals into one <row> and compute grouped counters/totals per @group:*
// - Reads totalizable columns from ROOT attributes: type:<col>="money|quantity" OR total:<col>=*
// - Sums positives and negatives
// - Writes state:count with original row count on the document element
// - Reduces dataset to a single <row> with global totals
// - Persists grouped summaries under <group:totals><group:total dim="..." value="..." .../></group:totals>
//   Each <group:total> has state:count and one attribute per totalizable column with the group sum

// Consolidate totals and output one <row> per dimension combination (or a single row if none)
// Columns to totalize are driven by ROOT attributes:
//   • type:<col> = "money" | "quantity"
//   • total:<col> = * (any value means opt‑in)
// Behaviour:
//   • Sums positives and negatives
//   • state:count on the root with original row count
//   • Uses XPath union selector for speed: */row/@col1 | */row/@col2 | ...
//   • Groups by all @group:* found on each row (ns http://panax.io/state/group)
//   • If no groups exist, a single consolidated row is created (key "")
//   • Replaces children with the aggregated fragment via replaceChildren

(function () {
    function parseNumber(s) {
        if (s == null) return NaN;
        const t = String(s)
            .replace(/[\s\u00A0]/g, "")      // spaces, NBSP
            .replace(/[^0-9+\-.,]/g, "")     // strip currency/symbols
            .replace(/,/g, "");               // thousands comma
        const n = parseFloat(t);
        return Number.isFinite(n) ? n : NaN;
    }

    function consolidate_data({ document, stylesheet }) {
        if (!stylesheet.selectFirst("//xsl:template[@mode='datagrid:footer-cell']")) return; // only when footer exists
        const root = (this.documentElement || this);
        const rows = root.select("row");
        if (!rows.length) return;
        const includeNames = root.select(`@type:*[.="money" or .="quantity"]|@total:*`).map(attr => attr.localName).distinct();
        if (includeNames.length === 0) return; // nothing marked

        // --- Build grouped sums object ---
        // groups: { key: { dims:Object, sums:{col:number} } }
        const groups = root.select(`@group:*`).map(group => group.localName);
        if (!groups.length) groups.push("");
        const sums = new Map()
        // Helper: build group key + dims map for a given row
        const buildKeyAndDims = (row) => {
            let key = {};
            for (group_name of groups) {
                key[group_name] = row.getAttribute(group_name);
            }
            key = JSON.stringify(key);
            sums.set(key, sums.get(key) || {});
            return sums.get(key);
        };

        // Fast XPath union to fetch only totalizable attributes
        const selector = [...includeNames].map(a => `row/@${a}`).join("|");

        for (const attr of root.select(selector)) {
            const v = parseNumber(attr.value);
            if (!Number.isFinite(v)) continue;
            const name = attr.name;
            const row = attr.parentNode;

            dim = buildKeyAndDims(row);
            dim[name] = (dim[name] || 0) + v;
        }

        // skeleton = copia del primer <row> pero sin atributos
        const skeleton = rows[0].cloneNode(false);
        while (skeleton.attributes && skeleton.attributes.length) {
            skeleton.removeAttribute(skeleton.attributes[0].name);
        }

        const frag = document.createDocumentFragment();
        if (sums.size === 0) {
            frag.appendChild(skeleton.cloneNode(false));
        } else {
            for (const [key, totals] of sums.entries()) {
                const r = skeleton.cloneNode(false);
                if (key) {
                    let keys = JSON.parse(key);
                    let selector = ""
                    for (const [key, value] of Object.entries(keys).filter(([key]) => key)) {
                        selector += `[@${key}="${value}"]`;
                        r.setAttribute(key, String(value));
                    }
                    let rows = root.select(`row${selector}`);
                    r.setAttributeNS(xo.spaces["state"], "state:count", rows.length)
                }
                for (const [col, total] of Object.entries(totals)) {
                    r.setAttribute(col, String(total));
                }

                frag.appendChild(r);
            }
        }
        root.replaceChildren(frag);
        root
    }
    function datagrid_sanitizer({ document, stylesheet }) {
        consolidate_data.call(this.single(`//ventas`), { document, stylesheet });
    }

    xo.listener.on(`beforeTransform?stylesheet.selectFirst("//xsl:template[@mode='datagrid:footer-cell']")`, consolidate_data, { priority: -999 });
    xo.listener.on(`beforeTransform?stylesheet.selectFirst("//xsl:template[@mode='datagrid:widget']")`, datagrid_sanitizer);

    const post_transform = function ({ original, result, stylesheet }) {
        const filters = this.select(`//@filter:*`).map(attr => attr.localName);
        const bodies = result.querySelectorAll(`tbody:has(tr > td)`);
        for (let [ix, tbody] of Object.entries(bodies)/*.slice(0, 10)*/) {
            let scope = tbody.scope;
            const frag = document.createDocumentFragment();
            let skeleton = tbody.querySelector(`tr:has(td)`);
            let groups = [...tbody.attributes].filter(attr => attr.name.indexOf("group:") == 0);
            let rows = scope.select(`row${groups.length ? `[${groups.map(attr => `@${attr.name.replace(/^group:/, '')}="${attr.value}"`).join(" and ") }]` : ""}`);
            if (!rows.length) continue;
            for (let [ix, row] of Object.entries(rows.slice(0, 400))) {
                let tr = skeleton.cloneNode(true)
                let row_head = tr.querySelector(`th[scope=row]`);
                row_head.textContent = +ix + 1;
                tr.setAttribute("xo-scope", row.getAttributeNS(xover.spaces["xover"], "id") || '');
                for (let slot of tr.select(`.//@xo-slot[.!='']`)) {
                    if (filters.includes(slot.value)) {
                        let cell = slot.closest('td');
                        if (cell)
                            cell.classList.add('filtered');
                    }
                    let value = row.getAttribute(slot.value) || '';
                    let td = slot.parentNode.querySelector(`:not(:has(*))`);
                    if (!td) continue;
                    td.textContent = value;
                    td.setAttribute("value", value)
                }
                frag.appendChild(tr);
            }
            skeleton.replaceWith(frag)
        }
        return result;
        //debugger
    }
    xo.listener.on(`transform?stylesheet.selectFirst("//xsl:template[@mode='datagrid:widget']")::/model[ventas]`, post_transform, { priority: -1 })
})();
document.querySelector(`main`)?.render();
