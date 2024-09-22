xover.listener.on('print', async function () {
    event.preventDefault();
    let target = this instanceof Node && !(this instanceof Document) && this || document.querySelector('main > article') || document.querySelector('main') || document.body;
    let content = target.cloneNode(true);
        content.style.width = "100%";
        content.style.height = "100%";
        content.style.overflow = 'visible'



        function copyStyles(sourceDoc, targetDoc) {
            Array.from(sourceDoc.styleSheets).forEach(styleSheet => {
                let rules;
                try {
                    rules = styleSheet.cssRules;
                } catch (e) {
                    return; // Cross-origin stylesheet
                }
                if (rules) {
                    const newStyleEl = targetDoc.createElement('style');
                    Array.from(rules).forEach(rule => {
                        newStyleEl.appendChild(targetDoc.createTextNode(rule.cssText));
                    });
                    targetDoc.head.appendChild(newStyleEl);
                }
            });
        }

        let printWindow = window.open('', '', 'width=1000,height=800');

        printWindow.document.write('<html><head><title>Print Content</title>');
        printWindow.document.write('</head><body>');
        printWindow.document.write('</body></html>');
        printWindow.document.body.appendChild(content)
        printWindow.document.body.style.padding = '20px';

        // Close the document to ensure all content is written
         printWindow.document.close();

        copyStyles(document, printWindow.document);

        printWindow.onload = function () {
            printWindow.focus(); // Required for some browsers
            printWindow.print();
            setTimeout(function () {
                printWindow.close(); // Delay closing the window
            }, 1000); // Allow some time for print dialog to show
        };
})

xo.listener.on('hashchange', function () {
    typeof (toggleSidebar) === 'function' && toggleSidebar(false)
})

xo.listener.on(['beforeRender::#shell.xslt', 'beforeAppendTo::main', 'beforeAppendTo::body'], function ({ target }) {
    if (!(event.detail.args || []).filter(el => !(el instanceof Comment || el instanceof HTMLStyleElement || el instanceof HTMLScriptElement || el.matches("dialog,[role=alertdialog],[role=alert],[role=dialog],[role=status],[role=progressbar]"))).length) return;
    [...target.childNodes].filter(el => el.matches && !el.matches(`script,dialog,[role=alertdialog],[role=alert],[role=dialog],[role=status],[role=progressbar]`)).removeAll()
})