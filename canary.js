

function getDescendantNodes(targetNode, nodeFilter = NodeFilter.SHOW_ELEMENT) {
    const nodeIterator = document.createNodeIterator(
        targetNode,
        nodeFilter // Include all node types: element, text, etc.
    );

    const descendantsArray = [];
    let currentNode;
    while (currentNode = nodeIterator.nextNode()) {
        descendantsArray.push(currentNode);
    }
    return descendantsArray
}



function copyComputedStyle(source, target = source.cloneNode(true)) {
    const computedStyle = window.getComputedStyle(source);

    // Apply computed styles to the target element
    for (let key of computedStyle) {
        target.style[key] = computedStyle.getPropertyValue(key);
    }

    // Recursively copy styles for all children
    Array.from(source.children).forEach((child, index) => {
        copyComputedStyle(child, target.children[index]);
    });
    return target
}


function fixStyles(element, name) {
    // Check if the element is already in the document, if not, clone it
    // Function to set computed background for an element
    let setComputedStyles = function (el) {
        let computedStyle = window.getComputedStyle(el);
        let mainStyles = [
            'content',
            'display',
            'position', 'visibility',
            'top', 'right', 'bottom', 'left',
            'float',
            'margin', 'margin-top', 'margin-right', 'margin-bottom', 'margin-left',
            'padding', 'padding-top', 'padding-right', 'padding-bottom', 'padding-left',
            'width', 'height',
            'min-width', 'min-height',
            'box-sizing',
            'flex', 'flex-flow', 'flex-direction', 'flex-basis', 'flex-shrink',
            'align-items', 'justify-content',
            'background', 'background-color',
            'color', 'color-scheme',
            'border', 'border-color', 'border-radius', 'border-top-left-radius',
            'font-family', 'font-size', 'font-weight', 'font-style',
            'line-height', 'letter-spacing',
            'text-align', 'text-decoration',
            'word-break', 'white-space',
            'opacity',
            'animation',
            'transition',
            'box-shadow',
            'outline', 'outline-color',
            'overflow', 'overflow-x', 'overflow-y',
            'scrollbar-color',
            'transform', 'transform-origin',
            'cursor',
            'z-index'
        ]
        for (let prop of mainStyles) {
            if (!el.style[prop] && computedStyle[prop]) {
                el.style[prop] = computedStyle[prop];
            }
        }
    };

    // Set computed background for the element
    setComputedStyles(element);

    // Iterate over children
    let children = element.children;
    for (let child of children) {
        // Set computed background for each child
        setComputedStyles(child);

        // Recursively fix styles for nested elements
        fixStyles(child, name);
    }

    return element;
}

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
            set_computed_background(el);
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