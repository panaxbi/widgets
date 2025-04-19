xo.listener.on('hashchange', function () {
    typeof (toggleSidebar) === 'function' && toggleSidebar(false)
})

xo.listener.on(['beforeRender::#shell.xslt', 'beforeAppendTo::main', 'beforeAppendTo::body'], function ({ target }) {
    if (!(event.detail.args || []).filter(el => !(el instanceof Comment || el instanceof HTMLStyleElement || el instanceof HTMLScriptElement || el.matches("dialog,[role=alertdialog],[role=alert],[role=dialog],[role=status],[role=progressbar]"))).length) return;
    [...target.childNodes].filter(el => el.matches && !el.matches(`script,dialog,[role=alertdialog],[role=alert],[role=dialog],[role=status],[role=progressbar]`)).removeAll()
})

function toggleSidebar(show) {
    let sidebar = document.querySelector('.sidebar');
    if (!sidebar) return
    let width = Number.parseInt(sidebar.style.width);
    let shown = !!width || show === false;
    sidebar.closest('.wrapper').classList.toggle('sitemap_collapsed', shown)
    sidebar.closest('.wrapper').classList.toggle('sitemap-collapsed', shown)
    sidebar.closest('.wrapper').classList.toggle('sitemap-expanded', !shown)
    sidebar.style.width = width || show === false ? 0 : '100%';
}

xover.listener.on('mouseout::aside', function () {
    toggleSidebar(false)
})

xover.listener.on('keyup', async function (event) {
    if (event.keyCode == 27) {
        toggleSidebar(false);
        event.stopPropagation();
    }
})