xover.listener.on('print', function () {
    let target = this instanceof Node && !(this instanceof Document) && this || document.querySelector('main > article') || document.querySelector('main') || document.body;
    //let iframes = document.querySelector('main iframe');

    //if (iframes) {
    //    for (let f = 0; f < iframes.length; ++f) {
    //        let iframe = iframes[f];
    //        if (iframe.classList.contains("non-printable")) {
    //            continue;
    //        }
    //        iframe.contentWindow.focus();
    //        iframe.contentWindow.print();
    //        f = iframes.length;
    //    }
    //} else {
    window.addEventListener('beforeprint', () => {
        const style = document.createElement('style');
        style.id = 'dynamic-print-styles';
        style.textContent = `
            /* Your print-specific styles here */
            body, 
            .element-with-background {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
                background-color: /* your desired color */;
            }
        `;
        document.head.appendChild(style);
    });

    window.addEventListener('afterprint', () => {
        const style = document.getElementById('dynamic-print-styles');
        if (style) {
            style.remove();
        }
    });

    let content = target.cloneNode(true);
        content.style.width = "100%";
        content.style.height = "100%";
        content.style.overflow = 'visible'
        //document.body.replaceWith(content);
        //window.print()
        //document.body.replaceWith(document_copy);



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

        // Write the content to the new window
        printWindow.document.write('<html><head><title>Print Content</title>');
        /*printWindow.document.write('<style>body { display: none; } #' + divId + ' { display: block; }</style>');*/
        printWindow.document.write('</head><body>');
        printWindow.document.write('</body></html>');
        printWindow.document.body.appendChild(content)
        printWindow.document.body.style.padding = '20px';
        /*printWindow.document.body.style.border = '1px solid #000';*/

        // Close the document to ensure all content is written
        printWindow.document.close();

        copyStyles(document, printWindow.document);

        // Wait for the content to load and then print
        printWindow.onload = function () {
            printWindow.focus(); // Required for some browsers
            printWindow.print();
            printWindow.close();
        };


        //    const blob = new Blob([content], { type: 'text/html' });
        //    const blobUrl = URL.createObjectURL(blob);
        //    const iframe = document.createElement('iframe');
        //    iframe.src = blobUrl;
        //    //iframe.style.position = 'absolute';
        //    //iframe.style.top = '0';
        //    //iframe.style.left = '0';
        //    iframe.style.width = '100vh';
        //    iframe.style.height = '100vw';
        //    iframe.style.border = 'none';
        //    iframe.onload = function () {
        //        [...iframe.contentDocument.querySelectorAll("[src]")].forEach(img => img.src = xover.URL(img.src).toString());
        //        const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
        //        copyStyles(document, iframeDoc);

        //        iframeDoc.documentElement.style.overflow = 'visible';
        //        iframeDoc.body.style.overflow = 'visible';
        //        iframe.style.width = "100%"
        //        iframe.style.height = "100%"
        //        iframeDoc.querySelector(`main`).style.width = "100%"
        //        iframeDoc.querySelector(`main`).style.height = "100%"

        //        const height = iframeDoc.documentElement.scrollHeight;
        //        const width = iframeDoc.documentElement.scrollWidth;

        //        iframe.style.height = height + 'px';
        //        iframe.style.width = width + 'px';

        //        setTimeout(() => {
        //            iframe.contentWindow.focus();
        //            iframe.contentWindow.print();
        //        }, 500);
        //    }
        //    dialog = xover.dom.createDialog(iframe);
        //    [...dialog.querySelectorAll('dialog > * > menu')].remove()
        //    dialog.style.height = "100vh"
        //    dialog.style.width = "100vw"
        //    dialog.style.overflow = 'visible'
        event.preventDefault();
    //}
})