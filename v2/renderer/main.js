const ahkSync = window.chrome.webview.hostObjects.sync.ahk;

const welcome = document.querySelectorAll(".welcome")[0];
const title = document.querySelectorAll(".title")[0];
const about = document.querySelectorAll(".about")[0];
const tools = document.querySelectorAll(".tools")[0];
const tools_container = document.querySelectorAll(".tools-container")[0];
const back_main = document.querySelectorAll(".back-main")[0];

back_main.textContent = "↩️ Back to main";
title.textContent = ahkSync.title;
about.textContent = ahkSync.about;

tools.classList.add("custom-scroll");

const toolsList = JSON.parse(ahkSync.tools);

Object.entries(toolsList).forEach(([key, value]) => {
    const tool = document.createElement("div");
    tool.classList.add("tool");
    tool.addEventListener("click", (e) => {
        ahkSync.click();
        target = e.target;
        if (!target.classList.contains("tool")) target = target.parentElement;
        const theTool = target.querySelectorAll(".tool-title")[0];
        loadPage(theTool.textContent);
    });

    const img = document.createElement("img");
    img.classList.add("tool-img");
    img.src = `assets/${key}.png`;

    const toolTitle = document.createElement("span");
    toolTitle.textContent = value.title;
    toolTitle.classList.add("tool-title");

    const toolDesc = document.createElement("span");
    toolDesc.textContent = value.desc;
    toolDesc.classList.add("tool-desc");

    tool.appendChild(img);
    tool.appendChild(toolTitle);
    tool.appendChild(toolDesc);
    tools.appendChild(tool);
});

function loadPage(name) {
    targetClass = name.replaceAll(" ", "-").toLowerCase();
    const target = document.querySelector(`.${targetClass}`);

    if (!target) {
        ahkSync.message(`This tool is not yet implemented!`, name, 0x40)
        return;
    }

    welcome.classList.add("hidden");
    target.classList.remove("hidden");
    back_main.from = target;
}

back_main.addEventListener("click", () => {
    ahkSync.click();
    back_main.from.classList.add("hidden");
    welcome.classList.remove("hidden");
});
