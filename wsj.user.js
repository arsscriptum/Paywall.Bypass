/* jshint esversion: 6 */
// ==UserScript==
// @name        WSJ and Barrons Paywall Hack
// @include     https://www.wsj.com/*
// @include     https://www.barrons.com/*
// @run-at      document-end
// @grant       none
// @version     2
// ==/UserScript==

let pageURL = window.location.href;
let host = window.location.host;
let isWSJ = host.includes('wsj');
let isBarrons = host.includes('barrons');
let isArticle = pageURL.match(/^https?:\/\/(www.)?(wsj|barrons).com\/articles\//);
let protocol = window.location.protocol;
let doBypass = (protocol == 'https:' && isArticle);
let isAMP = pageURL.includes('/amp/');


function returnAMPURL(arg) {
    if (isWSJ) {
        return 'https://www.wsj.com/amp/' + arg.slice(20);
    } else if (isBarrons) {
        return 'https://www.barrons.com/amp/' + arg.slice(24);
    }
}

let AMPArticlealternateURL = returnAMPURL(pageURL);

// http://vancelucas.com/blog/using-window-confirm-as-a-promise/

function confirmDialog(msg) {
    return new Promise(function(resolve, reject) {
        let confirmed = window.confirm(msg);
        return confirmed ? resolve(true) : reject(false);
    });
}

function doConfirm() {
    confirmDialog('Do you want to open the AMP version of this article?')
        .then(() => window.open(AMPArticlealternateURL))
        .catch(err => console.log(AMPArticlealternateURL));
}

document.onreadystatechange = function() {
    if (doBypass && document.readyState === "complete") {
        doConfirm();
    }
    //   else if (document.readyState === "complete" && isAMP) {

    //   }
};

// unhide hidden text and hide nags

if (isAMP) {
    document.querySelectorAll('[subscriptions-section="content-not-granted"], [subscriptions-display="NOT granted"]').forEach(function(el) {
        el.remove();
    });

    document.querySelectorAll('[subscriptions-section="content"], [subscriptions-display="granted"]').forEach(function(el) {
        el.style = 'display: block!important';
    });

    if (isWSJ) {
        document.querySelector('#mainBody').style.maxWidth = "45vw";
    }

    document.querySelectorAll('.articleBody h6').forEach(function(el) {
        el.style = 'margin: 25px 10px 0';
    });
}