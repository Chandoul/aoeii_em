const ahkSync = window.chrome.webview.hostObjects.sync.ahk;

const back_main = document.querySelectorAll(".back-main")[0];
back_main.textContent = "↩️ Back to main";

back_main.addEventListener("click", () => {
    ahkSync.click();
    ahkSync.loadPage('');
});
