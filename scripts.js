// تعديل هنا: استبدل USERNAME و REPO باسم حسابك واسم الـ repo
const username = "omarcs16";  
const repo = "my-plugins";  
const folder = "plugins";

const pluginList = document.getElementById("plugin-list");

async function fetchPlugins() {
  try {
    const response = await fetch(
      `https://api.github.com/repos/${username}/${repo}/contents/${folder}`
    );
    const data = await response.json();

    pluginList.innerHTML = ""; // امسح "Loading..."

    data.forEach(file => {
      if (file.name.endsWith(".sma")) {
        const card = document.createElement("div");
        card.className = "plugin-card";
        card.innerHTML = `
          <h3>${file.name}</h3>
          <p>Download my plugin: ${file.name}</p>
          <a href="${file.download_url}" class="btn">Download</a>
        `;
        pluginList.appendChild(card);
      }
    });
  } catch (error) {
    pluginList.innerHTML = "⚠️ Couldn't load plugins.";
    console.error(error);
  }
}

fetchPlugins();