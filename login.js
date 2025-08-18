/* microsoft sign-in */
const msalConfig = {
    auth: {
        clientId: (window.document.querySelector(`meta[name="microsoft-signin-client_id"]`) || window.document.createElement("p")).getAttribute("content"),
        redirectUri: location.origin
    }
};
login_function = () => {
    const msalInstance = new msal.PublicClientApplication(msalConfig);
    msalInstance.loginPopup({ scopes: ["User.Read"] }).then(response => {
        onMicrosoftLogin(response)
        console.log('User logged in:', response);
    }).catch(error => {
        // Handle login error
        console.error('Login error:', error);
    });
}

onMicrosoftLogin = function (response) {
    if (response.accessToken && xo.session.id_token != response.accessToken) {
        let username = document.querySelector('.form-signin #username');
        username = (xover.session.debug && username && !username.disabled && username.value || response.account.username);
        xover.session.user_login = username;
        xo.session.id_token = response.accessToken;
        xo.session.login(xo.session.user_login, response.accessToken).then(() => {
            document.forms[0].submit()
        }).catch(() => {
            xo.session.id_token = undefined;
        })
    }
}

/* google sign-in */
onGoogleLogin = function (response) {
    const responsePayload = xover.cryptography.decodeJwt(response.credential);
    let username = document.querySelector('.form-signin #username');
    username = (xover.session.debug && username && !username.disabled && username.value || responsePayload.email);
    xover.session.user_login = username;
    xover.session.id_token = response.credential;
    xover.session.login(xover.session.user_login, response.credential).then(() => {
        if (xo.site.seed == '#login') { window.location = '#' } else { xover.stores.seed.render() }
    }).catch((e) => {
        xover.session.id_token = undefined;
        [...document.querySelectorAll(`script[src*="accounts.google.com"]`)].remove()
        return Promise.reject(e);
    })
}
xover.listener.on('beforeRender::#login', function () {
    if (xo.session.status != 'authorizing') {
        [...document.querySelectorAll(`script[src*="accounts.google.com"]`)].remove()
    }
})
xover.listener.on('logout', function () {
    delete xover.session.id_token
})